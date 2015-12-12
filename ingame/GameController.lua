local GameController = class("GameController", Entity)

function GameController:initialize()
	Entity.initialize(self)
end

function GameController:enter()
	if self.player == nil then
		self.player = self.scene:find("player")
	end
	if self.camera == nil then
		self.camera = self.scene:getCamera()
	end
end

function GameController:update(dt)
	local cy = math.cap(self.player.y+32, 0, Screen.HEIGHT/2)
	self.camera:setY(cy)

	if Keyboard.wasPressed("f2") then
		local x = love.math.random(16, Screen.WIDTH-16)
		self.scene:add(require("ingame.Seed")(x, 0, 1))
	end
end

return GameController
