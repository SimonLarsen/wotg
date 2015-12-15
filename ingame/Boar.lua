local Enemy = require("ingame.Enemy")
local Pig = require("ingame.Pig")

local Boar = class("Boar", Pig)

Boar.static.MAX_HP = 75

function Boar:initialize(x, y, dir)
	Enemy.initialize(self, x, y, 0, "pig")

	self.dir = dir
	self.xspeed = 0
	self.time = 0

	self.state = Pig.static.STATE_WALK
	self.blink = 0
	self.hp = Boar.static.MAX_HP
	self.slot = nil
	self.view_range = 90

	self.animator = Animator(Resources.getAnimator("boar.lua"))
	self.collider = BoxCollider(18, 14)
end

function Boar:getScore()
	return 400
end

return Boar
