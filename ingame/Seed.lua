local Seed = class("Seed", Entity)

Seed.static.TYPE_NONE  = 0
Seed.static.TYPE_HEAL  = 1
Seed.static.TYPE_MAGIC = 2
Seed.static.TYPE_POWER = 3

function Seed:initialize(x, y, type)
	Entity.initialize(self, x, y, 1, "seed")

	self.type = type
end

function Seed:enter()

end

function Seed:update(dt)

end

function Seed:draw()

end

function Seed:getType()
	return self.type
end

return Seed
