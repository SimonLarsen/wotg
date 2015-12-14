return {
	default = "walk",
	
	states = {
		["walk"] = { image = "rat_walk.png", fw = 20, fh = 10, oy = 5, delay = 0.07 },
		["charge"] = { image = "rat_charge.png", fw = 14, fh = 14, oy = 9, delay = 1 },
		["jump"] = { image = "rat_jump.png", fw = 17, fh = 17, ox = 8, oy = 13, delay = 0.1, loop = false },
		["eat"] = { image = "rat_eat.png", fw = 16, fh = 10, oy = 5, delay = 0.1, },
		["stunned"] = { image = "rat_stunned.png", fw = 16, fh = 10, oy = 5, delay = 1 }
	},

	properties = {
		["state"] = { value = 1 }
	},

	transitions = {
		{ from = "any", to = "walk", property = "state", value = 1 },
		{ from = "any", to = "charge", property = "state", value = 2 },
		{ from = "any", to = "jump", property = "state", value = 3 },
		{ from = "any", to = "eat", property = "state", value = 4 },
		{ from = "any", to = "stunned", property = "state", value = 5 }
	}
}
