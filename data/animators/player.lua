return {
	default = "idle",

	states = {
		["idle"] = { image = "player_idle.png", fw = 16, fh = 32, oy = 20, delay = 1 },
		["run"] = { image = "player_run.png", fw = 18, fh = 32, oy = 20, delay = 0.1 },
		["charge"] = { image = "player_charge.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.02, loop = false },
		["attack"] = { image = "player_attack.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.05 }
	},

	properties = {
		["state"] = { value = 1 },
		["attack"] = { value = false, isTrigger = true }
	},

	transitions = {
		{
			from = "run", to = "idle",
			property = "state", value = 1
		},
		{
			from = "idle", to = "run",
			property = "state", value = 2
		},
		{
			from = "any", to = "charge",
			property = "state", value = 3
		},
		{
			from = "any", to = "attack",
			property = "attack", value = true
		},
		{
			from = "attack", to = "idle",
			property = "_finished", value = true
		}
	}
}
