"
/**
  * @brief A structure containing the function pointers to a persistence 
  * implementation and the context or state that will be shared across all 
  * the persistence functions.
  */
typedef struct {
  /** 
    * A pointer to any data required to initialize the persistent store.
    */
	void* context;
  /** 
    * A function pointer to an implementation of Persistence_open().
    */
	Persistence_open popen;
  /** 
    * A function pointer to an implementation of Persistence_close().
    */
	Persistence_close pclose;
  /**
    * A function pointer to an implementation of Persistence_put().
    */
	Persistence_put pput;
  /** 
    * A function pointer to an implementation of Persistence_get().
    */
	Persistence_get pget;
  /** 
    * A function pointer to an implementation of Persistence_remove().
    */
	Persistence_remove premove;
  /** 
    * A function pointer to an implementation of Persistence_keys().
    */
	Persistence_keys pkeys;
  /** 
    * A function pointer to an implementation of Persistence_clear().
    */
	Persistence_clear pclear;
  /** 
    * A function pointer to an implementation of Persistence_containskey().
    */
	Persistence_containskey pcontainskey;
} MQTTClient_persistence;
"
Class {
	#name : 'MQTTClientPersistence',
	#superclass : 'MQTTStructure',
	#category : 'MQTTAppPersistence'
}

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientPersistence class >> initializeAfterLoad [

	self
		members: #(context popen pclose pput pget premove pkeys pclear pcontainskey)
		types: #(pointer pointer pointer pointer pointer pointer pointer pointer pointer)
]

{ #category : 'Accessing' }
MQTTClientPersistence >> context [

	^self pointerAt: #context
]

{ #category : 'Accessing' }
MQTTClientPersistence >> context: anObject [

	self pointerAt: #context put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pclear [

	^self pointerAt: #pclear
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pclear: anObject [

	self pointerAt: #pclear put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pclose [

	^self pointerAt: #pclose
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pclose: anObject [

	self pointerAt: #pclose put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pcontainskey [

	^self pointerAt: #pcontainskey
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pcontainskey: anObject [

	self pointerAt: #pcontainskey put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pget [

	^self pointerAt: #pget
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pget: anObject [

	self pointerAt: #pget put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pkeys [

	^self pointerAt: #pkeys
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pkeys: anObject [

	self pointerAt: #pkeys put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> popen [

	^self pointerAt: #popen
]

{ #category : 'Accessing' }
MQTTClientPersistence >> popen: anObject [

	self pointerAt: #popen put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pput [

	^self pointerAt: #pput
]

{ #category : 'Accessing' }
MQTTClientPersistence >> pput: anObject [

	self pointerAt: #pput put: anObject
]

{ #category : 'Accessing' }
MQTTClientPersistence >> premove [

	^self pointerAt: #premove
]

{ #category : 'Accessing' }
MQTTClientPersistence >> premove: anObject [

	self pointerAt: #premove put: anObject
]
