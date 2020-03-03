Class {
	#name : 'MQTTPlatformFunctions',
	#superclass : 'SharedPool',
	#classVars : [
		'MQTTPropertyName',
		'MQTTProperty_getType',
		'MQTTProperties_add',
		'MQTTProperties_free',
		'MQTTProperties_hasProperty',
		'MQTTProperties_propertyCount',
		'MQTTProperties_getNumericValue',
		'MQTTProperties_getNumericValueAt',
		'MQTTProperties_getProperty',
		'MQTTProperties_getPropertyAt',
		'MQTTReasonCode_toString',
		'MQTTClient_global_init',
		'MQTTClient_setCallbacks',
		'MQTTClient_setDisconnected',
		'MQTTClient_setPublished',
		'MQTTClient_create',
		'MQTTClient_createWithOptions',
		'MQTTClient_getVersionInfo',
		'MQTTClient_connect',
		'MQTTResponse_free',
		'MQTTClient_disconnect',
		'MQTTClient_disconnect5',
		'MQTTClient_isConnected',
		'MQTTClient_subscribe',
		'MQTTClient_subscribeMany',
		'MQTTClient_unsubscribe',
		'MQTTClient_unsubscribeMany',
		'MQTTClient_publish',
		'MQTTClient_publishMessage',
		'MQTTClient_waitForCompletion',
		'MQTTClient_getPendingDeliveryTokens',
		'MQTTClient_yield',
		'MQTTClient_receive',
		'MQTTClient_freeMessage',
		'MQTTClient_free',
		'MQTTClient_destroy',
		'MQTTClient_setTraceLevel',
		'MQTTClient_setTraceCallback',
		'MQTTClient_strerror'
	],
	#type : 'variable',
	#category : 'MQTTApp'
}

{ #category : 'Initializing' }
MQTTPlatformFunctions class >> initialize [
	MQTTPropertyName := PlatformFunction fromArray: #('C' 'MQTTPropertyName' nil 'MQTT_PAHO_LIB' #(#int32) #pointer ).
	MQTTProperty_getType := PlatformFunction fromArray: #('C' 'MQTTProperty_getType' nil 'MQTT_PAHO_LIB' #(#int32) #int32 ).
	MQTTProperties_add := PlatformFunction fromArray: #('C' 'MQTTProperties_add' nil 'MQTT_PAHO_LIB' #(#pointer #pointer) #int32 ).
	MQTTProperties_free := PlatformFunction fromArray: #('C' 'MQTTProperties_free' nil 'MQTT_PAHO_LIB' #(#pointer) #void ).
	MQTTProperties_hasProperty := PlatformFunction fromArray: #('C' 'MQTTProperties_hasProperty' nil 'MQTT_PAHO_LIB' #(#pointer #int32) #int32 ).
	MQTTProperties_propertyCount := PlatformFunction fromArray: #('C' 'MQTTProperties_propertyCount' nil 'MQTT_PAHO_LIB' #(#pointer #int32) #int32 ).
	MQTTProperties_getNumericValue := PlatformFunction fromArray: #('C' 'MQTTProperties_getNumericValue' nil 'MQTT_PAHO_LIB' #(#pointer #int32) #int32 ).
	MQTTProperties_getNumericValueAt := PlatformFunction fromArray: #('C' 'MQTTProperties_getNumericValueAt' nil 'MQTT_PAHO_LIB' #(#pointer #int32 #int32) #int32 ).
	MQTTProperties_getProperty := PlatformFunction fromArray: #('C' 'MQTTProperties_getProperty' nil 'MQTT_PAHO_LIB' #(#pointer #int32) #pointer ).
	MQTTProperties_getPropertyAt := PlatformFunction fromArray: #('C' 'MQTTProperties_getPropertyAt' nil 'MQTT_PAHO_LIB' #(#pointer #int32 #int32) #pointer ).
	MQTTReasonCode_toString := PlatformFunction fromArray: #('C' 'MQTTReasonCode_toString' nil 'MQTT_PAHO_LIB' #(#int32) #pointer ).
	MQTTClient_global_init := PlatformFunction fromArray: #('C' 'MQTTClient_global_init' nil 'MQTT_PAHO_LIB' #(#pointer) #void ).
	MQTTClient_setCallbacks := PlatformFunction fromArray: #('C' 'MQTTClient_setCallbacks' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer #pointer #pointer) #int32 ).
	MQTTClient_setDisconnected := PlatformFunction fromArray: #('C' 'MQTTClient_setDisconnected' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer) #int32 ).
	MQTTClient_setPublished := PlatformFunction fromArray: #('C' 'MQTTClient_setPublished' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer) #int32 ).
	MQTTClient_create := PlatformFunction fromArray: #('C' 'MQTTClient_create' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer #int32 #pointer) #int32 ).
	MQTTClient_createWithOptions := PlatformFunction fromArray: #('C' 'MQTTClient_createWithOptions' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer #int32 #pointer #pointer) #int32 ).
	MQTTClient_getVersionInfo := PlatformFunction fromArray: #('C' 'MQTTClient_getVersionInfo' nil 'MQTT_PAHO_LIB' #() #pointer ).
	MQTTClient_connect := PlatformFunction fromArray: #('C' 'MQTTClient_connect' nil 'MQTT_PAHO_LIB' #(#pointer #pointer) #int32 ).
	MQTTResponse_free := PlatformFunction fromArray: #('C' 'MQTTResponse_free' nil 'MQTT_PAHO_LIB' #(#bytes) #void ).
	MQTTClient_disconnect := PlatformFunction fromArray: #('C' 'MQTTClient_disconnect' nil 'MQTT_PAHO_LIB' #(#pointer #int32) #int32 ).
	MQTTClient_disconnect5 := PlatformFunction fromArray: #('C' 'MQTTClient_disconnect5' nil 'MQTT_PAHO_LIB' #(#pointer #int32 #int32 #bytes) #int32 ).
	MQTTClient_isConnected := PlatformFunction fromArray: #('C' 'MQTTClient_isConnected' nil 'MQTT_PAHO_LIB' #(#pointer) #int32 ).
	MQTTClient_subscribe := PlatformFunction fromArray: #('C' 'MQTTClient_subscribe' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #int32) #int32 ).
	MQTTClient_subscribeMany := PlatformFunction fromArray: #('C' 'MQTTClient_subscribeMany' nil 'MQTT_PAHO_LIB' #(#pointer #int32 #pointer #pointer) #int32 ).
	MQTTClient_unsubscribe := PlatformFunction fromArray: #('C' 'MQTTClient_unsubscribe' nil 'MQTT_PAHO_LIB' #(#pointer #pointer) #int32 ).
	MQTTClient_unsubscribeMany := PlatformFunction fromArray: #('C' 'MQTTClient_unsubscribeMany' nil 'MQTT_PAHO_LIB' #(#pointer #int32 #pointer) #int32 ).
	MQTTClient_publish := PlatformFunction fromArray: #('C' 'MQTTClient_publish' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #int32 #pointer #int32 #int32 #pointer) #int32 ).
	MQTTClient_publishMessage := PlatformFunction fromArray: #('C' 'MQTTClient_publishMessage' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer #pointer) #int32 ).
	MQTTClient_waitForCompletion := PlatformFunction fromArray: #('C' 'MQTTClient_waitForCompletion' nil 'MQTT_PAHO_LIB' #(#pointer #int32 #uint32) #int32 ).
	MQTTClient_getPendingDeliveryTokens := PlatformFunction fromArray: #('C' 'MQTTClient_getPendingDeliveryTokens' nil 'MQTT_PAHO_LIB' #(#pointer #pointer) #int32 ).
	MQTTClient_yield := PlatformFunction fromArray: #('C' 'MQTTClient_yield' nil 'MQTT_PAHO_LIB' #() #void ).
	MQTTClient_receive := PlatformFunction fromArray: #('C' 'MQTTClient_receive' nil 'MQTT_PAHO_LIB' #(#pointer #pointer #pointer #pointer #uint32) #int32 ).
	MQTTClient_freeMessage := PlatformFunction fromArray: #('C' 'MQTTClient_freeMessage' nil 'MQTT_PAHO_LIB' #(#pointer) #void ).
	MQTTClient_free := PlatformFunction fromArray: #('C' 'MQTTClient_free' nil 'MQTT_PAHO_LIB' #(#pointer) #void ).
	MQTTClient_destroy := PlatformFunction fromArray: #('C' 'MQTTClient_destroy' nil 'MQTT_PAHO_LIB' #(#pointer) #void ).
	MQTTClient_setTraceLevel := PlatformFunction fromArray: #('C' 'MQTTClient_setTraceLevel' nil 'MQTT_PAHO_LIB' #(#int32) #void ).
	MQTTClient_setTraceCallback := PlatformFunction fromArray: #('C' 'MQTTClient_setTraceCallback' nil 'MQTT_PAHO_LIB' #(#pointer) #void ).
	MQTTClient_strerror := PlatformFunction fromArray: #('C' 'MQTTClient_strerror' nil 'MQTT_PAHO_LIB' #(#int32) #pointer ).
]
