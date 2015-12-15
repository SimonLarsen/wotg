local Seed = class("Seed", Entity)

Seed.static.TYPE_NONE  = 0
Seed.static.TYPE_HEAL  = 1
Seed.static.TYPE_MAGIC = 2
Seed.static.TYPE_POWER = 3

Seed.static.GRAVITY = 550

function Seed:initialize(x, y, xspeed, yspeed, type)
	Entity.initialize(self, x, y, 1, "seed")

	self.xspeed = xspeed or 0
	self.yspeed = yspeed or 0

	if self.type == nil then
		local r = love.math.random()
		if r < 0.3 then self.type = Seed.static.TYPE_HEAL
		elseif r < 0.5 then self.type = Seed.static.TYPE_MAGIC
		else self.type = Seed.static.TYPE_POWER
		end
	end

	self.time = 0

	self.image = Resources.getImage("seeds.png")
	self.quad = love.graphics.newQuad((self.type-1)*9, 0, 9, 9, 27, 9)
end

function Seed:enter()
	self.terrain = self.scene:find("terrain")
end

function Seed:update(dt)
	self.time = self.time + dt
	if self.collider == nil and self.time > 0.25 then
		self.collider = BoxCollider(8, 8)
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
		self.y = math.min(oldy, Screen.HEIGHT-20)
		self.xspeed = 0.5*self.xspeed
		self.yspeed = -0.2*self.yspeed
	end
end

function Seed:draw()
	love.graphics.draw(self.image, self.quad, self.x, self.y, 0, 1, 1, 5, 5)
end

function Seed:getType()
	return self.type
end

return Seed
