# Usage: python run_tests.py

import subprocess
import re

problem_size_m = [ "14848", "15104", "15360", "15616", "15872", "16128", "16384"]
problem_size_n = [ "14848", "15104", "15360", "15616", "15872", "16128", "16384"]
problem_size_k = [ "14848", "15104", "15360", "15616", "15872", "16128", "16384"]

subprocess.run(["make"])

print("problem_size_m, problem_size_n, problem_size_k, GFLOPs")

for pm in problem_size_m:
    for pn in problem_size_n:
        for pk in problem_size_k:
            if int(pm) == int(pn) and int(pn) == int(pk):
                result = subprocess.run(["./timing.sh", "--problem_size_m", pm, "--problem_size_n", pn, "--problem_size_k", pk, "--kernel", "gemm"], capture_output=True)
                res = result.stderr
                tidy = re.findall('\d*\.?\d+', res.decode('utf-8'))                                                              
                print(pm,", ",pn,", ",pk,", ",tidy)
