#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "${SCRIPT_DIR}"

echo "formating files..."
readarray -t INPUT_FILES_LIST < <(find "package/contents" \( -name "*.qml" -o -name "*.js" \))
qmlformat-qt6 -i "${INPUT_FILES_LIST[@]}"
echo "done formating files"
