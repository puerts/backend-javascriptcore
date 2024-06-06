mkdir -p build_linux64 && cd build_linux64
cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ../
cd ..
cmake --build build_linux64 --config Release
