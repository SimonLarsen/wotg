local TitleController = class("TitleController", Entity)

local Fade = require("transition.Fade")

function TitleController:initialize()
	Entity.initialize(self, 0, 0, 10)

	self.bg = Resources.getImage("title_bg.png")
	self.small_font = Resources.getImageFont("small.png")
end

function TitleController:enter()
	Resources.playMusic("stinkbug.ogg")
end

function TitleController:update(dt)
	if Keyboard.wasPressed("return")
	or Keyboard.wasPressed(" ")
	then
		Resources.playSound("wobble.wav")
		self.scene:add(Fade(1, Fade.static.OUT))
		timer.after(1, function()
			gamestate.switch(require("ingame.IngameScene")())
		end)
	end
end

function TitleController:gui()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setFont(self.small_font)
	love.graphics.printf("PUSH SPACE TO START", 0, 136, Screen.WIDTH, "center")
end

return TitleController
