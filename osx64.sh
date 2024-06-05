#!/bin/bash
pwd
[ -z "$WORKSPACE" ] && WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"
pwd
echo "$WORKSPACE"
echo "$GITHUB_WORKSPACE"

mkdir abc
cd abc
pwd
ls $WORKSPACE
ls $WORKSPACE/misc
ls $WORKSPACE/misc/cmakeconfig.h
cd ..

npm i
if [ ! -d "webkit" ]; then
    sudo git config --system core.longpaths true
    git clone https://github.com/WebKit/webkit.git
    cd webkit
    git reset --hard 8715d40f1d70
    cd ..
fi
echo =====[ build jsc ]=====
cd webkit
perl Tools/Scripts/build-webkit --jsc-only  --verbose
mkdir -p $WORKSPACE/jsc_bin/jsc/include/JavaScriptCore
mkdir -p $WORKSPACE/jsc_bin/jsc/lib/osx
cp WebKitBuild/JSCOnly/Release/cmakeconfig.h $WORKSPACE/jsc_bin/jsc/include/JavaScriptCore/cmakeconfig_mac.h
cp -r WebKitBuild/JSCOnly/Release/lib/JavaScriptCore.framework $WORKSPACE/jsc_bin/jsc/lib/osx
