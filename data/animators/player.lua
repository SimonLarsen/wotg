return {
	default = "idle",

	states = {
		["idle"] = { image = "player_idle.png", fw = 16, fh = 32, oy = 20, delay = 1 },
		["run"] = { image = "player_run.png", fw = 18, fh = 32, oy = 20, delay = 0.1 },
		["attack"] = { image = "player_attack.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.05 },
		["hurt"] = { image = "player_hurt.png", fw = 18, fh = 32, oy = 20, delay = 0.25 },
		["jump"] = { image = "player_jump.png", fw = 18, fh = 32, oy = 20, delay = 0.1, loop = false },
		["fall"] = { image = "player_fall.png", fw = 18, fh = 32, oy = 20, delay = 0.1 },
		["magic"] = { image = "player_magic.png", fw = 28, fh = 32, oy = 20, delay = 0.1 },
		["plant"] = { image = "player_plant.png", fw = 20, fh = 32, oy = 20, delay = 0.1, loop = false },
		["dead"] = { image = "player_death.png", fw = 29, fh = 32, ox = 14, oy = 20, delay = 0.1, loop = false }
	},

	properties = {
		["state"] = { value = 1 },
		["attack"] = { value = false, isTrigger = true },
		["jump"] = { value = false, isTrigger = true },
		["dead"] = { value = false, isTrigger = true }
	},

	transitions = {
		{ from = "run", to = "idle", property = "state", value = 1 },
		{ from = "idle", to = "run", property = "state", value = 2 },

		{ from = "idle", to = "attack", property = "attack", value = true },
		{ from = "run", to = "attack", property = "attack", value = true },
		{ from = "jump", to = "attack", property = "attack", value = true },
		{ from = "fall", to = "attack", property = "attack", value = true },
		{ from = "attack", to = "idle", property = "_finished", value = true },

		{ from = "any", to = "hurt", property = "state", value = 3 },
		{ from = "hurt", to = "idle", property = "_finished", value = true },

		{ from = "idle", to = "jump", property = "jump", value = true },
		{ from = "run", to = "jump", property = "jump", value = true },
		{ from = "jump", to = "jump", property = "jump", value = true },
		{ from = "fall", to = "jump", property = "jump", value = true },

		{ from = "jump", to = "fall", property = "state", value = 4 },
		{ from = "idle", to = "fall", property = "state", value = 4 },
		{ from = "run", to = "fall", property = "state", value = 4 },

		{ from = "fall", to = "idle", property = "state", value = 1 },
		{ from = "fall", to = "run", property = "state", value = 2 },

		{ from = "any", to = "plant", property = "state", value = 5 },
		{ from = "plant", to = "idle", property = "_finished", value = true },

		{ from = "any", to = "dead", property = "state", value = 6 }
	}
}
