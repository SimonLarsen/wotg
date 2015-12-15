local TitleScene = class("TitleScene", Scene)

local TitleController = require("title.TitleController")

function TitleScene:enter()
	self:add(TitleController())
end

return TitleScene
