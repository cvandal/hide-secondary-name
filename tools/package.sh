#!/bin/sh
# Builds dist/HideSecondaryName-<version>.zip: the addon alone, in a folder named HideSecondaryName, ready to unzip
# into Interface/AddOns. Upload it to a GitHub release.
set -e
cd "$(dirname "$0")/.."

version=$(sed -n 's/^## Version: *//p' src/HideSecondaryName.toc | tr -d '\r')
core=$(sed -n 's/^HSN.version = "\(.*\)"/\1/p' src/Core.lua)
if [ -z "$version" ] || [ "$version" != "$core" ]; then
    echo "error: version in src/HideSecondaryName.toc ($version) and src/Core.lua ($core) must match" >&2
    exit 1
fi

lua tools/smoke_test.lua >/dev/null || { echo "error: smoke test failed" >&2; exit 1; }

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir "$stage/HideSecondaryName"
# Only what the game loads: the TOC and Lua files.
(cd src && find . -name '*.toc' -o -name '*.lua') | while read -r file; do
    mkdir -p "$stage/HideSecondaryName/$(dirname "$file")"
    cp "src/$file" "$stage/HideSecondaryName/$file"
done
cp LICENSE "$stage/HideSecondaryName/"
chmod -R u=rwX,go=rX "$stage/HideSecondaryName"

mkdir -p dist
zip_path="$PWD/dist/HideSecondaryName-$version.zip"
rm -f "$zip_path"
(cd "$stage" && zip -qrX "$zip_path" HideSecondaryName)
echo "wrote dist/HideSecondaryName-$version.zip ($(unzip -l "$zip_path" | tail -1 | awk '{print $2}') files)"
