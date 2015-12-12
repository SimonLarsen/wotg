local Enemy = class("Enemy", Entity)

function Enemy:initialize(...)
	Entity.initialize(self, ...)

	self.stunned = false
end

function Enemy:setStunned()
	self.stunned = true
end

function Enemy:isStunned()
	return self.stunned
end

return Enemy
