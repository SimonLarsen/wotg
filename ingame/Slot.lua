local Slot = class("Slot", Entity)

local Seed = require("ingame.Seed")
local Fruit = require("ingame.Fruit")
local Leaf = require("ingame.Leaf")
local Minion = require("ingame.Minion")
local Attack = require("ingame.Attack")

Slot.static.SINGLE_GROW_TIME = 6
Slot.static.DOUBLE_GROW_TIME = 6

Slot.static.MAX_HP = 3

function Slot:initialize(x, y)
	Entity.initialize(self, x, y, 1, "slot")

	self.seed_size = 0
	self.progress = 0
	self.hp = 0
	self.swing = 0
	self.seed1 = Seed.static.TYPE_NONE
	self.seed2 = Seed.static.TYPE_NONE
	self.fruit = Fruit.static.TYPE_NONE
	self.collider = BoxCollider(16, 16, 0, 0)

	self.animator = Animator(Resources.getAnimator("slot.lua"))
	self.leaves1 = Animator(Resources.getAnimator("leaves.lua"))
	self.leaves2 = Animator(Resources.getAnimator("leaves.lua"))

	self.leaves1_pop = 0
	self.leaves2_pop = 0
	self:moveLeaves()

	self.img_fruits = Resources.getImage("fruits.png")
	self.img_fruits_growing = Resources.getImage("fruits_growing.png")
	self.fruit_quads = {}
	for i=1, 6 do
		self.fruit_quads[i] = love.graphics.newQuad((i-1)*10, 0, 10, 14, 60, 14)
	end

	self.img_seeds = Resources.getImage("seeds.png")
	self.seed_quads = {}
	for i=1, 3 do
		self.seed_quads[i] = love.graphics.newQuad((i-1)*9, 0, 9, 9, 27, 9)
	end
end

function Slot:update(dt)
	self.animator:update(dt)
	self.leaves1:update(dt)
	self.leaves2:update(dt)

	if not self:isEmpty() then
		self.seed_size = math.min(self.seed_size + dt*6, 1)
		if self.leaves1_pop > 0 then
			self.leaves1_pop = self.leaves1_pop - dt
			if self.leaves1_pop <= 0 then
				self.leaves1:setProperty("pop", true)
				self.swing = 0.6
			end
		end
		if self.leaves2_pop > 0 then
			self.leaves2_pop = self.leaves2_pop - dt
			if self.leaves2_pop <= 0 then
				self.leaves2:setProperty("pop", true)
			end
		end
		if self.leaves1_pop <= 0 then
			if self:isFull() then
				self.progress = math.cap(self.progress + dt/Slot.static.DOUBLE_GROW_TIME, 0, 1)
			else
				self.progress = math.cap(self.progress + dt/Slot.static.SINGLE_GROW_TIME, 0, 1)
			end
		end
		if self:isComplete() then
			if self.swing == 0.6 then
				Resources.playSound("fruit_ripe.wav")
			end
			self.swing = math.max(self.swing - dt, 0)
		end
	end
end

function Slot:draw()
	-- Seeds
	if not self:isEmpty() then
		local sc = self.seed_size
		if self:isFull() then
			love.graphics.draw(self.img_seeds, self.seed_quads[self.seed1], self.x-2, self.y, 0, 1, 1, 5, 5)
			love.graphics.draw(self.img_seeds, self.seed_quads[self.seed2], self.x+2, self.y+1, 0, sc, sc, 5, 5)
		else
			love.graphics.draw(self.img_seeds, self.seed_quads[self.seed1], self.x, self.y, 0, sc, sc, 5, 5)
		end
	end
	-- Leaves
	self.animator:draw(self.x, self.y)
	self.leaves1:draw(self.x+self.leaves1_x, self.y+self.leaves1_y)
	self.leaves2:draw(self.x+self.leaves2_x, self.y+self.leaves2_y)

	-- Fruits
	if not self:isEmpty() then
		if self:isComplete() then
			love.graphics.draw(
				self.img_fruits, self.fruit_quads[self.fruit],
				self.x+self.leaves1_x, self.y+self.leaves1_y-3,
				math.cos(love.timer.getTime()*20)*self.swing,
				self.progress, self.progress, 5, 4
			)
		else
			love.graphics.draw(
				self.img_fruits_growing, self.fruit_quads[self.fruit],
				self.x+self.leaves1_x, self.y+self.leaves1_y,
				0,
				self.progress, self.progress, 5, 7
			)
		end
	end
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

function Slot:moveLeaves()
	self.leaves1_x = love.math.random(-6, 6)
	self.leaves1_y = love.math.random(-46, -36)
	self.leaves2_x = love.math.random(-6, 6)
	self.leaves2_y = love.math.random(-26, -16)
	self.collider.ox = self.leaves1_x
	self.collider.oy = self.leaves1_y
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

	self.hp = Slot.static.MAX_HP
	self.seed_size = 0
	self.progress = 0
	self.animator:setProperty("plant", true)
	self.leaves1_pop = 0.7
	self.leaves2_pop = 0.5
	self:moveLeaves()
	self.leaves1:setProperty("reset", true)
	self.leaves2:setProperty("reset", true)
	self.fruit = self:getFruit()

	return true
end

function Slot:eat(dt)
	self.hp = self.hp - dt
	if self.hp <= 0 then
		self:clear()
	end
end

function Slot:eatFruit()
	self.progress = 0
end

function Slot:clear()
	self.progress = 0
	self.seed1 = Seed.static.TYPE_NONE
	self.seed2 = Seed.static.TYPE_NONE
	self.fruit = Fruit.static.TYPE_NONE
	self.animator:setProperty("kill", true)
	self.leaves1:setProperty("kill", true)
	self.leaves2:setProperty("kill", true)

	self.scene:add(Leaf(self.x+self.leaves1_x, self.y+self.leaves1_y))
	self.scene:add(Leaf(self.x+self.leaves2_x, self.y+self.leaves2_y))
end

function Slot:getFruit()
	if self.seed2 == Seed.static.TYPE_NONE then
		return self.seed1
	end

	local total = self.seed1 + self.seed2
	if total == 1+2 then return Fruit.static.TYPE_MINION end
	if total == 1+3 then return Fruit.static.TYPE_SHIELD end
	if total == 2+3 then return Fruit.static.TYPE_POWER end
end

function Slot:onCollide(o)
	if self:isComplete() and o:isInstanceOf(Attack) then
		if self.fruit == Fruit.static.TYPE_MINION then
			self.scene:add(Minion(
				self.x+self.leaves1_x,
				self.y+self.leaves1_y
			))
		else
			self.scene:add(Fruit(
				self.x+self.leaves1_x,
				self.y+self.leaves1_y,
				love.math.random(-20, 20),
				love.math.random(-100, 0),
				self.fruit
			))
		end
		self:clear()
	end
end

return Slot
