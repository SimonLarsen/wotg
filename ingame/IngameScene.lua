local IngameScene = class("IngameScene", Scene)

local Player = require("ingame.Player")
local Terrain = require("ingame.Terrain")

function IngameScene:enter()
	self:add(Player(180, 50))
	local terrain = self:add(Terrain())
	terrain:addBox(Screen.WIDTH, 16, Screen.WIDTH/2, Screen.HEIGHT-8)
	terrain:addBox(64, 16, Screen.WIDTH/2, 88)
end

return IngameScene
