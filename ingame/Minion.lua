local Enemy = require("ingame.Enemy")

local Minion = class("Minion", Entity)

Minion.static.STATE_IDLE   = 1
Minion.static.STATE_WALK   = 2
Minion.static.STATE_CHARGE = 3
Minion.static.STATE_JUMP   = 4

Minion.static.IDLE_TIME = 1
Minion.static.CHARGE_TIME = 0.5
Minion.static.WALK_SPEED = 60
Minion.static.GRAVITY = 400
Minion.static.HP = 30

function Minion:initialize(x, y, dir)
	Entity.initialize(self, x, y, 0, "minion")

	self.dir = dir or 1
	self.xspeed = 0
	self.yspeed = 0
	self.time = 0
	self.hp = Minion.static.HP

	self.animator = Animator(Resources.getAnimator("minion.lua"))
	self.state = Minion.static.STATE_IDLE
	self.collider = BoxCollider(14, 14)
end

function Minion:enter()
	self.terrain = self.scene:find("terrain")
end

function Minion:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.hp = self.hp - dt

	if self.state == Minion.static.STATE_IDLE then
		self.xspeed = 0

		if self.time <= 0 then
			self.state = Minion.static.STATE_WALK
		end

	elseif self.state == Minion.static.STATE_WALK then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Minion.static.WALK_SPEED, dt*200)

		if self.x < 16 then self.dir = 1 end
		if self.x > Screen.WIDTH-16 then self.dir = -1 end

		local enemy_los, enemy = self:canSeeEnemy()
		if enemy_los then
			self:charge(enemy.x, enemy.y)
		end

	elseif self.state == Minion.static.STATE_CHARGE then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*300)
		if self.time <= 0 then
			self.state = Minion.static.STATE_JUMP
			self.xspeed = self.target_xspeed
			self.yspeed = self.target_yspeed
		end

	elseif self.state == Minion.static.STATE_JUMP then
	end

	self.x = self.x + self.xspeed * dt
	local oldy = self.y
	self.yspeed = self.yspeed + Minion.static.GRAVITY*dt
	self.y = self.y + self.yspeed * dt
	local collided, o = self.terrain:checkCollision(self)
	if collided then
		if oldy+self.collider.h/2 <= o.y-o.collider.h/2 then
			self.y = oldy
			self.yspeed = 0
			if self.state == Minion.static.STATE_JUMP then
				self.state = Minion.static.STATE_IDLE
				self.time = Minion.static.IDLE_TIME
				self.xspeed = 0
			end
		end
	end

	if self.hp <= 0 then
		self:kill()
	end

	self.animator:setProperty("state", self.state)
end

function Minion:charge(x, y)
	self.dir = math.sign(x - self.x)
	self.state = Minion.static.STATE_CHARGE
	self.time = Minion.static.CHARGE_TIME

	self.target_xspeed = (x - self.x)*1.6
	self.target_yspeed = y - self.y - 150
end

function Minion:canSeeEnemy()
	local min_sqdist = nil
	local best_enemy = nil

	for i,v in ipairs(self.scene:getEntities()) do 
		if v:isInstanceOf(Enemy) and not v:isStunned() then
			local xdist = math.abs(self.x - v.x)
			local ydist = math.abs(self.y - v.y)
			local sqdist = xdist^2 + ydist^2

			if sqdist < 90^2 and xdist > 16
			and (best_enemy == nil or sqdist < min_sqdist) then
				min_sqdist = sqdist
				best_enemy = v
			end
		end
	end

	return best_enemy ~= nil, best_enemy
end

function Minion:draw()
	if self.hp > 3 or love.timer.getTime() % 0.2 < 0.1 then
		self.animator:draw(self.x, self.y, 0, self.dir, 1)
	end
end

function Minion:getDamage()
	return 15
end

return Minion
