local Entity = class("Entity")

function Entity:initialize(x, y, z, name)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.name = name
	self.alive = true
end

function Entity:enter()
	
end

function Entity:getName()
	return self.name
end

function Entity:kill()
	self.alive = false
end

function Entity:onRemove()
	
end

function Entity:onCollide(o, dt)
	
end

function Entity:isAlive()
	return self.alive
end

function Entity:getCollider()
	return self.collider
end

return Entity
