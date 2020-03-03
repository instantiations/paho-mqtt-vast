Class {
	#name : 'MQTTStaticFutureCallEngine',
	#superclass : 'MQTTCallEngine',
	#instVars : [
		'staticFuture'
	],
	#category : 'MQTTApp'
}

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction [
	"Perform 0-arg static future call"

	^(aPlatformFunction staticFutureCall: staticFuture) value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 [
	"Perform 1-arg static future call"

	^(aPlatformFunction staticFutureCall: staticFuture with: arg1) value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 with: arg2 [
	"Perform 2-arg static future call"

	^(aPlatformFunction staticFutureCall: staticFuture with: arg1 with: arg2) value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 [
	"Perform 3-arg static future call"

	^(aPlatformFunction staticFutureCall: staticFuture with: arg1 with: arg2 with: arg3) value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 [
	"Perform 4-arg static future call"

	^(aPlatformFunction staticFutureCall: staticFuture with: arg1 with: arg2 with: arg3 with: arg4)
		value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	"Perform 5-arg static future call"

	^(aPlatformFunction
		staticFutureCall: staticFuture
		with: arg1
		with: arg2
		with: arg3
		with: arg4
		with: arg5)
			value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 [
	"Perform 6-arg static future call"

	^(aPlatformFunction
		staticFutureCall: staticFuture
		with: arg1
		with: arg2
		with: arg3
		with: arg4
		with: arg5
		with: arg6)
			value
]

{ #category : 'API' }
MQTTStaticFutureCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 [
	"Perform 7-arg static future call"

	^(aPlatformFunction
		staticFutureCall: staticFuture
		with: arg1
		with: arg2
		with: arg3
		with: arg4
		with: arg5
		with: arg6
		with: arg7)
			value
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTStaticFutureCallEngine >> initialize [

	staticFuture := AcoResourceManager default createStaticFuture.
	staticFuture isAcoError
		ifTrue: [MQTTException signal: 'Error initializing static future calling engine']
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTStaticFutureCallEngine >> release [
	"Return the static future"

	(staticFuture isNil or: [staticFuture isAcoError]) ifTrue: [^self].
	AcoResourceManager default returnStaticFuture: staticFuture.
	staticFuture := nil
]
