/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttUserPrims.c
 *  @brief VA Smalltalk virtual machine user-primitives for MQTT Paho Impl
 *  @author Seth Berman
 *******************************************************************************/
#include "plibsys.h"
#include "esuser.h"

#include "EsMqttUserPrims.h"
#include "EsMqttCallbacks.h"
#include "EsMqttLibrary.h"
#include "EsMqttAsyncMessages.h"
#include "EsMqttVersionInfo.h"

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

void EsMqttUserPrims_ModuleInit(EsGlobalInfo *globalInfo) {
    ES_UNUSED(globalInfo);
}

void EsMqttUserPrims_ModuleShutdown() {
    // NO-OP
}

EsUserPrimitive(MqttVastRegisterCallback) {
    I_32 cbType;
    void *funcAddr;
    EsObject cbReceiver, cbSelector, cbAddress;

    EsMqttLibraryInit(EsPrimVMContext->globalInfo);

    // ArgCount-check: 3 args
    // callbackType (I_32), receiver (EsObject), selector (EsObject)
    if (EsPrimArgumentCount != 3) {
        EsPrimFail(EsPrimErrInvalidArgumentCount, EsPrimArgNumNoArg);
    }

    // Type-check: Arg 1 must be SmallInteger
    if (ES_UNLIKELY(!EsIsSmallInteger(EsPrimArgument(1)))) {
        EsPrimFail(EsPrimErrInvalidClass, 1);
    }

    cbType = EsSmallIntegerToI32(EsPrimArgument(1));
    cbReceiver = EsPrimArgument(2);
    cbSelector = EsPrimArgument(3);

    funcAddr = EsMqttCallbacks_Register(cbType, cbReceiver, cbSelector);
    if (ES_LIKELY(funcAddr != NULL)) {
        EsMakePointerInteger((U_PTR) funcAddr, &cbAddress, EsPrimVMContext);
    } else {
        cbAddress = EsNil;
    }

    EsPrimSucceed(cbAddress);
}

EsUserPrimitive(MqttVastCheckpoint) {
    I_32 id;
    BOOLEAN rc;
    EsMqttAsyncMessage *msg;

    EsMqttLibraryInit(EsPrimVMContext->globalInfo);

    // ArgCount-check: 1 args
    // id (I_32)
    if (EsPrimArgumentCount != 1) {
        EsPrimFail(EsPrimErrInvalidArgumentCount, EsPrimArgNumNoArg);
    }

    // Type-check: Arg 1 must be SmallInteger
    if (ES_UNLIKELY(!EsIsSmallInteger(EsPrimArgument(1)))) {
        EsPrimFail(EsPrimErrInvalidClass, 1);
    }

    id = EsSmallIntegerToI32(EsPrimArgument(1));
    msg = EsMqttAsyncMessage_newInit(ESMQTT_CB_TYPE_CHECKPOINT, 1, id);
    rc = EsMqttAsyncMessage_post(msg);

    EsPrimSucceedBoolean(rc);
}

EsUserPrimitive(MqttVastVersionString) {
    EsObject string;
    U_32 rc;

    rc = EsCStringToString(ES_MQTT_VERSION_STR, &string);
    if (ES_UNLIKELY(rc != EsPrimErrNoError)) {
        EsPrimFail(rc, 0);
    }
    EsPrimSucceed(string);
}
