local Enemy = require("ingame.Enemy")

local Pig = class("Pig", Enemy)

Pig.static.STATE_WALK   = 1
Pig.static.STATE_CHARGE = 2
Pig.static.STATE_DASH   = 3
Pig.static.STATE_TURN   = 4

Pig.static.WALK_SPEED = 25
Pig.static.CHARGE_TIME = 0.5
Pig.static.DASH_SPEED = 80
Pig.static.DASH_TIME = 2
Pig.static.TURN_TIME = 1

function Pig:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0)

	self.dir = dir
	self.time = 0
	self.state = Pig.static.STATE_WALK
	self.animator = Animator(Resources.getAnimator("pig.lua"))
end

function Pig:enter()
	self.players = self.scene:findAll("player")
end

function Pig:update(dt)
	self.animator:update(dt)

	if self.state == Pig.static.STATE_WALK then
		self.x = self.x + dt*self.dir*Pig.static.WALK_SPEED
		if self.x < 32 then
			self.dir = 1
		elseif self.x > Screen.WIDTH-32 then
			self.dir = -1
		end

		for i,v in ipairs(self.players) do
			local xdist = math.abs(self.x - v.x)
			local ydist = math.abs(self.y - v.y)
			if ydist < 16 and xdist < 80 then
				self.dir = math.sign(v.x-self.x)
				self.state = Pig.static.STATE_CHARGE
				self.time = Pig.static.CHARGE_TIME
			end
		end
	elseif self.state == Pig.static.STATE_CHARGE then
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = Pig.static.STATE_DASH
			self.time = Pig.static.DASH_TIME
		end
	elseif self.state == Pig.static.STATE_DASH then
		self.x = self.x + dt*self.dir*Pig.static.DASH_SPEED
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = Pig.static.STATE_WALK
		end
	elseif self.state == Pig.static.STATE_TURN then
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = Pig.static.STATE_WALK
		end
	end
end

function Pig:draw()
	self.animator:setProperty("state", self.state)
	self.animator:draw(self.x, self.y, 0, -self.dir, 1)
end

return Pig
