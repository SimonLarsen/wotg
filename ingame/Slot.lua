local Slot = class("Slot", Entity)

Slot.static.SEED_NONE = 0
Slot.static.SEED_HP   = 1

function Slot:initialize(x, y)
	Entity.initialize(self, x, y, 1, "slot")

	self.seed = Slot.static.SEED_NONE
end

function Slot:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.x, self.y, 8, 16)

	if self.seed ~= Slot.static.SEED_NONE then
		love.graphics.setColor(32, 255, 32)
		love.graphics.rectangle("fill", self.x-4, self.y-24, 8, 16)
	end

	love.graphics.setColor(255, 255, 255)
end

function Slot:isEmpty()
	return self.seed == Slot.static.SEED_NONE
end

function Slot:addSeed(type)
	self.seed = type
end

return Slot
