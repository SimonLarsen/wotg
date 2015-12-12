return {
	default = "idle",

	states = {
		["idle"] = { image = "player_idle.png", fw = 16, fh = 32, oy = 20, delay = 1 },
		["run"] = { image = "player_run.png", fw = 18, fh = 32, oy = 20, delay = 0.1 }
	},

	properties = {
		["state"] = { value = 0 }
	},

	transitions = {
		{
			from = "any", to = "idle",
			property = "state", value = 0
		},
		{
			from = "any", to = "run",
			property = "state", value = 1
		}
	}
}
