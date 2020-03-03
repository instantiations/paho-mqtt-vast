Class {
	#name : 'TestMQTTClientBuilder',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
TestMQTTClientBuilder >> testConnectionOptions [

	| builder connectOptions |

	builder :=
		MQTTClientBuilder new
			cleanSession: true;
			cleanStart: true;
			connectTimeout: (Duration hours: 2);
			keepAliveInterval: (Duration minutes: 59);
			maxInflightMessages: 42;
			password: 'myPass';
			reliable: true;
			retryInterval: (Duration minutes: 12);
			serverURIs:
				(Array with: 'tcp://test.mosquitto.org:1883' with: 'ssl://test.mosquitto.org:8883');
			username: 'myUser'.
	connectOptions := builder buildConnectOptionsStruct.

	[
		self
			assert: connectOptions cleansession = 1;
			assert: connectOptions cleanstart = 1;
			assert: connectOptions connectTimeout equals: (Duration hours: 2) asSeconds;
			assert: connectOptions keepAliveInterval equals: (Duration minutes: 59) asSeconds;
			assert: connectOptions maxInflightMessages equals: 42;
			assert: connectOptions password equals: 'myPass';
			assert: connectOptions reliable = 1;
			assert: connectOptions retryInterval equals: (Duration minutes: 12) asSeconds;
			assert: connectOptions username equals: 'myUser'.

		self assert: connectOptions serverURIcount equals: 2.
		self
			assert: (connectOptions serverURIs at: 0) asString
			equals: 'tcp://test.mosquitto.org:1883'.
		self
			assert: (connectOptions serverURIs at: 1) asString
			equals: 'ssl://test.mosquitto.org:8883']
				ensure: [connectOptions free]
]

{ #category : 'Testing' }
TestMQTTClientBuilder >> testCreationOptions [

	| builder createOptions |

	builder :=
		MQTTClientBuilder new
			mqttVersion: MQTTVERSION_5;
			persistenceContext: #[1 2 3 4 5];
			persistenceType: MQTTCLIENT_PERSISTENCE_DEFAULT;
			serverURI: 'tcp://test.mosquitto.org:1883' clientId: 'ExampleClientPub'.
	createOptions := builder buildCreateOptionsStruct.

	self
		assert: createOptions MQTTVersion equals: MQTTVERSION_5;
		assert: (builder createOptions at: ##PersistenceContext) equals: #[1 2 3 4 5];
		assert: (builder createOptions at: ##PersistenceType) equals: MQTTCLIENT_PERSISTENCE_DEFAULT;
		assert: (builder createOptions at: ##ServerURI) equals: 'tcp://test.mosquitto.org:1883';
		assert: (builder createOptions at: ##ClientId) equals: 'ExampleClientPub'
]

{ #category : 'Testing' }
TestMQTTClientBuilder >> testSslOptions [

	| builder sslOptions |

	builder :=
		MQTTClientBuilder new
			sslCAPath: 'CAPath';
			sslEnabledCipherSuites: 'ALL';
			sslEnableServerCertAuth: true;
			sslKeyStore: 'myKeyStore';
			sslPrivateKey: 'myPrivKey';
			sslPrivateKeyPassword: 'myPass';
			sslTrustStore: 'trustStore.crt' asPath;
			sslVerify: true;
			sslVersion: MQTT_SSL_VERSION_TLS_1_2.
	sslOptions := builder buildSslOptionsStruct.

	[
		self
			assert: sslOptions CApath equals: 'CAPath';
			assert: sslOptions enabledCipherSuites equals: 'ALL';
			assert: sslOptions enableServerCertAuth = 1;
			assert: sslOptions keyStore equals: 'myKeyStore';
			assert: sslOptions privateKey equals: 'myPrivKey';
			assert: sslOptions privateKeyPassword equals: 'myPass';
			assert: sslOptions trustStore equals: 'trustStore.crt';
			assert: sslOptions verify = 1;
			assert: sslOptions sslVersion equals: MQTT_SSL_VERSION_TLS_1_2;
			assert: sslOptions ssl_error_cb = 0;
			assert: sslOptions ssl_error_context = 0]
				ensure: [sslOptions free]
]

{ #category : 'Testing' }
TestMQTTClientBuilder >> testWillOptions [

	| builder willOptions |

	builder :=
		MQTTClientBuilder new
			willMessage: 'Will Message';
			willQos: MQTT_QoS2;
			willRetained: true;
			willTopicName: 'WillTopic'.
	willOptions := builder buildWillOptionsStruct.

	[
		self
			assert: willOptions message equals: 'Will Message';
			assert: willOptions qos equals: MQTT_QoS2;
			assert: willOptions retained = 1;
			assert: willOptions topicName equals: 'WillTopic';
			assert: willOptions payloadData isNull;
			assert: willOptions payloadLen = 0]
				ensure: [willOptions free]
]

{ #category : 'Testing' }
TestMQTTClientBuilder >> testWillOptions2 [

	| builder willOptions |

	builder :=
		MQTTClientBuilder new
			willMessage: 'Will Message' asByteArray;
			willQos: MQTT_QoS2;
			willRetained: true;
			willTopicName: 'WillTopic'.
	willOptions := builder buildWillOptionsStruct.

	[
		self
			assert: (willOptions payloadData memcpyFrom: 0 to: willOptions payloadLen - 1)
				equals: 'Will Message' asByteArray;
			assert: willOptions message isEmpty;
			assert: willOptions qos equals: MQTT_QoS2;
			assert: willOptions retained = 1;
			assert: willOptions topicName equals: 'WillTopic']
				ensure: [willOptions free]
]
