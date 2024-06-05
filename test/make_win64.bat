cmake -H. -B build_win -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -G "Visual Studio 16 2019" -A x64
cmake --build build_win --config Release

