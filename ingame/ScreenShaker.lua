local ScreenShaker = class("ScreenShaker", Entity)

function ScreenShaker:initialize(time, strength)
	Entity.initialize(self, 0, 0, -1000)

	self.time = time
	self.strength = strength
	self.ox = 0
	self.oy = 0
end

function ScreenShaker:update(dt)
	self.time = self.time - dt

	if self.time <= 0 then
		self:kill()
	else
		local cam = self.scene:getCamera()
		ox = cam.x + (love.math.random()*2 - 1) * self.strength
		oy = cam.y + (love.math.random()*2 - 1) * self.strength
		self.scene:getCamera():setPosition(ox, oy)
	end

end

return ScreenShaker
