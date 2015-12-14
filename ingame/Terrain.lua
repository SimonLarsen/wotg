local Terrain = class("Terrain", Entity)
local CollisionHandler = require("CollisionHandler")

function Terrain:initialize()
	Entity.initialize(self, 0, 0, 10, "terrain")

	self.colliders = {}
end

function Terrain:enter()
	self.collisionHandler = CollisionHandler(self.scene)
end

function Terrain:addBox(w, h, ox, oy)
	local e = Entity(ox, oy, 0)
	e.collider = BoxCollider(w, h)
	table.insert(self.colliders, e)
end

function Terrain:checkCollision(o)
	for i,v in ipairs(self.colliders) do
		local collision = self.collisionHandler:check(v, o)
		if collision == true then
			return true, v
		end
	end
	return false
end

return Terrain
