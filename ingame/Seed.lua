local Seed = class("Seed", Entity)

Seed.static.TYPE_NONE = 0
Seed.static.TYPE_HP   = 1

Seed.static.GRAVITY = 500

function Seed:initialize(x, y, xspeed, yspeed, type)
	Entity.initialize(self, x, y, 1, "seed")

	self.type = type
	self.xspeed = xspeed or 0
	self.yspeed = yspeed or 0
	self.collider = BoxCollider(4, 8)
end

function Seed:enter()
	if self.terrain == nil then
		self.terrain = self.scene:find("terrain")
	end
end

function Seed:update(dt)
	self.yspeed = self.yspeed + dt*Seed.static.GRAVITY
	
	self.x = self.x + self.xspeed*dt

	local oldy = self.y
	self.y = self.y + self.yspeed*dt
	if self.terrain:checkCollision(self) then
		self.y = oldy
		self.xspeed = 0.5*self.xspeed
		self.yspeed = -0.2*self.yspeed
	end
end

function Seed:draw()
	if self.type == Seed.static.TYPE_HP then
		love.graphics.setColor(255, 64, 0)
	end
	love.graphics.circle("fill", self.x, self.y, 4, 16)
	love.graphics.setColor(255, 255, 255)
end

return Seed
