return {
	default = "empty",

	states = {
		["empty"] = { image = "empty.png", fw = 1, fh = 1, delay = 1 },
		["pop"] = { image = "leaves_pop.png", fw = 20, fh = 20, delay = 0.1 },
		["idle"] = { image = "leaves_idle.png", fw = 20, fh = 20, delay = 0.15 },
		["wither"] = { image = "leaves_wither.png", fw = 20, fh = 20, delay = 0.1 }
	},

	properties = {
		["pop"] = { value = false, isTrigger = true },
		["kill"] = { value = false, isTrigger = true }
	},

	transitions = {
		{ from = "any", to = "pop", property = "pop", value = true },
		{ from = "pop", to = "idle", property = "_finished", value = true },
		{ from = "any", to = "wither", property = "kill", value = true },
		{ from = "wither", to = "empty", property = "_finished", value = true }
	}
}
