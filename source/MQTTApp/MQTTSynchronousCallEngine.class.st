"
(c) Copyright Instantiations Corporation 2005-2018. All Rights Reserved.

DESCRIPTION:
Implements the calling engine interface defined by the superclass using synchronous platform function calls.

RESPONSIBILITY:
Synchronous platform function calls with arguments
"
Class {
	#name : 'MQTTSynchronousCallEngine',
	#superclass : 'MQTTCallEngine',
	#category : 'MQTTApp'
}

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction [
	"Perform 0-arg sync call"
	
	^aPlatformFunction call
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 [
	"Perform 1-arg sync call"	
	
	^aPlatformFunction callWith: arg1
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 with: arg2 [
	"Perform 2-arg sync call"
	
	^aPlatformFunction callWith: arg1 with: arg2
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 [
	"Perform 3-arg sync call"
	
	^aPlatformFunction callWith: arg1 with: arg2 with: arg3
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 [
	"Perform 4-arg sync call"
	
	^aPlatformFunction callWith: arg1 with: arg2 with: arg3 with: arg4
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	"Perform 5-arg sync call"
	
	^aPlatformFunction callWith: arg1 with: arg2 with: arg3 with: arg4 with: arg5
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 [
	"Perform 6-arg sync call"
	
	^aPlatformFunction callWith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6
]

{ #category : 'API' }
MQTTSynchronousCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 [
	"Perform 7-arg sync call"
	
	^aPlatformFunction callWith: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7
]
