/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttAsyncArguments.h
 *  @brief Asynchronous Message Argument Preparation Interface
 *  @author Seth Berman
 *
 *  The purpose of this module is to help with argument allocation and
 *  preparation for posting to the VA Smalltalk async queue.
 *  Because async queue messages are received <later> and MQTT Paho sends
 *  in stack-allocated data to callbacks, then copies of the data must be
 *  made and managed.
 *
 *  The MQTT Paho Binding in Smalltalk uses a reference counter for data that
 *  it receives, therefore it is not necessary to track the data that we allocate
 *  here.  Smalltalk will deallocate the memory when it is no longer referenced
 *  using EsFreeMemory, which is why we use EsAllocateMemory in this module.
 *******************************************************************************/
#ifndef ES_MQTT_ASYNC_ARGUMENTS_H
#define ES_MQTT_ASYNC_ARGUMENTS_H

#include "esuser.h"

#include "MQTTClient.h"

/***********************************/
/*   S E T U P / S H U T D O W N   */
/***********************************/

/**
 * @brief Initialize the library modules, if necessary
 * @param EsGlobalInfo
 * @note No-Op if already init, can call multiple times
 */
void EsMqttAsyncArguments_ModuleInit(EsGlobalInfo *globalInfo);

/**
 * @brief Destruct and clear library module state
 */
void EsMqttAsyncArguments_ModuleShutdown();

/*************************************/
/*   M Q T T  D A T A  C O P I E S   */
/*************************************/

/**
 * @brief Answer a heap-allocated copy of the properties
 * @param props
 * @return props copy
 */
MQTTProperties *EsCopyProperties(MQTTProperties *props);

/**
 * @brief Answer a heap-allocated copy of the string
 * @param str
 * @return str copy
 */
char *EsCopyString(char *str);

/**
 * @brief Answer a heap-allocated copy of the topic string
 * @note Non-0 len could be due to embedded nulls...so use that if != 0
 * @param topicStr
 * @param len
 * @return topicStr copy
 */
char *EsCopyTopicString(char *topicStr, I_32 len);

/**
 * Answer a heap-allocated copy of the message
 * @param msg
 * @return msg copy
 */
MQTTClient_message *EsCopyMessage(MQTTClient_message *msg);


#endif //ES_MQTT_ASYNC_ARGUMENTS_H
