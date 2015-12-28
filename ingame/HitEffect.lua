local HitEffect = class("HitEffect", Entity)

HitEffect.static.TIME = 0.05*5

function HitEffect:initialize(x, y, dir)
	Entity.initialize(self, x, y, -1)

	self.dir = dir
	self.time = HitEffect.static.TIME
	self.anim = Animation(Resources.getImage("hit_effect.png"), 32, 32, 0.05, false, 4, 14)
end

function HitEffect:update(dt)
	self.anim:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self:kill()
	end
end

function HitEffect:draw()
	self.anim:draw(self.x, self.y, 0, self.dir, 1)
end

return HitEffect
