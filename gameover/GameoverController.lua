local GameoverController = class("GameoverController", Entity)

local Fade = require("transition.Fade")

function GameoverController:initialize()
	Entity.initialize(self, 0, 0, 10)

	self.bg = Resources.getImage("gameover_bg.png")
	self.small_font = Resources.getImageFont("small.png")

	self.highscore = Score.score
	if love.filesystem.exists("highscore") then
		local data = love.filesystem.read("highscore")
		local highscore = Serial.unpack(data)
		if highscore.score then
			self.highscore = math.max(self.highscore, highscore.score)
		end
	end

	local data = Serial.pack({ score = self.highscore })
	love.filesystem.write("highscore", data)

	self.text = "YOU SCORED\n" .. Score.score
	self.text = self.text .. "\n\nAT LEVEL\n" .. Score.level
	self.text = self.text .. "\n\nYOUR HIGHSCORE\n" .. self.highscore
end

function GameoverController:enter()
	self.scene:add(Fade(2, Fade.static.IN))
end

function GameoverController:update(dt)
	if Keyboard.wasPressed("return")
	or Keyboard.wasPressed("space")
	then
		Resources.playSound("wobble.wav")
		self.scene:add(Fade(1, Fade.static.OUT))
		timer.after(1, function()
			gamestate.switch(require("ingame.IngameScene")())
		end)
	end
end

function GameoverController:gui()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.setFont(self.small_font)
	love.graphics.printf(self.text, 0, 54, Screen.WIDTH, "center")

	if love.timer.getTime() % 1 < 0.7 then
		love.graphics.printf("PUSH SPACE TO PLAY AGAIN", 0, Screen.HEIGHT-26, Screen.WIDTH, "center")
	end
end

return GameoverController
