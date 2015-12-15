return {
	default = "fly",

	states = {
		["fly"] = { image = "bats_fly.png", fw = 22, fh = 18, delay = 0.1 },
		["seek"] = { image = "bats_fly.png", fw = 22, fh = 18, delay = 0.1 },
		["eat"] = { image = "bats_eat.png", fw = 18, fh = 18, delay = 0.15 },
		["attack"] = { image = "bats_fly.png", fw = 22, fh = 18, delay = 0.1 },
		["dead"] = { image = "bats_dead.png", fw = 18, fh = 18, delay = 1 }
	},

	properties = {
		["state"] = { value = 0 }
	},

	transitions = {
		{ from = "any", to = "fly", property = "state", value = 1 },
		{ from = "any", to = "seek", property = "state", value = 2 },
		{ from = "any", to = "eat", property = "state", value = 3 },
		{ from = "any", to = "attack", property = "state", value = 4 },
		{ from = "any", to = "dead", property = "state", value = 5 },
	}
}
