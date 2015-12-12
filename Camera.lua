local Camera = class("Camera")

function Camera:initialize(x, y, zoom)
	self.x = x or 0
	self.y = y or 0
	self.zoom = zoom or 1
end

function Camera:setPosition(x, y)
	self.x = x
	self.y = y
end

function Camera:move(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
end

function Camera:getX()
	return self.x
end

function Camera:getY()
	return self.y
end

function Camera:setZoom(zoom)
	self.zoom = zoom
end

function Camera:getZoom()
	return self.zoom
end

function Camera:apply()
	love.graphics.translate(-self.x + Screen.WIDTH/2, -self.y + Screen.HEIGHT/2)
	love.graphics.scale(self.zoom, self.zoom)
end

return Camera
