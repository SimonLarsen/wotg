local Player = class("Player", Entity)

local Keybinding = require("Keybinding")
local Slash = require("ingame.Slash")
local Seed = require("ingame.Seed")
local Fruit = require("ingame.Fruit")

Player.static.MOVE_SPEED = 100
Player.static.ACCELERATION = 1600
Player.static.FRICTION = 700
Player.static.JUMP_SPEED = 300
Player.static.MAX_JUMPS = 2
Player.static.ATTACK_COOLDOWN = 0.15
Player.static.GRAVITY = 1000

Player.static.MAX_HP = 100
Player.static.MAX_MAGIC = 100
Player.static.BASE_DAMAGE = 20

Player.static.STATE_RUN = 1
Player.static.STATE_CHARGE = 2

function Player:initialize(x, y, id)
	Entity.initialize(self, x, y, -1, "player")
	self.id = id or 1

	self.xspeed = 0
	self.yspeed = 0
	self.dir = 1
	self.onGround = false
	self.collider = BoxCollider(16, 22)
	self.jumps = 0
	self.attack_cooldown = 0
	self.charge = 0
	self.state = Player.static.STATE_RUN

	self.max_lives = 3
	self.lives = self.max_lives-1

	self.magic = 0
	self.max_magic = Player.static.MAX_MAGIC

	self.power = 1

	self.seeds = {3, 3, 3}
	self.selected_seed = 1

	self.animator = Animator(Resources.getAnimator("player.lua"))

	self.keys = Keybinding()
	if self.id == 1 then
		self.keys:add("up","up")
		self.keys:add("right","right")
		self.keys:add("down","down")
		self.keys:add("left","left")
		self.keys:add("plant", "s")
		self.keys:add("jump", "d")
		self.keys:add("attack", "f")
		self.keys:add("toggle", "e")
	end
end

function Player:enter()
	self.terrain = self.scene:find("terrain")
	self.hud = self.scene:find("hud")
	self.hud:setLives(self.id, self.lives, self.max_lives)
	self.hud:setMagic(self.id, self.magic, self.max_magic)
	self.hud:setSeeds(self.id, self.seeds, self.selected_seed)
end

function Player:update(dt)
	self.animator:update(dt)

	if self.state ~= Player.static.STATE_CHARGE or self.charge > 0.2 then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*Player.static.FRICTION)
	end
	self.yspeed = self.yspeed + dt*Player.static.GRAVITY
	self.attack_cooldown = self.attack_cooldown - dt

	if self.state == Player.static.STATE_RUN then
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
			self.state = Player.static.STATE_CHARGE
			self.charge = 0
		end

		if Keyboard.wasPressed(self.keys:get("plant")) then
			self:plant()
		end
	
	elseif self.state == Player.static.STATE_CHARGE then
		self.charge = self.charge + dt

		if not Keyboard.isDown(self.keys:get("attack")) then
			self.state = Player.static.STATE_RUN
			self.scene:add(Slash(x, self.y, self.xspeed, self.dir, self:getDamage()))
			self.attack_cooldown = Player.static.ATTACK_COOLDOWN
			self.animator:setProperty("attack", true)
		end
	end

	if Keyboard.wasPressed(self.keys:get("toggle")) then
		self.selected_seed = self.selected_seed % 3 + 1
		self.hud:setSeeds(self.id, self.seeds, self.selected_seed)
	end

	self.x = math.cap(self.x + self.xspeed*dt, 8, Screen.WIDTH-8)

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
	
	-- Update HUD
	self.hud:setLives(self.id, self.lives, self.max_lives)
	self.hud:setMagic(self.id, self.magic, self.max_magic)
	self.hud:setSeeds(self.id, self.seeds, self.selected_seed)
end

function Player:plant()
	if self.onGround == false then return end
	if self.seeds[self.selected_seed] == 0 then return end

	local slots = self.scene:findAll("slot")
	for i,v in ipairs(slots) do
		if math.abs(self.x-v.x) < 10
		and v.y > self.y and v.y < self.y+22
		and not v:isFull() then
			if v:addSeed(self.selected_seed) then
				self.seeds[self.selected_seed] = self.seeds[self.selected_seed]-1
			end
		end
	end
end

function Player:draw()
	if self.state == Player.static.STATE_CHARGE then
		self.animator:setProperty("state", 3)
	elseif math.abs(self.xspeed) < 2 then
		self.animator:setProperty("state", 1)
	else
		self.animator:setProperty("state", 2)
	end
	self.animator:draw(self.x, self.y, 0, self.dir, 1)
end

function Player:gui()
end

function Player:onCollide(o)
	if o:getName() == "fruit" then
		if o:getType() == Fruit.static.TYPE_HEAL then
			self.lives = math.cap(self.lives+1, 0, math.floor(self.max_lives))
		elseif o:getType() == Fruit.static.TYPE_MAGIC then
			self.magic = math.cap(self.magic+25, 0, self.max_magic)
		elseif o:getType() == Fruit.static.TYPE_POWER then
		elseif o:getType() == Fruit.static.TYPE_HEART then
			self.max_lives = self.max_lives + 0.25
		elseif o:getType() == Fruit.static.TYPE_UPGRADE then
			self.power = self.power + 0.2
		elseif o:getType() == Fruit.static.TYPE_MINION then
		end
		o:kill()
	end
end

function Player:getDamage()
	return self.power * Player.static.BASE_DAMAGE
end

return Player
