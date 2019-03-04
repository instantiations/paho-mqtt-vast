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
 *
 *  These must be called from VA Smalltalk virtual machine safe-points such
 *  as user-primitives.
 *******************************************************************************/
#ifndef ES_MQTT_LIBRARY_H
#define ES_MQTT_LIBRARY_H

#include "esuser.h"

/******************************************/
/*      S E T U P / S H U T D O W N       */
/******************************************/

/**
 * @brief Initialize the library modules, if necessary
 * @param EsGlobalInfo
 * @note No-Op if already init, can call multiple times
 */
void EsMqttLibraryInit(EsGlobalInfo *globalInfo);

/**
 * @brief Destruct and clear library module state
 */
void EsMqttLibraryShutdown();

#endif //ES_MQTT_LIBRARY_H