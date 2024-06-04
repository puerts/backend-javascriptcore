#!/bin/bash

npm i
if [ ! -d "webkit" ]; then
    git clone https://github.com/WebKit/webkit.git
    cd webkit
    git reset --hard 8715d40f1d70
    echo =====[ apply patch ]=====
    node $(dirname $0)/node-script/do-gitpatch.js -p $(dirname $0)/patchs/webkit_vc_compile_for_8715d40f1d7038e9f43619d153210883228d17a6.patch
    cd ..
fi
echo =====[ build jsc ]=====
cd webkit
perl Tools/Scripts/build-jsc --jsc-only
mkdir -p $(dirname $0)/jsc_bin/jsc/include
mkdir -p $(dirname $0)/jsc_bin/jsc/lib/linux64
cp -r Source/bmalloc/bmalloc $(dirname $0)/jsc_bin/jsc/include/
cp -r Source/WTF/wtf $(dirname $0)/jsc_bin/jsc/include/
cp -r Source/WTF/icu/unicode $(dirname $0)/jsc_bin/jsc/include/
cp -r WebKitBuild/JSCOnly/Release/JavaScriptCore/Headers/JavaScriptCore $(dirname $0)/jsc_bin/jsc/include/
cp -r WebKitBuild/JSCOnly/Release/JavaScriptCore/PrivateHeaders/JavaScriptCore/* $(dirname $0)/jsc_bin/jsc/include/JavaScriptCore/
cp $(dirname $0)/misc/cmakeconfig.h $(dirname $0)/jsc_bin/jsc/include/JavaScriptCore/cmakeconfig.h
cp WebKitBuild/JSCOnly/Release/cmakeconfig.h $(dirname $0)/jsc_bin/jsc/include/JavaScriptCore/cmakeconfig_linux64.h
cp WebKitBuild/JSCOnly/Release/lib/libJavaScriptCore.so* $(dirname $0)/jsc_bin/jsc/lib/linux64
cd ..
