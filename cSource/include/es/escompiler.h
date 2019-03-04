/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file escompiler.h
 *  @brief Low-level compiler/bits/types related features
 *  @author Seth Berman
 *******************************************************************************/
#ifndef ESCOMPILER_H
#define ESCOMPILER_H

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

/**********************/
/*	B I T N E S S	  */
/**********************/
#ifdef _MSC_VER
#  if defined(_M_X64) || defined(_M_AMD64)
#	 define ES_ARCH64
#  endif
#elif defined(__GNUC__)
#  if defined(__x86_64__) || defined(__sparcv9) || \
      defined(__64BIT__) || defined(__LP64__)
#	 define ES_ARCH64
#  endif
#elif defined(__SUNPRO_C) || defined(__SUNPRO_CC) /* Sun Studio C/C++ */
#  if defined(__x86_64) || defined(__sparcv9)
#	 define ES_ARCH64
#  endif
#elif defined(__xlc__) || defined(__xlC__)          /* IBM XL C/C++ */
#  if defined(__64BIT__)
#	 define ES_ARCH64
#  endif
#else
#  error "Unsupported Platform"
#endif /* 32/64 bitness */

/**************************************/
/*	B R A N C H	 P R E D I C T I O N  */
/**************************************/
#if (defined(_MSC_VER) && !defined(__clang__))
#	define ES_LIKELY(x) (x)
#	define ES_UNLIKELY(x) (x)
#elif (defined(__GNUC__) || defined(__clang__))
#	define ES_LIKELY(x)     __builtin_expect (!!(x), 1)
#	define ES_UNLIKELY(x) __builtin_expect (!!(x), 0)
#else
#	define ES_LIKELY(x)
#	define ES_UNLIKELY(x)
#endif /* Branch Prediction */

/**************************/
/*	D A T A	 T Y P E S	  */
/**************************/
typedef int8_t I_8;
typedef uint8_t U_8;
typedef int16_t I_16;
typedef uint16_t U_16;
typedef int32_t I_32;
typedef uint32_t U_32;
typedef int64_t I_64;
typedef uint64_t U_64;
typedef int32_t I_LONG;
typedef uint32_t U_LONG;
typedef size_t U_SIZE;
typedef double SYS_FLOAT;
typedef long double FLOAT_EXTENDED;
typedef uintptr_t U_PTR;
typedef intptr_t I_PTR;
typedef ptrdiff_t I_PTRDIFF;
typedef I_PTR S_INT;

#if defined(WIN32)
/* Don't typedef BOOLEAN since it's already defined on Windows */
#ifndef BOOLEAN
#define BOOLEAN   U_32
#endif

#else
typedef uint32_t  BOOLEAN;
#endif

#ifndef FALSE
#define FALSE     ((BOOLEAN) 0)
#endif /* FALSE */

#ifndef TRUE
#define TRUE      ((BOOLEAN) (!FALSE))
#endif /* TRUE */

#ifndef NULL
#define NULL      ((void *)0)
#endif /* NULL */

#define BASETYPES

/**************************/
/*   A T T R I B U T E S  */
/**************************/
#ifdef _MSC_VER
#	define ES_INLINE __inline
#	define ES_EXTERN_INLINE ES_INLINE
#	define ES_STATIC_INLINE static ES_INLINE

#	define DLLEXPORT
#	define DLLIMPORT
#elif defined(__GNUC__)
#	define ES_INLINE inline
#	define ES_EXTERN_INLINE extern ES_INLINE
#	define ES_STATIC_INLINE static ES_INLINE
#	if defined(__MINGW__)
#		define DLLEXPORT __declspec(dllexport)
#		define DLLIMPORT
#	else
#		define DLLEXPORT __attribute__((visibility("default")))
#		define DLLIMPORT
#	endif
#else
#	error "Unsupported Compiler"
#endif

#ifdef _MSC_VER
#   define ES_CONSTRUCTOR(func) void func(void)
#   define ES_DESTRUCTOR(func) void func(void)
#elif defined(__GNUC__)
#   define ES_CONSTRUCTOR(func) __attribute__((constructor))  void func(void)
#   define ES_DESTRUCTOR(func) __attribute__((destructor))  void func(void)
#else
#	error "Unsupported Compiler"
#endif

#ifdef WIN32
#   define VMCALL            __cdecl
#else
#   define VMCALL
#endif

#ifdef __MINGW32__
#   define DLLFUNCTION        __declspec(dllexport) I32 VMAPICALL
#else
#   define DLLFUNCTION        DLLEXPORT I32 VMAPICALL
#endif

#define ES_UNUSED(x)    ((void)(x))

#endif /* ESUSER_H */
