#ifndef HELLO_LIB_H
#define HELLO_LIB_H

#include <string>

namespace hello {

/// Return a greeting message.
std::string greet();

/// Return a greeting with a custom name.
std::string greet(const std::string& name);

} // namespace hello

#endif // HELLO_LIB_H
