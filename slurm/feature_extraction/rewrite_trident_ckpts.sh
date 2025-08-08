#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 INPUT_JSON OUTPUT_JSON STRING_MATCH STRING_REPLACE"
  echo "Example: $0 local_ckpts.json new_ckpts.json hf_models_bench /tmp/hf_models_bench"
  exit 1
fi

INPUT_JSON="$1"
OUTPUT_JSON="$2"
STRING_MATCH_RAW="$3"
STRING_REPLACE_RAW="$4"

# --- Normalize paths ---
# Remove leading/trailing slashes from match string
STRING_MATCH="$(echo "$STRING_MATCH_RAW" | sed 's|^/*||; s|/*$||')"

# Remove trailing slash from replacement
STRING_REPLACE="$(echo "$STRING_REPLACE_RAW" | sed 's|/*$||')"

# Escape for regex (jq regexes)
ESCAPED_MATCH="$(printf '%s' "$STRING_MATCH" | sed 's/[.[\*^$(){}+?|]/\\&/g')"

# Create final jq expression
jq \
  --arg match "$ESCAPED_MATCH" \
  --arg repl "$STRING_REPLACE" '
  with_entries(
    .value |=
      if type == "string" and (. | test($match)) then
        $repl + "/" + (sub(".*" + $match + "/?"; ""))
      else
        .
      end
  )
' "$INPUT_JSON" > "${OUTPUT_JSON}.tmp" && mv "${OUTPUT_JSON}.tmp" "$OUTPUT_JSON"
