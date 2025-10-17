extends StatusToken

func apply(_source:Unit,target:Unit):
	holder = target
	holder.damage_incoming.connect(double)
	target.token_container.add_child(self)

func double(amount):
	holder.incoming_mod += amount
	await holder.damage_taken
	queue_free()
