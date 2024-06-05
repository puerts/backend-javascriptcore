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
#perl Tools/Scripts/build-webkit --jsc-only --cmakeargs="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++" --verbose
perl Tools/Scripts/build-jsc --jsc-only
mkdir -p $WORKSPACE/jsc_bin/jsc/include
mkdir -p $WORKSPACE/jsc_bin/jsc/lib/linux64
cp -r Source/bmalloc/bmalloc $WORKSPACE/jsc_bin/jsc/include/
cp -r Source/WTF/wtf $WORKSPACE/jsc_bin/jsc/include/
cp -r Source/WTF/icu/unicode $WORKSPACE/jsc_bin/jsc/include/
cp -r Source/JavaScriptCore/config.h $WORKSPACE/jsc_bin/jsc/include/
cp -r WebKitBuild/JSCOnly/Release/JavaScriptCore/Headers/JavaScriptCore $WORKSPACE/jsc_bin/jsc/include/
cp -r WebKitBuild/JSCOnly/Release/JavaScriptCore/PrivateHeaders/JavaScriptCore/* $WORKSPACE/jsc_bin/jsc/include/JavaScriptCore/
cp $WORKSPACE/misc/cmakeconfig.h $WORKSPACE/jsc_bin/jsc/include/JavaScriptCore/cmakeconfig.h
cp WebKitBuild/JSCOnly/Release/cmakeconfig.h $WORKSPACE/jsc_bin/jsc/include/JavaScriptCore/cmakeconfig_linux64.h
cp WebKitBuild/JSCOnly/Release/lib/libJavaScriptCore.so* $WORKSPACE/jsc_bin/jsc/lib/linux64
cd ..
