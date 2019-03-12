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
 *******************************************************************************/
#ifndef ES_WORK_QUEUE_H
#define ES_WORK_QUEUE_H

#include "EsWorkTask.h"

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Supported queue types
 */
enum EsWorkQueueType {
    ES_QUEUE_SYNCHRONOUS,
    ES_QUEUE_MUTEX_POLLING_CONSUMER
};

/**
 * @brief
 */
typedef struct _EsWorkQueue EsWorkQueue;
struct _EsWorkQueue {
    enum EsWorkQueueType type;
    void *props;

    /* Lifecycle */
    void (*init)(EsWorkQueue *self);

    void (*shutDown)(EsWorkQueue *self);

    void (*free)(EsWorkQueue *self);

    /* Properties */
    char *(*propAt)(EsWorkQueue *self, const char *key);

    void (*propAtPut)(EsWorkQueue *self, const char *key, char *value);

    char *(*propRemoveKey)(EsWorkQueue *self, const char *key);

    U_32 (*propValueIs)(EsWorkQueue *self, const char *key, char *value);

    U_32 (*numProps)(EsWorkQueue *self);

    void (*flush)(EsWorkQueue *self);
};

/*************************/
/*   L I F E C Y C L E   */
/*************************/

/**
 *
 * @param type
 * @return
 */
EsWorkQueue *EsNewWorkQueue(enum EsWorkQueueType type);


#endif //ES_WORK_QUEUE_H
