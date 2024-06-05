#!/bin/bash
[ -z "$WORKSPACE" ] && WORKSPACE="$( cd "$( dirname "$0" )" && pwd )"

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
