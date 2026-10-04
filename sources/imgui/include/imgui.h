// EazyMake compatibility shim: the core headers live under include/imgui/.
// Backends use #include "imgui.h" and dependents only inherit the package's
// include/ root, so expose the core header at the root as well.
#pragma once
#include "imgui/imgui.h"
