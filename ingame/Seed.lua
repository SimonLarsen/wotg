local Seed = class("Seed", Entity)

Seed.static.TYPE_NONE  = 0
Seed.static.TYPE_HEAL  = 1
Seed.static.TYPE_MAGIC = 2
Seed.static.TYPE_POWER = 3

Seed.static.GRAVITY = 550

local seed_colors = {
	{255, 32, 32},
	{32, 32, 255},
	{32, 255, 32}
}

function Seed:initialize(x, y, xspeed, yspeed, type)
	Entity.initialize(self, x, y, 1, "seed")

	self.xspeed = xspeed or 0
	self.yspeed = yspeed or 0
	self.type = type
	self.time = 0
end

function Seed:enter()
	self.terrain = self.scene:find("terrain")
end

function Seed:update(dt)
	self.time = self.time + dt
	if self.collider == nil and self.time > 0.25 then
		self.collider = BoxCollider(4, 8)
	end

	self.yspeed = self.yspeed + dt*Seed.static.GRAVITY
	if self.x < 8 then
		self.xspeed = 8
	elseif self.x > Screen.WIDTH-8 then
		self.xspeed = -8
	end
	
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
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", self.x-4, self.y-4, 8, 8)
	love.graphics.setColor(seed_colors[self.type])
	love.graphics.rectangle("fill", self.x-3, self.y-3, 6, 6)
	love.graphics.setColor(255, 255, 255)
end

function Seed:getType()
	return self.type
end

return Seed
