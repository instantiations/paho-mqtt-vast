/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsWorkQueue.c
 *  @brief Work Queue Interface for executing tasks
 *  @author Seth Berman
 *******************************************************************************/
#include "plibsys.h"

#include "EsWorkQueue.h"

/*************************************************/
/*   S Y N C H R O N O U S  Q U E U E  I M P L   */
/*************************************************/

struct _EsWorkQueueSynchronous {
    EsWorkQueue parent;
};

static EsWorkQueue *EsNewWorkQueueSynchronous() {
    struct _EsWorkQueueSynchronous *impl =
            (struct _EsWorkQueueSynchronous *)
                    calloc(1, sizeof(struct _EsWorkQueueSynchronous));
    if (!impl) {
        return (EsWorkQueue *) NULL;
    }
    impl->parent.type = ES_QUEUE_SYNCHRONOUS;

    return (EsWorkQueue *) impl;
}

/*********************************************************************/
/*   M U T E X  P O L L I N G  C O N S U M E R  Q U E U E  I M P L   */
/*********************************************************************/

struct _EsWorkQueueMutexPollingConsumer {
    EsWorkQueue parent;
};

static EsWorkQueue *EsNewWorkQueueMutexPollingConsumer() {
    struct _EsWorkQueueMutexPollingConsumer *impl =
            (struct _EsWorkQueueMutexPollingConsumer *)
                    calloc(1, sizeof(struct _EsWorkQueueMutexPollingConsumer));
    if (!impl) {
        return (EsWorkQueue *) NULL;
    }
    impl->parent.type = ES_QUEUE_MUTEX_POLLING_CONSUMER;

    return (EsWorkQueue *) impl;
}

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

EsWorkQueue *EsNewWorkQueue(enum EsWorkQueueType type) {
    EsWorkQueue *queueImpl = NULL;

    switch (type) {
        case ES_QUEUE_SYNCHRONOUS:
            queueImpl = EsNewWorkQueueSynchronous();
            break;
        case ES_QUEUE_MUTEX_POLLING_CONSUMER:
            queueImpl = EsNewWorkQueueMutexPollingConsumer();
            break;
        default:
            break;
    }

    return queueImpl;
}
