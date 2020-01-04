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
 *  to perform their runtime setup and teardown procedures.
 *******************************************************************************/
#ifndef ES_MQTT_LIBRARY_H
#define ES_MQTT_LIBRARY_H

#include "EsMqtt.h"

/*************************/
/*   C O N S T A N T S   */
/*************************/

/**
 * @brief Library States
 *
 * The module state lifecycle is
 * UNITIT -> INIT -> SHUTDOWN
 */
static const I_32 ESMQTT_LIBRARY_UNINIT	= 0;
static const I_32 ESMQTT_LIBRARY_INIT =	1;
static const I_32 ESMQTT_LIBRARY_SHUTDOWN = 2;


/***********************************/
/*   S E T U P / S H U T D O W N   */
/***********************************/

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
 * @see Library State Constants above
 * @return Library State
 */
I_32 EsMqttLibrary_GetState();

#endif //ES_MQTT_LIBRARY_H
