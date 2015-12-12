local Enemy = require("ingame.Enemy")

local Pig = class("Pig", Enemy)

Pig.static.STATE_WALK    = 1
Pig.static.STATE_CHARGE  = 2
Pig.static.STATE_DASH    = 3
Pig.static.STATE_TURN    = 4
Pig.static.STATE_STUNNED = 5

Pig.static.WALK_SPEED = 25
Pig.static.CHARGE_TIME = 0.5
Pig.static.DASH_SPEED = 80
Pig.static.DASH_TIME = 2
Pig.static.TURN_TIME = 1
Pig.static.STUNNED_TIME = 3
Pig.static.MAX_HP = 30

function Pig:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "pig")

	self.dir = dir
	self.time = 0
	self.state = Pig.static.STATE_WALK
	self.blink = 0
	self.hp = Pig.static.MAX_HP

	self.animator = Animator(Resources.getAnimator("pig.lua"))
	self.collider = BoxCollider(22, 14)
end

function Pig:enter()
	self.players = self.scene:findAll("player")
end

function Pig:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.blink = self.blink - dt

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
		if self.time <= 0 then
			self.state = Pig.static.STATE_DASH
			self.time = Pig.static.DASH_TIME
		end
	elseif self.state == Pig.static.STATE_DASH then
		self.x = self.x + dt*self.dir*Pig.static.DASH_SPEED
		if self.time <= 0 then
			self.state = Pig.static.STATE_WALK
		end
	elseif self.state == Pig.static.STATE_TURN then
		if self.time <= 0 then
			self.state = Pig.static.STATE_WALK
		end
	elseif self.state == Pig.static.STATE_STUNNED then
		if self.time <= 0 then
			self:kill()
		end
	end
end

function Pig:draw()
	self.animator:setProperty("state", self.state)
	self.animator:draw(self.x, self.y, 0, -self.dir, 1)
	if (self.blink > 0)
	or (self:isStunned() and love.timer.getTime() % 0.2 < 0.1) then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
end

function Pig:onCollide(o)
	if self.blink <= 0 and not self:isStunned() then
		if o:getName() == "slash" then
			self.blink = 0.25
			self.hp = self.hp - 10
			if self.hp <= 0 then
				self:setStunned()
				self.state = Pig.static.STATE_STUNNED
				self.time = Pig.static.STUNNED_TIME
			end
		end
	end
end

return Pig
