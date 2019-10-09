#include "EsUnitTest.h"
#include "EsWorkQueue.h"
#include "EsWorkTask.h"

#include "esuser.h"

static U_PTR Counter = 0;
static EsWorkQueue *Queue;
static pboolean FreeFuncCalled = FALSE;

/*******************/
/*  U T I L I T Y  */
/*******************/

/**
 * @brief Simple work function to execute for tasks
 * @param task
 */
static void counterWorkTaskFunc(EsWorkTask *task) {
    U_PTR incAmount = (U_PTR) EsWorkTask_getUserData(task);
    Counter += incAmount;
}

/**
 * @brief Free Data function that only simulates a free
 * @param data
 */
static void noOpFreeWorkTaskDataFunc(void *data) {
    FreeFuncCalled = TRUE;
}

/**
 * @brief Thread-Function
 * @param arg
 * @return Exit code after thread is done
 */
static void *produceCounterIncrementer(void *arg) {
    int numTasks = (U_32) (U_PTR) arg;
    for (int i = 0; i < numTasks; i++) {
        EsWorkTask *task = NULL;

        task = EsWorkTask_newInit(counterWorkTaskFunc, (void *) (U_PTR) 1);
        EsWorkQueue_submit(Queue, task);
    }
    p_uthread_exit(0);
    return NULL;
}

/*****************/
/*   T E S T S   */
/*****************/

/**
 * @brief Test New/Free.
 * @note This also tests that a NULL EsWorkTaskFreeDataFunc is ok
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_newFree() {

    Queue = NULL;
    ES_ASSERT(EsWorkQueue_getSize(Queue) == 0);
    Queue = EsWorkQueue_new(ESQ_TYPE_SYNCHRONOUS);
    ES_ASSERT(EsWorkQueue_getSize(Queue) == 0);
    ES_ASSERT(Queue != NULL);
    EsWorkQueue_free(Queue);

    return TRUE;
}

/**
 * @brief Test property accessing
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_properties() {
    EsProperties *props;

    /* Test against null task */
    Queue = NULL;
    ES_ASSERT(EsWorkQueue_getProperties(Queue) == NULL);

    Queue = EsWorkQueue_new(ESQ_TYPE_SYNCHRONOUS);
    props = EsWorkQueue_getProperties(Queue);
    ES_ASSERT(EsProperties_getSize(props) == 0);

    EsWorkQueue_free(Queue);

    return TRUE;
}

/**
 * @brief Test execution of a single task in the
 * test thread for SYNC
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_sync_currentThreadProducer() {
    U_32 numTasks = 1000;

    Counter = 0;
    Queue = EsWorkQueue_new(ESQ_TYPE_SYNCHRONOUS);
    ES_ASSERT(Counter == 0);
    for (U_32 i = 0; i < numTasks; i++) {
        EsWorkTask *task = NULL;

        task = EsWorkTask_newInit(counterWorkTaskFunc, (void *) (U_PTR) 1);
        EsWorkQueue_submit(Queue, task);
    }
    ES_ASSERT(EsWorkQueue_getSize(Queue) == 0);
    EsWorkQueue_free(Queue);
    ES_ASSERT(Counter == numTasks);
    return TRUE;
}

/**
 * @brief Test execution of a tasks that are produced
 * in separate threads for type SYNC
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_sync_separateThreadProducer() {
    EsWorkQueue *queue = NULL;
    U_32 numTasks = 1000;

    Counter = 0;
    Queue = EsWorkQueue_new(ESQ_TYPE_SYNCHRONOUS);
    EsWorkQueue_init(queue);

    PUThread *producer = p_uthread_create((PUThreadFunc) produceCounterIncrementer, (ppointer) (U_PTR) numTasks, TRUE);
    ES_DENY(producer == NULL);
    p_uthread_join(producer);
    p_uthread_unref(producer);
    EsWorkQueue_free(queue);
    ES_ASSERT(Counter == numTasks);
    return TRUE;
}

/**************************/
/*   T E S T  S U I T E   */
/**************************/

/**
 * Run all Tests
 * @return 0 on Pass, -1 on Fail
 */
int main() {
    ES_RUN_TEST(test_newFree);
    ES_RUN_TEST(test_sync_currentThreadProducer);
    ES_RUN_TEST(test_sync_separateThreadProducer);
    ES_RETURN_TEST_RESULTS();
}