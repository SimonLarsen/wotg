local Fade = class("Fade", Entity)

Fade.static.IN = 0
Fade.static.OUT = 1

function Fade:initialize(time, dir, color)
	Entity.initialize(self, 0, 0, -100)

	self.time = time or 1
	self.color = color or {0, 0, 0}

	if dir == Fade.static.IN then
		self.alpha = 255
		self.tween = tween.new(self.time, self, {alpha = 0}, "linear")
	else
		self.alpha = 0
		self.tween = tween.new(self.time, self, {alpha = 255}, "linear")
	end
end

function Fade:update(dt)
	local complete = self.tween:update(dt)
	if complete then
		self:kill()
	end
end

function Fade:gui()
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
	love.graphics.rectangle("fill", 0, 0, Screen.WIDTH, Screen.HEIGHT)
	love.graphics.setColor(255, 255, 255)
end

return Fade
