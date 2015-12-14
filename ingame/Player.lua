local Player = class("Player", Entity)

local Keybinding = require("Keybinding")
local Slash = require("ingame.Slash")
local Seed = require("ingame.Seed")
local Fruit = require("ingame.Fruit")

Player.static.MOVE_SPEED = 100
Player.static.ACCELERATION = 1600
Player.static.FRICTION = 700
Player.static.JUMP_SPEED = 270
Player.static.MAX_JUMPS = 2
Player.static.ATTACK_COOLDOWN = 0.15
Player.static.GRAVITY = 800

Player.static.MAX_HP = 100
Player.static.MAX_MAGIC = 100
Player.static.BASE_DAMAGE = 20
Player.static.CHARGE_TIME = 0.6
Player.static.HURT_TIME = 0.25
Player.static.BLINK_TIME = 2

Player.static.STATE_IDLE   = 1
Player.static.STATE_CHARGE = 2
Player.static.STATE_HURT   = 3

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
	self.blink = 0
	self.state = Player.static.STATE_IDLE

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
		self.keys:add("plant", "d")
		self.keys:add("jump", " ")
		self.keys:add("attack", "f")
		self.keys:add("toggle", "s")
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

	self.yspeed = self.yspeed + dt*Player.static.GRAVITY
	self.attack_cooldown = self.attack_cooldown - dt
	self.blink = self.blink - dt

	if self.state == Player.static.STATE_IDLE then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*Player.static.FRICTION)

		-- Left right movement
		if Keyboard.isDown(self.keys:get("left")) then
			self.dir = -1
			self.xspeed = math.movetowards(self.xspeed, -Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
		end
		if Keyboard.isDown(self.keys:get("right")) then
			self.dir = 1
			self.xspeed = math.movetowards(self.xspeed, Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
		end

		if Keyboard.wasPressed(self.keys:get("attack"))
		and self.attack_cooldown <= 0 then
			self.animator:setProperty("charge", true)
			self.state = Player.static.STATE_CHARGE
			self.charge = 0
		end

		if Keyboard.wasPressed(self.keys:get("plant")) then
			self:plant()
		end
	
	elseif self.state == Player.static.STATE_CHARGE then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*Player.static.FRICTION/4)
		self.charge = self.charge + dt

		if Keyboard.isDown(self.keys:get("left")) then self.dir = -1 end
		if Keyboard.isDown(self.keys:get("right")) then self.dir = 1 end

		if not Keyboard.isDown(self.keys:get("attack")) then
			self.state = Player.static.STATE_IDLE
			local x = self.x + 16*self.dir
			local charged = self.charge >= Player.static.CHARGE_TIME
			self.scene:add(Slash(x, self.y, self.xspeed, self.yspeed, self.dir, self:getDamage(), charged))
			self.charge = 0
			self.attack_cooldown = Player.static.ATTACK_COOLDOWN
			self.animator:setProperty("attack", true)
		end
	
	elseif self.state == Player.static.STATE_HURT then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*200)
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = Player.static.STATE_IDLE
		end
	end

	if Keyboard.wasPressed(self.keys:get("jump"))
	and self.jumps < Player.static.MAX_JUMPS then
		self.onGround = false
		self.yspeed = math.min(self.yspeed, -Player.static.JUMP_SPEED)
		self.jumps = self.jumps+1
		self.animator:setProperty("jump", true)
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
			if oldy+self.collider.h/2 <= o.y-o.collider.h/2 then
				self.y = o.y-o.collider.h/2-self.collider.h/2-0.000001
				self.onGround = true
				self.jumps = 0
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
	if self.state == Player.static.STATE_HURT then
		self.animator:setProperty("state", 4)
	elseif self.onGround == false then
		if self.yspeed > 0 then
			self.animator:setProperty("state", 5)
		end
	else
		if math.abs(self.xspeed) < 2 then
			self.animator:setProperty("state", 1)
		else
			self.animator:setProperty("state", 2)
		end
	end

	self.animator:draw(self.x, self.y, 0, self.dir, 1)

	if self.charge > Player.static.CHARGE_TIME
	and love.timer.getTime() % 0.2 < 0.1 then
		love.graphics.setColor(50, 115, 165)
		self.animator:draw(self.x, self.y, 0, self.dir, 1)
		love.graphics.setColor(255, 255, 255)
	end

	if self.blink > 0 and love.timer.getTime() % 0.2 < 0.1 then
		love.graphics.setBlendMode("additive")
		self.animator:draw(self.x, self.y, 0, self.dir, 1)
		love.graphics.setBlendMode("alpha")
	end
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
			self.power = self.power + 0.05
		elseif o:getType() == Fruit.static.TYPE_MINION then
		end
		o:kill()
	elseif o:getName() == "seed" then
		self.seeds[o:getType()] = self.seeds[o:getType()] + 1
		o:kill()
	elseif self.blink <= 0 then
		if (o:getName() == "pig" or o:getName() == "bird" or o:getName() == "rat")
		and o:isStunned() == false then
			self.state = Player.static.STATE_HURT
			self.time = Player.static.HURT_TIME
			self.blink = Player.static.BLINK_TIME
			self.lives = self.lives - 1

			self.xspeed = 120*math.sign(self.x - o.x)
			self.yspeed = 150*math.sign(self.y - o.y)
		end
	end
end

function Player:getDamage()
	return self.power * Player.static.BASE_DAMAGE
end

return Player
