extends Face

func use(_source:Unit,targets:Array[Unit],pips):
	targets.front().pip_mod += pips
