#!/bin/bash
set -e

GODOT_PLUGINS=$(ls -d ./plugins/* | cut -f3 -d'/')
echo "1) PLUGINS LIST: ${GODOT_PLUGINS}"

VERBOSE='false'
MULTITHREAD_ENABLE=true
GODOT_VERSION='oops'


while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - attempt to capture frames"
      echo " "
      echo "$package [options] application [arguments]"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-v, --verbose             add debug output"
      echo "-d, --debug               single thread flag"
      echo "-g, --godot=version       godot version"
      exit 0
      ;;
    -v|--verbose)
      VERBOSE=true
      ;;
    -d|--debug)
      MULTITHREAD_ENABLE='false'
      ;;
    -g)
      shift
      if test $# -gt 0; then
        GODOT_VERSION=$1
      else
        echo "no godot version specified"
        exit 1
      fi
      shift
      ;;
    --godot*)
      GODOT_VERSION=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done

echo "godot version: ${GODOT_VERSION}"
echo "verbose: ${VERBOSE}"
echo "multithread: ${MULTITHREAD_ENABLE}"

compile() {

    local PLUGIN_NAME=$1
    local GODOT_VER=$2

    echo " - GENERATE XCFRAMEWORKS ${PLUGIN_NAME} ${GODOT_VER}"
    ./scripts/generate_xcframework.sh $PLUGIN_NAME release $GODOT_VER
    ./scripts/generate_xcframework.sh $PLUGIN_NAME release_debug $GODOT_VER

    if [ -e "./bin/${PLUGIN_NAME}.debug.xcframework" ]; then
        rm -rf "./bin/${PLUGIN_NAME}.debug.xcframework"
    fi

    mv ./bin/${PLUGIN_NAME}.release_debug.xcframework ./bin/${PLUGIN_NAME}.debug.xcframework
} 

echo "2) COMPILE PLUGINS"
# Compile Plugin
for lib in $GODOT_PLUGINS; do
    if [[ $MULTITHREAD_ENABLE == true ]]; then
        compile $lib $GODOT_VERSION &
    else
        compile $lib $GODOT_VERSION
    fi
done

if [[ $MULTITHREAD_ENABLE == true ]]; then
    wait
fi

echo "3) MOVE FILES"
# Move to release folder
rm -rf ./bin/release
mkdir -p ./bin/release

# Move Plugin
for lib in $GODOT_PLUGINS; do
    echo " - MOVE ${lib}"
    mkdir -p ./bin/release/${lib}
    mv ./bin/${lib}.{release,debug}.xcframework ./bin/release/${lib}
    cp ./plugins/${lib}/${lib}.gdip ./bin/release/${lib}
done
