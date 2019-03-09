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

    task = EsNewWorkTask(NULL, NULL);

    FreeFuncCalled = 0;
    ES_DENY(FreeFuncCalled);
    EsFreeWorkTask(task);
    ES_DENY(FreeFuncCalled);

    return TRUE;
}

/**
 * @brief Test all Get/Set Accessors
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_accessors() {
    EsWorkTask *task;
    void *arg;

    task = EsNewWorkTask(NULL, NULL);
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

static pboolean test_properties() {
    EsWorkTask *task;
    char *val;

    /* Test against null task */
    task = NULL;
    ES_ASSERT(EsWorkTaskNumProps(task) == 0);
    ES_ASSERT(EsWorkTaskPropAt(task, NULL) == NULL);
    EsWorkTaskPropAtPut(task, NULL, NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, NULL, NULL) == FALSE);
    ES_ASSERT(EsWorkTaskPropRemoveKey(task, NULL) == NULL);

    task = EsNewWorkTask(NULL, NULL);

    /* Test against null args */
    ES_ASSERT(EsWorkTaskNumProps(task) == 0);
    ES_ASSERT(EsWorkTaskPropAt(task, NULL) == NULL);
    EsWorkTaskPropAtPut(task, NULL, NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, NULL, NULL) == FALSE);
    ES_ASSERT(EsWorkTaskPropRemoveKey(task, NULL) == NULL);

    /* Test empty prop task / valid keys */
    ES_ASSERT(EsWorkTaskNumProps(task) == 0);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key") == NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key", "Value") == FALSE);

    /* Add key */
    EsWorkTaskPropAtPut(task, "Key", "Value");
    ES_ASSERT(EsWorkTaskNumProps(task) == 1);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key") != NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key", "Value"));

    /* Add second key */
    EsWorkTaskPropAtPut(task, "Key2", "Value2");
    ES_ASSERT(EsWorkTaskNumProps(task) == 2);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key") != NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key", "Value"));
    ES_ASSERT(EsWorkTaskPropAt(task, "Key2") != NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key2", "Value2"));

    /* Add third key */
    EsWorkTaskPropAtPut(task, "Key3", "Value3");
    ES_ASSERT(EsWorkTaskNumProps(task) == 3);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key") != NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key", "Value"));
    ES_ASSERT(EsWorkTaskPropAt(task, "Key2") != NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key2", "Value2"));
    ES_ASSERT(EsWorkTaskPropAt(task, "Key3") != NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key3", "Value3"));

    /* Remove head */
    val = EsWorkTaskPropRemoveKey(task, "Key");
    ES_ASSERT(EsWorkTaskNumProps(task) == 2);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value", strlen("Value")) == 0);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key") == NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key", "Value") == FALSE);

    /* Remove tail */
    val = EsWorkTaskPropRemoveKey(task, "Key3");
    ES_ASSERT(EsWorkTaskNumProps(task) == 1);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value3", strlen("Value3")) == 0);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key3") == NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key3", "Value3") == FALSE);

    /* Remove last*/
    val = EsWorkTaskPropRemoveKey(task, "Key2");
    ES_ASSERT(EsWorkTaskNumProps(task) == 0);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value2", strlen("Value2")) == 0);
    ES_ASSERT(EsWorkTaskPropAt(task, "Key2") == NULL);
    ES_ASSERT(EsWorkTaskPropValueIs(task, "Key2", "Value2") == FALSE);

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
    task = EsNewWorkTask(counterWorkTaskFunc, arg);
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