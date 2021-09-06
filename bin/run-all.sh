#!/bin/bash
set -e

GREEN="\033[0;32m"
ORANGE="\033[0;33m"
NC="\033[0m"

test_root="${1:-/solution}"
output_dir="${2:-/output/}"

# echo -e "${GREEN}Output:${NC} ${output_dir}"
# echo -e "${GREEN}Test root:${NC} ${test_root}"

for testdir in "${test_root}"/*; do
    testname="$(basename $testdir)"
#     echo -e "${GREEN}Test dir:${NC} ${testdir}"
#     echo -e "${GREEN}Test name:${NC} ${testname}"
#     echo "-----------"
    if [ "$testname" != output ] && [ -f "${testdir}/results.json" ]; then
        bin/run.sh "$testname" "$test_root" "$output_dir"
    fi
done
