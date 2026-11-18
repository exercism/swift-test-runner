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

set -eu

# If any required arguments is missing, print the usage and exit
if (( "$#" != 3 )); then
    printf 'Usage: %s exercise-slug /absolute/path/to/solution/ /absolute/path/to/output/\n' "$0"
    exit 1
fi

SLUG="$1"
INPUT_DIR="${2%/}"
OUTPUT_DIR="${3%/}"

get_target_name() {
    local section=$1
    local path
    path=$(jq -r --arg section "${section}" '.files.[$section][0]' "${CONFIG_FILE}")
    path=${path%/*}
    path=${path##*/}
    echo "${path}"
}

# Succeeds if the exercise's package has one target and one test target, with
# no dependencies other than RealModule from swift-numerics, uses
# swift-tools-version 6.x, holds only Swift files, and its tests don't import
# XCTest. bin/fast-test.sh only handles those packages.
uses_usual_package() {
    local target_name=$1
    local test_target_name=$2
    local usual='importPackageDescriptionletpackage=Package(name:"P",products:[.library(name:"P",targets:["T"])],dependencies:[],targets:[.target(name:"T",dependencies:[]),.testTarget(name:"TT",dependencies:["T"])])'
    local manifest

    head -n 1 "${INPUT_DIR}/Package.swift" | grep -Eq '^// *swift-tools-version: *6\.[0-9]+(\.[0-9]+)? *$' || return 1

    # Remove comments (but not the "//" in "https://"), whitespace,
    # swift-numerics and trailing commas, then replace the names.
    manifest=$(sed -e 's#\(^\|[^:]\)//.*#\1#' "${INPUT_DIR}/Package.swift" | tr -d ' \t\r\n' |
        sed -e 's#\.package(url:"https://github.com/apple/swift-numerics",from:"1\.0\.3")##' \
            -e 's/\.product(name:"RealModule",package:"swift-numerics")//g' \
            -e 's/\[,*/[/g' -e 's/,,*/,/g' -e 's/,\([])]\)/\1/g' \
            -e 's/\.target(name:"\([^"]*\)")/.target(name:"\1",dependencies:[])/' \
            -e 's/Package(name:"[^"]*"/Package(name:"P"/' \
            -e 's/\.library(name:"[^"]*"/.library(name:"P"/' \
            -e "s/\"${target_name}\"/\"T\"/g" \
            -e "s/\"${test_target_name}\"/\"TT\"/g")
    [[ "${manifest}" == "${usual}" ]] || return 1

    [[ "$(ls -A "${INPUT_DIR}/Sources")" == "${target_name}" ]] || return 1
    [[ "$(ls -A "${INPUT_DIR}/Tests")" == "${test_target_name}" ]] || return 1
    [[ -z "$(find "${INPUT_DIR}/Sources" "${INPUT_DIR}/Tests" -type f ! -name '*.swift')" ]] || return 1
    ! grep -rqs 'import XCTest' "${INPUT_DIR}/Tests"
}

use_fast_test=false

if [[ "${RUN_IN_DOCKER:-}" == "TRUE" ]]; then
    # Docker image contains a prebuilt package called TestEnvironment with a ready .build directory 
    # to build solutions as fast as it possible. To minimize changes in the build graph,
    # exercise resources are copied inside the TestEnvironment package as if they had always been there.

    WORKING_DIR="${PWD}"
    CONFIG_FILE="${INPUT_DIR}/.meta/config.json"
    SOURCE_TARGET_PATH="${WORKING_DIR}/Sources/TestEnvironment"
    TEST_TARGET_PATH="${WORKING_DIR}/Tests/TestEnvironmentTests"

    # 1. Replace source files with those of an exercise, saving TestEnvironement paths
    rm -r -- "${SOURCE_TARGET_PATH}" "${TEST_TARGET_PATH}"

    target_name=$(get_target_name solution)
    test_target_name=$(get_target_name test)

    # Copying everything from package in case of other targets.
    cp -r -- "${INPUT_DIR}/Sources/." "${WORKING_DIR}/Sources"
    cp -r -- "${INPUT_DIR}/Tests/." "${WORKING_DIR}/Tests"

    mv -- "${WORKING_DIR}/Sources/${target_name}" "${SOURCE_TARGET_PATH}"
    mv -- "${WORKING_DIR}/Tests/${test_target_name}" "${TEST_TARGET_PATH}"

    # 2. Replace @testable import SomeModule with @testable import TestEnvironment
    change_import="s/@testable import [^ ]\+/@testable import TestEnvironment/g"
    sed -i -- "${change_import}" "${WORKING_DIR}/Tests/TestEnvironmentTests"/*.swift

    # 3. Copy Package.swift and rename main & test targets.
    cp "${INPUT_DIR}/Package.swift" "${WORKING_DIR}"
    change_target="s/\"${target_name}\"/\"TestEnvironment\"/g;"
    change_target+="s/\"${test_target_name}\"/\"TestEnvironmentTests\"/g"
    sed -i -- "${change_target}" "${WORKING_DIR}/Package.swift"

    # 4. Use bin/fast-test.sh if the exercise has the track's usual package
    # layout and its tests use Swift Testing.
    if uses_usual_package "${target_name}" "${test_target_name}"; then
        use_fast_test=true
    fi

else
    WORKING_DIR=${INPUT_DIR}
fi

junit_file="${WORKING_DIR}/results-swift-testing.xml"
spec_file="${INPUT_DIR}/$(jq -r '.files.test[0]' "${INPUT_DIR}/.meta/config.json")"
capture_file="${OUTPUT_DIR}/capture"
results_file="${OUTPUT_DIR}/results.json"

touch "${results_file}"

export RUNALL=true

# Builds and runs tests. The resulting artifacts are saved to $junit_file (yes, the file name will change).
# bin/fast-test.sh does the same without SwiftPM, and fails for compile errors
# and crashes, which `swift test` then reports as usual.
if [[ "${use_fast_test}" != true ]] || ! bin/fast-test.sh "${WORKING_DIR}" "${junit_file}" "${capture_file}"; then
    rm -f -- "${junit_file}"
    swift test \
        --package-path "${WORKING_DIR}" \
        --xunit-output "${WORKING_DIR}/results.xml" \
        --build-system native \
        --skip-update &> "${capture_file}" || true
fi

# Convert test results into the Exercism test runner output format.
./bin/TestRunner "${spec_file}" "${junit_file}" "${capture_file}" "${results_file}" "${SLUG}"
