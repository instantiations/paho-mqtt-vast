/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttUserPrims.h
 *  @brief VA Smalltalk virtual machine user-primitives for MQTT Paho Interface
 *  @author Seth Berman
 *
 *  VA Smalltalk allows users to develop their own "primitives" to the virtual
 *  machine which can be called from the Smalltalk image. User Primitive calls
 *  are much faster than VA Smalltalk's FFI calls (PlatformFunctions) because
 *  the vm machinery is optimized to call user prims and there are no automatic
 *  argument (ST->C) conversions.
 *
 *  The primitives defined in this module allow the VA Smalltalk image to request
 *  MQTT Paho callbacks (as defined in C) whose activations are called in a
 *  separate native thread. This is why pure smalltalk callbacks (EsEntryPoints)
 *  can not be used since calling into the smalltalk vm from a separate thread
 *  would corrupt the execution machinery. Instead, callbacks defined here will
 *  pipe information back to Smalltalk using VA Smalltalk's asynchronous queue.
 *
 *  Asynchronous Queue's enqueue/dequeue ops are thread-safe and will be evaluated
 *  by the smalltalk machinery during "interrupt points" in the
 *  smalltalk interpreter which is a safe-point
 *******************************************************************************/
#ifndef ES_MQTT_USER_PRIMS_H
#define ES_MQTT_USER_PRIMS_H

#include "esuser.h"

/***********************************/
/*   S E T U P / S H U T D O W N   */
/***********************************/

/**
 * @brief Initialize the User-Prim module
 * @param globalInfo
 */
void EsMqttUserPrimsInit(EsGlobalInfo *globalInfo);

/**
 * @brief Shutdown the User-Prim module
 */
void EsMqttUserPrimsShutdown();


/************************************/
/*   U S E R  P R I M I T I V E S   */
/************************************/

/**
 * @brief Registers the C callback to activate for the provided callback type
 * and post a message to the VA Smalltalk Async Queue with the provided
 * receiver/selector
 *
 * Smalltalk Arguments
 * Arg1: Callback Type (@see MqttVastCallbackTypes)
 * Arg2: Class receiver of async message
 * Arg3: Selector to activate in async message
 * Returns: Callback Function Address as Smalltalk Integer
 *
 * C Arguments
 * @param EsPrimVMContext
 * @param EsPrimArgumentCount
 * @param EsPrimPushCount
 * @return TRUE
 */
EsDeclareUserPrimitive(MqttVastRegisterCallback);

/**
 * @brief Posts a message to the async queue (with unique id).
 * This servers as an async queue marker so the Smalltalk image
 * has a mechanism to flush the queue.
 *
 * @example Flushing async queue from smalltalk
 * sem := Semaphore new.
 * MQTTClient onCheckpoint: [sem signal].    <-- This calls the prim
 * sem wait.
 *
 * Smalltalk Arguments
 * Arg1: Pass-through unique id
 * Returns: receiver (self)
 *
 * C Arguments
 * @param EsPrimVMContext
 * @param EsPrimArgumentCount
 * @param EsPrimPushCount
 * @return TRUE
 */
EsDeclareUserPrimitive(MqttVastCheckpoint);

/**
 * @brief Answers a Smalltalk String representation
 * of the product version (major.minor.mod).
 *
 * @example 1.0.0
 *
 * Smalltalk Arguments
 * [None]
 *
 * C Arguments
 * @param EsPrimVMContext
 * @param EsPrimArgumentCount
 * @param EsPrimPushCount
 * @return TRUE
 */
EsDeclareUserPrimitive(MqttVastVersionString);

#endif //ES_MQTT_USER_PRIMS_H
