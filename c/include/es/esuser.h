/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file esuser.h
 *  @brief Subset and abstracted version of VA Smalltalk's virtual machine interface
 *  @author Seth Berman
 *
 *  The header file offers various pieces from the original esuser.h distributed
 *  with VA Smalltalk. However, many pieces are omitted and some are just
 *  abstractions with various levels of opaqueness.
 *  The main purpose of this file is to provide the necessary parts to properly
 *  implement VA Smalltalk User Primitives.
 *******************************************************************************/
#ifndef ESUSER_H
#define ESUSER_H

#include "escompiler.h"

/********************************************/
/*  S M A L L T A L K  I M M E D I A T E S  */
/********************************************/
#define EsTrue                          ((EsObject) 0x1E)
#define EsFalse                         ((EsObject) 0x2E)
#define EsNil                           ((EsObject) 0x0E)
#define EsIsNil(o)                      ((o) == EsNil)
#define EsLowBit(o)                     (((U_PTR) (o)) & 1u)
#define EsTagSmallInteger               1u
#define EsShiftSmallInteger             1u
#define EsPrivateToSmallInteger(o)      (((o) << (U_32)EsShiftSmallInteger) | EsTagSmallInteger)
#define EsPrivateToEsObject(o)          ((EsObject)(U_PTR)(S_INT)(o))
#define EsI32ToSmallInteger(val)        (EsPrivateToEsObject(EsPrivateToSmallInteger((U_32)(S_INT)(val))))
#define EsIsSmallInteger(o)             (EsLowBit(o) == (U_PTR)EsTagSmallInteger)
#define EsPrivateSmallIntegerAsI32(o)   ((I_32)(U_PTR)(o))
#define EsPrivateSmallIntegerAsU32(o)   ((U_32)EsPrivateSmallIntegerAsI32(o))
#define EsSmallIntegerToI32(o)          ((I_32)(EsPrivateSmallIntegerAsU32(o) >> EsShiftSmallInteger))

/**********************************/
/*  S M A L L T A L K  T Y P E S  */
/**********************************/
typedef void *EsObject;

typedef struct ESVMContext {
    void *pad1[10];
    EsObject *sp;
    void *pad2[5];
    U_32 errorCode;
    U_32 argNumber;
    U_32 pad3;
    void *pad4[6];
    U_32 pad5;
    void *globalInfo;
} ESVMContext;

typedef struct ESGlobalInfo {
    U_32 pad1;
    void *pad2[3];
    U_32 pad3[2];
    U_PTR currentVMContext;
} ESGlobalInfo;

typedef ESVMContext *EsVMContext;
typedef ESGlobalInfo EsGlobalInfo;

/**********************************/
/*  U S E R  P R I M I T I V E S  */
/*********************************/
#define EsDeclareUserPrimitive(name) \
BOOLEAN VMCALL name (EsVMContext EsPrimVMContext, U_32 EsPrimArgumentCount, U_32 EsPrimPushCount);

#define EsUserPrimitive(name) \
extern BOOLEAN VMCALL name (EsVMContext EsPrimVMContext, U_32 EsPrimArgumentCount, U_32 EsPrimPushCount); \
BOOLEAN VMCALL name (EsVMContext EsPrimVMContext, U_32 EsPrimArgumentCount, U_32 EsPrimPushCount)

#define EsPrimArgNumSelf                0
#define EsPrimArgNumNoArg               (-1)
#define EsPrimErrNoError                0
#define EsPrimErrInvalidClass           1
#define EsPrimErrInvalidArgumentCount   17
#define EsPrimArgument(n)               (EsPrimVMContext->sp[EsPrimPushCount-(n)])
#define EsPrimReceiver                  EsPrimArgument(EsPrimArgNumSelf)

#define EsPrimFail(err, arg) \
    return((EsPrimVMContext->errorCode = (U_32) (err)), \
        (EsPrimVMContext->argNumber = (U_32) (arg)), \
        (U_32)FALSE)

#define EsPrimSucceed(val)    return((EsPrimReceiver = (val)), (U_32)TRUE)
#define EsPrimSucceedBoolean(expr)    EsPrimSucceed((expr) ? EsTrue : EsFalse)

/******************/
/* E X T E R N S  */
/******************/
extern void *VMCALL EsAllocateMemory(U_SIZE byteAmount);

extern void VMCALL EsFreeMemory(void * memoryPointer);

extern BOOLEAN VMCALL EsPostAsyncMessage(EsVMContext, EsObject, EsObject, U_32, ...);

extern U_32 VMCALL EsMakeUnsignedInteger(U_32, EsObject *, EsVMContext);

extern U_32 VMCALL EsMakeUnsignedInt64(U_64, EsObject *, EsVMContext);

extern U_32 VMCALL EsMakeString(char *, EsObject *, EsVMContext);

#ifndef ES_ARCH64
#define EsMakePointerInteger EsMakeUnsignedInteger
#else
#define EsMakePointerInteger EsMakeUnsignedInt64
#endif // ES_ARCH64

#define EsCStringToString(val, o) EsMakeString((val), (o), EsPrimVMContext)

#endif /* ESUSER_H */
