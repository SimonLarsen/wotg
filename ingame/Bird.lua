local Enemy = require("ingame.Enemy")
local Seed = require("ingame.Seed")

local Bird = class("Bird", Enemy)

Bird.static.STATE_FLY     = 1
Bird.static.STATE_CHARGE  = 2
Bird.static.STATE_DASH    = 3
Bird.static.STATE_SEEK    = 4
Bird.static.STATE_EAT     = 5
Bird.static.STATE_STUNNED = 6

Bird.static.GRAVITY = 400
Bird.static.FLY_SPEED = 30
Bird.static.CHARGE_TIME = 0.25
Bird.static.SEEK_SPEED = 50
Bird.static.DASH_SPEED = 110
Bird.static.DASH_TIME = 1
Bird.static.DASH_COOLDOWN = 3
Bird.static.STUNNED_TIME = 4
Bird.static.ACCELERATION = 500

Bird.static.MAX_HP = 30
Bird.static.SEED = Seed.static.TYPE_POWER

function Bird:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "bird")

	self.dir = dir
	self.xspeed = 0
	self.yspeed = 0

	self.state = Bird.static.STATE_FLY
	self.time = 0
	self.blink = 0
	self.hp = Bird.static.MAX_HP
	self.slot = nil
	self.dash_cooldown = 0

	self.animator = Animator(Resources.getAnimator("bird.lua"))
	self.collider = BoxCollider(12, 12)
end

function Bird:enter()
	self.players = self.scene:findAll("player")
	self.slots = self.scene:findAll("slot")
	self.terrain = self.scene:find("terrain")
end

function Bird:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.blink = self.blink - dt
	self.dash_cooldown = self.dash_cooldown - dt

	if self.state == Bird.static.STATE_FLY then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Bird.static.FLY_SPEED, Bird.static.ACCELERATION*dt)
		self.yspeed = math.movetowards(self.yspeed, 0, Bird.static.ACCELERATION*dt)

		if self.dir == -1 and self.x < 16 then self.dir = 1 end
		if self.dir == 1 and self.x > Screen.WIDTH-16 then self.dir = -1 end

		if self.y > Screen.HEIGHT-48 then self.yspeed = -30 end
		if self.y < 48 then self.yspeed = 30 end

		if self.dash_cooldown <= 0 then
			local player_los, player = self:canSeePlayer()
			if player_los then
				local dx = player.x - self.x
				local dy = player.y - self.y
				local len = math.sqrt(dx^2 + dy^2)

				self.target_xspeed = dx / len * Bird.static.DASH_SPEED
				self.target_yspeed = dy / len * Bird.static.DASH_SPEED
				self.dir = math.sign(self.target_xspeed)
				self.state = Bird.static.STATE_CHARGE
				self.time = Bird.static.CHARGE_TIME
			else
				local slot_los, slot = self:canSeeSlot()
				if slot_los then
					self.slot = slot
					self.state = Bird.static.STATE_SEEK
				end
			end
		end

	elseif self.state == Bird.static.STATE_CHARGE then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*100)
		self.yspeed = math.movetowards(self.yspeed, 0, dt*100)

		if self.time <= 0 then
			self.state = Bird.static.STATE_DASH
			self.time = Bird.static.DASH_TIME
			self.dash_cooldown = Bird.static.DASH_COOLDOWN
		end

	elseif self.state == Bird.static.STATE_DASH then
		self.xspeed = math.movetowards(self.xspeed, self.target_xspeed, Bird.static.ACCELERATION*dt)
		self.yspeed = math.movetowards(self.yspeed, self.target_yspeed, Bird.static.ACCELERATION*dt)
		if self.time <= 0 then
			self.state = Bird.static.STATE_FLY
		end

	elseif self.state == Bird.static.STATE_SEEK then
		local dx = self.slot.x+self.slot.leaves1_x - self.x
		local dy = self.slot.y+self.slot.leaves1_y - self.y
		local len = math.sqrt(dx^2 + dy^2)
		self.target_xspeed = dx / len * Bird.static.SEEK_SPEED
		self.target_yspeed = dy / len * Bird.static.SEEK_SPEED
		self.dir = math.sign(self.target_xspeed)
		self.xspeed = math.movetowards(self.xspeed, self.target_xspeed, Bird.static.ACCELERATION*dt)
		self.yspeed = math.movetowards(self.yspeed, self.target_yspeed, Bird.static.ACCELERATION*dt)

		local dx = self.slot.x+self.slot.leaves1_x - self.x
		local dy = self.slot.y+self.slot.leaves1_y - self.y
		local sqdist = dx^2 + dy^2

		if sqdist < 4^2 then
			self.x = self.slot.x+self.slot.leaves1_x - self.dir*6
			self.y = self.slot.y+self.slot.leaves1_y
			self.state = Bird.static.STATE_EAT
		end
		if self.slot:isEmpty() == true then
			self.state = Bird.static.STATE_FLY
		end

	elseif self.state == Bird.static.STATE_EAT then
		self.xspeed = 0
		self.yspeed = 0

		self.slot:eat(dt)
		if self.slot:isEmpty() then
			self.slot = nil
			self.state = Bird.static.STATE_FLY
		end

	elseif self.state == Bird.static.STATE_STUNNED then
		self.xspeed = math.movetowards(self.xspeed, 0, 200*dt)
		self.yspeed = self.yspeed + dt*Bird.static.GRAVITY

		if self.x < 16 then self.xspeed = 50 end
		if self.x > Screen.WIDTH-16 then self.xspeed = -50 end

		if self.time <= 0 then
			self:kill()
		end
	end

	self.x = self.x + self.xspeed * dt

	local oldy = self.y
	self.y = math.min(self.y + self.yspeed * dt, Screen.HEIGHT-23)
	if self.state == Bird.static.STATE_STUNNED then
		local collided, o = self.terrain:checkCollision(self)
		if collided then
			if oldy+self.collider.h/2 <= o.y-o.collider.h/2 then
				self.y = oldy
				self.xspeed = 0.5*self.xspeed
				self.yspeed = -0.15*self.yspeed
			end
		end
	end
end

function Bird:canSeePlayer()
	local min_sqdist = nil
	local best_player = nil
	for i,v in ipairs(self.players) do
		local xdist = math.abs(self.x - v.x)
		local ydist = math.abs(self.y - v.y)
		local sqdist = xdist^2 + ydist^2

		if sqdist < 80^2 and xdist > 16
		and (best_player == nil or sqdist < min_sqdist) then
			min_sqdist = sqdist
			best_player = v
		end
	end

	return best_player ~= nil, best_player
end

function Bird:canSeeSlot()
	local min_sqdist = nil
	local best_slot = nil
	for i,v in ipairs(self.slots) do
		if not v:isEmpty() then
			local xdist = math.abs(self.x - v.x)
			local ydist = math.abs(self.y - v.y)
			local sqdist = xdist^2 + ydist^2

			if sqdist < 120^2
			and (best_slot == nil or sqdist < min_sqdist) then
				min_sqdist = sqdist
				best_slot = v
			end
		end
	end

	return best_slot ~= nil, best_slot
end

function Bird:draw()
	self.animator:setProperty("state", self.state)
	self.animator:draw(self.x, self.y, 0, -self.dir, 1)
	if (self.blink > 0)
	or (self:isStunned() and love.timer.getTime() % 0.2 < 0.1) then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
end

function Bird:damage(dmg)
	self.blink = 0.15
	self.hp = self.hp - dmg
	if self.state == Bird.static.STATE_EAT then
		self.state = Bird.static.STATE_FLY
	end
	if self.hp <= 0 then
		self:setStunned()
	end
end

function Bird:setStunned()
	Enemy.setStunned(self)
	self.state = Bird.static.STATE_STUNNED
	self.time = Bird.static.STUNNED_TIME
end

function Bird:onCollide(o)
	if self.blink > 0 then return end
	if o:getName() == "slash" then
		if self:isStunned() then
			if o:isCharged() then
				self.scene:add(Seed(self.x, self.y,
					o.dir*60,
					love.math.random(-80, -50),
					Bird.static.SEED
				))
				self:kill()
			end
		else
			self:damage(o:getDamage())
			self.xspeed = 140*o.dir
		end
	elseif o:getName() == "minion" and not self:isStunned() then
		self:damage(o:getDamage())
	end
end

return Bird
