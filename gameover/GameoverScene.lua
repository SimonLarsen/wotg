local GameoverScene = class("GameoverScene", Scene)

local GameoverController = require("gameover.GameoverController")

function GameoverScene:enter(score, level)
	self:add(GameoverController())
	self:setBackgroundColor(34, 36, 49)
end

return GameoverScene
