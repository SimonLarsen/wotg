local Blip = class("Blip", Entity)

function Blip:initialize(x, y, slots)
	Entity.initialize(self, x, y)

	self.xspeed = 0
	self.yspeed = 0
	self.target_xspeed = 0
	self.target_yspeed = 0
	self.slots = slots
	self.target = self:findNearestSlot()

	if self.target == nil then
		local dir = love.math.random() * math.pi
		self.target_xspeed = 200*math.cos(dir)
		self.target_yspeed = 200*math.sin(dir)
	end
end

function Blip:update(dt)
	if self.target ~= nil then
		self.target_xspeed = self.target.x-self.x
		self.target_yspeed = self.target.y-self.y
	else
		self.xspeed = math.movetowards(self.xspeed, self.target_xspeed, 200*dt)
		self.yspeed = math.movetowards(self.yspeed, self.target_yspeed, 200*dt)
	end

	self.x = self.x + self.xspeed * dt
	self.y = self.y + self.yspeed * dt

	if self.x < -32 or self.x > Screen.WIDTH+32
	or self.y < -32 or self.y > Screen.HEIGHT+32 then
		self:kill()
	end
end

function Blip:draw()
	love.graphics.circle("fill", self.x, self.y, 1, 4)
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
