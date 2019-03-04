/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttLibrary.c
 *  @brief MQTT Paho Vast Connector Library Initializer and State Implementation
 *  @author Seth Berman
 *******************************************************************************/
#include "plibsys.h"

#include "EsMqttLibrary.h"
#include "EsMqttUserPrims.h"
#include "EsMqttCallbacks.h"
#include "EsMqttAsyncMessages.h"
#include "EsMqttAsyncArguments.h"

/*******************************************/
/*  M O D U L E  P R I V A T E  V A R S    */
/*******************************************/

/**
 * @brief Boolean to check if the module is initialized
 */
static volatile I_32 _IsInitialized = 0;

/*************************************************************/
/*      I N T E R F A C E  I M P L E M E N T A T I O N       */
/*************************************************************/

void EsMqttLibraryInit(EsGlobalInfo *globalInfo) {
    if (!_IsInitialized) {
        p_libsys_init();
        EsMqttAsyncArgumentsInit(globalInfo);
        EsMqttAsyncMessagesInit(globalInfo);
        EsMqttCallbacksInit(globalInfo);
        EsMqttUserPrimsInit(globalInfo);
        _IsInitialized = 1;
    }
}

void EsMqttLibraryShutdown() {
    if (_IsInitialized) {
        EsMqttUserPrimsShutdown();
        EsMqttCallbacksShutdown();
        EsMqttAsyncMessagesShutdown();
        EsMqttAsyncArgumentsShutdown();
        p_libsys_shutdown();
        _IsInitialized = 0;
    }
}