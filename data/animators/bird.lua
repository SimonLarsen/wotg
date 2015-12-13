return {
	default = "fly",

	states = {
		["fly"] = { image = "bird_fly.png", fw = 25, fh = 23, ox = 14, oy = 14, delay = 0.1 },
		["dash"] = { image = "bird_dash.png", fw = 20, fh = 16, oy = 8, delay = 1 },
		["eat"] = { image = "bird_eat.png", fw = 20, fh = 19, oy = 10, delay = 0.15 },
		["stunned"] = { image = "bird_stunned.png", fw = 20, fh = 16, oy = 8, delay = 1 }
	},

	properties = {
		["state"] = { value = 0 }
	},

	transitions = {

	}
}
