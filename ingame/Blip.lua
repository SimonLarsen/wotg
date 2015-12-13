local Blip = class("Blip", Entity)

function Blip:initialize(x, y, slots)
	Entity.initialize(self, x, y)

	self.xspeed = 0
	self.yspeed = 0
	self.slots = slots
	self.target = self:findNearestSlot()
end

function Blip:update(dt)
	if self.target == nil then
		<F9>
	end
end

function Blip:draw()
	love.graphics.circle("fill", self.x, self.y, 2, 4)
end

function Blip:findNearestSlot()
	local nearest = nil
	local min_sqdist = nil

	for i,v in ipairs(self.slots) do
		if not v:isEmpty() then
			local xdist = math.abs(self.x - v.x)
			local ydist = math.abs(self.y - v.y)
			local sqdist = xdist^2 + ydist^2

			if nearest == nil or sqdist < min_sqdist then
				nearest = v
				min_sqdist = sqdist
			end
		end
	end

	return nearest
end

return Blip
