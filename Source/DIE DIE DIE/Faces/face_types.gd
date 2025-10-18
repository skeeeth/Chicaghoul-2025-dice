extends Node
## Singleton containing the data for all face types

#list of all face types
enum list {ATK,BLOCK,BLANK,AMP,WEAK,VULN,HATCH_LA,HATCH_RA,HATCH_LL,HATCH_RL}
#DEEPLY COUPLED TO LIST, REARRANGEMENT OF EITHER WILL BREAK EVERYTHING
@export var directory:Array[Face]
