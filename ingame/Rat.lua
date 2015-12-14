local Enemy = require("ingame.Enemy")
local Seed = require("ingame.Seed")

local Rat = class("Rat", Enemy)

Rat.static.STATE_WALK    = 1
Rat.static.STATE_CHARGE  = 2
Rat.static.STATE_JUMP    = 3
Rat.static.STATE_EAT     = 4
Rat.static.STATE_STUNNED = 5

Rat.static.GRAVITY = 400
Rat.static.WALK_SPEED = 35
Rat.static.CHARGE_TIME = 0.5
Rat.static.STUNNED_TIME = 4

Rat.static.MAX_HP = 25
Rat.static.SEED = Seed.static.TYPE_MAGIC

function Rat:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "rat")

	self.dir = dir
	self.xspeed = 0
	self.yspeed = 0
	self.time = 0
	self.blink = 0
	self.hp = Rat.static.MAX_HP
	self.slot = nil
	self.jump_cooldown = 0

	self.animator = Animator(Resources.getAnimator("rat.lua"))
	self.state = Rat.static.STATE_WALK
	self.collider = BoxCollider(8, 8)
end

function Rat:enter()
	self.players = self.scene:findAll("player")
	self.slots = self.scene:findAll("slot")
	self.terrain = self.scene:find("terrain")
end

function Rat:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.blink = self.blink - dt
	self.jump_cooldown = self.jump_cooldown - dt

	if self.state == Rat.static.STATE_WALK then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Rat.static.WALK_SPEED, dt*200)

		if self.x < 16 then self.dir = 1 end
		if self.x > Screen.WIDTH-16 then self.dir = -1 end

		if self.jump_cooldown <= 0 then
			local player_los, player = self:canSeePlayer()
			if player_los then
				self:charge(player.x, player.y)
			else
				local slot_los, slot = self:canSeeSlot()
				if slot_los then
					local xdist = math.abs(self.x - slot.x)
					if xdist < 1 then
						self.dir = math.sign(self.x - slot.x)
					elseif xdist > 7 then
						self.dir = math.sign(slot.x - self.x)
					else
						self.state = Rat.static.STATE_EAT
						self.slot = slot
					end
				end
			end
		end

	elseif self.state == Rat.static.STATE_CHARGE then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*300)
		if self.time <= 0 then
			self.state = Rat.static.STATE_JUMP
			self.xspeed = self.target_xspeed
			self.yspeed = self.target_yspeed
		end

	elseif self.state == Rat.static.STATE_JUMP then
	elseif self.state == Rat.static.STATE_EAT then
		self.xspeed = 0
		self.slot:eat(dt)
		if self.slot:isEmpty() then
			self.slot = nil
			self.state = Rat.static.STATE_WALK
		end

	elseif self.state == Rat.static.STATE_STUNNED then
		self.xspeed = math.movetowards(self.xspeed, 0, 200*dt)
		if self.time <= 0 then
			self:kill()
		end
	end

	self.x = self.x + self.xspeed * dt
	local oldy = self.y
	self.yspeed = self.yspeed + Rat.static.GRAVITY*dt
	self.y = self.y + self.yspeed * dt
	local collided, o = self.terrain:checkCollision(self)
	if collided then
		if oldy+self.collider.h/2 <= o.y-o.collider.h/2 then
			self.y = oldy
			self.yspeed = 0
			if self.state == Rat.static.STATE_JUMP then
				self.state = Rat.static.STATE_WALK
				self.xspeed = 0
			end
		end
	end

	self.animator:setProperty("state", self.state)
end

function Rat:charge(x, y)
	self.dir = math.sign(x - self.x)
	self.state = Rat.static.STATE_CHARGE
	self.time = Rat.static.CHARGE_TIME

	self.target_xspeed = (x - self.x)*1.4
	self.target_yspeed = y - self.y - 170
end

function Rat:canSeePlayer()
	local min_sqdist = nil
	local best_player = nil
	for i,v in ipairs(self.players) do
		local xdist = math.abs(self.x - v.x)
		local ydist = math.abs(self.y - v.y)
		local sqdist = xdist^2 + ydist^2

		if sqdist < 80^2 and xdist > 16
		and v.y < self.y
		and (best_player == nil or sqdist < min_sqdist) then
			min_sqdist = sqdist
			best_player = v
		end
	end

	return best_player ~= nil, best_player
end

function Rat:canSeeSlot()
	local min_dist = 50000
	local best_slot
	for i,v in ipairs(self.slots) do
		if not v:isEmpty() then
			local xdist = math.abs(self.x - v.x)
			if v.y > self.y and xdist < min_dist then
				best_slot = v
			end
		end
	end

	return best_slot ~= nil, best_slot
end

function Rat:draw()
	self.animator:draw(self.x, self.y, 0, -self.dir, 1)
	if (self.blink > 0)
	or (self:isStunned() and love.timer.getTime() % 0.2 < 0.1) then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
end

function Rat:damage(dmg)
	self.blink = 0.15
	self.hp = self.hp - dmg
	if self.state == Rat.static.STATE_EAT then
		self.state = Rat.static.STATE_WALK
	end
	if self.hp <= 0 then
		self:setStunned()
		self.state = Rat.static.STATE_STUNNED
		self.time = Rat.static.STUNNED_TIME
	end
end

function Rat:onCollide(o)
	if self.blink > 0 then return end
	if o:getName() == "slash" then
		if self:isStunned() then
			if o:isCharged() then
				self.scene:add(Seed(self.x, self.y-2,
					o.dir*60,
					love.math.random(-80, -50),
					Rat.static.SEED
				))
				self:kill()
			end
		else
			self:damage(o:getDamage())
			self.xspeed = 100*o.dir
		end
	elseif o:getName() == "minion" and not self:isStunned() then
		self:damage(o:getDamage())
	end
end

return Rat
