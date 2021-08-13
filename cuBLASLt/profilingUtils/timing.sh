#!/bin/bash

problem_size_m=${problem_size_m:-8192}
problem_size_n=${problem_size_n:-8192}
problem_size_k=${problem_size_k:-8192}
kernel=${kernel:-gemm}

# Get the passed parameter values if any.
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]
  then
    param="${1/--/}"
    declare $param="$2"
  fi

  shift
done

# Calculate flops.
((flops = $problem_size_m * $problem_size_n * $problem_size_k * 2))

# Profile
nsys profile --force-overwrite true -o gpu_ ./sample_cublasLt_LtSgemm $problem_size_m $problem_size_n $problem_size_k 10 2> dump_.txt

# Get average execution time of `turing`.
interval=$(nsys stats -q --force-overwrite true --format csv --report gpukernsum gpu_.qdrep | (awk -v kernel="$kernel" '$0~kernel') | (awk -F',' '{print $4}'))

rm -f gpu_.qdrep
rm -f gpu_.sqlite
rm -f dump_.txt

# Check if perf is reported by `nvprof`.
if [ -z "$interval" ]
then
    echo -e "\e[31merror:\e[0m" "execTime was not given by nvprof."
    exit
fi

# Calculate performance.
>&2 printf '%.6f TFLOPs\n' $(echo "(($flops / $interval) * 1000000000) / 1000000000000" | bc -l)

