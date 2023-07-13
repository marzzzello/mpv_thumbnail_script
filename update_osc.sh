#!/usr/bin/env bash
# Update the OSC to the specified mpv version

if [[ $1 == "" ]]; then
	echo "Usage: $0 <mpv tag>"
	exit 1
fi

pushd src || exit 1

# Download the new one
echo "Downloading the new osc.lua"
wget "https://raw.githubusercontent.com/mpv-player/mpv/$1/player/lua/osc.lua" || exit 1

# Apply the patch
echo "Patching"
patch --backup osc.lua osc.patch
# Exit if something was rejected
[[ -e osc.lua.rej ]] && exit 1

# Generate the patch
# This handles changes in the patch context which may cause problems in the future
echo "Generating a new patch"
mv osc.lua patched_osc.lua
mv osc.lua.orig osc.lua
diff --unified osc.lua patched_osc.lua > osc.patch
# Exit if diff failed
[[ $? == 2 ]] && exit 1

# Cleanup
echo "Cleaning up temp files"
rm osc.lua

popd || exit 1

# Commit the changes
git add src/osc.patch src/patched_osc.lua
git commit -m "Update osc to mpv $1"
