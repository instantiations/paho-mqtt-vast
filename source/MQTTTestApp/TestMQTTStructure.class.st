Class {
	#name : 'TestMQTTStructure',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
TestMQTTStructure >> testMemoryManagement1 [

	| smart1 weak1 addr |
	
	smart1 := MQTTProperties create.
	addr := smart1 address.
	self assert: smart1 ownsMemory.
	self assert: (MQTTMemoryTracker smartReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: smart1) = 0.
	
	weak1 := smart1 asWeakReference.
	self deny: weak1 ownsMemory.
	self assert: weak1 address = smart1 address.
	self assert: (MQTTMemoryTracker smartReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker smartReferenceCount: weak1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: weak1) = 1.
	
	weak1 free.
	self assert: (MQTTMemoryTracker smartReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: smart1) = 0.
	self assert: smart1 address = addr.
	self assert: weak1 isUndefined
	
]

{ #category : 'Testing' }
TestMQTTStructure >> testMemoryManagement2 [

	| smart1 weak1 temp |
	
	smart1 := MQTTProperties create.
	self assert: smart1 ownsMemory.
	self assert: (MQTTMemoryTracker smartReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: smart1) = 0.
	
	weak1 := smart1 asWeakReference.
	self deny: weak1 ownsMemory.
	self assert: weak1 address = smart1 address.
	self assert: (MQTTMemoryTracker smartReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: smart1) = 1.
	self assert: (MQTTMemoryTracker smartReferenceCount: weak1) = 1.
	self assert: (MQTTMemoryTracker weakReferenceCount: weak1) = 1.
	
	temp := OSVoid address: smart1 address.
	smart1 free.
	self assert: (MQTTMemoryTracker smartReferenceCount: temp) = 0.
	self assert: (MQTTMemoryTracker weakReferenceCount: temp) = 0.
	self assert: smart1 isUndefined.
	self assert: weak1 isUndefined
	
]

{ #category : 'Testing' }
TestMQTTStructure >> testMemoryManagement3 [
	"Test Expungeable refs.  These are refs that are placed in a special bin by the finalizer to
	 be freed.  They are not freed during finalization because there is a strange issue where the
	 pthread lock in an async openssl call during finalization will deadlock the vm during sleep.
	 
	 NOTE: Because we don't have perfect control over the GC...this test may fail the first time.
	 If this happens...try repeatedly.  If it's failing 10 times in a row...then that is a good indication
	 that this test no longer works."

	| maxSize props ref |

	"Garbage Collection and clear out the finalize queues"
	20 timesRepeat: [System scavenge].
	System globalGarbageCollect.
	[Processor finalizeCycle] whileTrue: [].
	System globalGarbageCollect.
	[Processor finalizeCycle] whileTrue: [].
	MQTTMemoryTracker expungeReferences.

	"Make sure we are starting with an empty bin.
	 Similar to reference counting algos, every new allocation will check if
	 the bin is over its max size and needs to be emptied.  So we allocate maxSize + 1
	 objects...and then lose the reference to them (x509Col := nil).
	 Then we run GC/Finalization which should add them to the expungeable bin.
	 From here...we allocate 1 more object which should trigger the removal of expungeable
	 refs.  After this the bin should be empty"
	self assert: (MQTTMemoryTracker classPool at: 'ExpungeableReferences') isEmpty.
	maxSize := MQTTMemoryTracker expungeMaxSize.
	props := OrderedCollection new.
	maxSize + 1 timesRepeat: [props add: MQTTProperties create].
	self assert: (MQTTMemoryTracker classPool at: 'ExpungeableReferences') isEmpty.
	props := nil.

	"Garbage Collection and clear out the finalize queues"
	20 timesRepeat: [System scavenge].
	System globalGarbageCollect.
	[Processor finalizeCycle] whileTrue: [].
	System globalGarbageCollect.
	[Processor finalizeCycle] whileTrue: [].

	"Scheduling free outside of finalization process is only required on Unix platforms"
	MQTTMemoryTracker finalizeAction = #scheduleExpunge:
		ifTrue: [
			self
				assert: (MQTTMemoryTracker classPool at: 'ExpungeableReferences') size
				equals: maxSize + 1]
		ifFalse: [self assert: (MQTTMemoryTracker classPool at: 'ExpungeableReferences') isEmpty].
	ref := MQTTProperties create.
	self assert: (MQTTMemoryTracker classPool at: 'ExpungeableReferences') isEmpty.
	ref free
]

{ #category : 'Testing' }
TestMQTTStructure >> testNonOpaqueAccessors [
	"Verify Accessors"

	| isStringField mappedFields |

	isStringField := [:struct :field |
		struct == MQTTClientConnectOptions
			ifTrue: [^(Array with: #returnedServerURI with: #serverURI) includes: field].
		struct == MQTTClientSslOptions
			ifTrue: [
				^#(trustStore keyStore privateKey privateKeyPassword enabledCipherSuites CApath)
					includes: field].
		struct == MQTTNameValue ifTrue: [^#(name value) includes: field].
		false].
	mappedFields :=
		Dictionary new
			at: MQTTClientConnectOptions
			put: (
				Dictionary new
					at: #MQTTVersionFor311 put: #returnedMQTTVersion;
					at: #sessionPresent put: #returnedSessionPresent;
					at: #len put: #binarypwdLen;
					at: #data put: #binarypwdData;
					at: #serverURI put: #returnedServerURI;
					yourself).

	MQTTStructure allSubclassesDo: [:structClass | | struct |
		struct := structClass new.
		structClass inlinedMembers do: [:memberName | | getters |
			getters :=
				Array with: (
					(mappedFields at: structClass ifAbsent: [Dictionary new])
						at: memberName asSymbol
						ifAbsent: [memberName asSymbol]).
			getters do: [:getter | | setter |
				setter := (getter , ':') asSymbol.
				(getter = #struct_id)
					ifTrue: [
						self
							shouldnt: [self assert: (struct perform: getter) = #[0 0 0 0] asString]
							raise: Exception]
					ifFalse: [
						(isStringField value: structClass value: getter)
							ifTrue: [
								self
									shouldnt: [self assert: (struct perform: getter) = '']
									raise: Exception]
							ifFalse: [
								self
									shouldnt: [self assert: (struct perform: getter) asInteger = 0]
									raise: Exception]].
				(structClass canUnderstand: setter)
					ifTrue: [
						(getter = #struct_id)
							ifTrue: [
								struct perform: setter with: 'ABCD'.
								self
									shouldnt: [self assert: (struct perform: getter) = 'ABCD']
									raise: Exception.
								struct perform: setter with: #[0 0 0 0] asString]
							ifFalse: [
								(isStringField value: structClass value: getter)
									ifTrue: [
										struct perform: setter with: 'ABCD'.
										self
											shouldnt: [
												self assert: (struct perform: getter) = 'ABCD']
											raise: Exception.
										struct perform: setter with: '']
									ifFalse: [
										struct perform: setter with: 1.
										self
											shouldnt: [
												self assert: (struct perform: getter) asInteger = 1]
											raise: Exception.
										struct perform: setter with: 0]]]]]]
]
