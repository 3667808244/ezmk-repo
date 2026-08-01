//----------------------------------------------------------------------------------------------------------------------
//
// toml++ v3.4.0
// https://github.com/marzer/tomlplusplus
// SPDX-License-Identifier: MIT
//
//----------------------------------------------------------------------------------------------------------------------
//
// -         THIS FILE WAS ASSEMBLED FROM MULTIPLE HEADER FILES BY A SCRIPT - PLEASE DON'T EDIT IT DIRECTLY            -
//
// If you wish to submit a contribution to toml++, hooray and thanks! Before you crack on, please be aware that this
// file was assembled from a number of smaller files by a python script, and code contributions should not be made
// against it directly. You should instead make your changes in the relevant source file(s). The file names of the files
// that contributed to this header can be found at the beginnings and ends of the corresponding sections of this file.
//
//----------------------------------------------------------------------------------------------------------------------
//
// TOML Language Specifications:
// latest:      https://github.com/toml-lang/toml/blob/master/README.md
// v1.0.0:      https://toml.io/en/v1.0.0
// v0.5.0:      https://toml.io/en/v0.5.0
// changelog:   https://github.com/toml-lang/toml/blob/master/CHANGELOG.md
//
//----------------------------------------------------------------------------------------------------------------------
//
// MIT License
//
// Copyright (c) Mark Gillard <mark.gillard@outlook.com.au>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//----------------------------------------------------------------------------------------------------------------------
#ifndef TOMLPLUSPLUS_HPP
#define TOMLPLUSPLUS_HPP

#define INCLUDE_TOMLPLUSPLUS_H // old guard name used pre-v3
#define TOMLPLUSPLUS_H		   // guard name used in the legacy toml.h

//********  impl/preprocessor.hpp  *************************************************************************************

#ifndef __cplusplus
#error toml++ is a C++ library.
#endif

#ifndef TOML_CPP
#ifdef _MSVC_LANG
#if _MSVC_LANG > __cplusplus
#define TOML_CPP _MSVC_LANG
#endif
#endif
#ifndef TOML_CPP
#define TOML_CPP __cplusplus
#endif
#if TOML_CPP >= 202900L
#undef TOML_CPP
#define TOML_CPP 29
#elif TOML_CPP >= 202600L
#undef TOML_CPP
#define TOML_CPP 26
#elif TOML_CPP >= 202302L
#undef TOML_CPP
#define TOML_CPP 23
#elif TOML_CPP >= 202002L
#undef TOML_CPP
#define TOML_CPP 20
#elif TOML_CPP >= 201703L
#undef TOML_CPP
#define TOML_CPP 17
#elif TOML_CPP >= 201402L
#undef TOML_CPP
#define TOML_CPP 14
#elif TOML_CPP >= 201103L
#undef TOML_CPP
#define TOML_CPP 11
#else
#undef TOML_CPP
#define TOML_CPP 0
#endif
#endif

#if !TOML_CPP
#error toml++ requires C++17 or higher. For a pre-C++11 TOML library see https://github.com/ToruNiina/Boost.toml
#elif TOML_CPP < 17
#error toml++ requires C++17 or higher. For a C++11 TOML library see https://github.com/ToruNiina/toml11
#endif

#ifndef TOML_MAKE_VERSION
#define TOML_MAKE_VERSION(major, minor, patch) (((major)*10000) + ((minor)*100) + ((patch)))
#endif

#ifndef TOML_INTELLISENSE
#ifdef __INTELLISENSE__
#define TOML_INTELLISENSE 1
#else
#define TOML_INTELLISENSE 0
#endif
#endif

#ifndef TOML_DOXYGEN
#if defined(DOXYGEN) || defined(__DOXYGEN) || defined(__DOXYGEN__) || defined(__doxygen__) || defined(__POXY__)        \
	|| defined(__poxy__)
#define TOML_DOXYGEN 1
#else
#define TOML_DOXYGEN 0
#endif
#endif

#ifndef TOML_CLANG
#ifdef __clang__
#define TOML_CLANG __clang_major__
#else
#define TOML_CLANG 0
#endif

// special handling for apple clang; see:
// - https://github.com/marzer/tomlplusplus/issues/189
// - https://en.wikipedia.org/wiki/Xcode
// -
// https://stackoverflow.com/questions/19387043/how-can-i-reliably-detect-the-version-of-clang-at-preprocessing-time
#if TOML_CLANG && defined(__apple_build_version__)
#undef TOML_CLANG
#define TOML_CLANG_VERSION TOML_MAKE_VERSION(__clang_major__, __clang_minor__, __clang_patchlevel__)
#if TOML_CLANG_VERSION >= TOML_MAKE_VERSION(15, 0, 0)
#define TOML_CLANG 16
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(14, 3, 0)
#define TOML_CLANG 15
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(14, 0, 0)
#define TOML_CLANG 14
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(13, 1, 6)
#define TOML_CLANG 13
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(13, 0, 0)
#define TOML_CLANG 12
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(12, 0, 5)
#define TOML_CLANG 11
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(12, 0, 0)
#define TOML_CLANG 10
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(11, 0, 3)
#define TOML_CLANG 9
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(11, 0, 0)
#define TOML_CLANG 8
#elif TOML_CLANG_VERSION >= TOML_MAKE_VERSION(10, 0, 1)
#define TOML_CLANG 7
#else
#define TOML_CLANG 6 // not strictly correct but doesn't matter below this
#endif
#undef TOML_CLANG_VERSION
#endif
#endif

#ifndef TOML_ICC
#ifdef __INTEL_COMPILER
#define TOML_ICC __INTEL_COMPILER
#ifdef __ICL
#define TOML_ICC_CL TOML_ICC
#else
#define TOML_ICC_CL 0
#endif
#else
#define TOML_ICC	0
#define TOML_ICC_CL 0
#endif
#endif

#ifndef TOML_MSVC_LIKE
#ifdef _MSC_VER
#define TOML_MSVC_LIKE _MSC_VER
#else
#define TOML_MSVC_LIKE 0
#endif
#endif

#ifndef TOML_MSVC
#if TOML_MSVC_LIKE && !TOML_CLANG && !TOML_ICC
#define TOML_MSVC TOML_MSVC_LIKE
#else
#define TOML_MSVC 0
#endif
#endif

#ifndef TOML_GCC_LIKE
#ifdef __GNUC__
#define TOML_GCC_LIKE __GNUC__
#else
#define TOML_GCC_LIKE 0
#endif
#endif

#ifndef TOML_GCC
#if TOML_GCC_LIKE && !TOML_CLANG && !TOML_ICC
#define TOML_GCC TOML_GCC_LIKE
#else
#define TOML_GCC 0
#endif
#endif

#ifndef TOML_CUDA
#if defined(__CUDACC__) || defined(__CUDA_ARCH__) || defined(__CUDA_LIBDEVICE__)
#define TOML_CUDA 1
#else
#define TOML_CUDA 0
#endif
#endif

#ifndef TOML_NVCC
#ifdef __NVCOMPILER_MAJOR__
#define TOML_NVCC __NVCOMPILER_MAJOR__
#else
#define TOML_NVCC 0
#endif
#endif

#ifndef TOML_ARCH_ITANIUM
#if defined(__ia64__) || defined(__ia64