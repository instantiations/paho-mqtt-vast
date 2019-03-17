/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsWorkTask.h
 *  @brief Executable Work Task Interface
 *  @see EsWorkQueue.h for additional info
 *  @author Seth Berman
 *
 *  A work task is an opaque and configurable encapsulation of a runnable
 *  function associated with user-supplied data.
 *
 *  Work Tasks are the elements of a Work Queue (@see EsWorkQueue) that
 *  are executed by the work queue consumer.
 *
 *  Example: Create and execute a work task to print the task property value associated
 *  with the key "PrintKey"
 *
 *  // Callback
 *  static void printProperties(EsWorkTask *task) { printf("%s", EsWorkTaskPropAt(task, "PrintKey")); }
 *
 *  EsWorkTask *task = EsWorkTask_new(printProperties, NULL);
 *  EsWorkTaskPropAtPut(task, "PrintKey", "Hello World");
 *  EsRunWorkTask(task);
 *  EsFreeWorkTask(task);
 *
 *******************************************************************************/
#ifndef ES_WORK_TASK_H
#define ES_WORK_TASK_H

#include "EsProperties.h"

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Opaque work task
 */
typedef struct _EsWorkTask EsWorkTask;

/**
 * @brief Function that task consumer runs
 */
typedef void (*EsWorkTaskFunc)(EsWorkTask *task);

/**
 * @brief Function called on EsFreeWorkTask to free args
 * @note If this func is set, it will run even if data is NULL
 */
typedef void (*EsWorkTaskFreeDataFunc)(void *args);

/*************************/
/*   L I F E C Y C L E   */
/*************************/

/**
 * @brief Answer a new work task instance
 * @return new work task
 */
EsWorkTask *EsWorkTask_new();

/**
 * @brief Answer an initialized work task instance
 * @param func to run
 * @param args user-supplied data
 * @return new work task
 */
EsWorkTask *EsWorkTask_newInit(EsWorkTaskFunc func, void *args);

/**
 * @brief Destroy the work task
 * @param task
 */
void EsWorkTask_free(EsWorkTask *task);

/*************************/
/*   A C C E S S I N G   */
/*************************/

/**
 * @brief Answer the task properties
 * @param task
 * @return EsProperties
 */
EsProperties *EsWorkTask_getProperties(const EsWorkTask *task);

/**
 * @brief Answer the runnable function
 * @param task
 * @return EsWorkFunc
 */
EsWorkTaskFunc EsWorkTask_getRunFunc(const EsWorkTask *task);

/**
 * @brief Set the runnable function
 * @param task
 * @param func to run by work queue consumer
 */
void EsWorkTask_setRunFunc(EsWorkTask *task, EsWorkTaskFunc func);

/**
 * @brief Answer the user-supplied data for the runnable function
 * @note EsWorkFunc is expected to provide concrete interp
 * for void* data
 * @param task
 * @return void* data user-supplied
 */
void *EsWorkTask_getUserData(const EsWorkTask *task);

/**
 * @brief Set the user-supplied data for the runnable function
 * @param task
 * @param data user-supplied
 */
void EsWorkTask_setUserData(EsWorkTask *task, void *data);

/**
 * @brief Answer the function used on free to cleanup args
 * @note Only required if memory for task data must be freed
 * @param task
 * @return func to run on free
 */
EsWorkTaskFreeDataFunc EsWorkTask_getFreeUserDataFunc(const EsWorkTask *task);

/**
 * @brief Set the function used on free to cleanup args
 * @note Only required if memory for task data must be freed
 * @param task
 * @param func to run on free
 */
void EsWorkTask_setFreeUserDataFunc(EsWorkTask *task, EsWorkTaskFreeDataFunc func);

/*************************/
/*   E X E C U T I O N   */
/*************************/

/**
 * @brief Execute the work task func
 * @param task
 * @post task is still valid and can be run again
 */
void EsWorkTask_run(EsWorkTask *task);

#endif //ES_WORK_TASK_H
