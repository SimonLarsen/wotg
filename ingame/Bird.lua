local Enemy = require("ingame.Enemy")
local Seed = require("ingame.Seed")

local Bird = class("Bird", Enemy)

Bird.static.STATE_FLY     = 1
Bird.static.STATE_DASH    = 2
Bird.static.STATE_EAT     = 3
Bird.static.STATE_STUNNED = 4

Bird.static.FLY_SPEED = 30
Bird.static.DASH_TIME = 1

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

	self.animator = Animator(Resources.getAnimator("bird.lua"))
	self.collider = BoxCollider(12, 12)
end

function Bird:enter()
	self.players = self.scene:findAll("player")
	self.slots = self.scene:findAll("slot")
end

function Bird:update(dt)
	self.animator:update(dt)
	self.time = self.time - dt
	self.blink = self.blink - dt

	if self.state == Bird.static.STATE_FLY then
		self.xspeed = math.movetowards(self.xspeed, self.dir*Bird.static.FLY_SPEED, 100*dt)
		if self.dir == -1 and self.x < 32 then self.dir = 1 end
		if self.dir == 1 and self.x > Screen.WIDTH-32 then self.dir = -1 end

		local player_los, player = self:canSeePlayer()
		if player_los then
			self.state = Bird.static.STATE_DASH
			self.time = Bird.static.DASH_TIME
		end
	end

	self.x = self.x + self.xspeed * dt
end

function Bird:canSeePlayer()
	local min_sqdist = nil
	local best_player = nil
	for i,v in ipairs(self.players) do
		local xdist = math.abs(self.x - v.x)
		local ydist = math.abs(self.y - v.y)
		local sqdist = xdist^2 + ydist^2

		if sqdist < 80^2
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

			if sqdist < 60^2
			and (best_slot == nil or sqdist < min_sqdist) then
				min_sqdist = sqdist
				best_slot = v
			end
		end
	end

	return best_slot ~= nil, best_slot
end

function Bird:draw()
	self.animator:draw(self.x, self.y, 0, -self.dir, 1)
	if (self.blink > 0)
	or (self:isStunned() and love.timer.getTime() % 0.2 < 0.1) then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, -self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
end

function Bird:onCollide(o)

end

return Bird
