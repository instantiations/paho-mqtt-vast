/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsProperties.c
 *  @brief Key/Value String Properties Container Implementation
 *  @author Seth Berman
 *******************************************************************************/
#include <stdlib.h>
#include <string.h>

#include "EsProperties.h"

/**
 * @brief BOOLEAN string comparison.
 * @return TRUE if strings are equal, FALSE otherwise
 */
#define STREQ(_s1, _s2) ((strcmp((_s1), (_s2)) == 0) ? TRUE : FALSE)

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Property Node for properties linked list
 */
typedef struct _EsProperty EsProperty;
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
	if (node != NULL) {
		node->key = key;
		node->value = strdup(value); /* Store Copy */
		node->next = NULL;
	}
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

EsProperties *EsProperties_new() {
    return (EsProperties *) calloc(1, sizeof(EsProperties));
}

void EsProperties_free(EsProperties *props) {
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

U_32 EsProperties_getSize(const EsProperties *props) {
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

void EsProperties_atIndex(const EsProperties *props, U_32 index, EsPropertyPair *pair) {
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

const char *EsProperties_at(const EsProperties *props, const char *key) {
    EsProperty *node = NULL;

    node = propertyNodeAt(props, key);
    return (node != NULL) ? node->value : NULL;
}

void EsProperties_atPut(EsProperties *props, const char *key, char *value) {
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

BOOLEAN EsProperties_includesKey(const EsProperties *props, const char *key) {
    return (EsProperties_at(props, key) != NULL) ? TRUE : FALSE;
}

char *EsProperties_removeKey(EsProperties *props, const char *key) {
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

BOOLEAN EsProperties_valueEquals(const EsProperties *props, const char *key, const char *value) {
    const char *result = NULL;

    result = EsProperties_at(props, key);
    return (result != NULL && value != NULL) ? STREQ(result, value) : FALSE;
}

