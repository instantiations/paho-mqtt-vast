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
/*   M O D U L E  P R I V A T E  V A R S   */
/*******************************************/

/**
 * @brief Boolean to check if the module is initialized
 */
static volatile I_32 _State = 0;

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

void EsMqttLibraryInit(EsGlobalInfo *globalInfo) {
    if (p_atomic_int_compare_and_exchange(&_State, ESMQTT_LIBRARY_UNINIT, ESMQTT_LIBRARY_INIT)) {
        p_libsys_init();
        EsMqttAsyncArguments_ModuleInit(globalInfo);
        EsMqttAsyncMessages_ModuleInit(globalInfo);
        EsMqttCallbacks_ModuleInit(globalInfo);
    }
}

void EsMqttLibraryShutdown() {
    if (p_atomic_int_compare_and_exchange(&_State, ESMQTT_LIBRARY_INIT, ESMQTT_LIBRARY_SHUTDOWN)) {
        EsMqttAsyncArguments_ModuleShutdown();
        EsMqttAsyncMessages_ModuleShutdown();
        EsMqttCallbacks_ModuleShutdown();
        p_libsys_shutdown();
    }
}

I_32 EsMqttLibrary_GetState() {
    return _State;
}
