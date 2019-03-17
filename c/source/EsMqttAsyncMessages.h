/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttAsyncMessages.h
 *  @brief Asynchronous Queue and Message Targets Interface
 *  @author Seth Berman
 *
 *  VA Smalltalk's Asynchronous Queue Interface Module
 *  The purpose of this module is to post messages, with supplied arguments, to
 *  the async queue for processing within Smalltalk. Arguments must be handled
 *  with care because some are MQTT Paho stack allocated and can not be passed, as is,
 *  to Smalltalk as a reference for processing in the future.
 *
 *  The Asynchronous Queue is a thread-safe queue (enqueue/dequeue ops) that the
 *  Smalltalk vm knows about and evaluates during the course of bytecode/send processing
 *  in VA Smalltalk's interrupt driven vm. At special interrupt points (i.e. Transfer Control bc)
 *  the async queue is checked and if not empty, the work (class>>selector and args) is evaluated.
 *  This allows VA Smalltalk to perform callback work at safe times within the vm.
 *
 *  At a high-level, we have a thread-safe queue with multiple threads doing enqueue and a single
 *  thread doing dequeue. This means, under heavy load, we must keep in mind that VA Smalltalk
 *  async message execution on the Smalltalk side could become a bottleneck if the service time
 *  is large or the enqueue rate is too large. Therefore mechanisms are employed to throttle the
 *  enqueue if, for example, the async queue is full.
 *
 *  Does this delayed processing cause issues? (callback -> async queue <Time> -> Smalltalk)
 *  Yes, there is a tricky part. The callback activator expects processing to be done now, and not
 *  at some point later (or different call stack). Arguments may be addresses to stack-allocated args,
 *  so you can't just pass the addresses of these on to smalltalk...their value is undefined by the
 *  time Smalltalk gets around to processing it.  To deal with this, copies or partial copies of some
 *  data may be made and those copies are passed to smalltalk. It's typically small and is not expected
 *  to hinder performance or memory. But it does mean the lifecycle of the data must be carefully
 *  considered since it may had gone from stack-allocated to heap-allocated leaving someone to clean it up.
 *
 *  How are arguments passed into Smalltalk?
 *  Another tricky part to deal with...especially in 64-bit. First the issue will be
 *  described. Then the current solution (though there are numerous ways to deal with this) will be discussed.
 *  Issue: What you end up passing are primitive values like integers. These could be immediate
 *  integers or addresses to complex datatypes. AND you can only construct the kinds of objects
 *  that do not require smalltalk heap allocation. So basically...smalltalk immediates where the values
 *  are encoded. The reason for this is that an async queue enqueue of a class>>selector with args
 *  is happening in a separate OS thread...you can't allocate an object from the smalltalk heap
 *  during this time.
 *  Issue2: Addresses (especially 64-bit) can be bigger than a SmallInteger immediate and require a LargeInteger
 *  which is a heap allocated object. How do we pass back the address to Smalltalk when we can't represent it?
 *  Here is where there are any number of clever schemes that could be employed. For simplicity, the address
 *  is split into high/low parts and passed as 2 arguments. Then they are put back together on the Smalltalk side.
 *******************************************************************************/
#ifndef ES_MQTT_ASYNC_QUEUE_MESSAGES_H
#define ES_MQTT_ASYNC_QUEUE_MESSAGES_H

#include "esuser.h"

#include "EsMqttCallbacks.h"

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Opaque async message
 */
typedef struct _EsMqttAsyncMessage EsMqttAsyncMessage;

/***********************************/
/*   S E T U P / S H U T D O W N   */
/***********************************/

/**
 * @brief Initialize the Async Queue Msg Module
 * @param globalInfo
 */
void EsMqttAsyncMessages_ModuleInit(EsGlobalInfo *globalInfo);

/**
 * @brief Shutdown the Async Queue Msg Module
 */
void EsMqttAsyncMessages_ModuleShutdown();

/***********************************************/
/*   A S Y N C  M E S S A G E  T A R G E T S   */
/***********************************************/

/**
 * @brief Answers receiver>>selector target for callback
 * @param cbType MqttVastCallbackTypes
 * @param receiver[out] async msg target class
 * @param selector[out] async msg target symbol selector
 * @return TRUE if successful get, FALSE otherwise
 */
BOOLEAN EsMqttAsyncMessage_GetTarget(enum EsMqttVastCallbackTypes cbType, EsObject *receiver, EsObject *selector);

/**
 * @brief Set the Smalltalk receiver>>selector target for callback
 * @param cbType  MqttVastCallback
 * @param receiver async msg target class
 * @param selector async msg target symbol selector
 * @return TRUE if successful set, FALSE otherwise
 */
BOOLEAN EsMqttAsyncMessage_SetTarget(enum EsMqttVastCallbackTypes cbType, EsObject receiver, EsObject selector);

/********************************/
/*   A S Y N C  M E S S A G E   */
/********************************/

/**
 * @brief Answer a new async message to post
 * @param cbType MqttVastCallbackTypes
 * @param argCount um of msg args for variadic function
 * @param ... msg args to post
 * @return EsMqttAsyncMessage* or NULL if
 */
EsMqttAsyncMessage *EsMqttAsyncMessage_newInit(enum EsMqttVastCallbackTypes cbType, U_32 argCount, ...);

/**
 * @brief Free the memory associated with the message
 * @param message
 */
void EsMqttAsyncMessage_free(EsMqttAsyncMessage *message);

/*******************************************/
/*   A S Y N C  M E S S A G E  Q U E U E   */
/*******************************************/

/**
 * @brief Post the message to the VAST Async Queue
 * @note This can fail if the async queue is full or
 * Smalltalk has async disable (i.e. ST critical section)
 * @param message
 * @return TRUE if posted, FALSE otherwise (full queue)
 */
BOOLEAN EsMqttAsyncMessage_post(EsMqttAsyncMessage *message);

#endif //ES_MQTT_ASYNC_QUEUE_MESSAGES_H