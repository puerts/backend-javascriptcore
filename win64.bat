call npm i
if not exist webkit (
    git config --system core.longpaths true
    git clone https://github.com/WebKit/webkit.git
    cd webkit
    git reset --hard 8715d40f1d70
    echo =====[ apply patch ]=====
    node %~dp0node-script\do-gitpatch.js -p %~dp0patchs\webkit_vc_compile_for_8715d40f1d7038e9f43619d153210883228d17a6.patch
    cd ..
)
echo =====[ build jsc ]=====
cd webkit
perl Tools\Scripts\build-jsc
if not exist %~dp0jsc_bin\jsc\include\JavaScriptCore mkdir %~dp0jsc_bin\jsc\include\JavaScriptCore
if not exist %~dp0jsc_bin\jsc\lib\win64 mkdir %~dp0jsc_bin\jsc\lib\win64
copy WebKitBuild\Release\cmakeconfig.h %~dp0jsc_bin\jsc\include\JavaScriptCore\cmakeconfig_win64.h
copy WebKitBuild\Release\lib64\* %~dp0jsc_bin\jsc\lib\win64\
copy WebKitLibraries\win\bin64\icudt75* %~dp0jsc_bin\jsc\lib\win64\
copy WebKitLibraries\win\bin64\icuin75* %~dp0jsc_bin\jsc\lib\win64\
copy WebKitLibraries\win\bin64\icuuc75* %~dp0jsc_bin\jsc\lib\win64\
copy WebKitBuild\Release\bin64\JavaScriptCore* %~dp0jsc_bin\jsc\lib\win64\
copy WebKitBuild\Release\bin64\WTF* %~dp0jsc_bin\jsc\lib\win64\
cd ..
