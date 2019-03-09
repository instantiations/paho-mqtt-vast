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
#include <string.h>

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Property Node for properties linked list
 */
typedef struct _EsWorkTaskPropertyNode EsWorkTaskPropertyNode;
struct _EsWorkTaskPropertyNode {
    const char *key;
    char *value;
    EsWorkTaskPropertyNode *next;
};

/**
 * @brief Hidden implementation for EsWorkTask
 *
 * Contains function to apply against args
 * Contains key=value properties that can
 * be queried
 */
struct _EsWorkTask {
    EsWorkTaskPropertyNode *props;
    EsWorkTaskFreeDataFunc freeDataFunc;
    EsWorkTaskFunc func;
    void *data;
};

/***************************/
/*   P R O P E R T I E S   */
/***************************/

/**
 * @brief Answer the node before the node with key
 * @param task
 * @param key null-terminated key
 * @return EsWorkTaskPropertyNode*
 * @return NULL if node to find is first in list, task is NULL or key is NULL
 */
EsWorkTaskPropertyNode *propertyNodeBeforeNodeAt(const EsWorkTask *task, const char *key) {
    EsWorkTaskPropertyNode *prev = NULL;
    if (task && key) {
        EsWorkTaskPropertyNode *next = task->props;
        while (next != NULL) {
            if (strcmp(next->key, key) == 0) {
                return prev;
            }
            prev = next;
            next = next->next;
        }
    }
    return prev;
}

/**
 * @brief Answer the node with matching key
 * @param task
 * @param key null-terminated key
 * @return EsWorkTaskPropertyNode*
 * @return NULL if node not found, task is NULL or key is NULL
 */
EsWorkTaskPropertyNode *propertyNodeAt(const EsWorkTask *task, const char *key) {
    if (task && task->props && key) {
        EsWorkTaskPropertyNode *node = task->props;

        if (strcmp(node->key, key) == 0) {
            return node;
        }
        node = node->next;
        while (node != NULL) {
            if (strcmp(node->key, key) == 0) {
                return node;
            }
            node = node->next;
        }
    }
    return (EsWorkTaskPropertyNode *) NULL;
}

/**
 * @brief Free the properties memory
 * @note The null-terminated string value is strdup internally
 * upon node creation and must be freed.
 * @param task
 */
void freeProps(EsWorkTask *task) {
    if (task) {
        EsWorkTaskPropertyNode *curr = task->props;
        while (curr != NULL) {
            EsWorkTaskPropertyNode *temp = curr;
            curr = curr->next;
            free(temp->value);
            free(temp);
        }
    }
}

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

EsWorkTask *EsNewWorkTask(EsWorkTaskFunc func, void *data) {
    EsWorkTask *task = (EsWorkTask *) malloc(sizeof(EsWorkTask));
    if (!task) {
        return NULL;
    }
    task->props = NULL;
    task->freeDataFunc = NULL;
    task->func = func;
    task->data = data;
    return task;
}

void EsFreeWorkTask(EsWorkTask *task) {
    if (task) {
        if (task->freeDataFunc) {
            task->freeDataFunc(task->data);
        }
        freeProps(task);
        free(task);
    }
}

EsWorkTaskFunc EsGetWorkTaskFunc(const EsWorkTask *task) {
    if (!task) {
        return (EsWorkTaskFunc) NULL;
    }
    return task->func;
}

void EsSetWorkTaskFunc(EsWorkTask *task, EsWorkTaskFunc func) {
    if (task) {
        task->func = func;
    }
}

EsWorkTaskFreeDataFunc EsGetWorkTaskFreeDataFunc(const EsWorkTask *task) {
    if (!task) {
        return (EsWorkTaskFreeDataFunc) NULL;
    }
    return task->freeDataFunc;
}

void EsSetWorkTaskFreeDataFunc(EsWorkTask *task, EsWorkTaskFreeDataFunc func) {
    if (task) {
        task->freeDataFunc = func;
    }
}

void *EsGetWorkTaskData(const EsWorkTask *task) {
    if (!task) {
        return NULL;
    }
    return task->data;
}

void EsSetWorkTaskData(EsWorkTask *task, void *data) {
    if (task) {
        task->data = data;
    }
}

char *EsWorkTaskPropAt(EsWorkTask *task, const char *key) {
    char *value = NULL;

    if (task && task->props) {
        EsWorkTaskPropertyNode *node = propertyNodeAt(task, key);
        if (node) {
            value = node->value;
        }
    }
    return value;
}

void EsWorkTaskPropAtPut(EsWorkTask *task, const char *key, char *value) {
    if (task && key && value) {
        EsWorkTaskPropertyNode *node = propertyNodeAt(task, key);
        if (node) {
            node->value = value;
        } else {
            node = (EsWorkTaskPropertyNode *) malloc(sizeof(EsWorkTaskPropertyNode));
            node->key = key;
            node->value = strdup(value); /* Store Copy */
            node->next = NULL;
            if (!task->props) {
                task->props = node;
            } else {
                EsWorkTaskPropertyNode *lastNode = task->props;
                while (lastNode->next != NULL) {
                    lastNode = lastNode->next;
                }
                lastNode->next = node;
            }
        }
    }
}

char *EsWorkTaskPropRemoveKey(EsWorkTask *task, const char *key) {
    char *value = NULL;
    if (task && task->props) {
        EsWorkTaskPropertyNode *node = propertyNodeAt(task, key);
        if (node) {
            EsWorkTaskPropertyNode *beforeNode = propertyNodeBeforeNodeAt(task, key);
            value = node->value;
            if (beforeNode != NULL) {
                beforeNode->next = node->next;
            } else {
                task->props = node->next;
            }
            node->next = NULL;
            free(node);
        }
    }
    return value;
}

BOOLEAN EsWorkTaskPropValueIs(EsWorkTask *task, const char *key, char *value) {
    char *result = EsWorkTaskPropAt(task, key);
    if (!result) {
        return FALSE;
    }
    return (strcmp(result, value) == 0) ? TRUE : FALSE;
}

U_32 EsWorkTaskNumProps(EsWorkTask *task) {
    U_32 numProps = 0;
    if(task && task->props) {
        EsWorkTaskPropertyNode *curr = task->props;
        while(curr != NULL) {
            numProps++;
            curr = curr->next;
        }
    }
    return numProps;
}

void EsRunWorkTask(EsWorkTask *task) {
    if (task && task->func) {
        task->func(task);
    }
}
