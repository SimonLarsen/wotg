local CollisionHandler = class("CollisionHandler")

function CollisionHandler:initialize(scene)
	self.scene = scene
end

function CollisionHandler:checkAll(dt)
	local entities = self.scene:getEntities()

	for i=1, #entities do
		for j=i+1, #entities do
			local a = entities[i]
			local b = entities[j]
			if CollisionHandler:check(a, b) then
				a:onCollide(b, dt)
				b:onCollide(a, dt)
			end
		end
	end
end

function CollisionHandler:check(a, b)
	if a.collider == nil or b.collider == nil then return false end

	if a:getCollider():getType() == "box"
	and b:getCollider():getType() == "box" then
		return CollisionHandler:checkBoxBox(a, b)
	end
end

function CollisionHandler:checkBoxBox(a, b)
	local ac = a:getCollider()
	local bc = b:getCollider()

	if math.abs((a.x+ac.ox) - (b.x+bc.ox)) > (ac.w+bc.w)/2
	or math.abs((a.y+ac.oy) - (b.y+bc.oy)) > (ac.h+bc.h)/2 then
		return false
	end

	return true
end

return CollisionHandler
