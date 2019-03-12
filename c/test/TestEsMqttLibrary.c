#include "EsUnitTest.h"
#include "EsMqttLibrary.h"

/*****************/
/*   T E S T S   */
/*****************/

/**
 * @brief Test Library Init/Shutdown.
 * @note This also tests various state queries
 * @return TRUE if tests passes, FALSE otherwise
 */
static pboolean test_initShutdown() {
    EsGlobalInfo globalInfo;

    ES_ASSERT(EsMqttGetLibraryState() == ESMQTT_LIBRARY_UNINIT);
    EsMqttLibraryInit(&globalInfo);
    ES_ASSERT(EsMqttGetLibraryState() == ESMQTT_LIBRARY_INIT);
    EsMqttLibraryShutdown();
    ES_ASSERT(EsMqttGetLibraryState() == ESMQTT_LIBRARY_SHUTDOWN);
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
   ES_RUN_TEST(test_initShutdown);
   ES_RETURN_TEST_RESULTS();
}