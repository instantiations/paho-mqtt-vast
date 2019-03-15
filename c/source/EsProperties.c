/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsProperties.c
 *  @brief Key/Value String Properties Container Implementation
 *  @author Seth Berman
 *******************************************************************************/
#include "EsProperties.h"

#include <stdlib.h>
#include <string.h>

/**
 * @brief BOOLEAN string comparison.
 * @return TRUE if strings are equal, FALSE otherwise
 */
#define STREQ(_s1, _s2) ((strcmp((_s1), (_s2)) == 0) ? TRUE : FALSE)

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Property Node for properties container
 */
typedef struct _EsProperty EsProperty;

/**
 * @brief Property Node for properties linked list
 */
struct _EsProperty {
    const char *key;
    char *value;
    EsProperty *next;
};

/**
 * @brief Container for properties
 * @note This is what the user has a handle to
 */
struct _EsProperties {
    EsProperty *head;
};

/***************************/
/*   P R O P E R T I E S   */
/***************************/

/**
 * @brief Answer new init instance of property
 * @param key null-terminated string
 * @param value null-terminated string
 * @return new property or NULL if out of memory
 */
static EsProperty *newProperty(const char *key, char *value) {
    EsProperty *node = (EsProperty *) malloc(sizeof(*node));
    node->key = key;
    node->value = strdup(value); /* Store Copy */
    node->next = NULL;
    return node;
}

/**
 * @brief Answer the node before the node with key
 * @param props
 * @param key null-terminated key
 * @return EsProperty*
 * @return NULL if node to find is first in list, props is NULL or key is NULL
 */
static EsProperty *propertyNodeBeforeNodeAt(const EsProperties *props, const char *key) {
    EsProperty *prev = NULL;

    if (props != NULL && key != NULL) {
        EsProperty *next = props->head;
        while (next != NULL) {
            if (STREQ(next->key, key)) {
                break;
            }
            prev = next;
            next = next->next;
        }
    }
    return prev;
}

/**
 * @brief Answer the node with matching key
 * @param props
 * @param key null-terminated key
 * @return EsProperty*
 * @return NULL if node not found, props is NULL or key is NULL
 */
static EsProperty *propertyNodeAt(const EsProperties *props, const char *key) {
    EsProperty *node = NULL;

    if (props != NULL && key != NULL) {
        node = props->head;
        while (node != NULL) {
            if (STREQ(node->key, key)) {
                break;
            }
            node = node->next;
        }
    }
    return node;
}

/******************************************************/
/*   I N T E R F A C E  I M P L E M E N T A T I O N   */
/******************************************************/

EsProperties *EsNewProperties() {
    return (EsProperties *) calloc(1, sizeof(EsProperties));
}

void EsFreeProperties(EsProperties *props) {
    if (props != NULL) {
        EsProperty *curr = props->head;
        while (curr != NULL) {
            EsProperty *temp = curr;
            curr = curr->next;
            free(temp->value);
            free(temp);
        }
        free(props);
    }
}

U_32 EsNumProperties(const EsProperties *props) {
    U_32 numProps = 0;

    if (props != NULL) {
        EsProperty *curr = props->head;
        while (curr != NULL) {
            numProps++;
            curr = curr->next;
        }
    }
    return numProps;
}

void EsPropertyPairAtIndex(const EsProperties *props, U_32 index, EsPropertyPair *const pair) {
    EsProperty *curr = NULL;
    U_32 i;

    if (pair != NULL) {
        if (props != NULL) {
            curr = props->head;
            /* Cursor forward until index (or reached the end) */
            for (i = 0; curr != NULL && i != index; curr = curr->next, i++);
            if (curr != NULL && i == index) {
                pair->key = curr->key;
                pair->value = curr->value;
            } else {
                pair->key = NULL;
                pair->value = NULL;
            }
        } else {
            /* props or props head was NULL */
            pair->key = NULL;
            pair->value = NULL;
        }
    }
}

const char *EsPropertyAt(const EsProperties *props, const char *key) {
    EsProperty *node = NULL;

    node = propertyNodeAt(props, key);
    return (node != NULL) ? node->value : NULL;
}

void EsPropertyAtPut(EsProperties *props, const char *key, char *value) {
    if (props != NULL && key != NULL && value != NULL) {
        EsProperty *node = propertyNodeAt(props, key);
        if (node != NULL) {
            /* Update Existing Entry */
            node->value = value;
        } else {
            /* New Entry */
            node = newProperty(key, value);
            if (props->head != NULL) {
                EsProperty *lastNode = props->head;
                while (lastNode->next != NULL) {
                    lastNode = lastNode->next;
                }
                lastNode->next = node;
            } else {
                props->head = node;
            }
        }
    }
}

BOOLEAN EsPropertyIncludesKey(const EsProperties *props, const char *key) {
    return (EsPropertyAt(props, key) != NULL) ? TRUE : FALSE;
}

char *EsPropertyRemoveKey(EsProperties *props, const char *key) {
    char *value = NULL;

    EsProperty *node = propertyNodeAt(props, key);
    if (node != NULL) {
        EsProperty *beforeNode = propertyNodeBeforeNodeAt(props, key);
        value = node->value;
        if (beforeNode != NULL) {
            beforeNode->next = node->next;
        } else {
            props->head = node->next;
        }
        node->next = NULL;
        free(node);
    }
    return value;
}

BOOLEAN EsPropertyValueIs(const EsProperties *props, const char *key, const char *value) {
    const char *result = NULL;

    result = EsPropertyAt(props, key);
    return (result != NULL && value != NULL) ? STREQ(result, value) : FALSE;
}

