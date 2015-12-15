return {
	default = "idle",

	states = {
		["idle"] = { image = "player_idle.png", fw = 16, fh = 32, oy = 20, delay = 1 },
		["run"] = { image = "player_run.png", fw = 18, fh = 32, oy = 20, delay = 0.1 },
		["charge"] = { image = "player_charge.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.02, loop = false },
		["attack"] = { image = "player_attack.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.05 },
		["hurt"] = { image = "player_hurt.png", fw = 18, fh = 32, oy = 20, delay = 0.25 },
		["jump"] = { image = "player_jump.png", fw = 18, fh = 32, oy = 20, delay = 0.10, loop = false },
		["fall"] = { image = "player_fall.png", fw = 18, fh = 32, oy = 20, delay = 0.1 },
		["dead"] = { image = "player_death.png", fw = 29, fh = 32, ox = 14, oy = 20, delay = 0.1, loop = false } 
	},

	properties = {
		["state"] = { value = 1 },
		["charge"] = { value = false, isTrigger = true },
		["attack"] = { value = false, isTrigger = true },
		["jump"] = { value = false, isTrigger = true },
		["dead"] = { value = false, isTrigger = true }
	},

	transitions = {
		{ from = "run", to = "idle", property = "state", value = 1 },
		{ from = "idle", to = "run", property = "state", value = 2 },

		{ from = "idle", to = "charge", property = "charge", value = true },
		{ from = "run", to = "charge", property = "charge", value = true },
		{ from = "jump", to = "charge", property = "charge", value = true },
		{ from = "fall", to = "charge", property = "charge", value = true },
		{ from = "charge", to = "attack", property = "attack", value = true },
		{ from = "attack", to = "idle", property = "_finished", value = true },

		{ from = "any", to = "hurt", property = "state", value = 4 },
		{ from = "hurt", to = "idle", property = "_finished", value = true },

		{ from = "idle", to = "jump", property = "jump", value = true },
		{ from = "run", to = "jump", property = "jump", value = true },
		{ from = "jump", to = "fall", property = "state", value = 5 },

		{ from = "idle", to = "fall", property = "state", value = 5 },
		{ from = "run", to = "fall", property = "state", value = 5 },
		{ from = "fall", to = "idle", property = "state", value = 1 },
		{ from = "fall", to = "run", property = "state", value = 2 },

		{ from = "any", to = "dead", property = "state", value = 6 }
	}
}
