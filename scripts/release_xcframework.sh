#!/bin/bash
set -e

GODOT_PLUGINS=$(ls -d ./plugins/* | cut -f3 -d'/')
echo "1) PLUGINS LIST: ${GODOT_PLUGINS}"

echo "2) COMPILE PLUGINS"
# Compile Plugin
for lib in $GODOT_PLUGINS; do
    echo " - GENERATE XCFRAMEWORKS ${lib} ${1}"
    ./scripts/generate_xcframework.sh $lib release $1
    ./scripts/generate_xcframework.sh $lib release_debug $1

    if [ -e "./bin/${lib}.debug.xcframework" ]; then
        rm -rf "./bin/${lib}.debug.xcframework"
    fi

    mv -f ./bin/${lib}.release_debug.xcframework ./bin/${lib}.debug.xcframework
done


echo "3) MOVE FILES"
# Move to release folder
rm -rf ./bin/release
mkdir -p ./bin/release

# Move Plugin
for lib in $GODOT_PLUGINS; do
    echo " - MOVE ${lib}"

    if [ -e "./bin/release/${lib}" ]; then
        rm -rf "./bin/release/${lib}"
    fi

    mkdir -p ./bin/release/${lib}
    mv -f ./bin/${lib}.{release,debug}.xcframework ./bin/release/${lib}
    cp -f ./plugins/${lib}/${lib}.gdip ./bin/release/${lib}
done
