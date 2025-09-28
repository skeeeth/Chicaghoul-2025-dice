extends Node
## Singleton containing the data for all face types

#list of all face types
enum list {ATK,BLOCK,BLANK}
#DEEPLY COUPLED TO LIST, REARRANGEMENT OF EITHER WILL BREAK EVERYTHING
@export var directory:Array[Face]
