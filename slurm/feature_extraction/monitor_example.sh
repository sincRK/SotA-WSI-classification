#!/bin/bash
#SBATCH --job-name=monitor_example
#SBATCH --output=monitor_example.out
#SBATCH --gres=gpu:1
#SBATCH --time=00:10:00

# Start your actual job in the background
bash ${HOME}/feature_extraction/test_gpu_access.sh &
JOB_PID=$!

# Get all PIDs belonging to this SLURM job
get_pids() {
    scontrol listpids $SLURM_JOB_ID | awk 'NR>1 {print $1}'
}

# Monitoring loop
while kill -0 "$JOB_PID" 2>/dev/null; do
    PIDS=$(get_pids)
    if [[ -n "$PIDS" ]]; then
        # Memory usage in MB (sum of all job processes)
        MEM_MB=$(ps -o rss= -p $PIDS 2>/dev/null | awk '{sum+=$1} END {print sum/1024}')

        # GPU usage
        GPU_INFO=$(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader,nounits \
            | awk -v pids="$PIDS" '
                BEGIN {
                    split(pids, pid_arr, " ")
                    for (i in pid_arr) target[pid_arr[i]]=1
                }
                ($1 in target) {sum += $2}
                END {print sum+0}')

        echo "$(date '+%F %T') MEM=${MEM_MB}MB GPU=${GPU_INFO}MB"
    fi
    sleep 5
done

wait $JOB_PID
