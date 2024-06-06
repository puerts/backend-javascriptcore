mkdir -p build_linux64 && cd build_linux64
cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DCMAKE_BUILD_TYPE=Debug ../
cd ..
cmake --build build_linux64 --config Debug
