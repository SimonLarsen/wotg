local HUD = class("HUD", Entity)

local POWER_BAR_WIDTH = 60

function HUD:initialize(players)
	Entity.initialize(self, 0, 0, -100, "hud")

	self.heart = Resources.getImage("heart.png")
	self.heart_black = Resources.getImage("heart_black.png")
	self.heart_part = {
		Resources.getImage("heart_part1.png"),
		Resources.getImage("heart_part2.png"),
		Resources.getImage("heart_part3.png")
	}

	self.lives = {}
	self.max_lives = {}

	self.magic = {}
	self.max_magic = {}

	self.seeds = {}

	self.players = players
	for player=1, self.players do
		self.lives[player] = 3
		self.max_lives[player] = 3

		self.magic[player] = 0
		self.max_magic[player] = 100

		self.seeds[player] = {0, 0, 0}
	end
end

function HUD:gui()
	-- Draw hearts
	for i=1, math.floor(self.max_lives[1]) do
		love.graphics.draw(self.heart_black, 10+(i-1)*10, 10, 0, 0.5, 0.5, 8, 8)
	end
	for i=1, self.lives[1] do
		love.graphics.draw(self.heart, 10+(i-1)*10, 10, 0, 0.5, 0.5, 8, 8)
	end

	local parts = math.floor(self.max_lives[1] % 1 * 4)
	if parts >= 1 and parts <= 3 then
		love.graphics.draw(self.heart_part[parts], math.floor(self.max_lives[1])*10+20, 10, 0, 0.5, 0.5, 8, 8)
	end

	-- Draw magic bar
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 6, 20, POWER_BAR_WIDTH, 6)
	love.graphics.setColor(255, 255, 255)
	local magic_width = self.magic[1]/self.max_magic[1]*POWER_BAR_WIDTH
	love.graphics.rectangle("fill", 6, 20, magic_width, 6)

	-- Seed slots
	love.graphics.setColor(0, 0, 0, 128)
	for i=1, 3 do
		love.graphics.rectangle("fill", (i-1)*16+7, 30, 16, 16)
	end
	love.graphics.setColor(0, 0, 0, 255)
	for i=1, 3 do
		love.graphics.rectangle("line", (i-1)*16+7, 30, 16, 16)
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function HUD:setLives(player, lives, max_lives)
	self.lives[player] = lives
	self.max_lives[player] = max_lives
end

function HUD:setMagic(player, magic, max_magic)
	self.magic[player] = magic
	self.max_magic[player] = max_magic
end

function HUD:setSeeds(player, seeds)
	self.seeds[player] = seeds
end

return HUD
