local Slot = class("Slot", Entity)

local Seed = require("ingame.Seed")

function Slot:initialize(x, y)
	Entity.initialize(self, x, y, 1, "slot")

	self.seed = Seed.static.TYPE_NONE
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
	return self.seed == Seed.static.TYPE_NONE
end

function Slot:isComplete()
	return self.progress >= 1
end

function Slot:addSeed(type)
	self.seed = type
end

function Slot:onCollide(o)
	if self:isComplete() and o:getName() == "slash" then
		self.progress = 0
		local count = 3
		for i=1,count do
			self.scene:add(Seed(
				self.x, self.y-50,
				-25 + (i-1) * 50/(count-1),
				love.math.random(-100, 0),
				1
			))
		end
		self.seed = Seed.static.TYPE_NONE
	end
end

return Slot
