local DustCloud = class("DustCloud", Entity)

DustCloud.static.TIME = 0.5

function DustCloud:initialize(x, y)
	Entity.initialize(self, x, y, -1)

	self.time = DustCloud.static.TIME
	self.anim = Animation(Resources.getImage("dustcloud.png"), 28, 28, 0.1, false, 14, 14)
end

function DustCloud:update(dt)
	self.anim:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self:kill()
	end
end

function DustCloud:draw()
	self.anim:draw(self.x, self.y)
end

return DustCloud
