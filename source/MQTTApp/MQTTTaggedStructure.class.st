Class {
	#name : 'MQTTTaggedStructure',
	#superclass : 'MQTTStructure',
	#category : 'MQTTApp'
}

{ #category : 'Accessing',
 #vaCategories : ['Accessing','Subclass Responsibility'] }
MQTTTaggedStructure class >> id [
	"Answer the struct_id for this structure
	 
	 Answers:
		<String> 4 bytes"
	
	self subclassResponsibility
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTTaggedStructure class >> initialize: anInstance version: aVersion [
	"Initialize the instance this struct to default vales
	 
	 Arguments:
		anInstance - <MQTTTaggedStructure>
		aVersion - <Integer>
	 Answers:
		<MQTTTaggedStructure> anInstance"

	^anInstance
		struct_id: self id;
		struct_version: self version;
		yourself
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','Subclass Responsibility'] }
MQTTTaggedStructure class >> version [
	"Answer the identifier for this struct type
	 
	 Answers:
		<Integer>"

	self subclassResponsibility
]

{ #category : 'Accessing' }
MQTTTaggedStructure >> struct_id [

	| offset size |

	offset := self offsetOf: #struct_id.
	size := 4.
	^self memcpyStringFrom: offset to: (offset+size-1)
]

{ #category : 'Accessing' }
MQTTTaggedStructure >> struct_id: aStringOrByteArray [

	| offset size |

	offset := self offsetOf: #struct_id.
	size := 4.
	aStringOrByteArray asString
		memcpyFrom: 0
		to: size-1
		into: self
		startingAt: offset
]

{ #category : 'Accessing' }
MQTTTaggedStructure >> struct_version [

	^self int32At: #struct_version
]

{ #category : 'Accessing' }
MQTTTaggedStructure >> struct_version: anObject [

	self int32At: #struct_version put: anObject
]
