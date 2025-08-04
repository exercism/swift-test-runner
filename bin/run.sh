#!/usr/bin/env bash

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: absolute path to solution folder
# $3: absolute path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/"
    exit 1
fi

SLUG="$1"
INPUT_DIR="${2%/}"
OUTPUT_DIR="${3%/}"

WORKING_DIR=${PWD}
cp -r "${INPUT_DIR}/." "${WORKING_DIR}"

junit_file="${WORKING_DIR}/results-swift-testing.xml"
spec_file="${WORKING_DIR}/$(jq -r '.files.test[0]' ${WORKING_DIR}/.meta/config.json)"
capture_file="${OUTPUT_DIR}/capture"
results_file="${OUTPUT_DIR}/results.json"

touch "${results_file}"

export RUNALL=true
swift test \
    --package-path "${WORKING_DIR}" \
    --xunit-output "${WORKING_DIR}/results.xml" \
    --skip-update &> "${capture_file}"

./bin/TestRunner "${spec_file}" "${junit_file}" "${capture_file}" "${results_file}" "${SLUG}"
