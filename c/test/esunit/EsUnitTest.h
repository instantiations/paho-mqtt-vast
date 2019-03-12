#include "plibsys.h"

/*************************************/
/*	 T E S T  C O U N T E R S	  */
/*************************************/
static pboolean testResult;
static pint testsPassed = 0;
static pint testsFailed = 0;
static pboolean plibsysIsInit = FALSE;

/************************/
/*	 M A C R O S	  */
/************************/
#define ES_ASSERT(...) if(!(__VA_ARGS__)) return FALSE;
#define ES_DENY(...)   if(!!(__VA_ARGS__)) return FALSE;
#define ES_ASSERT_ARRAY_EQ(arr1, arr2, count) \
    for (i = 0; i < (count); i++) { \
        if ((arr1)[i] != (arr2)[i]) { \
            return FALSE; \
        } \
    } \

#define ES_RUN_TEST(_func) \
    if(plibsysIsInit == FALSE) { \
        p_libsys_init(); \
        plibsysIsInit = TRUE; \
            } \
    testResult = _func(); \
    if (!testResult) { \
        testsFailed++; \
        printf("%s failed.\n", #_func); \
    } else { \
        testsPassed++; \
        printf("%s passed.\n", #_func); \
    }

#define ES_PRINT_TEST_RESULTS() \
    printf("\nNum Tests: %d. Num Passed: %d. Num Failed: %d", testsFailed + testsPassed, testsPassed, testsFailed)

#define ES_RETURN_TEST_RESULTS() \
    p_libsys_shutdown(); \
    plibsysIsInit = FALSE; \
    ES_PRINT_TEST_RESULTS(); \
    if (testsFailed == 0) { \
        return 0; \
    } else { \
        return -1; \
    }
