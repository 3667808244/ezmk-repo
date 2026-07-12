#include "hello.h"

namespace hello {

std::string greet() {
    return "Hello from EazyMake!";
}

std::string greet(const std::string& name) {
    return "Hello, " + name + "!";
}

} // namespace hello
