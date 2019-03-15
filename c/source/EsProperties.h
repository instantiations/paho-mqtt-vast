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
 *  EsProperties *p = EsNewProperties();
 *  EsPropertiesAtPut(p, "key", "value");
 *  EsPropertiesAtPut(p, "key2", "value2");
 *  ...
 *  char *value = EsPropertiesAt(p, "key");
 *
 *  Sequenceable Interface:
 *  U_32 totalNum = EsNumProperties(p);
 *  EsPropertyPair pair;
 *  for(i = 0; i < totalNum; i++) {
 *      EsPropertyPairAtIndex(p, i, &pair);
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
EsProperties *EsNewProperties();

/**
 * @brief Destroy the properties
 * @param props
 */
void EsFreeProperties(EsProperties *props);

/***************************/
/*   P R O P E R T I E S   */
/***************************/

/**
 * @brief Answer the current number of properties
 * @param props
 * @return number of properties
 * @return 0 if props is NULL
 */
U_32 EsNumProperties(const EsProperties *props);

/**
 * @brief Store the key/value pair info in output param
 * @param props
 * @param index of key/value to get (no-op if out of bounds)
 * @param pair[output] key/value container
 */
void EsPropertyPairAtIndex(const EsProperties *props, U_32 index, EsPropertyPair *pair);

/**
 * @brief Answer the string property value at key
 * @note props[key]
 * @param props
 * @param key null-terminated string
 * @return null-terminated value string if key found
 * @return NULL if key not found, key is NULL, or props is NULL
 */
const char *EsPropertyAt(const EsProperties *props, const char *key);

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
void EsPropertyAtPut(EsProperties *props, const char *key, char *value);

/**
 * @brief Test if props contains the key
 * @param props
 * @param key null-terminated string
 * @return BOOLEAN TRUE if key exists, FALSE otherwise
 */
BOOLEAN EsPropertyIncludesKey(const EsProperties *props, const char *key);

/**
 * @brief Remove the key/value string pair and answer the old value
 * @param props
 * @param key null-terminated string
 * @return value null-terminated string
 * @return NULL if key not found, key is NULL, or props is NULL
 */
char *EsPropertyRemoveKey(EsProperties *props, const char *key);

/**
 * @brief Test if props contains a value at key which strequals value
 * @note strcmp(props[key], value) == 0
 * @param props
 * @param key null-terminated string
 * @param value null-terminated string
 * @return TRUE if existing value and arg value are strequal, FALSE otherwise
 */
BOOLEAN EsPropertyValueIs(const EsProperties *props, const char *key, const char *value);

#endif //ES_PROPERTIES_H
