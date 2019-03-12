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
 *  EsWorkTask *task = EsNewWorkTask(printProperties, NULL);
 *  EsWorkTaskPropAtPut(task, "PrintKey", "Hello World");
 *  EsRunWorkTask(task);
 *  EsFreeWorkTask(task);
 *
 *******************************************************************************/
#ifndef ES_WORK_TASK_H
#define ES_WORK_TASK_H

#include "escompiler.h"

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
 * @brief Answer an initialized work task instance
 * @return new work task
 */
EsWorkTask *EsNewWorkTask();

/**
 * @brief Answer an initialized work task instance
 * @param func to run
 * @param args user-supplied data
 * @return new work task
 */
EsWorkTask *EsNewWorkTaskInit(EsWorkTaskFunc func, void *args);

/**
 * @brief Destroy the work task
 * @param task
 */
void EsFreeWorkTask(EsWorkTask *task);

/*************************/
/*   A C C E S S I N G   */
/*************************/

/**
 * @brief Answer the runnable function
 * @param task
 * @return EsWorkFunc
 */
EsWorkTaskFunc EsGetWorkTaskFunc(const EsWorkTask *task);

/**
 * @brief Set the runnable function
 * @param task
 * @param func to run by work queue consumer
 */
void EsSetWorkTaskFunc(EsWorkTask *task, EsWorkTaskFunc func);

/**
 * @brief Answer the user-supplied data for the runnable function
 * @note EsWorkFunc is expected to provide concrete interp
 * for void* data
 * @param task
 * @return void* data user-supplied
 */
void *EsGetWorkTaskData(const EsWorkTask *task);

/**
 * @brief Set the user-supplied data for the runnable function
 * @param task
 * @param data user-supplied
 */
void EsSetWorkTaskData(EsWorkTask *task, void *data);

/**
 * @brief Answer the function used on free to cleanup args
 * @note Only required if memory for task data must be freed
 * @param task
 * @return func to run on free
 */
EsWorkTaskFreeDataFunc EsGetWorkTaskFreeDataFunc(const EsWorkTask *task);

/**
 * @brief Set the function used on free to cleanup args
 * @note Only required if memory for task data must be freed
 * @param task
 * @param func to run on free
 */
void EsSetWorkTaskFreeDataFunc(EsWorkTask *task, EsWorkTaskFreeDataFunc func);

/***************************/
/*   P R O P E R T I E S   */
/***************************/

/**
 * @brief Answer the string property value at key
 * @note props[key]
 * @param task
 * @param key null-terminated string
 * @return null-terminated value string if key found
 * @return NULL if key not found, key is NULL, or task is NULL
 */
const char *EsWorkTaskPropAt(EsWorkTask *task, const char *key);

/**
 * @brief Add the key/value string pair.
 * @note props[key] = copy(value);
 * @note If key already exists, then update the value with a copy
 * @note No action taken if task is NULL, key is NULL or value is NULL
 * @note value is copied internally so don't forget to free the arg value
 * @param task
 * @param key null-terminated string
 * @param value null-terminated string (which is copied internally)
 */
void EsWorkTaskPropAtPut(EsWorkTask *task, const char *key, char *value);

/**
 * @brief Test if the properties of the task contains the key
 * @param task
 * @param key null-terminated string
 * @return BOOLEAN TRUE if key exists, FALSE otherwise
 */
BOOLEAN EsWorkTaskPropIncludesKey(EsWorkTask *task, const char *key);

/**
 * @brief Remove the key/value string pair and answer the old value
 * @param task
 * @param key null-terminated string
 * @return value null-terminated string
 * @return NULL if key not found, key is NULL, or task is NULL
 */
char *EsWorkTaskPropRemoveKey(EsWorkTask *task, const char *key);

/**
 * @brief Answer TRUE if the existing value at key strequal value argument
 * @note strcmp(props[key], value) == 0
 * @param task
 * @param key null-terminated string
 * @param value null-terminated string
 * @return TRUE if existing value and arg value are strequal, FALSE otherwise
 */
BOOLEAN EsWorkTaskPropValueIs(EsWorkTask *task, const char *key, const char *value);

/**
 * @brief Answer the current number of properties
 * @param task
 * @return number of properties
 * @return 0 if task is NULL
 */
U_32 EsWorkTaskNumProps(EsWorkTask *task);

/*************************/
/*   E X E C U T I O N   */
/*************************/

/**
 * @brief Execute the work task func
 * @param task
 * @post task is still valid and can be run again
 */
void EsRunWorkTask(EsWorkTask *task);

#endif //ES_WORK_TASK_H
