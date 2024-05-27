#pragma once

#if defined(PLATFORM_LINUX)
#include "cmakeconfig_linux64.h"
#elif defined(PLATFORM_WINDOWS)
#include "cmakeconfig_win64.h"
#elif defined(PLATFORM_MAC)
#include "cmakeconfig_mac.h"
#endif
