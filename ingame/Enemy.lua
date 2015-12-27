local Enemy = class("Enemy", Entity)

local Seed = require("ingame.Seed")
local Attack = require("ingame.Attack")
local DustCloud = require("ingame.DustCloud")

Enemy.static.BLINK_TIME = 0.35

function Enemy:initialize(x, y, z, name, seeds)
	Entity.initialize(self, x, y, z, name)

	self.stunned = false
	self.seed_count = seeds or 1
end

function Enemy:setStunned()
	self.stunned = true
	addScore(self:getScore())
end

function Enemy:isStunned()
	return self.stunned
end

function Enemy:getScore()
	return 0
end

function Enemy:damage(dmg)
	self.blink = Enemy.static.BLINK_TIME
	self.hp = self.hp - dmg
	if self.hp <= 0 then
		self:setStunned()
	end
	Resources.playSound("hurt2.wav")
end

function Enemy:spawnSeed(dir)
	self.scene:add(Seed(self.x, self.y, dir*60, love.math.random(-80, -50)))
end

function Enemy:onCollide(o)
	if self.blink > 0 then return end

	if o:isInstanceOf(Attack) or o:getName() == "minion" then
		if self:isStunned() then
			for i=1, self.seed_count do
				self:spawnSeed(o.dir)
			end
			self:kill()
			self.scene:add(DustCloud(self.x, self.y))
		else
			self:damage(o:getDamage())
			self:knockback(o.dir)
		end
	end
end

return Enemy
