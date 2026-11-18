#!/usr/bin/env bash

# Synopsis:
# Build and run the tests of the TestEnvironment package with swiftc directly,
# without SwiftPM. run.sh calls this after copying the exercise into the package.
#
# `swift test` spends about 2.5 seconds of every run on work around the
# compiler: it compiles and runs Package.swift, plans the build, generates and
# compiles a test runner that imports XCTest and Foundation, and runs the test
# binary twice (once for XCTest and once for Swift Testing). This script
# compiles the two modules, links them with an entry point compiled at image
# build, and runs the test binary once, for Swift Testing.
#
# Usage:
# bin/fast-test.sh --prepare <package-dir>
#   Compiles the entry point. The Dockerfile runs this once.
# bin/fast-test.sh <package-dir> <junit-file> <capture-file>
#   Builds and runs the tests, writing Swift Testing's JUnit XML to <junit-file>
#   and the test output to <capture-file>.
#
# Exit status:
# 0 if the tests ran and wrote their results. Anything else means run.sh should
# fall back to `swift test`, which reports compiler errors and crashes in its
# usual words.

set -uo pipefail

BIN_DIR="$(cd "$(dirname "$0")" && pwd)"
ENTRY_POINT_SOURCE="${BIN_DIR}/../src/FastTest/Runner.swift"
ENTRY_POINT_OBJECT="${BIN_DIR}/fast-test-main.o"
# This folder holds only the RealModule module from swift-numerics, so that the
# compiler can find it without seeing the other modules in .build.
NUMERICS_MODULES_DIR="${BIN_DIR}/fast-test-modules"

prepare=false
if [[ "$1" == "--prepare" ]]; then
    prepare=true
    shift
fi

PACKAGE_DIR="$1"
BUILD_DIR="${PACKAGE_DIR}/.build/x86_64-unknown-linux-gnu/debug"
WORK_DIR="$(mktemp -d)"

# These are the flags `swift build --build-system native` passes for a debug
# build of a package with swift-tools-version 6.x. The flags that reach Clang
# must stay the same, so that the compiler reuses the module cache built into
# the image by `swift build`. Otherwise it will rebuild every Clang module,
# which takes about 1.5 seconds.
common_flags=(
    -target x86_64-unknown-linux-gnu
    -Onone -enable-testing -g
    -DSWIFT_PACKAGE -DDEBUG -DSWIFT_MODULE_RESOURCE_BUNDLE_UNAVAILABLE
    -module-cache-path "${BUILD_DIR}/ModuleCache"
    -parse-as-library -swift-version 6
    -Xcc -fPIC -Xcc -g -Xcc -fno-omit-frame-pointer
    -package-name test_runner
    -I "${WORK_DIR}/Modules"
)

if [[ "${prepare}" == true ]]; then
    swiftc -module-name TestEnvironmentPackageTests "${common_flags[@]}" \
        -c "${ENTRY_POINT_SOURCE}" -o "${ENTRY_POINT_OBJECT}" || exit 1
    mkdir -p "${NUMERICS_MODULES_DIR}"
    ln -sf "${BUILD_DIR}/Modules/RealModule.swiftmodule" "${NUMERICS_MODULES_DIR}/"
    exit
fi

JUNIT_FILE="$2"
CAPTURE_FILE="$3"

# Some exercises use RealModule from swift-numerics, which the image built
# with the TestEnvironment package.
link_objects=()
if grep -q 'swift-numerics' "${PACKAGE_DIR}/Package.swift"; then
    numerics_include_dir="${PACKAGE_DIR}/.build/checkouts/swift-numerics/Sources/_NumericsShims/include"
    common_flags+=(
        -I "${NUMERICS_MODULES_DIR}"
        -Xcc "-fmodule-map-file=${numerics_include_dir}/module.modulemap"
        -Xcc -I -Xcc "${numerics_include_dir}"
    )
    link_objects+=("${BUILD_DIR}"/RealModule.build/*.o "${BUILD_DIR}"/_NumericsShims.build/*.o)
fi

mapfile -t source_files < <(find "${PACKAGE_DIR}/Sources/TestEnvironment" -name '*.swift' | sort)
mapfile -t test_files < <(find "${PACKAGE_DIR}/Tests/TestEnvironmentTests" -name '*.swift' | sort)

# -wmo compiles each module in one compiler process, which writes the module
# file and the object file together.
swiftc -module-name TestEnvironment "${common_flags[@]}" \
    -emit-module -emit-module-path "${WORK_DIR}/Modules/TestEnvironment.swiftmodule" \
    -wmo -c "${source_files[@]}" -o "${WORK_DIR}/TestEnvironment.o" &> /dev/null || exit 1

swiftc -module-name TestEnvironmentTests "${common_flags[@]}" \
    -Xfrontend -enable-cross-import-overlays \
    -wmo -c "${test_files[@]}" -o "${WORK_DIR}/TestEnvironmentTests.o" &> /dev/null || exit 1

# mold links the test binary in about 0.15 seconds, where GNU ld (the default)
# takes 0.35 seconds.
swiftc -target x86_64-unknown-linux-gnu -g -use-ld=mold -emit-executable \
    "${WORK_DIR}/TestEnvironment.o" "${WORK_DIR}/TestEnvironmentTests.o" "${ENTRY_POINT_OBJECT}" "${link_objects[@]}" \
    -o "${WORK_DIR}/TestEnvironmentPackageTests.xctest" &> /dev/null || exit 1

"${WORK_DIR}/TestEnvironmentPackageTests.xctest" \
    --testing-library swift-testing \
    --xunit-output "${JUNIT_FILE}" &> "${CAPTURE_FILE}"

# A crash stops the test binary before it writes the XML file.
grep -q '<testcase' "${JUNIT_FILE}" 2> /dev/null || exit 1
