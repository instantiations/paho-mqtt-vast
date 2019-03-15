/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsWorkQueue.h
 *  @brief Work Queue Interface for executing tasks
 *  @see EsWorkTask.h for additional info
 *  @author Seth Berman
 *
 *  The following module provides the implementation for Work Queues
 *  to help implement Producer/Consumer models.
 *
 *  @example
 *  static void printHelloWorld(EsWorkTask *task) { printf("Hello World\n"); }
 *
 *  EsWorkQueue *queue = EsNewWorkQueue(ESQ_TYPE_SYNCHRONOUS);
 *  EsWorkQueueInit(queue);
 *  EsWorkTask *task = EsNewWorkTaskInit(printHelloWorld, NULL);
 *  EsWorkQueueSubmit(queue, task);
 *  EsWorkQueueShutdown(queue);
 *  EsFreeWorkTask(task);
 *  EsFreeWorkQueue(queue);
 *
 *******************************************************************************/
#ifndef ES_WORK_QUEUE_H
#define ES_WORK_QUEUE_H

#include "EsWorkTask.h"

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @enum EsWorkQueueType
 * @brief Supported queue types
 */
enum EsWorkQueueType {
    ESQ_TYPE_UNDEFINED,
    ESQ_TYPE_SYNCHRONOUS
};

/**
 * @brief Work Queue that accepts and executes tasks
 * @note This is an opaque datatype
 * @see EsWorkTask for tasks
 */
typedef struct _EsWorkQueue EsWorkQueue;


/*************************/
/*   L I F E C Y C L E   */
/*************************/

/**
 * @brief Answer a new work queue of the specified type
 * @param type EsWorkQueueType
 * @return queue
 */
EsWorkQueue *EsNewWorkQueue(enum EsWorkQueueType type);

/**
 * @brief Initialize the queue
 * @example starting thread consumers might be done here
 * @param queue
 */
void EsWorkQueueInit(EsWorkQueue *queue);

/**
 * @brief Shuts down the queue gracefully
 * @param queue
 */
void EsWorkQueueShutdown(EsWorkQueue *queue);

/**
 * @brief Destroy the work queue
 * @note This will do a forced shutdown of the queue
 * @param queue
 */
void EsFreeWorkQueue(EsWorkQueue *queue);

/*************************/
/*   A C C E S S I N G   */
/*************************/

/**
 * @brief Answer the queue properties
 * @param queue
 * @return EsProperties
 */
EsProperties *EsGetWorkQueueProps(const EsWorkQueue *queue);


/************************/
/*   Q U E U E  A P I   */
/***********************/

/**
 * @brief Adds a new task to the queue
 * @param queue
 * @param task
 */
void EsWorkQueueSubmit(EsWorkQueue *queue, EsWorkTask *task);

/**
 * @brief Answer the number of tasks waiting to execute
 * @param queue
 * @return U_32 num pending tasks
 */
U_32 EsNumWorkQueueTasks(const EsWorkQueue *queue);

#endif //ES_WORK_QUEUE_H
