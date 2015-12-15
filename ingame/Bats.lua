local Enemy = require("ingame.Enemy")
local Seed = require("ingame.Seed")
local Attack = require("ingame.Attack")

local Bats = class("Bats", Enemy)

Bats.static.STATE_FLY    = 1
Bats.static.STATE_SEEK   = 2
Bats.static.STATE_EAT    = 3
Bats.static.STATE_ATTACK = 4
Bats.static.STATE_DEAD   = 5

Bats.static.GRAVITY = 400
Bats.static.FLY_SPEED = 30
Bats.static.SEEK_SPEED = 40
Bats.static.ATTACK_SPEED = 40
Bats.static.DASH_COOLDOWN = 3
Bats.static.ACCELERATION = 500

Bats.static.MAX_HP = 30
Bats.static.SEED = Seed.static.TYPE_POWER

function Bats:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "bats")

	self.dir = dir
	self.xspeed = 0
	self.yspeed = 0

	self.state = Bats.static.STATE_FLY
	self.time = 0
	self.blink = 0
	self.hp = Bats.static.MAX_HP
	self.slot = nil

	self.animator = Animator(Resources.getAnimator("bats.lua"))
	self.collider = BoxCollider(10, 10)
end

function Bats:enter()
	self.players = self.scene:findAll("player")
	self.slots = self.scene:findAll("slot")
end

function Bats:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.blink = self.blink - dt

	if self.state == Bats.static.STATE_FLY then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Bats.static.FLY_SPEED, Bats.static.ACCELERATION*dt)
		self.yspeed = math.movetowards(self.yspeed, 0, Bats.static.ACCELERATION*dt)

		if self.x > 16 and self.x < Screen.WIDTH-16 then
			local slot_los, slot = self:canSeeSlot()
			if slot_los then
				self.slot = slot
				self.state = Bats.static.STATE_SEEK
			else
				self.state = Bats.static.STATE_ATTACK
			end
		end

	elseif self.state == Bats.static.STATE_SEEK then
		local dx = self.slot.x+self.slot.leaves1_x - self.x
		local dy = self.slot.y+self.slot.leaves1_y - self.y
		local len = math.sqrt(dx^2 + dy^2)
		self.target_xspeed = dx / len * Bats.static.SEEK_SPEED
		self.target_yspeed = dy / len * Bats.static.SEEK_SPEED
		self.dir = math.sign(self.target_xspeed)
		self.xspeed = math.movetowards(self.xspeed, self.target_xspeed, Bats.static.ACCELERATION*dt)
		self.yspeed = math.movetowards(self.yspeed, self.target_yspeed, Bats.static.ACCELERATION*dt)

		local dx = self.slot.x+self.slot.leaves1_x - self.x
		local dy = self.slot.y+self.slot.leaves1_y - self.y
		local sqdist = dx^2 + dy^2

		if sqdist < 4^2 then
			self.x = self.slot.x+self.slot.leaves1_x - self.dir*6
			self.y = self.slot.y+self.slot.leaves1_y
			self.state = Bats.static.STATE_EAT
		end
		if self.slot:isEmpty() == true then
			self.state = Bats.static.STATE_ATTACK
		end

	elseif self.state == Bats.static.STATE_ATTACK then
		local player_los, player = self:canSeePlayer()
		local dx = player.x - self.x
		local dy = player.y - self.y
		local len = math.sqrt(dx^2 + dy^2)
		self.target_xspeed = dx / len * Bats.static.ATTACK_SPEED
		self.target_yspeed = dy / len * Bats.static.ATTACK_SPEED

		self.xspeed = math.movetowards(self.xspeed, self.target_xspeed, Bats.static.ACCELERATION*dt)
		self.yspeed = math.movetowards(self.yspeed, self.target_yspeed, Bats.static.ACCELERATION*dt)

	elseif self.state == Bats.static.STATE_EAT then
		self.xspeed = 0
		self.yspeed = 0

		self.slot:eatFruit(dt)
		if self.slot:isEmpty() then
			self.slot = nil
			self.state = Bats.static.STATE_FLY
		end
	elseif self.state == Bats.static.STATE_DEAD then
		self.xspeed = math.movetowards(self.xspeed, 0, 200*dt)
		self.yspeed = self.yspeed + dt*Bats.static.GRAVITY

		if self.y > Screen.HEIGHT-30 then
			self:kill()
		end
	end

	self.x = self.x + self.xspeed * dt
	self.y = math.min(self.y + self.yspeed * dt, Screen.HEIGHT-23)
end

function Bats:canSeePlayer()
	local min_sqdist = nil
	local best_player = nil
	for i,v in ipairs(self.players) do
		local xdist = math.abs(self.x - v.x)
		local ydist = math.abs(self.y - v.y)
		local sqdist = xdist^2 + ydist^2

		if best_player == nil or sqdist < min_sqdist then
			min_sqdist = sqdist
			best_player = v
		end
	end

	return best_player ~= nil, best_player
end

function Bats:canSeeSlot()
	local min_sqdist = nil
	local best_slot = nil
	for i,v in ipairs(self.slots) do
		if not v:isEmpty() then
			local xdist = math.abs(self.x - v.x)
			local ydist = math.abs(self.y - v.y)
			local sqdist = xdist^2 + ydist^2

			if best_slot == nil or sqdist < min_sqdist then
				min_sqdist = sqdist
				best_slot = v
			end
		end
	end

	return best_slot ~= nil, best_slot
end

function Bats:draw()
	self.animator:setProperty("state", self.state)
	if self.state ~= Bats.static.STATE_DEAD
	or love.timer.getTime() % 0.1 < 0.05 then
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
	end
	if (self.blink > 0) then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
end

function Bats:damage(dmg)
	self.blink = Enemy.static.BLINK_TIME
	self.hp = self.hp - dmg
	self.state = Bats.static.STATE_ATTACK
	if self.hp <= 0 then
		self.state = Bats.static.STATE_DEAD
	end
	Resources.playSound("hurt2.wav")
end

function Bats:setStunned()
	Enemy.setStunned(self)
	self.state = Bats.static.STATE_DEAD
end

function Bats:onCollide(o)
	if self.state == Bats.static.STATE_DEAD then return end

	if self.blink > 0 then return end
	if o:isInstanceOf(Attack) then
		self:damage(o:getDamage())
		self.xspeed = 140*o.dir
	elseif o:getName() == "minion" then
		self:damage(o:getDamage())
	end
end

function Bats:getScore()
	return 100
end

return Bats
