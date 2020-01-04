#include "EsUnitTest.h"
#include "EsWorkTask.h"

#include "EsMqtt.h"

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

    task = EsWorkTask_new();

    FreeFuncCalled = 0;
    ES_DENY(FreeFuncCalled);
    EsWorkTask_free(task);
    ES_DENY(FreeFuncCalled);

    task = EsWorkTask_newInit(counterWorkTaskFunc, (void *) (U_PTR) 5);
    ES_ASSERT(EsWorkTask_getRunFunc(task) == counterWorkTaskFunc);
    ES_ASSERT(EsWorkTask_getUserData(task) == (void *) (U_PTR) 5);
    EsWorkTask_free(task);

    return TRUE;
}

/**
 * @brief Test all Get/Set Accessors
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_accessors() {
    EsWorkTask *task;
    void *arg;

    task = EsWorkTask_newInit(NULL, NULL);
    ES_ASSERT(task != NULL);
    ES_ASSERT(EsWorkTask_getRunFunc(task) == NULL);
    ES_ASSERT(EsWorkTask_getUserData(task) == NULL);
    ES_ASSERT(EsWorkTask_getFreeUserDataFunc(task) == NULL);

    arg = (void *) (U_PTR) 5;
    EsWorkTask_setRunFunc(task, counterWorkTaskFunc);
    EsWorkTask_setUserData(task, arg);
    EsWorkTask_setFreeUserDataFunc(task, noOpFreeWorkTaskDataFunc);
    ES_ASSERT(EsWorkTask_getRunFunc(task) == counterWorkTaskFunc);
    ES_ASSERT(EsWorkTask_getUserData(task) == arg)
    ES_ASSERT(EsWorkTask_getFreeUserDataFunc(task) == noOpFreeWorkTaskDataFunc);

    EsWorkTask_setRunFunc(task, NULL);
    EsWorkTask_setUserData(task, NULL);
    ES_ASSERT(EsWorkTask_getRunFunc(task) == NULL);
    ES_ASSERT(EsWorkTask_getUserData(task) == NULL);

    FreeFuncCalled = FALSE;
    ES_DENY(FreeFuncCalled);
    EsWorkTask_free(task);
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
    ES_ASSERT(EsWorkTask_getProperties(task) == NULL);

    task = EsWorkTask_new();
    props = EsWorkTask_getProperties(task);
    ES_ASSERT(EsProperties_getSize(props) == 0);

    EsWorkTask_free(task);

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
    task = EsWorkTask_newInit(counterWorkTaskFunc, arg);
    EsWorkTask_run(task);
    ES_ASSERT(Counter == (U_PTR) arg);
    EsWorkTask_free(task);

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