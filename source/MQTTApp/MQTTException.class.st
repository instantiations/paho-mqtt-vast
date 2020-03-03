Class {
	#name : 'MQTTException',
	#superclass : 'Exception',
	#pools : [
		'MQTTConstants'
	],
	#category : 'MQTTApp'
}

{ #category : 'Codes' }
MQTTException class >> connectErrorCodes [
	"Extended error codes for connect api
	 
	 Answers:
		<Dictionary>"
	
	^self errorCodes
		at: 1 put: 'Connection refused: Unacceptable protocol version';
		at: 2 put: 'Connection refused: Identifier rejected';
		at: 3 put: 'Connection refused: Server unavailable';
		at: 4 put: 'Connection refused: Bad user name or password';
		at: 5 put: 'Connection refused: Not authorized';
		yourself
]

{ #category : 'Creation' }
MQTTException class >> errorCode: aCode [
	"Signal an exception using the error code
	 
	 Arguments:
		aCode - <Integer>"
	
	^self errorCode: aCode codes: self errorCodes
]

{ #category : 'Creation' }
MQTTException class >> errorCode: aCode codes: codes [
	"Signal an exception using the error code
	 which is then looked up in @codes to get
	 the message
	 
	 Arguments:
		aCode - <Integer>
		codes - <Dictionary>"
	
	self signal: (codes at: aCode ifAbsent: ['Unknown Error'])
]

{ #category : 'Codes' }
MQTTException class >> errorCodes [
	"Error codes dictionary
	 
	 Answers:
		<Dictionary>"
	
	^Dictionary new
		at: MQTTCLIENT_FAILURE put: 'MQTTCLIENT_FAILURE';
		at: MQTTCLIENT_DISCONNECTED put: 'MQTTCLIENT_DISCONNECTED';
		at: MQTTCLIENT_MAX_MESSAGES_INFLIGHT put: 'MQTTCLIENT_MAX_MESSAGES_INFLIGHT';
		at: MQTTCLIENT_BAD_UTF8_STRING put: 'MQTTCLIENT_BAD_UTF8_STRING';
		at: MQTTCLIENT_NULL_PARAMETER put: 'MQTTCLIENT_NULL_PARAMETER';
		at: MQTTCLIENT_TOPICNAME_TRUNCATED put: 'MQTTCLIENT_TOPICNAME_TRUNCATED';
		at: MQTTCLIENT_BAD_STRUCTURE put: 'MQTTCLIENT_BAD_STRUCTURE';
		at: MQTTCLIENT_BAD_QOS put: 'MQTTCLIENT_BAD_QOS';
		at: MQTTCLIENT_SSL_NOT_SUPPORTED put: 'MQTTCLIENT_SSL_NOT_SUPPORTED';
		at: MQTTCLIENT_BAD_MQTT_VERSION put: 'MQTTCLIENT_BAD_MQTT_VERSION';
		at: MQTTCLIENT_BAD_PROTOCOL put: 'MQTTCLIENT_BAD_PROTOCOL';
		at: MQTTCLIENT_BAD_MQTT_OPTION put: 'MQTTCLIENT_BAD_MQTT_OPTION';
		at: MQTTCLIENT_WRONG_MQTT_VERSION put: 'MQTTCLIENT_WRONG_MQTT_VERSION';
		yourself
]
