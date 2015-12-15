local GameOver = class("GameOver", Entity)

function GameOver:initialize()
	Entity.initialize(self, 0, 0, -10)
	self.img = Resources.getImage("gameover.png")
	self.time = 0
end

function GameOver:update(dt)
	self.time = self.time + dt
end

function GameOver:gui()
	local alpha = 255
	if self.time < 1 then
		alpha = self.time*255
	end
	love.graphics.setColor(255, 255, 255, alpha)
	love.graphics.draw(self.img, 0, (Screen.HEIGHT-58)/2)
	love.graphics.setColor(255, 255, 255, 255)
end

return GameOver
