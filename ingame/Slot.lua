local Slot = class("Slot", Entity)

local Seed = require("ingame.Seed")
local Fruit = require("ingame.Fruit")

function Slot:initialize(x, y)
	Entity.initialize(self, x, y, 1, "slot")

	self.seed1 = Seed.static.TYPE_NONE
	self.seed2 = Seed.static.TYPE_NONE
	self.progress = 0
	self.collider = BoxCollider(16, 16, 0, -50)
end

function Slot:update(dt)
	if not self:isEmpty() then
		self.progress = math.cap(self.progress + dt/4, 0, 1)
	end
end

function Slot:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.x, self.y, 4, 16)

	if not self:isEmpty() then
		love.graphics.setColor(32, 255, 32)
		love.graphics.rectangle("fill", self.x-4, self.y-56, 8, 48)

		love.graphics.setColor(255, 0, 0)
		love.graphics.circle("fill", self.x, self.y-50, 8*self.progress, 16)
	end love.graphics.setColor(255, 255, 255)
end

function Slot:isEmpty()
	return self.seed1 == Seed.static.TYPE_NONE
end

function Slot:isFull()
	return self.seed2 ~= Seed.static.TYPE_NONE
end

function Slot:isComplete()
	return self.progress >= 1
end

function Slot:addSeed(type)
	if self:isFull()
	or self.seed1 == type
	or self:isComplete() then
		return false
	end

	if self.seed1 == Seed.static.TYPE_NONE then
		self.seed1 = type
	else
		self.seed2 = type
	end
	self.progress = 0

	return true
end

function Slot:getFruit()
	if self.seed2 == Seed.static.TYPE_NONE then
		return self.seed1
	end

	local total = self.seed1 + self.seed2
	if total == 1+2 then return Fruit.static.TYPE_MINION end
	if total == 1+3 then return Fruit.static.TYPE_HEART end
	if total == 2+3 then return Fruit.static.TYPE_UPGRADE end
end

function Slot:onCollide(o)
	if self:isComplete() and o:getName() == "slash" then
		self.progress = 0
		local fruit_type = self:getFruit()
		self.scene:add(Fruit(
			self.x, self.y-50,
			love.math.random(-20, 20),
			love.math.random(-100, 0),
			fruit_type
		))
		self.seed1 = Seed.static.TYPE_NONE
		self.seed2 = Seed.static.TYPE_NONE
	end
end

return Slot
