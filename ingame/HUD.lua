local HUD = class("HUD", Entity)

local POWER_BAR_WIDTH = 60

function HUD:initialize(players)
	Entity.initialize(self, 0, 0, -50, "hud")

	self.heart = Resources.getImage("heart.png")
	self.heart_half = Resources.getImage("heart_half.png")
	self.heart_slot = Resources.getImage("heart_slot.png")
	self.heart_slot_half = Resources.getImage("heart_slot_half.png")

	self.img_hud1 = Resources.getImage("hud1.png")
	self.img_magic_bar = Resources.getImage("magic_bar.png")
	self.magic_left = love.graphics.newQuad(0, 0, 2, 4, 5, 4)
	self.magic_mid = love.graphics.newQuad(2, 0, 1, 4, 5, 4)
	self.magic_right = love.graphics.newQuad(3, 0, 2, 4, 5, 4)

	self.small_font = Resources.getImageFont("small.png")

	self.seed_slots_overlay = Resources.getImage("seed_slots_overlay.png")
	self.seed_slots_quads = {
		love.graphics.newQuad(0, 0, 18, 17, 51, 17),
		love.graphics.newQuad(17, 0, 17, 17, 51, 17),
		love.graphics.newQuad(33, 0, 18, 17, 51, 17),
	}
	self.seed_slots_offsets = { 0, 18, 33 }

	self.lives = {}
	self.max_lives = {}

	self.magic = {}
	self.max_magic = {}

	self.seeds = {}
	self.selected_seed = {}

	self.xp = {}
	self.max_xp = {}

	self.players = players
	for player=1, self.players do
		self.lives[player] = 3
		self.max_lives[player] = 3

		self.magic[player] = 0
		self.max_magic[player] = 100

		self.seeds[player] = {0, 0, 0}
		self.selected_seed[player] = 1

		self.xp[player] = 0
		self.max_xp[player] = 3
	end
end

function HUD:gui()
	-- Draw heart slots
	local full = math.floor(self.max_lives[1] / 2)
	local halves = self.max_lives[1] % 2
	love.graphics.rectangle("fill", 17, 10, (full+halves)*13+4, 2)
	for i=1,full do
		love.graphics.draw(self.heart_slot, 19+(i-1)*13, 7)
	end
	if halves > 0 then
		love.graphics.draw(self.heart_slot_half, 19+full*13, 7)
	end

	-- Draw hearts
	full = math.floor(self.lives[1] / 2)
	halves = self.lives[1] % 2
	for i=1,full do
		love.graphics.draw(self.heart, 19+(i-1)*13, 7)
	end
	if halves > 0 then
		love.graphics.draw(self.heart_half, 19+full*13, 7)
	end

	-- Draw back overlay
	love.graphics.draw(self.img_hud1, 0, 0)

	-- Draw magic bar
	local magic_len = self.magic[1] / self.max_magic[1] * 64
	if self.magic[1] > 0 then
		love.graphics.draw(self.img_magic_bar, self.magic_left, 18, 19)
		love.graphics.draw(self.img_magic_bar, self.magic_mid, 20, 19, 0, magic_len-4, 1)
		if self.magic[1] == self.max_magic[1] then
			love.graphics.draw(self.img_magic_bar, self.magic_right, 80, 19)
		end
	end

	-- Seed slots
	local sel = self.selected_seed[1]
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.seed_slots_overlay, self.seed_slots_quads[sel], 17+self.seed_slots_offsets[sel], 26)

	-- Seed counts
	love.graphics.setFont(self.small_font)
	for i=1, 3 do
		love.graphics.print(self.seeds[1][i], (i-1)*16+27, 34)
	end

	-- Draw XP
	local xp_len = self.xp[1] / self.max_xp[1] * 32
	love.graphics.setColor(255, 216, 41)
	love.graphics.rectangle("fill", 9, 41-xp_len, 3, xp_len)
	love.graphics.setColor(255, 255, 255)
end

function HUD:setLives(player, lives, max_lives)
	self.lives[player] = lives
	self.max_lives[player] = max_lives
end

function HUD:setMagic(player, magic, max_magic)
	self.magic[player] = magic
	self.max_magic[player] = max_magic
end

function HUD:setSeeds(player, seeds, selected_seed)
	self.seeds[player] = seeds
	self.selected_seed[player] = selected_seed
end

function HUD:setXP(player, xp, max_xp)
	self.xp[player] = xp
	self.max_xp[player] = max_xp
end

return HUD
