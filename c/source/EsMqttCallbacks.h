/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttCallbacks.h
 *  @brief MQTT Paho C MQClient Callbacks Interface for VA Smalltalk
 *  @author Seth Berman
 *
 *  MQTT Paho Callback module.
 *  The purpose of this module is to provide VA Smalltalk with callbacks entry
 *  points that can be used safely in a thread-safely context within MQTT Paho.
 *  VA Smalltalk (via user-prims) will request the addresses of these callbacks
 *  and then pass them off to the MQTT Paho C library via FFI calls.
 *
 *  Why not use VA Smalltalk EsEntryPoints (ST Callbacks)?
 *  VA Smalltalk implements a callback interface into the virtual machine with
 *  an entry point address that can be passed to C functions.  Why not just use that?
 *  The reason is due to the fact that MQTT Paho C runs the callbacks in separate threads
 *  and EsEntryPoints can only be activated by the main smalltalk interpreter thread which
 *  is done at special safe-points. Not doing so will simply crash the virtual machine
 *  since it will corrupt the smalltalk execution machinery that's in progress.
 *
 *  How do you re-enter the virtual machine safely from these C callback functions?
 *  The logic for what to do when callbacks are received lives in Smalltalk code.
 *  The job of this C module is to have the callback route through here first and then into
 *  the Smalltalk vm. But this module still has the callback activated in a separate
 *  thread so the same problem exists as with EsEntryPoints.
 *
 *  The answer to fix this is the Smalltalk Asynchronous Queue
 *  @see EsMqttAsyncQueueMessages.h for a discussion on how this works
 *******************************************************************************/
#ifndef ES_MQTT_CALLBACKS_H
#define ES_MQTT_CALLBACKS_H

/*****************/
/*   E N U M S   */
/*****************/

/**
 * @enum EsMqttVastCallbackTypes
 * @brief MQTT Callback types from MQClient.h
 * @note This is mirrored in the Smalltalk image
 * via pool dictionary and any changes here should
 * must also be reflected in smalltalk
 */
#define MIN_MQTT_CALLBACKS          0
#define NUM_MQTT_CALLBACKS          7
enum EsMqttVastCallbackTypes {
    ESMQTT_CB_TYPE_TRACE = MIN_MQTT_CALLBACKS,
    ESMQTT_CB_TYPE_CONNECTIONLOST,
    ESMQTT_CB_TYPE_DISCONNECTED,
    ESMQTT_CB_TYPE_MESSAGEARRIVED,
    ESMQTT_CB_TYPE_DELIVERYCOMPLETE,
    ESMQTT_CB_TYPE_PUBLISHED,
    ESMQTT_CB_TYPE_CHECKPOINT
};

/***********************************/
/*   S E T U P / S H U T D O W N   */
/***********************************/

/**
 * @brief Initialize the Callback module
 * @param globalInfo
 */
void EsMqttCallbacksInit(EsGlobalInfo *globalInfo);

/**
 * @brief Shutdown the User-Prim module
 */
void EsMqttCallbacksShutdown();

/*************************/
/*   C A L L B A C K S   */
/*************************/

/**
 * Test if the supplied callback type value is valid
 * @param cbType EsMqttVastCallbackTypes
 * @return TRUE if valid, FALSE otherwise
 */
ES_STATIC_INLINE BOOLEAN EsIsValidCallbackType(enum EsMqttVastCallbackTypes cbType) {
    return (cbType >= MIN_MQTT_CALLBACKS && cbType < NUM_MQTT_CALLBACKS) ? TRUE : FALSE;
}

/**
 * @brief Answers callback address
 * @param cbType EsMqttVastCallbackTypes
 * @param target[out] contains callback address or NULL
 * @return TRUE if successful get, FALSE otherwise
 */
BOOLEAN EsGetCallbackTarget(enum EsMqttVastCallbackTypes cbType, void **target);

/**
 * @brief Register the receiver>>selector as async msg target for callback
 * @param cbType EsMqttVastCallbackTypes
 * @param receiver EsObject smalltalk class
 * @param selector EsObject smalltalk symbol
 * @return address to callback function or NULL if none
 * @note Thread-safe.
 */
void *EsRegisterCallback(enum EsMqttVastCallbackTypes cbType, EsObject receiver, EsObject selector);


#endif //ES_MQTT_CALLBACKS_H
