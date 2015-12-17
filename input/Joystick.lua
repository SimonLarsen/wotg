local Joystick = {}

local state = {}

function Joystick.initialize()
	for i=1,4 do
		state[i] = {
			down = {},
			pressed = {},
			released = {}
		}
	end
end

function Joystick.wasPressed(joy, k, consume)
	local s = state[joy].pressed[k] == true
	if consume then
		state[joy].pressed[k] = false
	end
	return s
end

function Joystick.wasReleased(joy, k)
	return state[joy].released[k] == true
end

function Joystick.isDown(joy, k)
	return state[joy].down[k] == true
end

function Joystick.keypressed(joy, k)
	state[joy].down[k] = true
	state[joy].pressed[k] = true
end

function Joystick.keyreleased(joy, k)
	state[joy].down[k] = false
	state[joy].released[k] = true
end

function Joystick.clear()
	for joy=1,4 do
		for i,v in pairs(state[joy].pressed) do
			state[joy].pressed[i] = false
		end

		for i,v in pairs(state[joy].released) do
			state[joy].released[i] = false
		end
	end
end

return Joystick
