local Enemy = require("ingame.Enemy")
local Pig = require("ingame.Pig")
local Attack = require("ingame.Attack")
local Seed = require("ingame.Seed")

local Boar = class("Boar", Pig)

Boar.static.MAX_HP = 75

function Boar:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "pig")

	self.dir = dir
	self.xspeed = 0
	self.time = 0

	self.state = Pig.static.STATE_WALK
	self.blink = 0
	self.hp = Boar.static.MAX_HP
	self.slot = nil
	self.view_range = 90

	self.animator = Animator(Resources.getAnimator("boar.lua"))
	self.collider = BoxCollider(18, 14)
end

function Boar:getScore()
	return 400
end

function Boar:onCollide(o)
	if self.blink > 0 then return end
	if o:isInstanceOf(Attack) then
		if self:isStunned() then
			if o:isCharged() then
				self.scene:add(Seed(self.x, self.y,
					o.dir*30,
					love.math.random(-80, -50)
				))
				self.scene:add(Seed(self.x, self.y,
					o.dir*60,
					love.math.random(-80, -50)
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

return Boar
