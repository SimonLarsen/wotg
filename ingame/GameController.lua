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
	self.scene:add(Slot(36, Screen.HEIGHT-8))
	self.scene:add(Slot(56, Screen.HEIGHT-8))
	-- Middle slots
	self.scene:add(Slot(110, 88))
	self.scene:add(Slot(130, 88))
	-- Right slots
	self.scene:add(Slot(184, Screen.HEIGHT-8))
	self.scene:add(Slot(204, Screen.HEIGHT-8))
end

function GameController:update(dt)
	local cy = Screen.HEIGHT/2
	if self.player.y < 64 then
		cy = math.cap(Screen.HEIGHT/2 - 1.0*(64-self.player.y), 0, Screen.HEIGHT/2)
	end
	self.camera:setY(cy)

	if Keyboard.wasPressed("f2") then
		self.scene:add(require("ingame.Pig")(Screen.WIDTH+16, Screen.HEIGHT-24, -1))
	end
end

return GameController
