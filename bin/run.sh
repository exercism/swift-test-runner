#!/bin/bash
set -e

GREEN="\033[0;32m"
ORANGE="\033[0;33m"
NC="\033[0m"

printHelpAndExit() {
    echo -e "Usage: run.sh ${GREEN}-s${NC} exercise-slug ${GREEN}-i${NC} /solution ${GREEN}-o${NC} /output"
    echo
    echo -e "${ORANGE}PARAMETERS${NC}"
    echo -e "${GREEN}   -s, --slug${NC}		Name of exercise slug"
    echo -e "${GREEN}   -i, --input${NC}		Absolute path to solution folder"
    echo -e "${GREEN}   -o, --output${NC}		Absolute path to output directory (For result.json report)"
    echo
    exit 1
}

if [ $# -eq 0 ]; then
    printHelpAndExit
fi

BASEDIR=$(dirname "$0")

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

# Print settings
# echo -e "${ORANGE}OPTIONS${NC}"
# echo -e "${GREEN}SLUG${NC}    = ${SLUG}"
# echo -e "${GREEN}INPUT${NC}   = ${INPUT_DIR}"
# echo -e "${GREEN}OUTPUT${NC}  = ${OUTPUT_DIR}"
# echo "-------------"

RUNALL=true "${BASEDIR}"/TestRunner --slug "${SLUG}" --solution-directory "${INPUT_DIR}" --output-directory "${OUTPUT_DIR}" --swift-location $(which swift) --build-directory "/tmp"
