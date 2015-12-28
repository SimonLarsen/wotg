local Player = class("Player", Entity)

local Slash = require("ingame.Slash")
local Beam = require("ingame.Beam")
local Seed = require("ingame.Seed")
local Fruit = require("ingame.Fruit")
local Enemy = require("ingame.Enemy")
local Dust = require("ingame.Dust")
local LevelUp = require("ingame.LevelUp")
local ScreenShaker = require("ingame.ScreenShaker")
local MagicShader = require("ingame.MagicShader")
local Fade = require("transition.Fade")

Player.static.MOVE_SPEED = 100
Player.static.ACCELERATION = 1600
Player.static.FRICTION = 700
Player.static.JUMP_SPEED = 270
Player.static.MAX_JUMPS = 10
Player.static.ATTACK_COOLDOWN = 0.2
Player.static.GRAVITY = 800

Player.static.MAX_MAGIC = 3
Player.static.BASE_DAMAGE = 20
Player.static.HURT_TIME = 0.25
Player.static.PLANT_TIME = 0.3
Player.static.BLINK_TIME = 2
Player.static.POWER_INCREMENT = 0.2
Player.static.SHIELD_TIME = 15
Player.static.BERSERK_TIME = 15

Player.static.STATE_IDLE  = 1
Player.static.STATE_HURT  = 2
Player.static.STATE_PLANT = 3
Player.static.STATE_DEAD  = 4

function Player:initialize(x, y, id, keys)
	Entity.initialize(self, x, y, -1, "player")
	self.id = id or 1

	self.xspeed = 0
	self.yspeed = 0
	self.dir = 1
	self.onGround = false
	self.collider = BoxCollider(16, 22)
	self.jumps = 0
	self.attack_cooldown = 0
	self.blink = 0
	self.state = Player.static.STATE_IDLE

	self.level = 1

	self.max_lives = 6
	self.lives = self.max_lives
	self.max_magic = Player.static.MAX_MAGIC
	self.magic = self.max_magic
	self.power = 1
	self.seeds = {3, 3, 3}
	self.selected_seed = 1

	self.shield = 0
	self.berserk = 0

	self.animator = Animator(Resources.getAnimator("player.lua"))
	self.shield_anim = Animation(Resources.getImage("shield.png"), 24, 32, 0.15)
	self.img_berserk = Resources.getImage("berserk.png")

	self.keys = keys
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
	self.shield_anim:update(dt)

	self.yspeed = self.yspeed + dt*Player.static.GRAVITY
	self.attack_cooldown = self.attack_cooldown - dt
	self.blink = self.blink - dt
	self.shield = self.shield - dt
	self.berserk = self.berserk - dt

	local axis1 = self.keys:getAxis("leftx")

	if self.state == Player.static.STATE_IDLE then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*Player.static.FRICTION)

		if axis1 < 0 then
			self.dir = -1
			self.xspeed = math.movetowards(self.xspeed, axis1*Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
		end
		if axis1 > 0 then
			self.dir = 1
			self.xspeed = math.movetowards(self.xspeed, axis1*Player.static.MOVE_SPEED, dt*Player.static.ACCELERATION)
		end

		if self.keys:wasPressed("attack")
		and self.attack_cooldown <= 0 then
			local x = self.x + 16*self.dir
			self.scene:add(Slash(self, self.dir, self:getDamage()))
			Resources.playSound("slash.wav")
			self.attack_cooldown = Player.static.ATTACK_COOLDOWN
			self.animator:setProperty("attack", true)
		end

		if self.keys:wasPressed("plant") then
			self:plant()
		end
	
	elseif self.state == Player.static.STATE_HURT then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*200)
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = Player.static.STATE_IDLE
		end

	elseif self.state == Player.static.STATE_PLANT then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*500)
		self.time = self.time - dt
		if self.time <= 0 then
			self.state = Player.static.STATE_IDLE
		end

	elseif self.state == Player.static.STATE_DEAD then
		self.xspeed = math.movetowards(self.xspeed, 0, dt*200)
	end

	if self.keys:wasPressed("magic") then
		self:useMagic()
		self.state = Player.static.STATE_IDLE
		self.attack_cooldown = Player.static.ATTACK_COOLDOWN
		self.animator:setProperty("attack", true)
	end

	if self.keys:wasPressed("jump")
	and self.jumps < Player.static.MAX_JUMPS
	and self.state ~= Player.static.STATE_DEAD then
		Resources.playSound("jump.wav")
		self.onGround = false
		self.yspeed = math.min(self.yspeed, -Player.static.JUMP_SPEED)
		self.jumps = self.jumps+1
		self.animator:setProperty("state", 1)
		self.animator:setProperty("jump", true)
	end

	if self.keys:wasPressed("togglel") then
		self.selected_seed = self.selected_seed - 1
		if self.selected_seed == 0 then
			self.selected_seed = 3
		end
		self.hud:setSeeds(self.id, self.seeds, self.selected_seed)
		Resources.playSound("seedselect.wav")
	end
	if self.keys:wasPressed("toggler") then
		self.selected_seed = self.selected_seed % 3 + 1
		self.hud:setSeeds(self.id, self.seeds, self.selected_seed)
		Resources.playSound("seedselect.wav")
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
				if self.yspeed > 50 then
					self.scene:add(Dust(self.x, o.y-o.collider.h/2))
				end
				self.yspeed = 0
			end
		end
	end

	if self.state == Player.static.STATE_DEAD
	and self.onGround then
		self.animator:setProperty("state", 6)
	elseif self.state == Player.static.STATE_HURT then
		self.animator:setProperty("state", 3)
	elseif self.state == Player.static.STATE_PLANT then
		self.animator:setProperty("state", 5)
	elseif self.onGround == false then
		if self.yspeed > 0 then
			self.animator:setProperty("state", 4)
		end
	else
		if math.abs(self.xspeed) < 2 then
			self.animator:setProperty("state", 1)
		else
			self.animator:setProperty("state", 2)
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
				self.seeds[self.selected_seed] = self.seeds[self.selected_seed] - 1
				addScore(25)
				self.state = Player.static.STATE_PLANT
				self.time = Player.static.PLANT_TIME
				Resources.playSound("plant.wav")
			end
		end
	end
end

function Player:draw()
	local t = love.timer.getTime()
	if self.shield > 0
	and (self.shield > 3 or t % 0.2 < 0.1) then
		local r = 230*(math.cos(t*16)/2 + 0.5)
		love.graphics.setColor(r, 230, 230)
		self.shield_anim:draw(self.x, self.y)
		love.graphics.setColor(255, 255, 255)
	end

	if self.berserk > 0
	and (self.berserk > 3 or t % 0.2 < 0.1) then
		love.graphics.draw(self.img_berserk, self.x, self.y, 0, 1, 1, 15, 15)
		local a = 255*(math.cos(t*16)/2 + 0.5)
		love.graphics.setColor(255, 255, 255, a)
		love.graphics.setBlendMode("add")
		love.graphics.draw(self.img_berserk, self.x, self.y, 0, 1, 1, 15, 15)
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(255, 255, 255, 255)
	end

	if self.blink < 0 or love.timer.getTime() % 0.04 < 0.02 then
		self.animator:draw(self.x, self.y, 0, self.dir, 1)
	end
end

function Player:onCollide(o)
	if self.state == Player.static.STATE_DEAD then return end

	if o:getName() == "fruit" then
		if o:getType() == Fruit.static.TYPE_HEAL then
			self.lives = math.cap(self.lives+2, 0, math.floor(self.max_lives))
		elseif o:getType() == Fruit.static.TYPE_MAGIC then
			self.magic = math.cap(self.magic+1, 0, self.max_magic)
		elseif o:getType() == Fruit.static.TYPE_XP then
		elseif o:getType() == Fruit.static.TYPE_MINION then
		elseif o:getType() == Fruit.static.TYPE_SHIELD then
			self.shield = Player.static.SHIELD_TIME
		elseif o:getType() == Fruit.static.TYPE_POWER then
			self.berserk = Player.static.BERSERK_TIME
		end

		Resources.playSound("pickup_fruit.wav")
		o:kill()
	elseif o:getName() == "seed" then
		self.seeds[o:getType()] = math.min(self.seeds[o:getType()] + 1, 9)
		Resources.playSound("pickup_seed.wav")
		o:kill()
		addScore(200)
	elseif self.blink <= 0 and self.shield <= 0 then
		if o:isInstanceOf(Enemy) and o:isStunned() == false then
			self.state = Player.static.STATE_HURT
			self.time = Player.static.HURT_TIME
			self.blink = Player.static.BLINK_TIME
			self.attack_cooldown = Player.static.ATTACK_COOLDOWN

			local name = o:getName()
			if name == "bird" or name == "rat" or name == "pig" then
				self.lives = self.lives - 1
			elseif name == "boar" or name == "darkbird" then
				self.lives = self.lives - 2
			end
			self.lives = math.max(self.lives, 0)

			if self.lives <= 0 then
				self.state = Player.static.STATE_DEAD
				self.blink = 0
				self.scene:find("controller"):gameOver()
				Resources.playSound("death.wav")
			else
				Resources.playSound("hurt.wav")
			end

			self.xspeed = 120*math.sign(self.x - o.x)
			self.yspeed = 150*math.sign(self.y - o.y)
		end
	end
end

function Player:levelUp()
	self.level = self.level + 1
	self.max_lives = self.max_lives + 1
	self.lives = self.lives + 1
	self.power = self.power + Player.static.POWER_INCREMENT
	self.scene:add(LevelUp())
	Resources.playSound("levelup.wav")
end

function Player:useMagic()
	if self.magic < self.max_magic then return end
	self.magic = 0
	self.scene:add(MagicShader(2))
	Resources.playSound("super.wav")
	for i,v in ipairs(self.scene:getEntities()) do
		if v:isInstanceOf(Enemy) then
			v:setStunned()
		end
	end
end

function Player:getDamage()
	local dmg = self.power * Player.static.BASE_DAMAGE
	if self.berserk > 0 then
		dmg = dmg * 1.25
	end
	return dmg
end

return Player
