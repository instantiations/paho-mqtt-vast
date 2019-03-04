/*******************************************************************************
 *  Copyright (c) 2019 Instantiations, Inc
 *
 *  Distributed under the MIT License (see License.txt file)
 *
 *  @file EsMqttAsyncArguments.c
 *  @brief Asynchronous Message Argument Preparation Implementation
 *  @author Seth Berman
 *******************************************************************************/
#include "MQTTClient.h"

#include "EsMqttAsyncArguments.h"

#include <string.h>

/*******************/
/*  U T I L I T Y  */
/*******************/

static void copyMessageInto(MQTTClient_message *dest, MQTTClient_message *src) {
    if (src != NULL && dest != NULL) {
        memcpy(dest, src, sizeof(MQTTClient_message));
        memcpy(dest->payload, src->payload, src->payloadlen);
    }
}

/*************************************************************/
/*      I N T E R F A C E  I M P L E M E N T A T I O N       */
/*************************************************************/

void EsMqttAsyncArgumentsInit(EsGlobalInfo *globalInfo) {
    ES_UNUSED(globalInfo);
}

void EsMqttAsyncArgumentsShutdown() {
    /* No-Op */
}

MQTTProperties *EsCopyProperties(MQTTProperties *props) {
    MQTTProperties *heapCopy;

    if (props == NULL) {
        return NULL;
    }

    heapCopy = (MQTTProperties *) EsAllocateMemory(sizeof(MQTTProperties));
    memcpy(heapCopy, props, sizeof(MQTTProperties));

    // TODO: Copy the list of properties

    return heapCopy;
}

char *EsCopyString(char *str) {
    if (str == NULL) {
        return NULL;
    }

    return (char *) EsAllocateMemory(strlen(str) + 1);
}

char *EsCopyTopicString(char *topicStr, I_32 len) {
    I_32 actualLen;

    if (topicStr == NULL) {
        return NULL;
    }

    actualLen = (len == 0) ? (I_32) strlen(topicStr) : len;

    return (char *) EsAllocateMemory(actualLen + 1);
}

MQTTClient_message *EsCopyMessage(MQTTClient_message *msg) {
    MQTTClient_message *heapCopy;
    if (msg == NULL) {
        return NULL;
    }

    heapCopy = (MQTTClient_message *) EsAllocateMemory(sizeof(MQTTClient_message));
    copyMessageInto(heapCopy, msg);
    return heapCopy;
}
