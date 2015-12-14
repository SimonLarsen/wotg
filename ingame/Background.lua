local Background = class("Background", Entity)

function Background:initialize()
	Entity.initialize(self, 0, 0, 10)

	self.fg = Resources.getImage("fg.png")
	self.mid = Resources.getImage("mid.png")
	self.bg = Resources.getImage("bg.png")
end

function Background:draw()
	love.graphics.draw(self.bg, 0, (self.scene:getCamera():getY()-Screen.HEIGHT/2)*0.75, 0, 1, 1, 0, 80)
	love.graphics.draw(self.mid, 0, (self.scene:getCamera():getY()-Screen.HEIGHT/2)/2, 0, 1, 1, 0, 80)
	love.graphics.draw(self.fg, 0, 0, 0, 1, 1, 0, 80)
end

return Background
