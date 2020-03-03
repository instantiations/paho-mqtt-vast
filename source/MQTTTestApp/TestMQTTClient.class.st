Class {
	#name : 'TestMQTTClient',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'SUnit' }
TestMQTTClient class >> resources [
	
	^Array with: MQTTTestResource
]

{ #category : 'Support',
  #vaVisibility : 'private' }
TestMQTTClient >> runExampleClientPub: aBuilder [
	"From the bottom of https://github.com/eclipse/paho.mqtt.c/blob/master/src/MQTTClient.h"

	| client topic token pubmsg payload stream prevTraceHandler |

	topic := 'MQTT Examples'.
	payload := 'Hello World!'.
	stream := String new writeStream.
	prevTraceHandler := self startTracingOn: stream.
	[
		client :=
			aBuilder
				keepAliveInterval: 20;
				cleanSession: true;
				connectClient: [:ex | self assert: false];
				getClient.
		self assert: client isConnected.

		token := MQTTDeliveryToken new.
		self
			shouldnt: [
				pubmsg :=
					(payload asMQTTMessage)
						qos: MQTTConstants::MQTT_QoS1;
						retained: false;
						yourself]
			raise: MQTTException.
		self shouldnt: [client publish: topic message: pubmsg token: token] raise: Exception.
		self
			shouldnt: [client waitForCompletion: token timeout: (Duration milliseconds: 10000)]
			raise: MQTTException.
		self shouldnt: [client disconnect: (Duration milliseconds: 10000)] raise: Exception]
			ensure: [
				client ifNotNil: [client free].
				pubmsg ifNotNil: [pubmsg free].
				self stopTracing: prevTraceHandler.
				self deny: stream isEmpty].

	^stream
]

{ #category : 'Testing' }
TestMQTTClient >> testExampleClientPub [
	"From the bottom of https://github.com/eclipse/paho.mqtt.c/blob/master/src/MQTTClient.h"

	| address clientId builder |

	address := 'tcp://test.mosquitto.org:1883'.
	clientId := self convertToUTF8: UUID new asString.

	builder := MQTTClient builder serverURI: address clientId: clientId.

	self runExampleClientPub: builder
	
	
]

{ #category : 'Testing' }
TestMQTTClient >> testExampleClientPubSsl [
	"From the bottom of https://github.com/eclipse/paho.mqtt.c/blob/master/src/MQTTClient.h"

	| address clientId builder |

	address := 'ssl://test.mosquitto.org:8883'.
	clientId := self convertToUTF8: UUID new asString.

	builder :=
		MQTTClient builder
			serverURI: address clientId: clientId;
			sslTrustStore: MQTTTestResource current getTestMosquittoOrgTrustStorePEMFileName.

	self runExampleClientPub: builder
]
