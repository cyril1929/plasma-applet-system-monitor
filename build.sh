#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "${SCRIPT_DIR}"

VERSION="${1:-}"

if [ -n "${VERSION}" ]
then
    echo "start build with version '${VERSION}'"
    if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
        echo "Error: invalid version format. Expected format: XX.YY.ZZ (e.g. 1.0.0)"
        exit 1
    fi
    echo "setting version in package/metadata.json..."
    jq --tab --arg v "${VERSION}" '.KPlugin.Version = $v' package/metadata.json >package/metadata.json.tmp
    mv package/metadata.json.tmp package/metadata.json
    NAME_SUFFIX="-v${VERSION}"
else
    echo "start build without version"
    NAME_SUFFIX=""
fi

echo "building translations..."
./package/translate/build.sh

echo "building archive..."
PACKAGE_ID=$(jq -r '.KPlugin.Id' package/metadata.json)
OUTPUT_FILE="${PACKAGE_ID}${NAME_SUFFIX}.plasmoid"
cd package
zip -r - metadata.json contents >"../${OUTPUT_FILE}"
cd - >/dev/null

echo "cleaning..."
jq --tab 'del(.KPlugin.Version)' package/metadata.json >package/metadata.json.tmp 
mv package/metadata.json.tmp package/metadata.json

echo "build done!" 
echo "created: ${OUTPUT_FILE}"
