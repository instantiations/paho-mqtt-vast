/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttCallbacks.c
 *  @brief MQTT Paho C MQClient Callbacks Implementation for VA Smalltalk
 *  @author Seth Berman
 *******************************************************************************/

#include "plibsys.h"
#include "MQTTClient.h"
#include "esuser.h"

#include "EsMqttCallbacks.h"
#include "EsMqttAsyncMessages.h"

#include <string.h>
#include <stdlib.h>

/***************************/
/*   P R O T O T Y P E S   */
/***************************/

/**
 * @brief MQTT Paho MQTTClient.h callback to capture trace info
 * @see MQTTClient_traceCallback
 * @param level
 * @param message
 */
static void traceCallback(I_32 level, char *message);

/**
 * MQTT Paho MQTTClient.h callback when loss of conn from server
 * @see MQTTClient_setCallbacks
 * @param context
 * @param cause
 */
static void connectionLostCallback(void *context, char *cause);

/**
 * @brief MQTT Paho MQTTClient.h callback when disconnect packet from server is received
 * @see MQTTClient_setDisconnected
 * @param context
 * @param properties
 * @param reasonCode
 */
static void disconnectedCallback(void *context, MQTTProperties *properties, enum MQTTReasonCodes reasonCode);

/**
 * @brief MQTT Paho MQTTClient.h callback when new msg that matches client subscription is received by server
 * @see MQTTClient_setCallbacks
 * @param context
 * @param topicName
 * @param topicLen
 * @param message
 * @return 1 for successful deliver, 0 otherwise
 */
static I_32 messageArrivedCallback(void *context, char *topicName, I_32 topicLen, MQTTClient_message *message);

/**
 * @brief MQTT Paho MQTTClient.h callback called by client after has published a message to server.
 * @see MQTTClient_setCallbacks
 * @param context
 * @param token
 */
static void deliveryCompleteCallback(void *context, MQTTClient_deliveryToken token);

/**
 * @brief MQTT Paho MQTTClient.h callback called by v5 client after has published a message to server.
 * @note MQTT V5 ONLY
 * @see MQTTClient_setPublished
 * @param context
 * @param dt
 * @param packet_type
 * @param properties
 * @param reasonCode
 */
static void publishedCallback(void *context, I_32 dt, I_32 packet_type, MQTTProperties *properties,
                              enum MQTTReasonCodes reasonCode);

/**
 * @brief Dummy method whose address is used as the result
 * for user prim MqttVastRegisterCallback
 * @param id
 */
static void dummyCheckpointCallback(I_32 id);

/**
 * @brief Associative Array of callback functions
 *
 * The index is the MqttVastCallbackTypes and value
 * is the callback function associated with the cbType
 */
static void *_CallbackTargets[NUM_MQTT_CALLBACKS] = {
        traceCallback,
        connectionLostCallback,
        disconnectedCallback,
        messageArrivedCallback,
        deliveryCompleteCallback,
        publishedCallback,
        dummyCheckpointCallback
};

/*********************/
/*   U T I L I T Y   */
/*********************/

/**
 * @brief Get the callback function address (target) for callback type
 *
 * @param cbType
 * @param target[output] set to NULL if fails
 * @return TRUE if success, FALSE otherwise
 */
static BOOLEAN getCallbackTarget(enum MqttVastCallbackTypes cbType, void **target) {
    if (target == NULL) {
        return FALSE;
    } else if (EsIsValidCallbackType(cbType)) {
        *target = _CallbackTargets[cbType];
        return TRUE;
    } else {
        *target = NULL;
        return FALSE;
    }
}

/*************************/
/*   C A L L B A C K S   */
/*************************/

static void traceCallback(I_32 level, char *message) {
    EsMqttAsyncMessage *msg = EsNewAsyncMessage(MQTTVAST_CALLBACK_TYPE_TRACE, 2, level, message);
    if (msg != NULL) {
        EsPostMessageToAsyncQueue(msg);
    }
}

static void connectionLostCallback(void *context, char *cause) {
    EsMqttAsyncMessage *msg = EsNewAsyncMessage(MQTTVAST_CALLBACK_TYPE_CONNECTIONLOST, 2, context, cause);
    if (msg != NULL) {
        EsPostMessageToAsyncQueue(msg);
    }
}

static void disconnectedCallback(void *context, MQTTProperties *properties, enum MQTTReasonCodes reasonCode) {
    EsMqttAsyncMessage *msg = EsNewAsyncMessage(MQTTVAST_CALLBACK_TYPE_DISCONNECTED, 3, context, context, properties,
                                                reasonCode);
    if (msg != NULL) {
        EsPostMessageToAsyncQueue(msg);
    }
}

static I_32 messageArrivedCallback(void *context, char *topicName, I_32 topicLen, MQTTClient_message *message) {
    EsMqttAsyncMessage *msg = EsNewAsyncMessage(MQTTVAST_CALLBACK_TYPE_MESSAGEARRIVED, 4, context, topicName, topicLen,
                                                message);
    if (msg != NULL) {
        if (EsPostMessageToAsyncQueue(msg)) {
            return 1;
        } else {
            return 0;
        }
    }
}

static void deliveryCompleteCallback(void *context, MQTTClient_deliveryToken token) {
    EsMqttAsyncMessage *msg = EsNewAsyncMessage(MQTTVAST_CALLBACK_TYPE_DELIVERYCOMPLETE, 2, context, token);
    if (msg != NULL) {
        EsPostMessageToAsyncQueue(msg);
    }
}

static void publishedCallback(void *context, I_32 dt, I_32 packet_type, MQTTProperties *properties,
                              enum MQTTReasonCodes reasonCode) {
    EsMqttAsyncMessage *msg = EsNewAsyncMessage(MQTTVAST_CALLBACK_TYPE_PUBLISHED, 5, context, dt, packet_type,
                                                properties, reasonCode);
    if (msg != NULL) {
        EsPostMessageToAsyncQueue(msg);
    }
}

static void dummyCheckpointCallback(I_32 id) {
    ES_UNUSED(id);
}

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

void EsMqttCallbacksInit(EsGlobalInfo *globalInfo) {
    ES_UNUSED(globalInfo);
}

void EsMqttCallbacksShutdown() {
    /* No-Op */
}

BOOLEAN EsGetCallbackTarget(enum MqttVastCallbackTypes cbType, void **target) {
    return getCallbackTarget(cbType, target);
}

void *EsRegisterCallback(enum MqttVastCallbackTypes cbType, EsObject receiver, EsObject selector) {
    void *funcAddr = 0;

    if ((EsSetAsyncMessageTarget(cbType, receiver, selector) == TRUE) &&
        (getCallbackTarget(cbType, &funcAddr) == TRUE)) {
        return funcAddr;
    } else {
        return 0;
    }
}


