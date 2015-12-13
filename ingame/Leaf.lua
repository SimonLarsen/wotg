local Leaf = class("Leaf", Entity)

function Leaf:initialize(x, y)
	Entity.initialize(self, x, y, 1)

	self.animation = Animation(Resources.getImage("leaf.png"), 11, 8, 0.1, true, 5, 4)
	for i=1,3 do
		self.animation:update(love.math.random())
	end
	self.yspeed = 16
end

function Leaf:update(dt)
	self.animation:update(dt)
	self.y = self.y + self.yspeed*dt

	if self.y >= Screen.HEIGHT-18 then
		self:kill()
	end
end

function Leaf:draw()
	self.animation:draw(self.x, self.y)
end

return Leaf
