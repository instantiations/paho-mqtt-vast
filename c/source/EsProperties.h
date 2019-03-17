/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsProperties.h
 *  @brief Key/Value String Properties Container Interface
 *  @author Seth Berman
 *
 *  This module provides a reusable key<str>=value<str> container
 *
 *  EsProperties is a sequenceable collection of EsPropertyPairs
 *  with the constraint that each EsPropertyPair has a unique key member.
 *
 *  Map Interface:
 *  EsProperties *p = EsProperties_new();
 *  EsProperties_atPut(p, "key", "value");
 *  EsProperties_atPut(p, "key2", "value2");
 *  ...
 *  char *value = EsProperties_at(p, "key");
 *
 *  Sequenceable Interface:
 *  U_32 totalNum = EsProperties_getSizep);
 *  EsPropertyPair pair;
 *  for(i = 0; i < totalNum; i++) {
 *      EsProperties_atIndex(p, i, &pair);
 *      printf("%s:%s\n", pair.key, pair.value);
 *  }
 *
 *******************************************************************************/
#ifndef ES_PROPERTIES_H
#define ES_PROPERTIES_H

#include "escompiler.h"

/**************************/
/*   D A T A  T Y P E S   */
/**************************/

/**
 * @brief Key/Value Property
 * @note const key/value view of each property element
 */
typedef struct _EsPropertyPair EsPropertyPair;
struct _EsPropertyPair {
    const char *key;
    const char *value;
};

/**
 * @brief Properties container
 * @note This is an opaque type
 */
typedef struct _EsProperties EsProperties;

/*************************/
/*   L I F E C Y C L E   */
/*************************/

/**
 * @brief Answer a new properties instance
 * @return props or NULL if out of memory
 */
EsProperties *EsProperties_new();

/**
 * @brief Destroy the properties
 * @param props
 */
void EsProperties_free(EsProperties *props);

/***************************/
/*   P R O P E R T I E S   */
/***************************/

/**
 * @brief Answer the current number of properties
 * @param props
 * @return number of properties
 * @return 0 if props is NULL
 */
U_32 EsProperties_getSize(const EsProperties *props);

/**
 * @brief Store the key/value pair info in output param
 * @param props
 * @param index of key/value to get (no-op if out of bounds)
 * @param pair[output] key/value container
 */
void EsProperties_atIndex(const EsProperties *props, U_32 index, EsPropertyPair *pair);

/**
 * @brief Answer the string property value at key
 * @note props[key]
 * @param props
 * @param key null-terminated string
 * @return null-terminated value string if key found
 * @return NULL if key not found, key is NULL, or props is NULL
 */
const char *EsProperties_at(const EsProperties *props, const char *key);

/**
 * @brief Add the key/value string pair.
 * @note props[key] = copy(value);
 * @note If key already exists, then update the value with a copy
 * @note No action taken if props is NULL, key is NULL or value is NULL
 * @note value is copied internally so don't forget to free the arg value
 * @param props
 * @param key null-terminated string
 * @param value null-terminated string (which is copied internally)
 */
void EsProperties_atPut(EsProperties *props, const char *key, char *value);

/**
 * @brief Test if props contains the key
 * @param props
 * @param key null-terminated string
 * @return BOOLEAN TRUE if key exists, FALSE otherwise
 */
BOOLEAN EsProperties_includesKey(const EsProperties *props, const char *key);

/**
 * @brief Remove the key/value string pair and answer the old value
 * @param props
 * @param key null-terminated string
 * @return value null-terminated string
 * @return NULL if key not found, key is NULL, or props is NULL
 */
char *EsProperties_removeKey(EsProperties *props, const char *key);

/**
 * @brief Test if props contains a value at key which strequals value
 * @note strcmp(props[key], value) == 0
 * @param props
 * @param key null-terminated string
 * @param value null-terminated string
 * @return TRUE if existing value and arg value are strequal, FALSE otherwise
 */
BOOLEAN EsProperties_valueEquals(const EsProperties *props, const char *key, const char *value);

#endif //ES_PROPERTIES_H
