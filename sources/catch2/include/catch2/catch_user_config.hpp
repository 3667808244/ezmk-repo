//              Copyright Catch2 Authors
// Distributed under the Boost Software License, Version 1.0.
//   (See accompanying file LICENSE.txt or copy at
//        https://www.boost.org/LICENSE_1_0.txt)

// SPDX-License-Identifier: BSL-1.0

/**\file
 * Materialized compile-time configuration for EazyMake (non-CMake build).
 * All options use Catch2 defaults. If you need to customize behaviour,
 * edit this file to #define the relevant CATCH_CONFIG_* macros.
 */

#ifndef CATCH_USER_CONFIG_HPP_INCLUDED
#define CATCH_USER_CONFIG_HPP_INCLUDED

// Use Catch2 defaults for all options — nothing forced ON or OFF.

#define CATCH_CONFIG_DEFAULT_REPORTER "console"
#define CATCH_CONFIG_CONSOLE_WIDTH 80

#endif // CATCH_USER_CONFIG_HPP_INCLUDED
