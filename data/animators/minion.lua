return {
	default = "idle",

	states = {
		["idle"] = { image = "minion_idle.png", fw = 12, fh = 14, oy = 6, delay = 1 },
		["walk"] = { image = "minion_run.png", fw = 24, fh = 24, oy = 16, delay = 0.1 },
		["charge"] = { image = "minion_charge.png", fw = 25, fh = 25, ox = 13, oy = 17, delay = 0.1, loop = false },
		["jump"] = { image = "minion_jump.png", fw = 25, fh = 25, ox = 13, oy = 17, delay = 0.1, loop = false }
	},

	properties = {
		["state"] = { value = 1 }
	},

	transitions = {
		{ from = "any", to = "idle", property = "state", value = 1 },
		{ from = "any", to = "walk", property = "state", value = 2 },
		{ from = "any", to = "charge", property = "state", value = 3 },
		{ from = "any", to = "jump", property = "state", value = 4 },
	}
}
