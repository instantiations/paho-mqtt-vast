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

/*******************/
/*   M A C R O S   */
/*******************/

/**
 * @brief Common downcast of self ptr to concrete struct
 */
#define DECL_SELF(_type, _var) _type *_var = (_type*)self;

/**
 * @brief Atomic Operations
 */
#define I_CMPXCHG   p_atomic_int_compare_and_exchange
#define I_GET       p_atomic_int_get
#define I_SET       p_atomic_int_set
#define I_INC       p_atomic_int_inc
#define I_DEC       p_atomic_int_dec_and_test

/**
 * @brief Mutex Operations
 */
#define MUTEX_LOCK      p_mutex_lock
#define MUTEX_UNLOCK    p_mutex_unlock
#define MUTEX_NEW       p_mutex_new
#define MUTEX_FREE      p_mutex_free

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @struct EsWorkQueue
 * @brief Abstract Queue that executes dequeue'd tasks
 * @see Abstract Queue Impl section below for
 * generic function templates
 *
 * This is an abstract work queue that uses plugable function
 * slots to give a kind of Prototype-Based data structure that
 * can be overridden
 *
 * Concrete queues should add the work queue as its first member
 * so it can be up-casted.
 * @example
 * struct MyWorkQueue {
 *  EsWorkQueue parent;
 *  void *additionalState;
 * }
 * ...
 * EsWorkQueue *queue = EsWorkQueue_new(ESQ_TYPE_SYNCHRONOUS)
 * queue->shutDown = myShutdownImpl;
 *
 * @see Synchronous Queue Impl below for a complete example
 *
 */
struct _EsWorkQueue {
    /* Lifecycle */
    void (*init)(EsWorkQueue *self);

    void (*shutDown)(EsWorkQueue *self);

    void (*free)(EsWorkQueue *self);

    /* Accessing */
    EsProperties *(*getProps)(const EsWorkQueue *self);

    U_32 (*getNumTasks)(const EsWorkQueue *self);

    /* Queue API */
    void (*enqueue)(EsWorkQueue *self, EsWorkTask *task);

    EsWorkTask *(*dequeue)(EsWorkQueue *self);

    /* State */
    EsProperties *props;
    enum EsWorkQueueType type;
};

/*******************************************/
/*   A B S T R A C T  Q U E U E  I M P L   */
/*******************************************/

/**
 * @brief Initialize the queue
 * @note hook for creating resources
 * @example Create a new mutex
 * @param self
 */
static void genericInit(EsWorkQueue *self) {
    ES_UNUSED(self);
}

/**
 * @brief Shutdown the queue
 * @note hook for gracefully destroying resources
 * @example Acquire mutex lock and destroy it.
 * @param self
 */
static void genericShutdown(EsWorkQueue *self) {
    ES_UNUSED(self);
}

/**
 * @brief Free memory associated with the queue
 * @param self
 */
static void genericFree(EsWorkQueue *self) {
    if (self != NULL) {
        EsProperties_free(self->props);
        free(self);
    }
}

/**
 * @brief Generic properties accessor
 * @param self
 * @return EsProperties
 */
static EsProperties *genericGetProps(const EsWorkQueue *self) {
    return (self != NULL) ? self->props : NULL;
}

/**
 * @brief Generic number of tasks accessor
 * @param self
 * @return EsProperties
 */
static U_32 genericGetNumTasks(const EsWorkQueue *self) {
    ES_UNUSED(self);
    return 0;
}

/**
 * @brief Generic adding task to the queue
 * @note No-Op
 * @param queue
 */
static void genericEnqueue(EsWorkQueue *self, EsWorkTask *task) {
    ES_UNUSED(self);
    ES_UNUSED(task);
}

/**
 * @brief Generic removal of task from the queue
 * @note No-Op
 * @param self
 * @return NULL
 */
static EsWorkTask *genericDequeue(EsWorkQueue *self) {
    ES_UNUSED(self);
    return NULL;
}

/**
 * @brief Init the state and queue slots with generic functions.
 * @param queue
 */
static void initWorkQueue(EsWorkQueue *queue) {
    if (queue != NULL) {
        /* State */
        queue->type = ESQ_TYPE_UNDEFINED;
        queue->props = EsProperties_new();

        /* Function Slots */
        queue->init = genericInit;
        queue->shutDown = genericShutdown;
        queue->free = genericFree;
        queue->getProps = genericGetProps;
        queue->getNumTasks = genericGetNumTasks;
        queue->enqueue = genericEnqueue;
        queue->dequeue = genericDequeue;
    }
}

/*************************************************/
/*   S Y N C H R O N O U S  Q U E U E  I M P L   */
/*************************************************/

/**
 * @struct EsSyncWorkQueue
 * @brief Concrete Lock-Less Multi-Producer/Single Consumer work queue
 * @note Synchronous work queues are intended to be used
 * only for testing.
 * @note Thread-safe (via lock-less atomics)
 *
 * A Synchronous work queue can accept multiple producers
 * submitting tasks (from different OS threads) to the queue.
 * The consumer runs in the same thread as the producer.
 * Tasks are consumed one at a time.
 * The moment a task is successfully "submitted", it is then
 * executed. In effect, the producer is the consumer.
 * Therefore, the "queue" can be thought of as the line that
 * forms when looping on atomic compareExchange guards that
 * control state transitions.
 *
 * This type of queue is quite limiting unless a simple
 * low-throughput, but thread-safe, queue is desired.
 *
 * The primary purpose of this queue type is to help simplify
 * internal testing scenarios
 */
typedef struct _EsSyncWorkQueue EsSyncWorkQueue;
struct _EsSyncWorkQueue {
    EsWorkQueue parent;
    volatile I_32 state;
    volatile I_32 numTasks;
};

/**
 * @brief Sync Queue States
 *
 * The module state lifecycle is
 * IDLE -> BUSY -> SHUTDOWN
 *
 * IDLE: Initial State - Ready for task execution
 * BUSY: Executing task - new enqueue must wait
 * SHUTDOWN: Terminal state - No new tasks
 */
static const I_32 ESQ_SYNC_STATE_IDLE = 2;
static const I_32 ESQ_SYNC_STATE_BUSY = 3;
static const I_32 ESQ_SYNC_STATE_SHUTDOWN = 4;

/**
 * @brief Add task to "virtual" queue to be executed by single consumer
 * @param self
 * @param task to enqueue
 * @note thread-safe
 *
 * Multiple-Producers / Single Consumer
 * This is a "virtual queue" so there is no data-structure that holds
 * pending tasks.
 * On entry, the number of tasks is incremented.
 * Go into loop attempting atomic state transition from IDLE -> BUSY
 * Once transitioned, the task is executed and then transitions back to IDLE
 * This means a single task can be executed at a time (even if submitting from
 * many OS threads at the same time)
 * Exit if a transition occurs to the SHUTDOWN state. If the task has not been
 * run, then it is simply cancelled.
 */
static void syncEnqueue(EsWorkQueue *self, EsWorkTask *task) {
    DECL_SELF(EsSyncWorkQueue, queue);

    if (queue != NULL && task != NULL) {
        I_INC(&queue->numTasks);
        do {
            if (I_CMPXCHG(&queue->state, ESQ_SYNC_STATE_IDLE, ESQ_SYNC_STATE_BUSY) == TRUE) {
                I_DEC(&queue->numTasks);
                EsWorkTask_run(task);
                queue->state = ESQ_SYNC_STATE_IDLE;
                break;
            } else if (queue->state == ESQ_SYNC_STATE_SHUTDOWN) {
                I_DEC(&queue->numTasks);
                break;
            }
        } while (TRUE);
    }
}

/**
 * @brief Shutdown the queue and free resources
 * @param self
 * @note A task in progress is allowed to finish
 * @note thread-safe
 *
 * Try state transitions from IDLE -> SHUTDOWN until successful.
 * On success, wait until the number of tasks waiting drops to 0.
 * Any future enqueues attempted will be rejected.
 * If the queue already shutdown, then just leave
 */
static void syncShutdown(EsWorkQueue *self) {
    DECL_SELF(EsSyncWorkQueue, queue);

    if (queue != NULL) {
        do {
            if (I_CMPXCHG(&queue->state, ESQ_SYNC_STATE_IDLE, ESQ_SYNC_STATE_SHUTDOWN) == TRUE) {
                /* Flush existing tasks */
                while (queue->numTasks > 0) {
                    p_uthread_sleep(50);
                }
                break;
            } else if (queue->state == ESQ_SYNC_STATE_SHUTDOWN) {
                break;
            }
        } while (TRUE);
    }
}

/**
 * @brief Free memory associated with the queue
 * @note A shutdown is performed first to ensure
 * not tasks will attempt to use the data structure
 * @param self
 */
static void syncFree(EsWorkQueue *self) {
    syncShutdown(self);
    EsProperties_free(self->props);
    free(self);
}

/**
 * @brief Answer the current number of tasks in the queue
 * @note Executing tasks are not considered since they are dequeued
 * @param self
 * @return U_32
 */
static U_32 syncGetNumTasks(const EsWorkQueue *self) {
    DECL_SELF(EsSyncWorkQueue, queue);
    I_32 numTasks = 0;

    if (queue != NULL) {
        do {
            if (I_CMPXCHG(&queue->state, ESQ_SYNC_STATE_IDLE, ESQ_SYNC_STATE_BUSY) == TRUE) {
                numTasks = queue->numTasks;
                queue->state = ESQ_SYNC_STATE_IDLE;
                break;
            } else if (queue->state == ESQ_SYNC_STATE_SHUTDOWN) {
                return 0;
            }
        } while (TRUE);
    }
    return (U_32) numTasks;
}

/**
 * @brief Answer a new synchronous work queue
 * @return queue
 */
static EsWorkQueue *EsSyncWorkQueue_new() {
    EsSyncWorkQueue *impl = NULL;

    impl = (EsSyncWorkQueue *) calloc(1, sizeof(*impl));
    if (impl != NULL) {
        initWorkQueue((EsWorkQueue *) impl);

        impl->state = ESQ_SYNC_STATE_IDLE;
        impl->numTasks = 0;

        /* Overrides */
        impl->parent.type = ESQ_TYPE_SYNCHRONOUS;
        impl->parent.shutDown = syncShutdown;
        impl->parent.enqueue = syncEnqueue;
        impl->parent.getNumTasks = syncGetNumTasks;
        impl->parent.free = syncFree;
    }

    return (EsWorkQueue *) impl;
}


/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

EsProperties *EsWorkQueue_getProperties(const EsWorkQueue *queue) {
    return (queue != NULL) ? queue->props : NULL;
}

EsWorkQueue *EsWorkQueue_new(enum EsWorkQueueType type) {
    EsWorkQueue *queueImpl = NULL;

    switch (type) {
        case ESQ_TYPE_SYNCHRONOUS:
            queueImpl = EsSyncWorkQueue_new();
            break;
        default:
            break;
    }

    return queueImpl;
}

void EsWorkQueue_free(EsWorkQueue *queue) {
    if (queue != NULL) {
        queue->free(queue);
    }
}

void EsWorkQueue_init(EsWorkQueue *queue) {
    if (queue != NULL) {
        queue->init(queue);
    }
}

void EsWorkQueue_shutdown(EsWorkQueue *queue) {
    if (queue != NULL) {
        queue->shutDown(queue);
    }
}

void EsWorkQueue_submit(EsWorkQueue *queue, EsWorkTask *task) {
    if (queue != NULL) {
        queue->enqueue(queue, task);
    }
}

U_32 EsWorkQueue_getSize(const EsWorkQueue *queue) {
    return (queue != NULL) ? queue->getNumTasks(queue) : 0;
}
