return {
	default = "walk",

	states = {
		["walk"] = { image = "pig_walk.png", fw = 32, fh = 32, oy = 24, delay = 0.2 },
		["charge"] = { image = "pig_charge.png", fw = 32, fh = 32, oy = 24, delay = 1 },
		["dash"] = { image = "pig_dash.png", fw = 32, fh = 32, oy = 24, delay = 0.12 },
		["eat"] = { image = "pig_eat.png", fw = 24, fh = 32, oy = 24, delay = 0.15 },
		["stunned"] = { image = "pig_stunned.png", fw = 32, fh = 32, oy = 24, delay = 0.2 }
	},

	properties = {
		["state"] = { value = 0 }
	},

	transitions = {
		{ from = "any", to = "walk", property = "state", value = 1 },
		{ from = "any", to = "charge", property = "state", value = 2 },
		{ from = "any", to = "dash", property = "state", value = 3 },
		{ from = "any", to = "eat", property = "state", value = 4 },
		{ from = "any", to = "stunned", property = "state", value = 5 }
	}
}
