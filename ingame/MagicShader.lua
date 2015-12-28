local MagicShader = class("MagicShader", Entity)

function MagicShader:initialize(time)
	Entity.initialize(self, 0, 0, 100)

	self.total_time = time
	self.time = time
	local code = Resources.getShader("magic")
	self.shader = love.graphics.newShader(code)
	self.shader:send("width", Screen.WIDTH)
	self.shader:send("height", Screen.HEIGHT)
end

function MagicShader:update(dt)
	self.time = self.time - dt
	if self.time <= 0 then
		self:kill()
	end

	self.shader:send("time", love.timer.getTime())
	self.shader:send("strength", self.time / self.total_time)
end

function MagicShader:gui()
	drawFullscreenShader(self.shader)
end

return MagicShader
