local HUD = class("HUD", Entity)

local POWER_BAR_WIDTH = 60

function HUD:initialize(players)
	Entity.initialize(self, 0, 0, -50, "hud")

	self.time_hud = Resources.getImage("time_hud.png")
	self.time_bar = Resources.getImage("time_bar.png")
	self.time_quad = love.graphics.newQuad(0, 0, 78, 7, 78, 7)

	self.heart = Resources.getImage("heart.png")
	self.heart_half = Resources.getImage("heart_half.png")
	self.heart_slot = Resources.getImage("heart_slot.png")
	self.heart_slot_half = Resources.getImage("heart_slot_half.png")

	self.img_hud1 = Resources.getImage("hud1.png")
	self.img_magic_bar = Resources.getImage("magic_bar.png")
	self.magic_bar_quad = love.graphics.newQuad(0, 0, 64, 4, 64, 4)

	self.small_font = Resources.getImageFont("small.png")

	self.seed_slots_overlay = Resources.getImage("seed_slots_overlay.png")
	self.seed_slots_quads = {
		love.graphics.newQuad(0, 0, 18, 17, 51, 17),
		love.graphics.newQuad(17, 0, 17, 17, 51, 17),
		love.graphics.newQuad(33, 0, 18, 17, 51, 17),
	}
	self.seed_slots_offsets = { 0, 17, 33 }

	self.time = 10
	self.max_time = 10

	self.lives = {}
	self.max_lives = {}

	self.magic = {}
	self.magic_show = {}
	self.max_magic = {}

	self.seeds = {}
	self.selected_seed = {}

	self.players = players
	for player=1, self.players do
		self.lives[player] = 3
		self.max_lives[player] = 3

		self.magic_show[player] = 0
		self.magic[player] = 0
		self.max_magic[player] = 100

		self.seeds[player] = {0, 0, 0}
		self.selected_seed[player] = 1
	end
end

function HUD:update(dt)
	for player=1,self.players do
		self.magic_show[player] = math.movetowards(self.magic_show[player], self.magic[player], 3*dt)
	end
end

function HUD:gui()
	-- Draw timer
	love.graphics.draw(self.time_hud, (Screen.WIDTH-80)/2, 7)
	local time_len = self.time / self.max_time * 78
	love.graphics.draw(self.time_bar, self.time_quad, (Screen.WIDTH-time_len)/2, 8)

	for player=1,self.players do
		love.graphics.push()
		love.graphics.translate((player-1)*Screen.WIDTH/2, 0)

		-- Draw heart slots
		local full = math.floor(self.max_lives[player] / 2)
		local halves = self.max_lives[player] % 2
		love.graphics.setColor(243, 203, 203)
		love.graphics.rectangle("fill", 10, 10, (full+halves)*13+4, 2)
		love.graphics.setColor(255, 255, 255)
		for i=1,full do
			love.graphics.draw(self.heart_slot, 12+(i-1)*13, 7)
		end
		if halves > 0 then
			love.graphics.draw(self.heart_slot_half, 12+full*13, 7)
		end

		-- Draw hearts
		full = math.floor(self.lives[player] / 2)
		halves = self.lives[player] % 2
		for i=1,full do
			love.graphics.draw(self.heart, 12+(i-1)*13, 7)
		end
		if halves > 0 then
			love.graphics.draw(self.heart_half, 12+full*13, 7)
		end

		-- Draw back overlay
		love.graphics.draw(self.img_hud1, 10, 18)

		-- Draw magic bar
		love.graphics.draw(self.img_magic_bar, self.magic_bar_quad, 11, 19)

		-- Seed slots
		local sel = self.selected_seed[player]
		love.graphics.draw(self.seed_slots_overlay, self.seed_slots_quads[sel], 10+self.seed_slots_offsets[sel], 26)

		-- Seed counts
		love.graphics.setFont(self.small_font)
		for i=1, 3 do
			love.graphics.print(self.seeds[player][i], 20+(i-1)*16, 34)
		end

		love.graphics.pop()
	end
end

function HUD:setTime(time, max_time)
	self.time = time
	self.max_time = max_time
	local time_len = self.time / self.max_time * 78
	self.time_quad:setViewport((78-time_len)/2, 0, time_len, 7)
end

function HUD:setLives(player, lives, max_lives)
	self.lives[player] = lives
	self.max_lives[player] = max_lives
end

function HUD:setMagic(player, magic, max_magic)
	self.magic[player] = magic
	self.max_magic[player] = max_magic
	local magic_len = self.magic_show[player] / self.max_magic[player] * 64
	self.magic_bar_quad:setViewport(0, 0, magic_len, 4)
end

function HUD:setSeeds(player, seeds, selected_seed)
	self.seeds[player] = seeds
	self.selected_seed[player] = selected_seed
end

return HUD
