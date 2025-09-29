extends Face

func use(source:Unit,targets:Array[Unit],count:int):
	targets[0].take_damage(count,source)
	
