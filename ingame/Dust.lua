local Dust = class("Dust", Entity)

Dust.static.TIME = 0.4

function Dust:initialize(x, y)
	Entity.initialize(self, x, y, -1)

	self.time = Dust.static.TIME
	self.anim = Animation(Resources.getImage("dust.png"), 32, 16, 0.1, false, 16, 16)
end

function Dust:update(dt)
	self.anim:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self:kill()
	end
end

function Dust:draw()
	self.anim:draw(self.x, self.y)
end

return Dust
