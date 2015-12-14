local LevelUp = class("LevelUp", Entity)

LevelUp.static.TIME = 2

function LevelUp:initialize()
	Entity.initialize(self, 0, 0, -10)
	self.img = Resources.getImage("levelup.png")
	self.time = 0
end

function LevelUp:update(dt)
	self.time = self.time + dt
	if self.time >= 2 then
		self:kill()
	end
end

function LevelUp:gui()
	local alpha = 255
	if self.time < 0.25 then
		alpha = self.time*4*255
	elseif self.time > LevelUp.static.TIME-0.25 then
		alpha = (1 - (LevelUp.static.TIME + self.time)*4) * 255
	end
	love.graphics.setColor(255, 255, 255, alpha)
	love.graphics.draw(self.img, 0, (Screen.HEIGHT-58)/2)
	love.graphics.setColor(255, 255, 255, 255)
end

return LevelUp
