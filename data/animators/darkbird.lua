return {
	default = "fly",

	states = {
		["fly"] = { image = "bird2_fly.png", fw = 25, fh = 23, ox = 14, oy = 14, delay = 0.1 },
		["charge"] = { image = "bird2_charge.png", fw = 25, fh = 23, ox = 14, oy = 14, delay = 1 },
		["dash"] = { image = "bird2_dash.png", fw = 25, fh = 23, ox = 14, oy = 14, delay = 0.07 },
		["seek"] = { image = "bird2_fly.png", fw = 25, fh = 23, ox = 14, oy = 14, delay = 0.1 },
		["eat"] = { image = "bird2_eat.png", fw = 20, fh = 19, oy = 10, delay = 0.15 },
		["stunned"] = { image = "bird2_stunned.png", fw = 24, fh = 14, oy = 7, delay = 1 }
	},

	properties = {
		["state"] = { value = 0 }
	},

	transitions = {
		{ from = "any", to = "fly", property = "state", value = 1 },
		{ from = "any", to = "charge", property = "state", value = 2 },
		{ from = "any", to = "dash", property = "state", value = 3 },
		{ from = "any", to = "seek", property = "state", value = 4 },
		{ from = "any", to = "eat", property = "state", value = 5 },
		{ from = "any", to = "stunned", property = "state", value = 6 }
	}
}
