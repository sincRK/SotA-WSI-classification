#!/bin/bash

#SBATCH --job-name=test_run_sharded
#SBATCH --output=test_run_sharded.out
#SBATCH --error=test_run_sharded.err
#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --mem=90000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --cpus-per-task=16
#SBATCH --gres=gpu:a30:1
#SBATCH --partition=gpu

# ==========================
# Config
# ==========================
RESOURCE_LOG="${SLURM_JOBID}_resource_usage.log"
MONITOR_INTERVAL=5  # seconds

# ==========================
# Monitoring function
# ==========================
monitor_resources() {
    echo "timestamp,pid,cmd,mem_mb,gpu_mem_mb" > "$RESOURCE_LOG"

    while scontrol listpids "$SLURM_JOB_ID" &>/dev/null; do
        PIDS=$(scontrol listpids "$SLURM_JOB_ID" | awk 'NR>1 {print $1}')
        if [[ -n "$PIDS" ]]; then
            # Collect RAM usage per PID
            ps -o pid=,rss=,cmd= -p $PIDS 2>/dev/null | while read -r pid rss cmd; do
                mem_mb=$(awk "BEGIN {printf \"%.1f\", $rss/1024}")
                # Match GPU mem usage for this PID
                gpu_mb=$(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader,nounits \
                    | awk -v target="$pid" '$1==target {sum+=$2} END {print sum+0}')
                ts=$(date '+%F %T')
                echo "$ts,$pid,\"$cmd\",$mem_mb,$gpu_mb" >> "$RESOURCE_LOG"
            done
        fi
        sleep "$MONITOR_INTERVAL"
    done
}

# Start monitoring in the background
monitor_resources &
MONITOR_PID=$!

# ==========================
# Main job logic
# ==========================
export BENCH=/pfs/10/project/bw16k010/benchmark/test

if [ -z "${TMPDIR+x}" ]; then
    echo "TMPDIR not set."
    exit 1
else
    echo "Scratch folder set to ${TMPDIR}."
fi

if [ -z "${BENCH+x}" ]; then
    echo "BENCH not set."
    exit 1
else
    echo "Project base folder set to ${BENCH}."
fi

if [ -z "${HOME+x}" ]; then
    echo "HOME not set."
    exit 1
else
    echo "Script/config folder set to ${HOME}."
fi

cp -r "${HOME}/feature_extraction" "$TMPDIR"
bash "${TMPDIR}/feature_extraction/check_global_vars.sh"
bash "${TMPDIR}/feature_extraction/node_setup.sh"
cp -r "${BENCH}/hf_models_bench/"* "${TMPDIR}/hf_models_bench/"

bash "${TMPDIR}/feature_extraction/move_img_folder_to_node.sh" "${BENCH}/histai" "${TMPDIR}/histai/data" "tiff"
bash "${TMPDIR}/feature_extraction/move_img_folder_to_node.sh" "${BENCH}/cobra" "${TMPDIR}/cobra/data" "tif"
bash "${TMPDIR}/feature_extraction/move_img_folder_to_node.sh" "${BENCH}/pp" "${TMPDIR}/pp/data" "isyntax"

bash "${TMPDIR}/feature_extraction/create_list_of_files.sh" "${TMPDIR}/histai/data" "tiff" 0.5
bash "${TMPDIR}/feature_extraction/create_list_of_files.sh" "${TMPDIR}/cobra/data" "tif" 0.5
bash "${TMPDIR}/feature_extraction/create_list_of_files.sh" "${TMPDIR}/pp/data" "isyntax" 0.25

bash "${TMPDIR}/feature_extraction/extract_features_sharded.sh" "${TMPDIR}/histai/data" "${TMPDIR}/histai/output" 8 4
bash "${TMPDIR}/feature_extraction/extract_features_sharded.sh" "${TMPDIR}/cobra/data" "${TMPDIR}/cobra/output" 8 4
bash "${TMPDIR}/feature_extraction/extract_features_sharded.sh" "${TMPDIR}/pp/data" "${TMPDIR}/pp/output" 1 32

bash "${TMPDIR}/feature_extraction/move_node_to_bench.sh"
bash "${TMPDIR}/feature_extraction/node_cleanup.sh"

# ==========================
# Cleanup monitor
# ==========================
kill "$MONITOR_PID" 2>/dev/null || true
wait "$MONITOR_PID" 2>/dev/null || true

# Move the log to $HOME to avoid node cleanup
FINAL_LOG="$HOME/resource_usage_${SLURM_JOB_ID}.log"
mv "$RESOURCE_LOG" "$FINAL_LOG"
echo "Resource usage log saved to: $FINAL_LOG"
