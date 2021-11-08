#!/bin/bash
set -e

GODOT_PLUGINS=$(ls -d ./plugins/* | cut -f3 -d'/')
echo "1) PLUGINS LIST: ${GODOT_PLUGINS}"

verbose='false'
multithread='true'
print_usage() {
  printf "Usage: ..."
}

while getopts 'abf:v' flag; do
  case "${flag}"
    d) multithread=false ;;
    v) verbose='true' ;;
    *) print_usage ;;
  esac
done


compile() {

    local PLUGIN_NAME=$1
    local GODOT_VER=$2

    echo " - GENERATE XCFRAMEWORKS ${PLUGIN_NAME} ${GODOT_VER}"
    ./scripts/generate_xcframework.sh $PLUGIN_NAME release $GODOT_VER
    ./scripts/generate_xcframework.sh $PLUGIN_NAME release_debug $GODOT_VER

    if [ -e "./bin/${PLUGIN_NAME}.debug.xcframework" ]; then
        rm -rf "./bin/${PLUGIN_NAME}.debug.xcframework"
    fi

    mv -f ./bin/${PLUGIN_NAME}.release_debug.xcframework ./bin/${PLUGIN_NAME}.debug.xcframework
} 

echo "2) COMPILE PLUGINS"
# Compile Plugin
for lib in $GODOT_PLUGINS; do
    if multithread; then
        compile $lib $1 &
    else
        compile $lib $1
    fi
done

if multithread; then
    wait
fi

echo "3) MOVE FILES"
# Move to release folder
rm -rf ./bin/release
mkdir -p ./bin/release

# Move Plugin
for lib in $GODOT_PLUGINS; do
    echo " - MOVE ${lib}"
    mkdir ./bin/release/${lib}
    mv -f ./bin/${lib}.{release,debug}.xcframework ./bin/release/${lib}
    cp -f ./plugins/${lib}/${lib}.gdip ./bin/release/${lib}
done
