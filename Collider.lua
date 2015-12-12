local Collider = class("Collider")

function Collider:initialize(oneway)
	self.oneway = oneway
	if self.oneway == nil then
		self.oneway = false
	end
end

function Collider:isOneway()
	return self.oneway
end

return Collider
