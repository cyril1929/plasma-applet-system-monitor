#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "${SCRIPT_DIR}"

echo "linting files..."
readarray -t INPUT_FILES_LIST < <(find "package/contents" \( -name "*.qml" -o -name "*.js" \))
qmllint-qt6 --max-warnings 0 "${INPUT_FILES_LIST[@]}"
echo "done linting files"
