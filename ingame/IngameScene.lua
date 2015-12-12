local IngameScene = class("IngameScene", Scene)

local Player = require("ingame.Player")
local Terrain = require("ingame.Terrain")
local Slot = require("ingame.Slot")
local GameController = require("ingame.GameController")

function IngameScene:enter()
	self:add(GameController())
	self:add(Player(180, 50, 1))
	self:setBackgroundColor(40, 80, 160)

	local terrain = self:add(Terrain())
	terrain:addBox(Screen.WIDTH, 16, Screen.WIDTH/2, Screen.HEIGHT-8)
	terrain:addBox(64, 16, Screen.WIDTH/2, 88)

	-- Left slots
	self:add(Slot(40, Screen.HEIGHT-8))
	self:add(Slot(56, Screen.HEIGHT-8))
	-- Middle slots
	self:add(Slot(112, 88))
	self:add(Slot(128, 88))
	-- Right slots
	self:add(Slot(184, Screen.HEIGHT-8))
	self:add(Slot(200, Screen.HEIGHT-8))
end

return IngameScene
