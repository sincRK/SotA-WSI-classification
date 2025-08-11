"""
Shard wrapper for `run_batch_of_slides.py`.

The wrapper will:
  * split an input list into shards (preserving header when requested),
  * create per-shard temporary output directories,
  * render `exec_template` using a `context` that contains:
      - shard_input: path to the shard CSV produced by the wrapper
      - shard_output: path to the shard-specific output directory
      - shard_index: integer index of the shard (0..N-1)
      - num_shards: total number of shards
      - all keys from config['args'] (as strings)
  * execute the formatted command for every shard and then
  * merge outputs according to the configured merge strategy.

Configuration (config.yaml)
  * exec_template (str): a full command string using Python format placeholders.
    Required placeholders that the wrapper provides:
      - {shard_input}, {shard_output}, {shard_index}, {num_shards}
    Any other placeholders must exist as keys under the `args` mapping in the same config.
  * args (mapping): key -> value. Values are inserted into the template via .format(**context).
    - For boolean flags use preformatted tokens in `args`, e.g.
        skip_errors_flag: "--skip_errors"  # enable
        skip_errors_flag: ""                # disable
    - For optional key/value arguments use preformatted tokens, e.g.
        seg_batch_size_arg: "--seg_batch_size 32"
    - For simple numeric/string parameters that are placed directly in flags (like {gpu})
      you may put the raw value (int/string) and include the flag in the template (e.g. `--gpu {gpu}`).

Why preformatted tokens?
  * The template formatting is purely textual (template.format(context)), it does not
    inject or omit flags conditionally. To make a flag conditional, the template expects
    a placeholder which resolves to either the flag token (e.g. "--skip_errors") or an
    empty string "" in `args`.

Example exec_template (compatible with this parser)
  python run_batch_of_slides.py --gpu {gpu} --task {task} {skip_errors_flag} --max_workers {max_workers}
  --batch_size {batch_size} --custom_list_of_wsis {shard_input} --job_dir {shard_output}
  --segmenter {segmenter} --seg_conf_thresh {seg_conf_thresh} --mag {mag} --patch_size {patch_size}

Example usage (wrapper CLI):
  shard_wrapper.py --config /path/to/config.yaml --input-list /path/to/wsis.csv \
                   --num-shards 4 --output-structure dir --final-output /results/merged

Behavior notes:
  * The wrapper supplies {shard_input} and {shard_output}. The `exec_template` should
    use these in the exact flags expected by `run_batch_of_slides.py`:
      --custom_list_of_wsis {shard_input} --job_dir {shard_output}
  * To enable `--skip_errors`, set in config:
      skip_errors_flag: "--skip_errors"
    leaving it empty disables it:
      skip_errors_flag: ""
  * If you need CLI-level overrides for flags, the wrapper must convert those overrides
    into the same preformatted-token shape before formatting the template.

Returns:
  The wrapper writes merged outputs to the configured `final-output` and exits with
  non-zero status if any shard execution fails (unless you implement a `--skip-failed` behavior).
"""


from __future__ import annotations

import argparse
import concurrent.futures
import csv
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path
from string import Formatter
from typing import Dict, List, Optional, Sequence, Tuple, Any, Set

# -----------------------
# Utility parsers/helpers
# -----------------------

def parse_cli_kv_args(tokens: Sequence[str]) -> Dict[str, Any]:
    """Parse leftover CLI tokens to a mapping of keys -> values/True.

    Supports forms:
      --key=value
      --key value
      --flag (becomes True)
      -k value
    Returns keys without leading dashes and underscores normalized to underscores.

    Args:
        tokens: list of tokens (the unknown args from argparse).

    Returns:
        dict mapping key -> value or True.
    """
    out: Dict[str, Any] = {}
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok.startswith("--") or (tok.startswith("-") and len(tok) > 1):
            if "=" in tok:
                key, val = tok.lstrip("-").split("=", 1)
                out[key.replace("-", "_")] = _coerce_value(val)
                i += 1
            else:
                # lookahead for value
                if i + 1 < len(tokens) and not tokens[i + 1].startswith("-"):
                    out[tok.lstrip("-").replace("-", "_")] = _coerce_value(tokens[i + 1])
                    i += 2
                else:
                    out[tok.lstrip("-").replace("-", "_")] = True
                    i += 1
        else:
            # positional or stray token -> store under special key "_positional"
            out.setdefault("_positional", []).append(tok)
            i += 1
    return out


def _coerce_value(v: str) -> Any:
    """Simple coercion: int/float/bool/string."""
    if v.lower() in ("true", "yes", "on"):
        return True
    if v.lower() in ("false", "no", "off"):
        return False
    try:
        return int(v)
    except ValueError:
        pass
    try:
        return float(v)
    except ValueError:
        pass
    return v


def extract_template_fields(template: str) -> Set[str]:
    """Return set of placeholder names used in a format string."""
    return {fname for _, fname, _, _ in Formatter().parse(template) if fname}


# -----------------------
# Input / sharding logic
# -----------------------

def split_input_file(input_path: Path, num_shards: int, has_header: bool) -> List[Path]:
    """Split an input file into `num_shards` shard files.

    The first line is treated as header if has_header is True and is prepended to
    each shard file.

    Args:
        input_path: path to the original input list (text file).
        num_shards: number of shards > 0.
        has_header: whether to preserve the first line as header.

    Returns:
        List of paths to shard input files (in the same directory as input_path).
    """
    lines = input_path.read_text(encoding="utf-8").splitlines()
    header = []
    data = lines
    if has_header and lines:
        header = [lines[0]]
        data = lines[1:]

    shard_paths: List[Path] = []
    for idx in range(num_shards):
        shard_file = input_path.parent / f"shard_{idx}_input.txt"
        shard_lines = header + [line for i, line in enumerate(data) if (i % num_shards) == idx]
        shard_file.write_text("\n".join(shard_lines) + ("\n" if shard_lines else ""))
        shard_paths.append(shard_file)
    return shard_paths


# -----------------------
# Execution
# -----------------------

def format_exec_command(template: Optional[str],
                        fallback_cmd: Optional[str],
                        context: Dict[str, Any],
                        extra_args_list: Optional[List[str]] = None) -> List[str]:
    """Produce the final command token list to run for a shard.

    Priority:
      - If template is provided: format it using context (template fields must be provided).
      - Else if fallback_cmd provided: use fallback_cmd split, append extra_args_list, then append
        shard_input and shard_output if present in context as defaults.

    Args:
        template: command template with format placeholders.
        fallback_cmd: simple command string to use if no template (e.g. "python process.py").
        context: mapping with keys like shard_input, shard_output, shard_index, num_shards, and user keys.
        extra_args_list: original extra args tokens (used only for fallback mode).

    Returns:
        A list of command tokens suitable for subprocess.run.

    Raises:
        KeyError if template is missing placeholders.
        ValueError if neither template nor fallback_cmd is provided.
    """
    if template:
        placeholders = extract_template_fields(template)
        missing = [p for p in placeholders if p not in context]
        if missing:
            raise KeyError(f"Template requires placeholders not in context: {missing}")
        formatted = template.format(**{k: str(v) for k, v in context.items()})
        return shlex.split(formatted)
    if fallback_cmd:
        cmd = shlex.split(fallback_cmd)
        if extra_args_list:
            cmd += list(extra_args_list)
        # fallback: if context contains shard_input/shard_output, append them in that order
        if "shard_input" in context:
            cmd.append(str(context["shard_input"]))
        if "shard_output" in context:
            cmd.append(str(context["shard_output"]))
        return cmd
    raise ValueError("Either template or fallback_cmd must be provided.")


def run_one_shard(cmd_tokens: List[str], cwd: Optional[Path] = None) -> None:
    """Run a single shard command, raising on non-zero return."""
    print(f"[INFO] executing: {' '.join(map(shlex.quote, cmd_tokens))}")
    subprocess.run(cmd_tokens, check=True, cwd=str(cwd) if cwd else None)


# -----------------------
# Merge strategies
# -----------------------

def merge_csv_outputs(shard_dirs: Sequence[Path], final_output_file: Path, csv_pattern: str, has_header: bool) -> None:
    """Concatenate CSV files from shard dirs into a single CSV.

    Behavior:
      - Searches each shard_dir for files matching csv_pattern (glob)
      - If multiple matches in a shard => appends in sorted order
      - Keeps a single header (first encountered) if has_header True

    Args:
        shard_dirs: list of shard output directories
        final_output_file: target CSV file path
        csv_pattern: glob pattern for CSV files, e.g., "*.csv"
        has_header: whether to treat the first line as header (and only write it once)
    """
    final_output_file.parent.mkdir(parents=True, exist_ok=True)
    header_written = False
    with final_output_file.open("w", encoding="utf-8", newline="") as fout:
        writer = None  # use raw write to preserve formatting
        for sd in shard_dirs:
            for csv_file in sorted(sd.glob(csv_pattern)):
                with csv_file.open("r", encoding="utf-8", newline="") as fin:
                    for i, line in enumerate(fin):
                        if has_header and i == 0:
                            if not header_written:
                                fout.write(line)
                                header_written = True
                        else:
                            fout.write(line)


def copy_with_collision_resolution(src: Path, dest_dir: Path, shard_idx: int) -> None:
    """Copy a single file src into dest_dir, avoiding name collisions.

    If dest file exists, append _shard{idx} before extension.

    Args:
        src: source file path
        dest_dir: destination directory
        shard_idx: index of shard for suffixing
    """
    rel = src.name
    dest = dest_dir / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    if not dest.exists():
        shutil.copy2(src, dest)
        return
    # collision -> append suffix
    stem = dest.stem
    suffix = dest.suffix
    new_name = f"{stem}_shard{shard_idx}{suffix}"
    new_dest = dest_dir / new_name
    shutil.copy2(src, new_dest)


def merge_dir_outputs(shard_dirs: Sequence[Path], final_dir: Path, strategy: str) -> None:
    """Merge all files from shard_dirs into final_dir according to strategy.

    Strategies:
      - per_shard_dir: final_dir/shard_{i}/... (no collisions)
      - prefix_shard: copy files into final_dir with filenames prefixed: shard{i}__originalname
      - safe_copy: try to preserve relpaths; on collision append _shard{idx} (default)

    Args:
        shard_dirs: list of shard output directories (ordered by shard index)
        final_dir: destination root directory
        strategy: one of "per_shard_dir", "prefix_shard", "safe_copy"
    """
    final_dir.mkdir(parents=True, exist_ok=True)
    for idx, sd in enumerate(shard_dirs):
        if strategy == "per_shard_dir":
            dest_root = final_dir / f"shard_{idx}"
            if dest_root.exists():
                shutil.rmtree(dest_root)
            shutil.copytree(sd, dest_root)
            continue

        for p in sd.rglob("*"):
            if not p.is_file():
                continue
            rel = p.relative_to(sd)
            if strategy == "prefix_shard":
                dest_name = f"shard{idx}__{rel.as_posix().replace('/', '__')}"
                dest_path = final_dir / dest_name
                dest_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, dest_path)
            else:  # safe_copy
                dest_path = final_dir / rel
                if not dest_path.exists():
                    dest_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(p, dest_path)
                else:
                    copy_with_collision_resolution(p, dest_path.parent, idx)


# -----------------------
# Main workflow
# -----------------------

def main(argv: Optional[Sequence[str]] = None) -> None:
    parser = argparse.ArgumentParser(description="Full lifecycle sharding wrapper (template based)")
    parser.add_argument("--input-list", type=Path, required=True, help="Path to input list (text file)")
    parser.add_argument("--num-shards", type=int, required=True)
    parser.add_argument("--has-header", action="store_true", help="Treat first line as header and replicate")
    parser.add_argument("--config", type=Path, help="Optional YAML config providing exec_template and defaults")
    parser.add_argument("--exec-template", type=str,
                        help="Command template using placeholders, e.g. "
                             "\"python process.py --wsi_dir {shard_input} --out_dir {shard_output} --model {model}\"")
    parser.add_argument("--exec", dest="exec_fallback", type=str,
                        help="Fallback simple command if no template provided (tokens will be appended with shard_input and shard_output).")
    parser.add_argument("--final-output", type=Path, required=True,
                        help="Final merged output: file (for csv) or directory (for dir merging).")
    parser.add_argument("--output-structure", choices=["csv", "dir"], required=True,
                        help="How outputs from shards should be merged.")
    parser.add_argument("--csv-pattern", type=str, default="*.csv",
                        help="Glob pattern for csv files inside shard outputs (when output-structure=csv).")
    parser.add_argument("--merge-strategy", choices=["per_shard_dir", "prefix_shard", "safe_copy"],
                        default="safe_copy",
                        help="Strategy for merging directory outputs to avoid collisions.")
    parser.add_argument("--keep-temp", action="store_true", help="Do not delete temporary shard directories.")
    parser.add_argument("--parallel", type=int, default=1, help="Max parallel workers (1 = sequential).")

    known_args, extra = parser.parse_known_args(args=argv)

    # Load config yaml if provided (lightweight yaml read)
    import yaml as _yaml
    cfg: Dict[str, Any] = {}
    if known_args.config:
        if not known_args.config.exists():
            raise SystemExit(f"Config not found: {known_args.config}")
        cfg = _yaml.safe_load(known_args.config.read_text(encoding="utf-8")) or {}

    # gather default placeholders from config (cfg.get('args', {}))
    cfg_args: Dict[str, Any] = {k: v for k, v in (cfg.get("args") or {}).items()}

    # parse extra CLI args into mapping but keep original list for fallback mode
    extra_map = parse_cli_kv_args(list(extra))
    extra_list = list(extra)  # original token list to append in fallback

    # merged placeholders: CLI extra_map wins over config args
    placeholders = {**{k: str(v) for k, v in cfg_args.items()}, **{k: str(v) for k, v in extra_map.items()}}

    # discover exec template / fallback
    exec_template = known_args.exec_template or (cfg.get("exec_template") if cfg else None)
    exec_fallback = known_args.exec_fallback or (cfg.get("exec") if cfg else None)
    if exec_template is None and exec_fallback is None:
        raise SystemExit("Provide either --exec-template or --exec (or config with exec_template/exec).")

    # prepare shards
    shard_inputs = split_input_file(known_args.input_list, known_args.num_shards, known_args.has_header)

    # temp root for shard outputs
    temp_root = Path(tempfile.mkdtemp(prefix="shards_"))
    shard_output_dirs = [temp_root / f"shard_{i}_output" for i in range(known_args.num_shards)]

    # run shards (parallel or sequential)
    def _run_shard(idx: int) -> None:
        shard_in = shard_inputs[idx]
        shard_out = shard_output_dirs[idx]
        context: Dict[str, Any] = {
            "shard_input": str(shard_in),
            "shard_output": str(shard_out),
            "shard_index": idx,
            "num_shards": known_args.num_shards,
            "workdir": str(shard_out),
            **placeholders
        }
        cmd = format_exec_command(exec_template, exec_fallback, context, extra_list)
        # ensure out dir exists before running
        shard_out.mkdir(parents=True, exist_ok=True)
        run_one_shard(cmd, cwd=shard_out)

    try:
        if known_args.parallel and known_args.parallel > 1:
            with concurrent.futures.ThreadPoolExecutor(max_workers=known_args.parallel) as ex:
                futures = [ex.submit(_run_shard, i) for i in range(len(shard_inputs))]
                for f in concurrent.futures.as_completed(futures):
                    f.result()  # re-raise exceptions if any
        else:
            for i in range(len(shard_inputs)):
                _run_shard(i)

        # merge outputs
        if known_args.output_structure == "csv":
            merge_csv_outputs(shard_output_dirs, known_args.final_output, known_args.csv_pattern, known_args.has_header)
        else:
            merge_dir_outputs(shard_output_dirs, known_args.final_output, known_args.merge_strategy)

    finally:
        if known_args.keep_temp:
            print(f"[INFO] temporary shard dirs kept at {temp_root}")
        else:
            shutil.rmtree(temp_root, ignore_errors=True)

    print(f"[INFO] Final output: {known_args.final_output}")


if __name__ == "__main__":
    main()
