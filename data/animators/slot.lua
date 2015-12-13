return {
	default = "empty",

	states = {
		["empty"] = { image = "empty.png", fw = 1, fh = 1, delay = 1 },
		["growing"] = { image = "slot_growing.png", fw = 26, fh = 48, oy = 42, delay = 0.1, loop = false },
		["idle"] = { image = "slot_idle.png", fw = 26, fh = 48, oy = 42, delay = 1 },
		["wither"] = { image = "slot_wither.png", fw = 26, fh = 48, oy = 42, delay = 0.10, loop = false }
	},

	properties = {
		["plant"] = { value = false, isTrigger = true },
		["kill"] = { value = false, isTrigger = true }
	},

	transitions = {
		{ from = "any", to = "growing", property = "plant", value = true },
		{ from = "growing", to = "idle", property = "_finished", value = true },
		{ from = "any", to = "wither", property = "kill", value = true },
		{ from = "wither", to = "empty", property = "_finished", value = true }
	}
}
