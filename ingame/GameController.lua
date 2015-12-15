local GameController = class("GameController", Entity)

local Player = require("ingame.Player")
local Terrain = require("ingame.Terrain")
local Background = require("ingame.Background")
local Slot = require("ingame.Slot")
local HUD = require("ingame.HUD")
local Enemy = require("ingame.Enemy")
local GameOver = require("ingame.GameOver")

local Fade = require("transition.Fade")

local Bird = require("ingame.Bird")
local DarkBird = require("ingame.DarkBird")
local Rat = require("ingame.Rat")
local Pig = require("ingame.Pig")
local Boar = require("ingame.Boar")
local Bats = require("ingame.Bats")

local enemies = { "rat", "bird", "pig", "darkbird", "boar" }

GameController.static.WAVE_DELAY = 12
GameController.static.SPAWN_DELAY = 1

function GameController:initialize()
	Entity.initialize(self, 0, 0, 0, "controller")

	self.next_wave = 10
	self.next_spawn = 0
	self.wave = 0
	self.spawned = 0

	self.wave_enemies = { "pig" }
end

function GameController:enter()
	Score.score = 0

	self.scene:add(Background())
	local terrain = self.scene:add(Terrain())
	terrain:addBox(2*Screen.WIDTH, 16, Screen.WIDTH/2, Screen.HEIGHT-8)
	terrain:addBox(64, 16, Screen.WIDTH/2, 88)

	self.scene:add(HUD(1))
	self.scene:add(Player(Screen.WIDTH/2, Screen.HEIGHT-48, 1))
	self.camera = self.scene:getCamera()

	-- Left slots
	self.scene:add(Slot(34, Screen.HEIGHT-8))
	self.scene:add(Slot(58, Screen.HEIGHT-8))
	-- Middle slots
	self.scene:add(Slot(108, 88))
	self.scene:add(Slot(132, 88))
	-- Right slots
	self.scene:add(Slot(182, Screen.HEIGHT-8))
	self.scene:add(Slot(206, Screen.HEIGHT-8))

	self.scene:add(Fade(2, Fade.static.IN))

	self.players = self.scene:findAll("player")
end

function GameController:update(dt)
	self.next_wave = self.next_wave - dt
	self.next_spawn = self.next_spawn - dt

	if self.wave > 0 and self.next_spawn <= 0
	and self.spawned < #self.wave_enemies then
		self.spawned = self.spawned + 1
		self.next_spawn = GameController.static.SPAWN_DELAY
		self:spawn(self.wave_enemies[self.spawned])
	end

	if self.next_wave <= 0 and self:waveClear() then
		self:advanceWave()
	end

	local cx = Screen.WIDTH/2
	local cy = Screen.HEIGHT/2

	local py = 0
	for i,v in ipairs(self.players) do
		py = py + v.y
	end
	py = py / #self.players

	if py < 64 then
		cy = math.cap(Screen.HEIGHT/2 - 1.0*(64-py), 0, Screen.HEIGHT/2)
	end
	self.camera:setPosition(cx, cy)
end

function GameController:advanceWave()
	self.wave = self.wave + 1
	self.next_wave = GameController.static.WAVE_DELAY
	self.spawned = 0

	local avail = math.min(math.floor(3 + self.wave/7), #enemies)
	local min_count = 1
	if self.wave > 2 then
		min_count = math.max(2, math.floor(self.wave / 4.5))
	end
	local max_count = math.max(1, math.ceil(self.wave / 3.5))

	self.wave_enemies = {}
	local count = min_count
	if max_count > min_count then
		count = love.math.random(min_count, max_count)
	end
	for i=1, count do
		local type = love.math.random(1, avail)
		table.insert(self.wave_enemies, enemies[type])
	end
end

function GameController:spawn(type)
	if type == "rat" then
		if love.math.random(1,2) == 1 then
			self.scene:add(Rat(-16, Screen.HEIGHT-24, 1))
		else
			self.scene:add(Rat(Screen.WIDTH+16, Screen.HEIGHT-24, -1))
		end
	elseif type == "bird" then
		local y = math.random(16, 100)
		if love.math.random(1,2) == 1 then
			self.scene:add(Bird(-16, y, 1))
		else
			self.scene:add(Bird(Screen.WIDTH+16, y, -1))
		end
	elseif type == "darkbird" then
		local y = math.random(16, 100)
		if love.math.random(1,2) == 1 then
			self.scene:add(DarkBird(-16, y, 1))
		else
			self.scene:add(DarkBird(Screen.WIDTH+16, y, -1))
		end
	elseif type == "bats" then
		local y = math.random(16, 100)
		if love.math.random(1,2) == 1 then
			self.scene:add(Bats(-16, y, 1))
		else
			self.scene:add(Bats(Screen.WIDTH+16, y, -1))
		end
	elseif type == "pig" then
		if love.math.random(1,2) == 1 then
			self.scene:add(Pig(-16, Screen.HEIGHT-24, 1))
		else
			self.scene:add(Pig(Screen.WIDTH+16, Screen.HEIGHT-24, -1))
		end
	elseif type == "boar" then
		if love.math.random(1,2) == 1 then
			self.scene:add(Boar(-16, Screen.HEIGHT-24, 1))
		else
			self.scene:add(Boar(Screen.WIDTH+16, Screen.HEIGHT-24, -1))
		end
	end
end

function GameController:waveClear()
	if self.wave > 0 and self.spawned < #self.wave_enemies then
		return false
	end

	for i,v in ipairs(self.scene:getEntities()) do
		if v:isInstanceOf(Enemy) then
			return false
		end
	end
	return true
end

function GameController:gameOver()
	self.scene:add(GameOver())
	timer.after(4, function()
		self.scene:add(Fade(1, Fade.static.OUT))
	end)
	Score.level = self.scene:find("player").level
	timer.after(5, function()
		gamestate.switch(require("gameover.GameoverScene")())
	end)
end

return GameController
