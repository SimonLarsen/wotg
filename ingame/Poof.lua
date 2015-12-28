local Poof = class("Poof", Entity)

Poof.static.TIME = 0.5

function Poof:initialize(x, y)
	Entity.initialize(self, x, y, -1)

	self.time = Poof.static.TIME
	self.anim = Animation(Resources.getImage("poof.png"), 28, 28, 0.1, false, 14, 14)
end

function Poof:update(dt)
	self.anim:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self:kill()
	end
end

function Poof:draw()
	self.anim:draw(self.x, self.y)
end

return Poof
