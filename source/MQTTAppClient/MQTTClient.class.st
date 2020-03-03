Class {
	#name : 'MQTTClient',
	#superclass : 'MQTTStructure',
	#classVars : [
		'TraceEntryPoint',
		'TraceHandler'
	],
	#category : 'MQTTAppClient'
}

{ #category : 'Accessing' }
MQTTClient class >> builder [
	"Answer a new client builder
	 
	 Answers:
		<MQTTClientBuilder>"
	
	^MQTTClientBuilder new
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClient class >> initializeAfterLoad [

	self initializeOpaqueLayout
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClient class >> initializeOpaqueLayout [
	"Initialize Opaque Layout"
	
	^self members: #() types: #()
]

{ #category : 'Tracing' }
MQTTClient class >> isTracing [
	"Test if tracing"

	TraceEntryPoint isNil ifTrue: [^false].
	[TraceEntryPoint address] on: Exception do: [:ex | ^false].
	^true
]

{ #category : 'Tracing' }
MQTTClient class >> startTracing: aLevel on: aWriteStream [
	"Start tracing to aWriteStream

	 @see MQTTConstants:
		MQTTCLIENT_TRACE_MAXIMUM = 1,
		MQTTCLIENT_TRACE_MEDIUM,
		MQTTCLIENT_TRACE_MINIMUM,
		MQTTCLIENT_TRACE_PROTOCOL,
		MQTTCLIENT_TRACE_ERROR,
		MQTTCLIENT_TRACE_SEVERE,
		MQTTCLIENT_TRACE_FATAL
		
	 Arguments:
		aLevel - <Integer> @see MQTTConstants::MQTTCLIENT_TRACE*
		aWriteStream - <WriteStream>"

	self traceLevel: aLevel handler: [:msg | aWriteStream nextPutAll: msg; cr]
]

{ #category : 'Tracing' }
MQTTClient class >> stopTracing [
	"Stop all tracing"
	
	self traceLevel: nil handler: nil
]

{ #category : 'Tracing',
  #vaVisibility : 'private' }
MQTTClient class >> traceEntryPoint [

	TraceEntryPoint isNil
		ifTrue: [
			TraceEntryPoint :=
				EsEntryPoint
					receiver: self
					selector: #traceProc:message:
					callingConvention: 'c'
					arrayBased: false
					parameterTypes: #(int32 pointer)
					returnType: #void].
	^TraceEntryPoint
]

{ #category : 'Tracing',
  #vaVisibility : 'private' }
MQTTClient class >> traceHandler: aBlock [
	"Set the trace handler
	 
	 Arguments:
		aBlock - <Block> 2-arg trace block.  
									Arg1 - <Integer> traceLevel
									Arg2 - <String> traceMessage"

	((TraceHandler := aBlock) isNil and: [TraceEntryPoint notNil])
		ifTrue: [
			TraceEntryPoint unbind.
			TraceEntryPoint := nil]
		ifFalse: [
			MQTTLibraryDispatcher sync
				callMQTTClient_setTraceCallbackWith: self traceEntryPoint address]
]

{ #category : 'Tracing',
  #vaVisibility : 'private' }
MQTTClient class >> traceLevel: aLevel [
	"Set the trace level
	 
	 @see MQTTConstants:
		MQTTCLIENT_TRACE_MAXIMUM = 1,
		MQTTCLIENT_TRACE_MEDIUM,
		MQTTCLIENT_TRACE_MINIMUM,
		MQTTCLIENT_TRACE_PROTOCOL,
		MQTTCLIENT_TRACE_ERROR,
		MQTTCLIENT_TRACE_SEVERE,
		MQTTCLIENT_TRACE_FATAL
	 
	 Arguments:
		aLevel - <Integer> see above or nil for noop"

	aLevel isNil ifTrue: [^self].
	MQTTLibraryDispatcher sync callMQTTClient_setTraceLevelWith: aLevel
]

{ #category : 'Tracing' }
MQTTClient class >> traceLevel: aLevel handler: aBlock [
	"Set the trace level
	 
	 Example to send trace output to the console:
	 MQTTClient
		traceLevel: MQTTConstants::MQTTCLIENT_TRACE_MAXIMUM
		handler: [:msg :len | CwAppContext default asyncExecInUI: [Transcript show: msg]].
		
	 To stop, @see MQTTClient>>stopTracing
	 
	 @see MQTTConstants:
		MQTTCLIENT_TRACE_MAXIMUM = 1,
		MQTTCLIENT_TRACE_MEDIUM,
		MQTTCLIENT_TRACE_MINIMUM,
		MQTTCLIENT_TRACE_PROTOCOL,
		MQTTCLIENT_TRACE_ERROR,
		MQTTCLIENT_TRACE_SEVERE,
		MQTTCLIENT_TRACE_FATAL
	 
	 Arguments:
		aLevel - <Integer> see above
		aBlock - <Block> 0, 1 or 2-arg trace block.  
									Arg1 - <Integer> traceLevel
									Arg2 - <String> traceMessage"

	self
		traceLevel: aLevel;
		traceHandler: aBlock
]

{ #category : 'Tracing',
  #vaVisibility : 'private' }
MQTTClient class >> traceProc: level message: osMessage [

	TraceHandler notNil
		ifTrue: [
			[| message |
				message := (OSStringZ address: osMessage) asString.
				TraceHandler cull: message cull: level]
					on: Exception
					do: [:ex | ]]
]

{ #category : 'Connection' }
MQTTClient >> connect: options [
	"Attempts to connect the client to an MQTT server using the specified options.
	 
	 Arguments:
		options - <MQTTClientConnectOptions>
	 Answers:
		<Integer> - MQTTCLIENT_SUCCESS
		<MQTTException> error object"

	| rc |

	rc := self dispatcher callMQTTClient_connectWith: self with: options.
	rc == MQTTCLIENT_SUCCESS
		ifFalse: [MQTTException errorCode: rc codes: MQTTException connectErrorCodes].
	^rc
]

{ #category : 'Connection' }
MQTTClient >> disconnect: timeout [
	"Attempts to disconnect the client from the MQTT
	 server. In order to allow the client time to complete handling of messages
	 that are in-flight when this function is called, a timeout period is
	 specified. When the timeout period has expired, the client disconnects even
	 if there are still outstanding message acknowledgements.
	 The next time the client connects to the same server, any QoS 1 or 2
	 messages which have not completed will be retried depending on the
	 cleansession settings for both the previous and the new connection
	 
	 Arguments:
		timeout - <Duration> or <Integer> The client delays disconnection for up to this time in milliseconds
	 Answers:
		<Integer> - MQTTCLIENT_SUCCESS if the client successfully disconnects from the server
		<MQTTException> error object"

	| rc |

	rc :=
		self dispatcher
			callMQTTClient_disconnectWith: self
			with: (timeout isInteger ifTrue: [timeout] ifFalse: [timeout asMilliseconds]).
	rc == MQTTCLIENT_SUCCESS ifFalse: [MQTTException errorCode: rc].
	^rc
]

{ #category : 'Connection' }
MQTTClient >> isConnected [
	"Test whether or not a client is currently connected to the MQTT server.
	 
	 Answers:
		<Boolean> true if connected, false otherwise"

	^(self dispatcher callMQTTClient_isConnectedWith: self) ~= 0
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTClient >> nativeFree [
	"Free the MQTTClient object
	 INTERNAL USE ONLY: External callers need to use #free"

	| clientPtr |

	clientPtr := OSObjectPointer itemType: self class.
	clientPtr at: 0 put: self.
	self dispatcher callMQTTClient_destroyWith: clientPtr
]

{ #category : 'Publish' }
MQTTClient >> publish: topicName message: message [
	"Attempts ot publish a message to a given topic.
	 A @deliveryToken is issued when this function returns successfully.
	 If the client application needs to test for successful deliver of QoS1 and QoS2 messages, this can
	 be done either async or sync
	 
	 NO TOKEN
	 
	 Arguments:
		topicName - <String>
		message - <MQTTClientMessage> contains the payload and attributes of the message to be published.
	 Answers:
		<Integer> MQTTCLIENT_SUCCESS if message is accepted for publication.
		<MQTTException> Error object"

	^self publish: topicName message: message token: nil
]

{ #category : 'Publish' }
MQTTClient >> publish: topicName message: message token: deliveryToken [
	"Attempts ot publish a message to a given topic.
	 A @deliveryToken is issued when this function returns successfully.
	 If the client application needs to test for successful deliver of QoS1 and QoS2 messages, this can
	 be done either async or sync
	 
	 Arguments:
		topicName - <String>
		message - <MQTTClientMessage> contains the payload and attributes of the message to be published.
		deliveryToken - <MQTTClientDeliveryToken> or nil.  <OUTPUT PARAMETER>
	 Answers:
		<Integer> MQTTCLIENT_SUCCESS if message is accepted for publication.
		<MQTTException> Error object"

	| rc |

	rc :=
		self dispatcher
			callMQTTClient_publishMessageWith: self
			with: topicName
			with: message
			with: deliveryToken.
	rc == MQTTCLIENT_SUCCESS ifFalse: [MQTTException errorCode: rc].
	^rc
]

{ #category : 'Publish' }
MQTTClient >> publish: topicName payload: payload qos: qos retained: retained [
	"Attempts ot publish a message to a given topic.
	 A @deliveryToken is issued when this function returns successfully.
	 If the client application needs to test for successful deliver of QoS1 and QoS2 messages, this can
	 be done either async or sync
	 
	 NO TOKEN
	 
	 Arguments:
		topicName - <String>
		payload - <ByteArray> bytes
		qos - <Integer> MQTT_QoS0 - Fire and forget - the message may not be delivered
							   MQTT_QoS1 - At least once - the message will be delivered, but may be
													delivered more than once in some circumstances.
							   MQTT_QoS2 - Once and one only - the message will be delivered exactly once.
		retained - <Boolean> true setting indicates that the MQTT server should retain a copy of the message
									   false indicates the server should not retain the message
		deliveryToken - <MQTTClientDeliveryToken> or nil.  <OUTPUT PARAMETER>
	 Answers:
		<Integer> MQTTCLIENT_SUCCESS if message is accepted for publication.
		<MQTTException> Error object"

	^self publish: topicName payload: payload qos: qos retained: retained token: nil
]

{ #category : 'Publish' }
MQTTClient >> publish: topicName payload: payload qos: qos retained: retained token: deliveryToken [
	"Attempts ot publish a message to a given topic.
	 A @deliveryToken is issued when this function returns successfully.
	 If the client application needs to test for successful deliver of QoS1 and QoS2 messages, this can
	 be done either async or sync
	 
	 Arguments:
		topicName - <String>
		payload - <ByteArray> bytes
		qos - <Integer> MQTT_QoS0 - Fire and forget - the message may not be delivered
							   MQTT_QoS1 - At least once - the message will be delivered, but may be
													delivered more than once in some circumstances.
							   MQTT_QoS2 - Once and one only - the message will be delivered exactly once.
		retained - <Boolean> true setting indicates that the MQTT server should retain a copy of the message
									   false indicates the server should not retain the message
		deliveryToken - <MQTTClientDeliveryToken> or nil.  <OUTPUT PARAMETER>
	 Answers:
		<Integer> MQTTCLIENT_SUCCESS if message is accepted for publication.
		<MQTTException> Error object"

	| rc |

	rc :=
		self dispatcher
			callMQTTClient_publishWith: self
			with: topicName
			with: payload size
			with: payload
			with: qos
			with: retained
			with: deliveryToken.
	rc == MQTTCLIENT_SUCCESS ifFalse: [MQTTException errorCode: rc].
	^rc
]

{ #category : 'Publish' }
MQTTClient >> waitForCompletion: deliveryToken timeout: timeout [
	"Synchronize execution of the main thread with completed publication of a message.
	 When called, this method blocks execution until the message has been successful delivered
	 or the specified timeout has expired.
	 
	 Arguments:
		deliveryToken - <MQTTClientDeliveryToken> token issued by publish
		timeout - <Duration> or <Integer> max time to wait in milliseconds
	 Answers:
		<Integer> MQTTCLIENT_SUCCESS if message is accepted for publication.
		<MQTTException> Error object"

	| rc |

	rc :=
		self dispatcher
			callMQTTClient_waitForCompletionWith: self
			with: deliveryToken value
			with: (timeout isInteger ifTrue: [timeout] ifFalse: [timeout asMilliseconds]).
	rc == MQTTCLIENT_SUCCESS ifFalse: [MQTTException errorCode: rc].
	^rc
]
