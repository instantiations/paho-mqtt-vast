Class {
	#name : 'MQTTDeliveryToken',
	#superclass : 'OSInt32',
	#category : 'MQTTAppClient'
}

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTDeliveryToken class >> initializeAfterLoad [
	"Initialize the information describing this type"

	self
		fixedSize: 4;
		isSigned: true
]

{ #category : 'Creation' }
MQTTDeliveryToken class >> value: tokenValue [
	"Answer a new instance of this token with the specified value
	 
	 Note: This allocates in smalltalk heap...so you don't need to free this
	 
	 Answers:
		<MQTTClientDeliveryToken>"
	
	^self new
		value: tokenValue;
		yourself
]

{ #category : 'Accessing' }
MQTTDeliveryToken >> value [
	"Answer the value of the delivery token.
	 Answer nil if this token is null
	 
	 Answers:
		<Integer> token value"

	^self isNull ifTrue: [nil] ifFalse: [self at: 0]
]

{ #category : 'Accessing' }
MQTTDeliveryToken >> value: tokenValue [
	"Set the value of the delivery token.
	 
	 Arguments:
		tokenValue - <Integer> token value"

	self isNull ifTrue: [^self].
	self at: 0 put: tokenValue asInt32
]
