local Slot = class("Slot", Entity)

local Seed = require("ingame.Seed")
local Fruit = require("ingame.Fruit")

function Slot:initialize(x, y)
	Entity.initialize(self, x, y, 1, "slot")

	self.seed1 = Seed.static.TYPE_NONE
	self.seed2 = Seed.static.TYPE_NONE
	self.progress = 0
	self.collider = BoxCollider(16, 16, 0, -50)

	self.animator = Animator(Resources.getAnimator("slot.lua"))
	self.leaves1 = Animator(Resources.getAnimator("leaves.lua"))
	self.leaves2 = Animator(Resources.getAnimator("leaves.lua"))

	self.leaves1_pop = 0
	self.leaves2_pop = 0

	self.leaves1_x = love.math.random(-6, 6)
	self.leaves1_y = love.math.random(-46, -36)

	self.leaves2_x = love.math.random(-6, 6)
	self.leaves2_y = love.math.random(-26, -16)
end

function Slot:update(dt)
	self.animator:update(dt)
	self.leaves1:update(dt)
	self.leaves2:update(dt)

	if not self:isEmpty() then
		if self.leaves1_pop > 0 then
			self.leaves1_pop = self.leaves1_pop - dt
			if self.leaves1_pop <= 0 then
				self.leaves1:setProperty("pop", true)
			end
		end
		if self.leaves2_pop > 0 then
			self.leaves2_pop = self.leaves2_pop - dt
			if self.leaves2_pop <= 0 then
				self.leaves2:setProperty("pop", true)
			end
		end
		self.progress = math.cap(self.progress + dt/4, 0, 1)
	end
end

function Slot:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.x, self.y, 4, 16)
	love.graphics.setColor(255, 255, 255)

	self.animator:draw(self.x, self.y)
	self.leaves1:draw(self.x+self.leaves1_x, self.y+self.leaves1_y)
	self.leaves2:draw(self.x+self.leaves2_x, self.y+self.leaves2_y)
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
	self.animator:setProperty("plant", true)
	self.leaves1_pop = 0.7
	self.leaves2_pop = 0.5

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
		self.animator:setProperty("kill", true)
		self.leaves1:setProperty("kill", true)
		self.leaves2:setProperty("kill", true)
	end
end

return Slot
