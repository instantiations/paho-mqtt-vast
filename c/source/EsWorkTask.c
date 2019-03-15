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
#include "EsProperties.h"

#include <stdlib.h>
#include <string.h>

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
    EsWorkTaskFreeDataFunc freeDataFunc;
    EsWorkTaskFunc func;
    void *data;
};

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

EsWorkTask *EsNewWorkTask() {
    return (EsWorkTask *) calloc(1, sizeof(EsWorkTask));
}

EsWorkTask *EsNewWorkTaskInit(EsWorkTaskFunc func, void *args) {
    EsWorkTask *task = NULL;

    task = EsNewWorkTask();
    if (task != NULL) {
        EsSetWorkTaskFunc(task, func);
        EsSetWorkTaskData(task, args);
    }
    return task;
}

void EsFreeWorkTask(EsWorkTask *task) {
    if (task != NULL) {
        if (task->freeDataFunc != NULL) {
            task->freeDataFunc(task->data);
        }
        EsFreeProperties(task->props);
        free(task);
    }
}

EsProperties *EsGetWorkTaskProps(const EsWorkTask *task) {
    return (task != NULL) ? task->props : NULL;
}

EsWorkTaskFunc EsGetWorkTaskFunc(const EsWorkTask *task) {
    return (task != NULL) ? task->func : NULL;
}

void EsSetWorkTaskFunc(EsWorkTask *task, EsWorkTaskFunc func) {
    if (task != NULL) {
        task->func = func;
    }
}

EsWorkTaskFreeDataFunc EsGetWorkTaskFreeDataFunc(const EsWorkTask *task) {
    return (task != NULL) ? task->freeDataFunc : NULL;
}

void EsSetWorkTaskFreeDataFunc(EsWorkTask *task, EsWorkTaskFreeDataFunc func) {
    if (task != NULL) {
        task->freeDataFunc = func;
    }
}

void *EsGetWorkTaskData(const EsWorkTask *task) {
    return (task != NULL) ? task->data : NULL;
}

void EsSetWorkTaskData(EsWorkTask *task, void *data) {
    if (task != NULL) {
        task->data = data;
    }
}

void EsRunWorkTask(EsWorkTask *task) {
    if (task != NULL && task->func != NULL) {
        task->func(task);
    }
}
