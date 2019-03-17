/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsWorkTask.c
 *  @brief Executable Work Task Implementation
 *  @author Seth Berman
 *******************************************************************************/
#include "EsWorkTask.h"

#include <stdlib.h>

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Hidden implementation for EsWorkTask
 *
 * Contains function to apply against args
 * Contains key=value properties that can
 * be queried
 */
struct _EsWorkTask {
    EsProperties *props;
    EsWorkTaskFreeUserDataFunc freeUserDataFunc;
    EsWorkTaskRunFunc runFunc;
    void *userData;
};

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

EsWorkTask *EsWorkTask_new() {
    return (EsWorkTask *) calloc(1, sizeof(EsWorkTask));
}

EsWorkTask *EsWorkTask_newInit(EsWorkTaskRunFunc func, void *args) {
    EsWorkTask *task = NULL;

    task = EsWorkTask_new();
    if (task != NULL) {
        EsWorkTask_setRunFunc(task, func);
        EsWorkTask_setUserData(task, args);
    }
    return task;
}

void EsWorkTask_free(EsWorkTask *task) {
    if (task != NULL) {
        if (task->freeUserDataFunc != NULL) {
            task->freeUserDataFunc(task->userData);
        }
        EsProperties_free(task->props);
        free(task);
    }
}

EsProperties *EsWorkTask_getProperties(const EsWorkTask *task) {
    return (task != NULL) ? task->props : NULL;
}

EsWorkTaskRunFunc EsWorkTask_getRunFunc(const EsWorkTask *task) {
    return (task != NULL) ? task->runFunc : NULL;
}

void EsWorkTask_setRunFunc(EsWorkTask *task, EsWorkTaskRunFunc func) {
    if (task != NULL) {
        task->runFunc = func;
    }
}

EsWorkTaskFreeUserDataFunc EsWorkTask_getFreeUserDataFunc(const EsWorkTask *task) {
    return (task != NULL) ? task->freeUserDataFunc : NULL;
}

void EsWorkTask_setFreeUserDataFunc(EsWorkTask *task, EsWorkTaskFreeUserDataFunc func) {
    if (task != NULL) {
        task->freeUserDataFunc = func;
    }
}

void *EsWorkTask_getUserData(const EsWorkTask *task) {
    return (task != NULL) ? task->userData : NULL;
}

void EsWorkTask_setUserData(EsWorkTask *task, void *data) {
    if (task != NULL) {
        task->userData = data;
    }
}

void EsWorkTask_run(EsWorkTask *task) {
    if (task != NULL && task->runFunc != NULL) {
        task->runFunc(task);
    }
}
