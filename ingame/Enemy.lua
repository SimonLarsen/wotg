local Enemy = class("Enemy", Entity)

Enemy.static.BLINK_TIME = 0.25

function Enemy:initialize(...)
	Entity.initialize(self, ...)

	self.stunned = false
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

return Enemy
