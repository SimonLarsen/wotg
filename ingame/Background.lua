local Background = class("Background", Entity)

function Background:initialize()
	Entity.initialize(self, 0, 0, 10)

	self.bg = Resources.getImage("bg.png")
end

function Background:draw()
	love.graphics.draw(self.bg, 0, 0, 0, 1, 1, 0, 480-160)
end

return Background
