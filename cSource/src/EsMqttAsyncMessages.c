/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttAsyncMessages.c
 *  @brief Asynchronous Queue and Message Targets Implementation
 *  @author Seth Berman
 *******************************************************************************/
#include "plibsys.h"
#include "MQTTClient.h"

#include "EsMqttAsyncMessages.h"
#include "EsMqttAsyncArguments.h"

#include <stdarg.h>

/*************************/
/* P R O T O T Y P E S   */
/*************************/
/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_TRACE
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (I_32 level, char *message)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN traceHandler(EsObject receiver, EsObject selector, va_list argsList);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_CONNECTIONLOST
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (void *context, char *cause)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN connectionLostHandler(EsObject receiver, EsObject selector, va_list argsList);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_DISCONNECTED
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (void *context, MQTTProperties *properties, enum MQTTReasonCodes reasonCode)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN disconnectedHandler(EsObject receiver, EsObject selector, va_list argsList);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_MESSAGEARRIVED
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (void *context, char *topicName, I_32 topicLen, MQTTClient_message *message)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN messageArrivedHandler(EsObject receiver, EsObject selector, va_list argsList);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_DELIVERYCOMPLETE
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (void *context, MQTTClient_deliveryToken token)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN deliveryCompleteHandler(EsObject receiver, EsObject selector, va_list argsList);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_PUBLISHED
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (void *context, I_32 dt, I_32 packet_type, MQTTProperties *properties, enum MQTTReasonCodes)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN publishedHandler(EsObject receiver, EsObject selector, va_list argsList);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_CHECKPOINT
 * @param receiver EsObject class
 * @param selector EsObject symbol selector
 * @param argsList (I_32 id)
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN checkpointHandler(EsObject receiver, EsObject selector, va_list argsList);


/*******************************************/
/*  M O D U L E  P R I V A T E  V A R S    */
/*******************************************/

/**
 * @brief Dummy vmContext for globalInfo access
 *
 * EsPostAsyncMessage() calls require a vmContext
 * only for globalInfo access. These calls are made
 * from callbacks coming in on a separate thread.
 * A dummy context with the globalInfo is used
 * instead since it is unsafe to refer to the current
 * vm context from a non-vm thread. The globalInfo to
 * which the dummy context refers will be valid.
 */
static ESVMContext _DummyVMContext;

/**
 * @brief Array of EsObject Receiver/Selector Pairs used
 * as the target for a VA Smalltalk Asynchronous message
 *
 * An adjacent even/odd pair is the EsObject class>>selector
 * to activate for an async message
 */
#define ASYNC_MSG_TARGETS_SIZE      (NUM_MQTT_CALLBACKS * 2)
static EsObject _AsyncMessageTargets[ASYNC_MSG_TARGETS_SIZE] = {EsNil};

/**
 * @brief Read-Write Lock used for coordinated access to
 * the _AsyncMessageTargets array.
 *
 * It is expected that write access to the array will be rare
 * because writes would only would happen when the user makes
 * receiver/selector
 * adjustments.
 */
static PRWLock *_AsyncMessageTargetsLock = NULL;

/**
 * Handler functions that post async messages to VA Smalltalk's async queue
 * with the receiver>>selector target and the arguments
 */
typedef BOOLEAN AsyncMessageHandlerFunc(EsObject receiver, EsObject selector, va_list argsList);

/**
 * @brief Array of AsyncMessageHandlerFunc handlers
 *
 * The index is the MqttVastCallbackTypes and value
 * is the handler function associated with the cbType
 */
static AsyncMessageHandlerFunc *_AsyncMessageHandlers[NUM_MQTT_CALLBACKS] = {
        traceHandler,
        connectionLostHandler,
        disconnectedHandler,
        messageArrivedHandler,
        deliveryCompleteHandler,
        publishedHandler,
        checkpointHandler
};

/*******************/
/*  U T I L I T Y  */
/*******************/
/**
 * @brief Split u64 into high/low i32
 *
 * Its possible that the full u64 could not be
 * represented by 2 positive i32s.
 *
 * @param u64
 * @param iHigh
 * @param iLow
 * @return TRUE if success, FALSE if overflow
 */
static BOOLEAN hiLowFrom64(U_64 u64, I_32 *iHigh, I_32 *iLow) {
    *iHigh = (I_32) (((u64) & 0x3FFFFFFF80000000LL) >> 31);
    *iLow = (I_32) ((u64) & 0x7FFFFFFFLL);
    return (BOOLEAN) ((u64 & 0xC000000000000000LL) == 0);
}

/**
 * @brief Split pointer address into high/low i32
 * @see hiLowFrom64 for more details
 * @param ptr
 * @param iHigh
 * @param iLow
 * @return TRUE if success, FALSE if overflow
 */
static BOOLEAN hiLowFromPointer(void *ptr, I_32 *iHigh, I_32 *iLow) {
    return hiLowFrom64((U_64) (U_PTR) ptr, iHigh, iLow);
}

/**
 * @brief Get the receiver/selector target for a callback type
 *
 * Reads the receiver/selector into the output parameters.
 * Access is guarded by read lock
 *
 * @param cbType
 * @param receiverPtr[output]
 * @param selectorPtr [output]
 * @return TRUE if success, FALSE otherwise
 */
static BOOLEAN getAsyncMessageTarget(enum MqttVastCallbackTypes cbType, EsObject *receiverPtr, EsObject *selectorPtr) {
    if ((receiverPtr == NULL) || (selectorPtr == NULL)) {
        return FALSE;
    }

    /* READ LOCK */
    p_rwlock_reader_lock(_AsyncMessageTargetsLock);
    *receiverPtr = _AsyncMessageTargets[cbType * 2];
    *selectorPtr = _AsyncMessageTargets[cbType * 2 + 1];
    p_rwlock_reader_unlock(_AsyncMessageTargetsLock);

    if (ES_LIKELY(!EsIsNil(*receiverPtr) && !EsIsNil(*selectorPtr))) {
        return TRUE;
    } else {
        return FALSE;
    }
}

/**
 * @brief Set the receiver/selector target for a callback type
 *
 * Writes the receiver/selector to the async message target array.
 * Access is guarded by write lock
 *
 * @param cbType
 * @param receiver
 * @param selector
 */
static BOOLEAN setAsyncMessageTarget(enum MqttVastCallbackTypes cbType, EsObject receiver, EsObject selector) {
    if (EsIsValidCallbackType(cbType)) {
        /* WRITE LOCK */
        p_rwlock_writer_lock(_AsyncMessageTargetsLock);
        _AsyncMessageTargets[cbType * 2] = receiver;
        _AsyncMessageTargets[cbType * 2 + 1] = selector;
        p_rwlock_writer_unlock(_AsyncMessageTargetsLock);
        return TRUE;
    } else {
        return FALSE;
    }
}

/**
 * @brief Get the async message handler function address for callback type
 *
 * @param cbType
 * @param handler[output] set to NULL if fails
 * @return TRUE if success, FALSE otherwise
 */
static BOOLEAN getAsyncMessageHandler(enum MqttVastCallbackTypes cbType, AsyncMessageHandlerFunc **handlerPtr) {
    if (handlerPtr == NULL) {
        return FALSE;
    } else if (EsIsValidCallbackType(cbType)) {
        *handlerPtr = _AsyncMessageHandlers[cbType];
        return TRUE;
    } else {
        *handlerPtr = NULL;
        return FALSE;
    }
}

/**************************************************/
/*      A S Y N C  Q U E U E  H A N D L E R S     */
/**************************************************/
static BOOLEAN traceHandler(EsObject receiver, EsObject selector, va_list argsList) {
    I_32 level = va_arg(argsList, I_32);
    char *message = va_arg(argsList, char*);

    char *messageCopy;
    I_32 messageHigh, messageLow;

    messageCopy = EsCopyString(message);
    strcpy(messageCopy, message);
    hiLowFromPointer(messageCopy, &messageHigh, &messageLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            3,
            EsI32ToSmallInteger(level),
            EsI32ToSmallInteger(messageHigh),
            EsI32ToSmallInteger(messageLow));
}

static BOOLEAN connectionLostHandler(EsObject receiver, EsObject selector, va_list argsList) {
    void *context = va_arg(argsList, void*);
    char *cause = va_arg(argsList, char*);

    char *causeCopy;
    I_32 causeHigh, causeLow;

    causeCopy = EsCopyString(cause);
    hiLowFromPointer(causeCopy, &causeHigh, &causeLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            3,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(causeHigh),
            EsI32ToSmallInteger(causeLow));
}

static BOOLEAN disconnectedHandler(EsObject receiver, EsObject selector, va_list argsList) {
    void *context = va_arg(argsList, void*);
    MQTTProperties *properties = va_arg(argsList, MQTTProperties*);
    enum MQTTReasonCodes reasonCode = va_arg(argsList, enum MQTTReasonCodes);

    MQTTProperties *propertiesCopy;
    I_32 propertiesHigh, propertiesLow;

    propertiesCopy = EsCopyProperties(properties);
    hiLowFromPointer(propertiesCopy, &propertiesHigh, &propertiesLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            4,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(propertiesHigh),
            EsI32ToSmallInteger(propertiesLow),
            EsI32ToSmallInteger(reasonCode));
}

static BOOLEAN messageArrivedHandler(EsObject receiver, EsObject selector, va_list argsList) {
    void *context = va_arg(argsList, void*);
    char *topicName = va_arg(argsList, char*);
    I_32 topicLen = va_arg(argsList, I_32);
    MQTTClient_message *message = va_arg(argsList, MQTTClient_message*);

    MQTTClient_message *messageCopy;
    char *topicNameCopy;
    I_32 topicNameHigh, topicNameLow;
    I_32 messageHigh, messageLow;

    topicNameCopy = EsCopyTopicString(topicName, topicLen);
    messageCopy = EsCopyMessage(message);
    hiLowFromPointer(topicNameCopy, &topicNameHigh, &topicNameLow);
    hiLowFromPointer(messageCopy, &messageHigh, &messageLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            6,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(topicNameHigh),
            EsI32ToSmallInteger(topicNameLow),
            EsI32ToSmallInteger(topicLen),
            EsI32ToSmallInteger(messageHigh),
            EsI32ToSmallInteger(messageLow));
}

static BOOLEAN deliveryCompleteHandler(EsObject receiver, EsObject selector, va_list argsList) {
    void *context = va_arg(argsList, void*);
    MQTTClient_deliveryToken token = va_arg(argsList, MQTTClient_deliveryToken);

    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            2,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(token));
}

static BOOLEAN publishedHandler(EsObject receiver, EsObject selector, va_list argsList) {
    void *context = va_arg(argsList, void*);
    I_32 dt = va_arg(argsList, I_32);
    I_32 packet_type = va_arg(argsList, I_32);
    MQTTProperties *properties = va_arg(argsList, MQTTProperties*);
    enum MQTTReasonCodes reasonCode = va_arg(argsList, enum MQTTReasonCodes);

    MQTTProperties *propertiesCopy;
    I_32 propertiesHigh, propertiesLow;

    propertiesCopy = EsCopyProperties(properties);
    hiLowFromPointer(propertiesCopy, &propertiesHigh, &propertiesLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            6,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(dt),
            EsI32ToSmallInteger(packet_type),
            EsI32ToSmallInteger(propertiesHigh),
            EsI32ToSmallInteger(propertiesLow),
            EsI32ToSmallInteger(reasonCode));
}

static BOOLEAN checkpointHandler(EsObject receiver, EsObject selector, va_list argsList) {
    I_32 id = va_arg(argsList, I_32);

    return EsPostAsyncMessage(
            &_DummyVMContext,
            receiver,
            selector,
            1,
            EsI32ToSmallInteger(id));
}

/*************************************************************/
/*      I N T E R F A C E  I M P L E M E N T A T I O N       */
/*************************************************************/
void EsMqttAsyncMessagesInit(EsGlobalInfo *globalInfo) {
    _DummyVMContext.globalInfo = globalInfo;
    _AsyncMessageTargetsLock = p_rwlock_new();
}

void EsMqttAsyncMessagesShutdown() {
    _DummyVMContext.globalInfo = NULL;
}

BOOLEAN EsGetAsyncMessageTarget(enum MqttVastCallbackTypes cbType, EsObject *receiver, EsObject *selector) {
    return getAsyncMessageTarget(cbType, receiver, selector);
}

BOOLEAN EsSetAsyncMessageTarget(enum MqttVastCallbackTypes cbType, EsObject receiver, EsObject selector) {
    return setAsyncMessageTarget(cbType, receiver, selector);
}

BOOLEAN EsPostMessageToAsyncQueue(enum MqttVastCallbackTypes cbType, U_32 argCount, ...) {
    EsObject receiver, selector;
    AsyncMessageHandlerFunc *handler;
    BOOLEAN success;
    va_list argsList;

    /* Get valid receiver>>selector */
    if (!getAsyncMessageTarget(cbType, &receiver, &selector)) {
        return FALSE;
    }

    /* Get valid handler which will post msg */
    if (!getAsyncMessageHandler(cbType, &handler)) {
        return FALSE;
    }

    va_start(argsList, argCount);
    success = handler(receiver, selector, argsList);
    va_end(argsList);

    return success;
}