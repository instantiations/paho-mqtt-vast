#include "EsUnitTest.h"
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
    EsWorkTask *task;

    task = EsNewWorkTask();

    FreeFuncCalled = 0;
    ES_DENY(FreeFuncCalled);
    EsFreeWorkTask(task);
    ES_DENY(FreeFuncCalled);

    task = EsNewWorkTaskInit(counterWorkTaskFunc, (void *) (U_PTR) 5);
    ES_ASSERT(EsGetWorkTaskFunc(task) == counterWorkTaskFunc);
    ES_ASSERT(EsGetWorkTaskData(task) == (void*)(U_PTR)5);
    EsFreeWorkTask(task);

    return TRUE;
}

/**
 * @brief Test all Get/Set Accessors
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_accessors() {
    EsWorkTask *task;
    void *arg;

    task = EsNewWorkTaskInit(NULL, NULL);
    ES_ASSERT(task != NULL);
    ES_ASSERT(EsGetWorkTaskFunc(task) == NULL);
    ES_ASSERT(EsGetWorkTaskData(task) == NULL);
    ES_ASSERT(EsGetWorkTaskFreeDataFunc(task) == NULL);

    arg = (void *) (U_PTR) 5;
    EsSetWorkTaskFunc(task, counterWorkTaskFunc);
    EsSetWorkTaskData(task, arg);
    EsSetWorkTaskFreeDataFunc(task, noOpFreeWorkTaskDataFunc);
    ES_ASSERT(EsGetWorkTaskFunc(task) == counterWorkTaskFunc);
    ES_ASSERT(EsGetWorkTaskData(task) == arg)
    ES_ASSERT(EsGetWorkTaskFreeDataFunc(task) == noOpFreeWorkTaskDataFunc);

    EsSetWorkTaskFunc(task, NULL);
    EsSetWorkTaskData(task, NULL);
    ES_ASSERT(EsGetWorkTaskFunc(task) == NULL);
    ES_ASSERT(EsGetWorkTaskData(task) == NULL);

    FreeFuncCalled = FALSE;
    ES_DENY(FreeFuncCalled);
    EsFreeWorkTask(task);
    ES_ASSERT(FreeFuncCalled);

    return TRUE;
}

/**
 * @brief Test property accessing
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_properties() {
    EsWorkTask *task;
    EsProperties *props;

    /* Test against null task */
    task = NULL;
    ES_ASSERT(EsGetWorkTaskProps(task) == NULL);

    task = EsNewWorkTask();
    props = EsGetWorkTaskProps(task);
    ES_ASSERT(EsNumProperties(props) == 0);

    EsFreeWorkTask(task);

    return TRUE;
}

/**
 * @brief Test a task that is created and run
 * @note The runnable func will add 5 to the Counter
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_run() {
    EsWorkTask *task;
    void *arg;

    Counter = 0;
    arg = (void *) (U_PTR) 5;
    task = EsNewWorkTaskInit(counterWorkTaskFunc, arg);
    EsRunWorkTask(task);
    ES_ASSERT(Counter == (U_PTR) arg);
    EsFreeWorkTask(task);

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
    ES_RUN_TEST(test_properties);
    ES_RUN_TEST(test_run);
    ES_RETURN_TEST_RESULTS();
}