Class {
	#name : 'TestMQTTReasonCode',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
TestMQTTReasonCode >> testInteger_AsMQTTReasonCodeString [

	(MQTTConstants keys select: [:e | e beginsWithSubCollection: 'MQTTREASONCODE_'])
		do: [:e | self assert: (MQTTConstants at: e) asMQTTReasonCodeString notNil].
		
	self assert: -1 asMQTTReasonCodeString isNil
]
