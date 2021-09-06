#!/usr/bin/env bash
set -e

GREEN="\033[0;32m"
ORANGE="\033[0;33m"
NC="\033[0m"

printHelpAndExit() {
    echo -e "${ORANGE}USAGE${NC}"
    echo -e "   ./run-in-docker.sh ${GREEN}-s${NC} two-fer ${GREEN}-i${NC} ./relative/path/to/two-fer/solution/folder/ ${GREEN}-o${NC} ./relative/path/to/output/directory/"
    echo
    echo -e "${ORANGE}SYNOPSIS${NC}"
    echo "   Test runner for run.sh in a docker container;"
    echo "   Takes the same arguments as run.sh (EXCEPT THAT SOLUTION AND OUTPUT PATH ARE RELATIVE);"
    echo "   Builds the Dockerfile;"
    echo "   Runs the docker image passing along the initial arguments."
    echo
    echo -e "${ORANGE}ARGUMENTS${NC}"
    echo -e "${GREEN}   -s, --slug${NC}		Name of exercise slug"
    echo -e "${GREEN}   -i, --input${NC}		Relative path to solution folder (with trailing slash)"
    echo -e "${GREEN}   -o, --output${NC}		Relative path to output directory (with trailing slash)"
    echo
    echo -e "${ORANGE}OUTPUT${NC}"
    echo "   Writes the test results to a results.json file in the passed-in output directory."
    echo "   The test results are formatted according to the specifications at https://github.com/exercism/automated-tests/blob/master/docs/interface.md"
    exit 1
}

if [ $# -eq 0 ]; then
    printHelpAndExit
fi

#Parse keys
while(( "$#" )); do
    case "$1" in
        -s|--slug)
            SLUG="$2"
            shift
            shift
            ;;
        -i|--input)
            INPUT_DIR="$2"
            shift
            shift
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift
            shift
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done

# build docker image
docker build --rm --no-cache -t swift-test-runner .

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# run image passing the arguments
docker run \
    --mount type=bind,src=$PWD/$INPUT_DIR,dst=/solution \
    --mount type=bind,src=$PWD/$OUTPUT_DIR,dst=/output \
    swift-test-runner $SLUG /solution/ /output/
