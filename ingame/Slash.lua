local Slash = class("Slash", Entity)

Slash.static.TIME = 0.2
Slash.static.COLLISION_TIME = 0.1

function Slash:initialize(x, y, xspeed, dir, damage, charged)
	Entity.initialize(self, x, y, -1, "slash")

	self.xspeed = xspeed
	self.dir = dir
	self.damage = damage
	self.charged = charged

	self.time = Slash.static.TIME
	self.collider = BoxCollider(20, 12)
end

function Slash:update(dt)
	self.time = self.time - dt
	self.x = self.x + self.xspeed*dt
	if self.time < Slash.static.TIME-Slash.static.COLLISION_TIME then
		self.collider = nil
	end
	if self.time <= 0 then
		self:kill()
	end
end

function Slash:getDamage()
	return self.damage
end

function Slash:isCharged()
	return self.charged
end

return Slash
