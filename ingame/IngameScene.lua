local IngameScene = class("IngameScene", Scene)

local GameController = require("ingame.GameController")

function IngameScene:enter()
	self:add(GameController())
	self:setBackgroundColor(40, 80, 160)
end

return IngameScene
