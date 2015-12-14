local GameController = class("GameController", Entity)

local Player = require("ingame.Player")
local Terrain = require("ingame.Terrain")
local Slot = require("ingame.Slot")
local HUD = require("ingame.HUD")

function GameController:initialize()
	Entity.initialize(self)
end

function GameController:enter()
	local terrain = self.scene:add(Terrain())
	terrain:addBox(2*Screen.WIDTH, 16, Screen.WIDTH/2, Screen.HEIGHT-8)
	terrain:addBox(64, 16, Screen.WIDTH/2, 88)

	self.scene:add(HUD(1))
	self.player = self.scene:add(Player(180, 50, 1))
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
end

function GameController:update(dt)
	local cy = Screen.HEIGHT/2
	if self.player.y < 64 then
		cy = math.cap(Screen.HEIGHT/2 - 1.0*(64-self.player.y), 0, Screen.HEIGHT/2)
	end
	self.camera:setY(cy)

	if Keyboard.wasPressed("f1") then
		if love.math.random(1,2) == 1 then
			self.scene:add(require("ingame.Rat")(-16, Screen.HEIGHT-24, 1))
		else
			self.scene:add(require("ingame.Rat")(Screen.WIDTH+16, Screen.HEIGHT-24, -1))
		end
	end
	if Keyboard.wasPressed("f2") then
		if love.math.random(1,2) == 1 then
			self.scene:add(require("ingame.Pig")(-16, Screen.HEIGHT-24, 1))
		else
			self.scene:add(require("ingame.Pig")(Screen.WIDTH+16, Screen.HEIGHT-24, -1))
		end
	end
	if Keyboard.wasPressed("f3") then
		local y = math.random(16, 100)
		if love.math.random(1,2) == 1 then
			self.scene:add(require("ingame.Bird")(-16, y, 1))
		else
			self.scene:add(require("ingame.Bird")(Screen.WIDTH+16, y, -1))
		end
	end
end

return GameController
