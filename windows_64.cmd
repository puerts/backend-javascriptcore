git clone https://github.com/WebKit/webkit.git
git checkout 8715d40f1d7038e9f43619d153210883228d17a6
cd webkit
echo =====[ apply patch ]=====
node %WORKSPACE%\node-script\do-gitpatch.js -p %WORKSPACE%\patchs\webkit_vc_compile_for_8715d40f1d7038e9f43619d153210883228d17a6.patch
echo =====[ apply patch ]=====
perl Tools\Scripts\build-webkit --jsc-only --verbose
