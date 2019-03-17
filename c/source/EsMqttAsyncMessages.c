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

#include "esuser.h"

#include "EsMqttAsyncMessages.h"
#include "EsMqttAsyncArguments.h"
#include "EsWorkTask.h"

/***************************/
/*   P R O T O T Y P E S   */
/***************************/

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_TRACE
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN traceHandler(EsMqttAsyncMessage *message);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_CONNECTIONLOST
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN connectionLostHandler(EsMqttAsyncMessage *message);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_DISCONNECTED
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN disconnectedHandler(EsMqttAsyncMessage *message);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_MESSAGEARRIVED
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN messageArrivedHandler(EsMqttAsyncMessage *message);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_DELIVERYCOMPLETE
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN deliveryCompleteHandler(EsMqttAsyncMessage *message);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_PUBLISHED
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN publishedHandler(EsMqttAsyncMessage *message);

/**
 * Post Async Message for MQTTVAST_CALLBACK_TYPE_CHECKPOINT
 * @param message to post to VAST async queue
 * @return TRUE if async msg posted, FALSE otherwise
 */
static BOOLEAN checkpointHandler(EsMqttAsyncMessage *message);


/*******************************************/
/*   M O D U L E  P R I V A T E  V A R S   */
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
 */
typedef BOOLEAN (*AsyncMessageHandlerFunc)(EsMqttAsyncMessage *message);

/**
 * @brief Array of AsyncMessageHandlerFunc handlers
 *
 * The index is the MqttVastCallbackTypes and value
 * is the handler function associated with the cbType
 */
static AsyncMessageHandlerFunc _AsyncMessageHandlers[NUM_MQTT_CALLBACKS] = {
        traceHandler,
        connectionLostHandler,
        disconnectedHandler,
        messageArrivedHandler,
        deliveryCompleteHandler,
        publishedHandler,
        checkpointHandler
};

/**********************************/
/*   A S Y N C  M E S S A G E S   */
/**********************************/

typedef union _EsMqttAsynMessageArg EsMqttAsyncMessageArg;
union _EsMqttAsynMessageArg {
    void *ptr;
    char *str;
    MQTTClient_message *msg;
    MQTTProperties *props;
    I_32 i;
    enum MQTTReasonCodes reasonCode;
    MQTTClient_deliveryToken token;
};

struct _EsMqttAsyncMessage {
    enum EsMqttVastCallbackTypes cbType;
    EsObject receiver;
    EsObject selector;
    EsMqttAsyncMessageArg args[];
};

/*********************/
/*   U T I L I T Y   */
/*********************/

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
    *iHigh = (I_32) (((u64) & 0x3FFFFFFF80000000UL) >> 31u);
    *iLow = (I_32) ((u64) & 0x7FFFFFFFUL);
    return (BOOLEAN) ((u64 & 0xC000000000000000UL) == 0);
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
static BOOLEAN
getAsyncMessageTarget(enum EsMqttVastCallbackTypes cbType, EsObject *receiverPtr, EsObject *selectorPtr) {
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
static BOOLEAN setAsyncMessageTarget(enum EsMqttVastCallbackTypes cbType, EsObject receiver, EsObject selector) {
    if (EsMqttCallbacks_IsValidCallbackType(cbType)) {
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
static BOOLEAN getAsyncMessageHandler(enum EsMqttVastCallbackTypes cbType, AsyncMessageHandlerFunc *handlerPtr) {
    if (handlerPtr == NULL) {
        return FALSE;
    } else if (EsMqttCallbacks_IsValidCallbackType(cbType)) {
        *handlerPtr = _AsyncMessageHandlers[cbType];
        return TRUE;
    } else {
        *handlerPtr = NULL;
        return FALSE;
    }
}

/*********************************************/
/*   A S Y N C  Q U E U E  H A N D L E R S   */
/*********************************************/

static BOOLEAN traceHandler(EsMqttAsyncMessage *message) {
    I_32 level;
    I_32 traceStrHigh, traceStrLow;
    char *traceStr;
    char *traceStrCopy;

    level = message->args[0].i;
    traceStr = message->args[1].str;

    traceStrCopy = EsCopyString(traceStr);
    hiLowFromPointer(traceStrCopy, &traceStrHigh, &traceStrLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            3,
            EsI32ToSmallInteger(level),
            EsI32ToSmallInteger(traceStrHigh),
            EsI32ToSmallInteger(traceStrLow));
}

static BOOLEAN connectionLostHandler(EsMqttAsyncMessage *message) {
    void *context = message->args[0].ptr;
    char *cause = message->args[1].str;

    char *causeCopy = EsCopyString(cause);
    I_32 causeHigh, causeLow;

    hiLowFromPointer(causeCopy, &causeHigh, &causeLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            3,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(causeHigh),
            EsI32ToSmallInteger(causeLow));
}

static BOOLEAN disconnectedHandler(EsMqttAsyncMessage *message) {
    void *context = message->args[0].ptr;
    MQTTProperties *properties = message->args[1].props;
    enum MQTTReasonCodes reasonCode = message->args[2].reasonCode;

    MQTTProperties *propertiesCopy = EsCopyProperties(properties);
    I_32 propertiesHigh, propertiesLow;

    hiLowFromPointer(propertiesCopy, &propertiesHigh, &propertiesLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            4,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(propertiesHigh),
            EsI32ToSmallInteger(propertiesLow),
            EsI32ToSmallInteger(reasonCode));
}

static BOOLEAN messageArrivedHandler(EsMqttAsyncMessage *message) {
    void *context = message->args[0].ptr;
    char *topicName = message->args[1].str;
    I_32 topicLen = message->args[2].i;
    MQTTClient_message *clientMessage = message->args[3].msg;

    MQTTClient_message *clientMessageCopy = EsCopyMessage(clientMessage);
    char *topicNameCopy = EsCopyTopicString(topicName, topicLen);
    I_32 topicNameHigh, topicNameLow;
    I_32 messageHigh, messageLow;

    hiLowFromPointer(topicNameCopy, &topicNameHigh, &topicNameLow);
    hiLowFromPointer(clientMessageCopy, &messageHigh, &messageLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            6,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(topicNameHigh),
            EsI32ToSmallInteger(topicNameLow),
            EsI32ToSmallInteger(topicLen),
            EsI32ToSmallInteger(messageHigh),
            EsI32ToSmallInteger(messageLow));
}

static BOOLEAN deliveryCompleteHandler(EsMqttAsyncMessage *message) {
    void *context = message->args[0].ptr;
    MQTTClient_deliveryToken token = message->args[1].token;

    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            2,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(token));
}

static BOOLEAN publishedHandler(EsMqttAsyncMessage *message) {
    void *context = message->args[0].ptr;
    I_32 dt = message->args[1].i;
    I_32 packet_type = message->args[2].i;
    MQTTProperties *properties = message->args[3].props;
    enum MQTTReasonCodes reasonCode = message->args[4].reasonCode;

    MQTTProperties *propertiesCopy = EsCopyProperties(properties);
    I_32 propertiesHigh, propertiesLow;

    hiLowFromPointer(propertiesCopy, &propertiesHigh, &propertiesLow);
    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            6,
            EsI32ToSmallInteger(context),
            EsI32ToSmallInteger(dt),
            EsI32ToSmallInteger(packet_type),
            EsI32ToSmallInteger(propertiesHigh),
            EsI32ToSmallInteger(propertiesLow),
            EsI32ToSmallInteger(reasonCode));
}

static BOOLEAN checkpointHandler(EsMqttAsyncMessage *message) {
    I_32 id = message->args[0].i;

    return EsPostAsyncMessage(
            &_DummyVMContext,
            message->receiver,
            message->selector,
            1,
            EsI32ToSmallInteger(id));
}

static void submitToAsyncQueue(EsWorkTask *task) {
    EsObject receiver, selector;
    AsyncMessageHandlerFunc handler;
    EsMqttAsyncMessage *msg;

    msg = (EsMqttAsyncMessage *) EsWorkTask_getUserData(task);
    if (!msg) {
        return;
    }

    /* Get valid receiver>>selector */
    if (!getAsyncMessageTarget(msg->cbType, &receiver, &selector)) {
        EsMqttAsyncMessage_free(msg);
        EsWorkTask_free(task);
    }

    msg->receiver = receiver;
    msg->selector = selector;
    /* Get valid handler which will post msg */
    if (!getAsyncMessageHandler(msg->cbType, &handler)) {
        return;
    }

    handler(msg);

}

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

void EsMqttAsyncMessages_ModuleInit(EsGlobalInfo *globalInfo) {
    _DummyVMContext.globalInfo = globalInfo;
    _AsyncMessageTargetsLock = p_rwlock_new();
}

void EsMqttAsyncMessages_ModuleShutdown() {
    _DummyVMContext.globalInfo = NULL;
}

EsMqttAsyncMessage *EsMqttAsyncMessage_newInit(enum EsMqttVastCallbackTypes cbType, U_32 argCount, ...) {
    EsMqttAsyncMessage *msg;
    va_list argsList;

    msg = (EsMqttAsyncMessage *) EsAllocateMemory(
            sizeof(EsMqttAsyncMessage) + sizeof(EsMqttAsyncMessageArg) * argCount);
    if (!msg) {
        return (EsMqttAsyncMessage *) NULL;
    }

    msg->cbType = cbType;
    msg->receiver = EsNil;
    msg->selector = EsNil;
    va_start(argsList, argCount);
    switch (cbType) {
        case ESMQTT_CB_TYPE_TRACE:
            if (argCount != 2) {
                return NULL;
            }
            msg->args[0].i = va_arg(argsList, I_32);
            msg->args[1].str = EsCopyString(va_arg(argsList, char*));
            break;
        case ESMQTT_CB_TYPE_CONNECTIONLOST:
            if (argCount != 2) {
                return NULL;
            }
            msg->args[0].i = va_arg(argsList, I_32);
            msg->args[1].str = EsCopyString(va_arg(argsList, char*));
            break;
        case ESMQTT_CB_TYPE_DISCONNECTED:
            if (argCount != 3) {
                return NULL;
            }
            msg->args[0].ptr = va_arg(argsList, void*);
            msg->args[1].props = EsCopyProperties(va_arg(argsList, MQTTProperties*));
            msg->args[2].reasonCode = va_arg(argsList, enum MQTTReasonCodes);
            break;
        case ESMQTT_CB_TYPE_MESSAGEARRIVED:
            if (argCount != 4) {
                return NULL;
            }
            msg->args[0].ptr = va_arg(argsList, void*);
            msg->args[1].str = va_arg(argsList, char*);
            msg->args[2].i = va_arg(argsList, I_32);
            msg->args[3].msg = EsCopyMessage(va_arg(argsList, MQTTClient_message*));
            break;
        case ESMQTT_CB_TYPE_DELIVERYCOMPLETE:
            if (argCount != 2) {
                return NULL;
            }
            msg->args[0].ptr = va_arg(argsList, void*);
            msg->args[1].token = va_arg(argsList, MQTTClient_deliveryToken);
            break;
        case ESMQTT_CB_TYPE_PUBLISHED:
            if (argCount != 5) {
                return NULL;
            }
            msg->args[0].ptr = va_arg(argsList, void*);
            msg->args[1].i = va_arg(argsList, I_32);
            msg->args[2].i = va_arg(argsList, I_32);
            msg->args[3].props = EsCopyProperties(va_arg(argsList, MQTTProperties*));
            msg->args[4].reasonCode = va_arg(argsList, enum MQTTReasonCodes);
            break;
        case ESMQTT_CB_TYPE_CHECKPOINT:
            if (argCount != 1) {
                return NULL;
            }
            msg->args[0].i = va_arg(argsList, I_32);
            break;
        default:
            break;
    }
    va_end(argsList);

    return msg;
}

void EsMqttAsyncMessage_free(EsMqttAsyncMessage *message) {
    if (message) {
        if (message->args) {
            EsFreeMemory(message->args);
        }
        EsFreeMemory(message);
    }
}

BOOLEAN EsMqttAsyncMessage_GetTarget(enum EsMqttVastCallbackTypes cbType, EsObject *receiver, EsObject *selector) {
    return getAsyncMessageTarget(cbType, receiver, selector);
}

BOOLEAN EsMqttAsyncMessage_SetTarget(enum EsMqttVastCallbackTypes cbType, EsObject receiver, EsObject selector) {
    return setAsyncMessageTarget(cbType, receiver, selector);
}


BOOLEAN EsMqttAsyncMessage_post(EsMqttAsyncMessage *message) {
    EsWorkTask *task;

    task = EsWorkTask_newInit(submitToAsyncQueue, message);
    if (!task) {
        return FALSE;
    }

    EsWorkTask_run(task);
    return TRUE;
}
