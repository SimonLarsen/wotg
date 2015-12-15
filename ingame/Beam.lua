local Attack = require("ingame.Attack")

local Beam = class("Beam", Attack)

Beam.static.TIME = 0.3
Beam.static.SPEED = 200

function Beam:initialize(x, y, dir, damage, charged)
	Entity.initialize(self, x, y, -1, "beam")

	self.time = Beam.static.TIME
	self.dir = dir
	self.damage = damage
	self.charged = charged
	self.collider = BoxCollider(10, 14)
	self.anim = Animation(Resources.getImage("beam.png"), 7, 14, 0.1, true, 6, 7)
end

function Beam:update(dt)
	self.time = self.time - dt
	self.anim:update(dt)

	if self.time <= 0 then
		self:kill()
	end

	self.x = self.x + dt*self.dir*Beam.static.SPEED
end

function Beam:draw()
	self.anim:draw(self.x, self.y, 0, self.dir, 1)
end

function Beam:getDamage()
	return self.damage
end

function Beam:isCharged()
	return self.charged
end

return Beam
