local TitleController = class("TitleController", Entity)

local Fade = require("transition.Fade")

function TitleController:initialize()
	Entity.initialize(self, 0, 0, 10)

	self.bg = Resources.getImage("title_bg.png")
end

function TitleController:enter()
end

function TitleController:update(dt)
	if Keyboard.wasPressed("return")
	or Keyboard.wasPressed(" ")
	then
		self.scene:add(Fade(1, Fade.static.OUT))
		timer.after(1, function()
			gamestate.switch(require("ingame.IngameScene")())
		end)
	end
end

function TitleController:gui()
	love.graphics.draw(self.bg, 0, 0)
end

return TitleController
