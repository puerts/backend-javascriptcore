cmake_minimum_required(VERSION 3.23)

project(JavaScriptCoreTest)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(
  ${CMAKE_SOURCE_DIR}/deps/jsc/include
)

if ( WIN32 )
    list(APPEND PUERTS_COMPILE_DEFINITIONS PLATFORM_WINDOWS)
    # Compiler options
    add_compile_definitions(
      BUILDING_WITH_CMAKE=1
      HAVE_CONFIG_H=1
      NOCRYPT
      NOMINMAX
      NTDDI_VERSION=0x0A000006
      PAS_BMALLOC=1
      UNICODE
      _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES=1
      _CRT_SECURE_NO_WARNINGS
      _ENABLE_EXTENDED_ALIGNED_STORAGE
      _HAS_EXCEPTIONS=0
      _UNICODE
      _WIN32_WINNT=0x0A00
      _WINDOWS
      _WINSOCKAPI_=""
    )

    add_compile_options(
      /W4 /DWIN32 /D_WINDOWS /GR- /EHs- /EHc-  /O2 /Ob2 /DNDEBUG -MD 
      /wd4018 /wd4060 /wd4068 /wd4100 /wd4127 /wd4146 /wd4189 /wd4201 
      /wd4244 /wd4245 /wd4251 /wd4275 /wd4267 /wd4305 /wd4309 /wd4312
      /wd4324 /wd4389 /wd4456 /wd4457 /wd4458 /wd4459 /wd4505 /wd4611
      /wd4646 /wd4701 /wd4702 /wd4706 /wd4715 /wd4722 /wd4723 /wd4805
      /wd4838 /wd4840 /wd4996 /wd5205 /wd5054 /wd5055 /Zi /GS /EHa- 
      /EHc- /EHs- /fp:except- /analyze- /bigobj /utf-8 /validate-charset
      /Oy- /Zc:lambda /WX
    )
    
    link_directories(${CMAKE_SOURCE_DIR}/deps/jsc/lib/win64)
    set(LIBS JavaScriptCore WTF)
    
elseif ( ANDROID )
    list(APPEND PUERTS_COMPILE_DEFINITIONS PLATFORM_ANDROID)
elseif ( APPLE )
    if ( IOS )
        list(APPEND PUERTS_COMPILE_DEFINITIONS PLATFORM_IOS)
    else ()
       set(CMAKE_CXX_EXTENSIONS OFF)
       add_compile_definitions( 
           BUILDING_JSCONLY__
           BUILDING_WITH_CMAKE=1
           BUILDING_jsc
           HAVE_CONFIG_H=1
           PAS_BMALLOC=1
           U_DISABLE_RENAMING=1
       )
       add_compile_options(
         -fdiagnostics-color=always
         -fcolor-diagnostics
         -Wextra
         -Wall
         -pipe
         -Wno-noexcept-type
         -Wno-psabi
         -Wno-misleading-indentation
         -Wno-parentheses-equality
         -Wno-shorten-64-to-32
         -Wno-macro-redefined
         -Qunused-arguments
         -Wundef
         -Wpointer-arith
         -Wmissing-format-attribute
         -Wformat-security
         -Wcast-align
         -Wno-tautological-compare
         -fno-strict-aliasing
         -fno-exceptions
         -fno-rtti
         -O3
         -DNDEBUG
         -mmacosx-version-min=14.4
         -fPIE
         -fvisibility=hidden
         -fvisibility-inlines-hidden
         -Werror
        )

        #link_directories(${CMAKE_SOURCE_DIR}/deps/jsc/lib/osx)
        #set(LIBS "JavaScriptCore.framework")
        #find_library(LIBS JavaScriptCore PATHS ${CMAKE_SOURCE_DIR}/deps/jsc/lib/osx/JavaScriptCore.framework)
        set(LIBS "${CMAKE_SOURCE_DIR}/deps/jsc/lib/osx/JavaScriptCore.framework/JavaScriptCore")
        message("LIBS = ${LIBS}")
        
        list(APPEND PUERTS_COMPILE_DEFINITIONS PLATFORM_MAC)
    endif ()
elseif (UNIX)
    list(APPEND PUERTS_COMPILE_DEFINITIONS PLATFORM_LINUX)
    add_definitions(-DBUILDING_JSCONLY__ 
      -DBUILDING_WEBKIT=1
      -DBUILDING_WITH_CMAKE=1
      -DBUILDING_jsc
      -DHAVE_CONFIG_H=1
      -DPAS_BMALLOC=1
    )

    add_compile_options(-fdiagnostics-color=always -Wextra -Wall -pipe -fmax-errors=20
      -Wno-odr -Wno-stringop-overread -Wno-stringop-overflow -Wno-nonnull -Wno-array-bounds
      -Wno-expansion-to-defined -Wno-noexcept-type -Wno-uninitialized -Wno-mismatched-new-delete
      -Wno-psabi -Wno-misleading-indentation -Wno-maybe-uninitialized -Wundef -Wpointer-arith
      -Wmissing-format-attribute -Wformat-security -Wcast-align -Wno-tautological-compare
      -fno-strict-aliasing -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections -O3
      -DNDEBUG -fPIE -fvisibility=hidden -fvisibility-inlines-hidden -Werror
    )
    
    link_directories(${CMAKE_SOURCE_DIR}/deps/jsc/lib/linux64)
    set(LIBS JavaScriptCore)
endif ()

set(SOURCE_FILES
  src/perf.cpp
)

add_executable(perf ${SOURCE_FILES})

target_compile_definitions (perf PRIVATE ${PUERTS_COMPILE_DEFINITIONS})

target_link_libraries(perf PRIVATE ${LIBS})

if ( WIN32 )
    add_custom_command(TARGET perf POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E copy_if_different  
            "${PROJECT_SOURCE_DIR}/deps/jsc/lib/win64/JavaScriptCore.dll" 
            "${PROJECT_SOURCE_DIR}/deps/jsc/lib/win64/WTF.dll" 
            "${PROJECT_SOURCE_DIR}/deps/jsc/lib/win64/icuin75.dll" 
            "${PROJECT_SOURCE_DIR}/deps/jsc/lib/win64/icuuc75.dll" 
            "${PROJECT_SOURCE_DIR}/deps/jsc/lib/win64/icudt75.dll" 
            $<TARGET_FILE_DIR:perf>)
endif ()

# Linker flags
#target_link_options(perf PRIVATE
#  /machine:x64
#  /DEBUG
#  /OPT:NOICF
#  /OPT:REF
#  /INCREMENTAL:NO
#  /subsystem:console
#  "/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='amd64' publicKeyToken='6595b64144ccf1df' language='*'"
#)
