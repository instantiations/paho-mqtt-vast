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

    props = EsNewProperties();
    ES_ASSERT(props != NULL);
    EsFreeProperties(props);

    return TRUE;
}

static pboolean test_properties() {
    EsProperties *props;
    EsPropertyPair pair;
    char *val;

    /* Test against null props */
    props = NULL;
    ES_ASSERT(EsPropertyNum(props) == 0);
    ES_ASSERT(EsPropertyIncludesKey(props, NULL) == FALSE);
    ES_ASSERT(EsPropertyAt(props, NULL) == NULL);
    EsPropertyAtPut(props, NULL, NULL);
    ES_ASSERT(EsPropertyValueIs(props, NULL, NULL) == FALSE);
    ES_ASSERT(EsPropertyRemoveKey(props, NULL) == NULL);
    EsPropertyPairAtIndex(props, 0, &pair);
    ES_ASSERT(pair.key == NULL);
    ES_ASSERT(pair.value == NULL);

    props = EsNewProperties();

    /* Test against null args */
    ES_ASSERT(EsPropertyNum(props) == 0);
    ES_ASSERT(EsPropertyIncludesKey(props, NULL) == FALSE);
    ES_ASSERT(EsPropertyAt(props, NULL) == NULL);
    EsPropertyAtPut(props, NULL, NULL);
    ES_ASSERT(EsPropertyValueIs(props, NULL, NULL) == FALSE);
    ES_ASSERT(EsPropertyRemoveKey(props, NULL) == NULL);
    EsPropertyPairAtIndex(props, 0, NULL);

    /* Test empty prop props / valid keys */
    ES_ASSERT(EsPropertyNum(props) == 0);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == FALSE);
    ES_ASSERT(EsPropertyAt(props, "Key") == NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key", "Value") == FALSE);

    /* Add key */
    EsPropertyAtPut(props, "Key", "Value");
    ES_ASSERT(EsPropertyNum(props) == 1);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == TRUE);
    ES_ASSERT(EsPropertyAt(props, "Key") != NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key", "Value"));
    EsPropertyPairAtIndex(props, 0, &pair);
    ES_ASSERT(strcmp(pair.key, "Key") == 0);
    ES_ASSERT(strcmp(pair.value, "Value") == 0)
    EsPropertyPairAtIndex(props, 1, &pair);
    ES_ASSERT(pair.key == NULL);
    ES_ASSERT(pair.value == NULL);

    /* Add second key */
    EsPropertyAtPut(props, "Key2", "Value2");
    ES_ASSERT(EsPropertyNum(props) == 2);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == TRUE);
    ES_ASSERT(EsPropertyAt(props, "Key") != NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key", "Value"));
    ES_ASSERT(EsPropertyIncludesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsPropertyAt(props, "Key2") != NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key2", "Value2"));

    /* Add third key */
    EsPropertyAtPut(props, "Key3", "Value3");
    ES_ASSERT(EsPropertyNum(props) == 3);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == TRUE);
    ES_ASSERT(EsPropertyAt(props, "Key") != NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key", "Value"));
    ES_ASSERT(EsPropertyIncludesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsPropertyAt(props, "Key2") != NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key2", "Value2"));
    ES_ASSERT(EsPropertyIncludesKey(props, "Key3") == TRUE);
    ES_ASSERT(EsPropertyAt(props, "Key3") != NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key3", "Value3"));
    EsPropertyPairAtIndex(props, 2, &pair);
    ES_ASSERT(strcmp(pair.key, "Key3") == 0);
    ES_ASSERT(strcmp(pair.value, "Value3") == 0)
    EsPropertyPairAtIndex(props, 3, &pair);
    ES_ASSERT(pair.key == NULL);
    ES_ASSERT(pair.value == NULL);

    /* Remove head */
    val = EsPropertyRemoveKey(props, "Key");
    ES_ASSERT(EsPropertyNum(props) == 2);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == FALSE);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key3") == TRUE);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value", strlen("Value")) == 0);
    ES_ASSERT(EsPropertyAt(props, "Key") == NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key", "Value") == FALSE);

    /* Remove tail */
    val = EsPropertyRemoveKey(props, "Key3");
    ES_ASSERT(EsPropertyNum(props) == 1);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == FALSE);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key2") == TRUE);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key3") == FALSE);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value3", strlen("Value3")) == 0);
    ES_ASSERT(EsPropertyAt(props, "Key3") == NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key3", "Value3") == FALSE);

    /* Remove last*/
    val = EsPropertyRemoveKey(props, "Key2");
    ES_ASSERT(EsPropertyNum(props) == 0);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key") == FALSE);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key2") == FALSE);
    ES_ASSERT(EsPropertyIncludesKey(props, "Key3") == FALSE);
    ES_ASSERT(val != NULL);
    ES_ASSERT(strncmp(val, "Value2", strlen("Value2")) == 0);
    ES_ASSERT(EsPropertyAt(props, "Key2") == NULL);
    ES_ASSERT(EsPropertyValueIs(props, "Key2", "Value2") == FALSE);

    EsFreeProperties(props);

    return TRUE;
}

static pboolean test_sequenceable() {
    EsProperties *p = NULL;
    EsPropertyPair pair;
    U_32 totalNum = 0;
    U_32 i = 0;

    p = EsNewProperties();
    EsPropertyAtPut(p, "key1", "value");
    EsPropertyAtPut(p, "key2", "value");
    EsPropertyAtPut(p, "key3", "value");
    EsPropertyAtPut(p, "key4", "value");

    totalNum = EsPropertyNum(p);
    for(i = 0; i < totalNum; i++) {
        EsPropertyPairAtIndex(p, i, &pair);
        printf("%s:%s\n", pair.key, pair.value);
    }
    ES_ASSERT(i == 4);
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