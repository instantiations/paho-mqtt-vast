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

const char *EsWorkTaskPropAt(EsWorkTask *task, const char *key) {
    return (task != NULL) ? EsPropertyAt(task->props, key) : NULL;
}

void EsWorkTaskPropAtPut(EsWorkTask *task, const char *key, char *value) {
    if (task != NULL) {
        if (task->props != NULL) {
            EsPropertyAtPut(task->props, key, value);
        } else {
            task->props = EsNewProperties();
        }
    }
}

BOOLEAN EsWorkTaskPropIncludesKey(EsWorkTask *task, const char *key) {
    return (task != NULL) ? EsPropertyIncludesKey(task->props, key) : FALSE;
}

char *EsWorkTaskPropRemoveKey(EsWorkTask *task, const char *key) {
    return (task != NULL) ? EsPropertyRemoveKey(task->props, key) : NULL;
}

BOOLEAN EsWorkTaskPropValueIs(EsWorkTask *task, const char *key, const char *value) {
    return (task != NULL) ? EsPropertyValueIs(task->props, key, value) : FALSE;
}

U_32 EsWorkTaskNumProps(EsWorkTask *task) {
    return (task != NULL) ? EsPropertyNum(task->props) : 0;
}

void EsRunWorkTask(EsWorkTask *task) {
    if (task != NULL && task->func != NULL) {
        task->func(task);
    }
}
