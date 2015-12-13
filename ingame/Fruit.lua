local Fruit = class("Fruit", Entity)

Fruit.static.TYPE_NONE    = 0
Fruit.static.TYPE_HEAL    = 1
Fruit.static.TYPE_MAGIC   = 2
Fruit.static.TYPE_POWER   = 3
Fruit.static.TYPE_MINION  = 4 -- HEAL + MAGIC
Fruit.static.TYPE_HEART   = 5 -- HEAL + POWER
Fruit.static.TYPE_UPGRADE = 6 -- MAGIC + POWER

Fruit.static.GRAVITY = 500

function Fruit:initialize(x, y, xspeed, yspeed, type)
	Entity.initialize(self, x, y, 1, "fruit")

	self.xspeed = xspeed or 0
	self.yspeed = yspeed or 0
	self.type = type
	self.time = 0

	self.image = Resources.getImage("fruits.png")
	self.quad = love.graphics.newQuad((self.type-1)*10, 0, 10, 14, 60, 14)
end

function Fruit:enter()
	self.terrain = self.scene:find("terrain")
end

function Fruit:update(dt)
	self.time = self.time + dt
	if self.collider == nil and self.time > 0.25 then
		self.collider = BoxCollider(10, 14)
	end

	self.yspeed = self.yspeed + dt*Fruit.static.GRAVITY
	
	self.x = self.x + self.xspeed*dt

	local oldy = self.y
	self.y = self.y + self.yspeed*dt
	if self.terrain:checkCollision(self) then
		self.y = oldy
		self.xspeed = 0.5*self.xspeed
		self.yspeed = -0.2*self.yspeed
	end
end

function Fruit:draw()
	love.graphics.draw(self.image, self.quad, self.x, self.y, 0, 1, 1, 5, 7)
end

function Fruit:getType()
	return self.type
end

return Fruit
