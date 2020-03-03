"
(c) Copyright Instantiations Corporation 2005-2018. All Rights Reserved.

DESCRIPTION:
Abstract class that has just the interface to describe making platform function
calls with arguments.  Concrete subclasses apply specific call semantics

Only 1 concrete subclass is implemented in this application, but that is primary due to
prerequisites.  The default subclass is synchrounous.

Via simple subclasses, it is very straightforward to provide other types like asynchrounous or static future
calls.  To change this system wide do this: LZ4CallEngine default: <new impl class>

RESPONSIBILITY:
Simle platform function caling interface
"
Class {
	#name : 'MQTTCallEngine',
	#superclass : 'Object',
	#classVars : [
		'Default'
	],
	#category : 'MQTTApp'
}

{ #category : 'Defaults',
  #vaVisibility : 'private' }
MQTTCallEngine class >> default [
	"Answers the default calling engine
	 
	 Answers:
		<MQTTCallEngine>"
	
	^Default
]

{ #category : 'Defaults',
  #vaVisibility : 'private' }
MQTTCallEngine class >> default: aCallEngineClass [
	"Sets the default calling engine class
	 
	 Arguments:
		aCallEngineClass - <MQTTCallEngine class>"
	
	Default := aCallEngineClass
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTCallEngine class >> initializeAfterLoad [
	"The default calling engine is synchronous"

	self default: MQTTSynchronousCallEngine
]

{ #category : 'Creation' }
MQTTCallEngine class >> new [
	"Answer a new instance of this call engine
	 
	 Answers:
		<MQTTCallEngine>"
	
	^self basicNew initialize
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction [
	"Perform 0-arg call"
	
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 [
	"Perform 1-arg call"
		
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 with: arg2 [
	"Perform 2-arg call"
		
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 [
	"Perform 3-arg call"
		
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 [
	"Perform 4-arg call"
		
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	"Perform 5-arg call"
		
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 [
	"Perform 6-arg call"
		
	self subclassResponsibility
]

{ #category : 'API',
 #vaCategories : ['API','Subclass Responsibility'] }
MQTTCallEngine >> call: aPlatformFunction with: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 [
	"Perform 7-arg call"
		
	self subclassResponsibility
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTCallEngine >> initialize [
	"Do nothing by default"
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTCallEngine >> release [
	"Subclasses should use this to release any resources"
]
