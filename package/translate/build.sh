#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "${SCRIPT_DIR}"

echo "compiling po files..."
PACKAGE_NAME=$(jq -r '.KPlugin.Id' ../metadata.json)
for PO_FILE in *.po
do
    echo "compiling ${PO_FILE}..."
    LANG="${PO_FILE%.po}"
    TARGET_DIR="../contents/locale/${LANG}/LC_MESSAGES"
	mkdir -p "$TARGET_DIR"
    msgfmt --check -o "${TARGET_DIR}/plasma_applet_${PACKAGE_NAME}.mo" "${PO_FILE}"
done
echo "done compiling po files"
