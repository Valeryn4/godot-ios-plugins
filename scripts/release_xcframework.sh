#!/bin/bash
set -e

GODOT_PLUGINS=(find ./plugins/ -type d -printf '%f ')
#GODOT_PLUGINS=(echo ${GODOT_PLUGINS//plugins\//})
echo "1) PLUGINS LIST: ${GODOT_PLUGINS}"

echo "2) COMPILE PLUGINS"
# Compile Plugin
for lib in $GODOT_PLUGINS; do
    echo " - GENERATE XCFRAMEWORK ${lib} ${1}"
    ./scripts/generate_xcframework.sh $lib release $1
    ./scripts/generate_xcframework.sh $lib release_debug $1
    mv ./bin/${lib}.release_debug.xcframework ./bin/${lib}.debug.xcframework
done

# Move to release folder

rm -rf ./bin/release
mkdir ./bin/release
echo "3) MOVE FILES"
# Move Plugin
for lib in $GODOT_PLUGINS; do
    echo " - MOVE ${lib}"
    mkdir ./bin/release/${lib}
    mv ./bin/${lib}.{release,debug}.xcframework ./bin/release/${lib}
    cp ./plugins/${lib}/${lib}.gdip ./bin/release/${lib}
done
