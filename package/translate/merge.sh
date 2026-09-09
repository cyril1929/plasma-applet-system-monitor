#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
cd "${SCRIPT_DIR}"

echo "extracting messages..."
PACKAGE_NAME=$(jq -r '.KPlugin.Id' ../metadata.json)
AUTHOR_EMAIL=$(jq -r '.KPlugin.Authors[0].Email' ../metadata.json)
AUTHOR_NAME=$(jq -r '.KPlugin.Authors[0].Name' ../metadata.json)
readarray -t INPUT_FILES_LIST < <(find "../contents" \( -name "*.qml" -o -name "*.js" \) | LC_ALL=C sort)
xgettext --from-code=utf-8 \
    --language=JavaScript \
    --kde \
    -ki18n:1 \
    -ki18nc:1c,2 \
    -ki18np:1,2 \
    -ki18ncp:1c,2,3 \
    -ki18nd:2 \
    --package-name="${PACKAGE_NAME}" \
    --msgid-bugs-address="${AUTHOR_EMAIL}" \
    --copyright-holder="${AUTHOR_NAME}" \
    --output template.pot.new \
    "${INPUT_FILES_LIST[@]}"
sed -i 's/charset=CHARSET/charset=UTF-8/' template.pot.new
if diff -q -I '^"POT-Creation-Date:' template.pot template.pot.new >/dev/null 2>&1
then
    rm -f template.pot.new
else
    mv template.pot.new template.pot
fi
echo "done extracting messages"

echo "merging messages..."
for PO_FILE in *.po 
do
   echo "updating ${PO_FILE}..."
   msgmerge --no-fuzzy-matching "${PO_FILE}" template.pot | msgattrib --no-obsolete -o "${PO_FILE}"
done
echo "done merging messages"
