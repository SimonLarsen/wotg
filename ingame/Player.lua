local Player = class("Player", Entity)

local Keybinding = require("Keybinding")
local Slash = require("ingame.Slash")

Player.static.MOVE_SPEED = 100
Player.static.ACCELERATION = 1600
Player.static.FRICTION = 700
Player.static.JUMP_SPEED = 300
Player.static.MAX_JUMPS = 2
Player.static.ATTACK_COOLDOWN = 0.25

Player.static.GRAVITY = 1000

function Player:initialize(x, y, id)
	Entity.initialize(self, x, y, 0, "player")
	self.id = id or 1

	self.xspeed = 0
	self.yspeed = 0
	self.dir = 1
	self.onGround = false
	self.collider = BoxCollider(16, 22)
	self.jumps = 0
	self.attack_cooldown = 0
	self.max_hp = 100
	self.hp = self.max_hp

	self.animator = Animator(Resources.getAnimator("player.lua"))

	self.keys = Keybinding()
	if self.id == 1 then
		self.keys:add("up","up")
		self.keys:add("right","right")
		self.keys:add("down","down")
		self.keys:add("left","left")
		self.keys:add("action", "a")
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
	self.animator:update(dt)

	self.xspeed = math.movetowards(self.xspeed, 0, dt*Player.static.FRICTION)
	self.yspeed = self.yspeed + dt*Player.static.GRAVITY
	self.attack_cooldown = self.attack_cooldown - dt

	-- Left right movement
	if Keyboard.isDown(self.keys:get("left")) then
		self.dir = -1
		self.xspeed = math.movetowards(self.xspeed, -Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
	end
	if Keyboard.isDown(self.keys:get("right")) then
		self.dir = 1
		self.xspeed = math.movetowards(self.xspeed, Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
	end

	if Keyboard.wasPressed(self.keys:get("jump"))
	and self.jumps < Player.static.MAX_JUMPS then
		self.onGround = false
		self.yspeed = -Player.static.JUMP_SPEED
		self.jumps = self.jumps+1
	end

	if Keyboard.wasPressed(self.keys:get("attack"))
	and self.attack_cooldown <= 0 then
		local x = self.x + self.dir*16
		self.scene:add(Slash(x, self.y, self.xspeed, self.dir))
		self.attack_cooldown = Player.static.ATTACK_COOLDOWN
	end

	if Keyboard.isDown(self.keys:get("down"))
	and Keyboard.wasPressed(self.keys:get("action")) then
		self:plant()
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

function Player:plant()
	if self.onGround == false then return end

	local slots = self.scene:findAll("slot")
	for i,v in ipairs(slots) do
		if math.abs(self.x-v.x) < 6
		and v.y > self.y and v.y < self.y+22
		and v:isEmpty() then
			v:addSeed(1)
		end
	end
end

function Player:draw()
	self.animator:draw(self.x, self.y, 0, self.dir, 1)
end

function Player:gui()
	-- Draw hp bar
	local hpw = self.hp/self.max_hp * 80
	local hpx
	local hpy = 8
	if self.id == 1 then hpx = 8
	elseif self.id == 2 then hpx = Screen.WIDTH-88
	end
	love.graphics.setColor(255, 16, 16)
	love.graphics.rectangle("fill", hpx, hpy, hpw, 6)
	love.graphics.setColor(255, 255, 255)
end

function Player:onCollide(o)
	if o:getName() == "seed" then
		o:kill()
	end
end

return Player
