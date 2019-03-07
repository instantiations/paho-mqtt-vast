/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttLibrary.h
 *  @brief MQTT Paho Vast Connector Library Initializer and State Interface
 *  @author Seth Berman
 *
 *  Library setup and teardown which will delegate to the various modules
 *  to perform their setup and teardown procedures that require runtime
 *  information.
 *******************************************************************************/
#ifndef ES_MQTT_LIBRARY_H
#define ES_MQTT_LIBRARY_H

#include "esuser.h"

/**
 * @enum EsMqttLibraryState
 * @brief Library States
 *
 */
enum EsMqttLibraryState {
    ESMQTT_LIBRARY_UNINIT = 0,
    ESMQTT_LIBRARY_INIT,
    ESMQTT_LIBRARY_SHUTDOWN
};

/******************************************/
/*      S E T U P / S H U T D O W N       */
/******************************************/

/**
 * @brief Initialize the library modules, if necessary
 * @param EsGlobalInfo
 * @note No-Op if already init, can call multiple times
 * @note Thread-Safe
 */
void EsMqttLibraryInit(EsGlobalInfo *globalInfo);

/**
 * @brief Destruct and clear library module state
 * @note Thread-Safe
 */
void EsMqttLibraryShutdown();

/**
 * @brief Answer the current state of the library
 * @return EsMqttLibraryState
 */
enum EsMqttLibraryState EsMqttGetLibraryState();

#endif //ES_MQTT_LIBRARY_H