local Binding = require("input.Binding", Binding)

local JoystickBinding = class("JoystickBinding", Binding)

JoystickBinding.DEFAULT_DEADZONE = 0.5

function JoystickBinding:initialize(joy, deadzone)
	Binding.initialize(self)

	self.joy = joy
	self.deadzone = deadzone or JoystickBinding.DEFAULT_DEADZONE
	self.actions = {}
end

function JoystickBinding:add(action, key)
	self.actions[action] = key
end

function JoystickBinding:wasPressed(action, consume)
	return Joystick.wasPressed(self.joy, self.actions[action], consume)
end

function JoystickBinding:isDown(action)
	return Joystick.isDown(self.joy, self.actions[action])
end

function JoystickBinding:getAxis(name)
	local joystick = love.joystick.getJoysticks()[self.joy]
	local v = joystick:getGamepadAxis(name)
	if math.abs(v) > self.deadzone then
		return v
	else
		return 0
	end
end

return JoystickBinding
