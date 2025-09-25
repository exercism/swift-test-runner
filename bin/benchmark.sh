#!/usr/bin/env bash

# Synopsis:
# Benchmark the test runner code.
# Each run will clean the test directory being used to prevent previous runs from affecting the results.

# Output:
# Outputs performance metrics.

# Example:
# ./bin/benchmark.sh

set -euo pipefail

die() { echo "$*" >&2; exit 1; }

required_tool() {
    command -v "${1}" >/dev/null 2>&1 ||
        die "${1} is required but not installed. Please install it and make sure it's in your PATH."
}

required_tool hyperfine

test_list=$(find tests -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | paste -sd "," -)
hyperfine \
    --parameter-list slug "${test_list}" \
    --prepare 'git clean -xdfq tests/{slug}' \
    './bin/run.sh {slug} tests/{slug} tests/{slug}'
