mkdir -p build_osx && cd build_osx
cmake -GXcode -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ../
cd ..
cmake --build build_osx --config Release
