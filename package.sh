#!/usr/bin/env bash
#export SCRIPT_DIR="$(dirname "$0")"
cd "$(dirname "$0")"
export $SCRIPT_DIR="$(pwd)"
echo  $SCRIPT_DIR
export PACKAGE_NAME=lrkomoot
export TARGET_DIR=$SCRIPT_DIR/target/Lightroom
export SOURCE_DIR=$SCRIPT_DIR/src/main/lua/$PACKAGE_NAME.lrdevplugin
export RESOURCE_DIR=$SCRIPT_DIR/res
# cleanup
if [ -d  "$TARGET_DIR" ]; then
   rm -d -f -r $TARGET_DIR
fi
mkdir $TARGET_DIR
mkdir $TARGET_DIR/Modules
mkdir $TARGET_DIR/Modules/$PACKAGE_NAME.lrplugin
# copy dev

cp -R $SOURCE_DIR/* $TARGET_DIR/Modules/$PACKAGE_NAME.lrplugin
# compile
cd $TARGET_DIR/Modules/$PACKAGE_NAME.lrplugin
for f in *.lua
do
 luac5.1 -o $f $f
done
cd $RESOURCE_DIR
cp -R * $TARGET_DIR