#include "EsUnitTest.h"
#include "EsWorkQueue.h"
#include "EsWorkTask.h"

#include "esuser.h"

static U_PTR Counter = 0;
static pboolean FreeFuncCalled = FALSE;

/*******************/
/*  U T I L I T Y  */
/*******************/

/**
 * @brief Simple work function to execute for tasks
 * @param task
 */
static void counterWorkTaskFunc(EsWorkTask *task) {
    U_PTR incAmount = (U_PTR) EsGetWorkTaskData(task);
    Counter += incAmount;
}

/**
 * @brief Free Data function that only simulates a free
 * @param data
 */
static void noOpFreeWorkTaskDataFunc(void *data) {
    FreeFuncCalled = TRUE;
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
    EsWorkQueue *queue;

    queue = EsNewWorkQueue(ES_QUEUE_SYNCHRONOUS);
    //EsFreeWorkQueue(queue);

    return TRUE;
}

/**
 * @brief Test all Get/Set Accessors
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_accessors() {
    EsWorkQueue *queue;

    //queue = EsNewWorkQueue(ES_QUEUE_SYNCHRONOUS);

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
    ES_RUN_TEST(test_accessors);
    ES_RETURN_TEST_RESULTS();
}