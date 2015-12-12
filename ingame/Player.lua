local Player = class("Player", Entity)

local Keybinding = require("Keybinding")
local BoxCollider = require("BoxCollider")

Player.static.MOVE_SPEED = 100
Player.static.ACCELERATION = 1600
Player.static.FRICTION = 700
Player.static.JUMP_SPEED = 300
Player.static.MAX_JUMPS = 2

Player.static.GRAVITY = 900

function Player:initialize(x, y, id)
	Entity.initialize(self, x, y, 0, "player")
	self.id = id or 1

	self.xspeed = 0
	self.yspeed = 0
	self.onGround = false
	self.collider = BoxCollider(16, 24)
	self.jumps = 0

	if self.id == 1 then
		self.keys = Keybinding()
		self.keys:add("up","up")
		self.keys:add("right","right")
		self.keys:add("down","down")
		self.keys:add("left","left")
		self.keys:add("jump", "d")
		self.keys:add("attack", "f")
	end
end

function Player:enter()
	if self.terrain == nil then
		self.terrain = self.scene:find("terrain")
	end
end

function Player:update(dt)
	self.xspeed = math.movetowards(self.xspeed, 0, dt*Player.static.FRICTION)
	self.yspeed = self.yspeed + dt*Player.static.GRAVITY

	if Keyboard.isDown(self.keys:get("left")) then
		self.xspeed = math.movetowards(self.xspeed, -Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
	end
	if Keyboard.isDown(self.keys:get("right")) then
		self.xspeed = math.movetowards(self.xspeed, Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
	end

	if Keyboard.wasPressed(self.keys:get("jump"))
	and self.jumps < Player.static.MAX_JUMPS then
		self.onGround = false
		self.yspeed = -Player.static.JUMP_SPEED
		self.jumps = self.jumps+1
	end
	if Keyboard.isDown("w") then
		self.yspeed = 0
	end

	self.x = self.x + self.xspeed*dt

	local oldy = self.y
	self.onGround = false
	self.y = self.y + self.yspeed*dt
	if self.yspeed > 0 then
		local collided, o = self.terrain:checkCollision(self)
		if collided then
			if oldy+self.collider.h/2 < o.y-o.collider.h/2 then
				self.y = oldy
				if self.yspeed > 0 then
					self.onGround = true
					self.jumps = 0
				end
				self.yspeed = 0
			end
		end
	end
end

function Player:draw()
	love.graphics.rectangle("fill", self.x-8, self.y-12, 16, 24)
end

return Player
