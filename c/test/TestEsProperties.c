#include "EsUnitTest.h"
#include "EsProperties.h"

/*****************/
/*   T E S T S   */
/*****************/

/**
 * @brief Test New/Free.
 * @note This also tests that a NULL EsWorkTaskFreeDataFunc is ok
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_newFree() {
    EsProperties *props;

    props = EsProperties_new();
    ES_ASSERT(props != NULL);
    EsProperties_free(props);

    return TRUE;
}

static pboolean test_properties() {
    EsProperties *props;
    EsPropertyPair pair;
    char *val;

    /* Test against null props */
    props = NULL;
    ES_ASSERT(EsProperties_getSize(props) == 0);
    ES_ASSERT(EsProperties_includesKey(props, NULL) == FALSE);
    ES_ASSERT(EsProperties_at(props, NULL) == NULL);
    EsProperties_atPut(props, NULL, NULL);
    ES_ASSERT(EsProperties_valueEquals(props, NULL, NULL) == FALSE);
    ES_ASSERT(EsProperties_removeKey(props, NULL) == NULL);
    EsProperties_atIndex(props, 0, &pair);
    ES_ASSERT(pair.key == NULL);
    ES_ASSERT(pair.value == NULL);

    props = EsProperties_new();

    /* Test against null args */
    ES_ASSERT(EsProperties_getSize(props) == 0);
    ES_ASSERT(EsProperties_includesKey(props, NULL) == FALSE);
    ES_ASSERT(EsProperties_at(props, NULL) == NULL);
    EsProperties_atPut(props, NULL, NULL);
    ES_ASSERT(EsProperties_valueEquals(props, NULL, NULL) == FALSE);
    ES_ASSERT(EsProperties_removeKey(props, NULL) == NULL);
    EsProperties_atIndex(props, 0, NULL);

    /* Test empty prop props / valid keys */
    ES_ASSERT(EsProperties_getSize(props) == 0);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == FALSE);
    ES_ASSERT(EsProperties_at(props, "Key") == NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key", "Value") == FALSE);

    /* Add key */
    EsProperties_atPut(props, "Key", "Value");
    ES_ASSERT(EsProperties_getSize(props) == 1);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == TRUE);
    ES_ASSERT(EsProperties_at(props, "Key") != NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key", "Value"));
    EsProperties_atIndex(props, 0, &pair);
    ES_ASSERT(strcmp(pair.key, "Key") == 0);
    ES_ASSERT(strcmp(pair.value, "Value") == 0)
    EsProperties_atIndex(props, 1, &pair);
    ES_ASSERT(pair.key == NULL);
    ES_ASSERT(pair.value == NULL);

    /* Add second key */
    EsProperties_atPut(props, "Key2", "Value2");
    ES_ASSERT(EsProperties_getSize(props) == 2);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == TRUE);
    ES_ASSERT(EsProperties_at(props, "Key") != NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key", "Value"));
    ES_ASSERT(EsProperties_includesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsProperties_at(props, "Key2") != NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key2", "Value2"));

    /* Add third key */
    EsProperties_atPut(props, "Key3", "Value3");
    ES_ASSERT(EsProperties_getSize(props) == 3);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == TRUE);
    ES_ASSERT(EsProperties_at(props, "Key") != NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key", "Value"));
    ES_ASSERT(EsProperties_includesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsProperties_at(props, "Key2") != NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key2", "Value2"));
    ES_ASSERT(EsProperties_includesKey(props, "Key3") == TRUE);
    ES_ASSERT(EsProperties_at(props, "Key3") != NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key3", "Value3"));
    EsProperties_atIndex(props, 2, &pair);
    ES_ASSERT(strcmp(pair.key, "Key3") == 0);
    ES_ASSERT(strcmp(pair.value, "Value3") == 0)
    EsProperties_atIndex(props, 3, &pair);
    ES_ASSERT(pair.key == NULL);
    ES_ASSERT(pair.value == NULL);

    /* Remove head */
    val = EsProperties_removeKey(props, "Key");
    ES_ASSERT(EsProperties_getSize(props) == 2);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == FALSE);
    ES_ASSERT(EsProperties_includesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsProperties_includesKey(props, "Key3") == TRUE);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value", strlen("Value")) == 0);
    ES_ASSERT(EsProperties_at(props, "Key") == NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key", "Value") == FALSE);

    /* Remove tail */
    val = EsProperties_removeKey(props, "Key3");
    ES_ASSERT(EsProperties_getSize(props) == 1);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == FALSE);
    ES_ASSERT(EsProperties_includesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsProperties_includesKey(props, "Key3") == FALSE);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value3", strlen("Value3")) == 0);
    ES_ASSERT(EsProperties_at(props, "Key3") == NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key3", "Value3") == FALSE);

    /* Remove last*/
    val = EsProperties_removeKey(props, "Key2");
    ES_ASSERT(EsProperties_getSize(props) == 0);
    ES_ASSERT(EsProperties_includesKey(props, "Key") == FALSE);
    ES_ASSERT(EsProperties_includesKey(props, "Key2") == FALSE);
    ES_ASSERT(EsProperties_includesKey(props, "Key3") == FALSE);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value2", strlen("Value2")) == 0);
    ES_ASSERT(EsProperties_at(props, "Key2") == NULL);
    ES_ASSERT(EsProperties_valueEquals(props, "Key2", "Value2") == FALSE);

    EsProperties_free(props);

    return TRUE;
}

static pboolean test_sequenceable() {
    EsProperties *p = NULL;
    EsPropertyPair pair;
    U_32 totalNum = 0;
    U_32 i = 0;

    p = EsProperties_new();
	EsProperties_atPut(p, "key1", "value");
    EsProperties_atPut(p, "key2", "value");
    EsProperties_atPut(p, "key3", "value");
    EsProperties_atPut(p, "key4", "value");
	
    totalNum = EsProperties_getSize(p);
    for(i = 0; i < totalNum; i++) {
        EsProperties_atIndex(p, i, &pair);
    }
    ES_ASSERT(i == 4);

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
    ES_RUN_TEST(test_properties);
    ES_RUN_TEST(test_sequenceable);
    ES_RETURN_TEST_RESULTS();
}