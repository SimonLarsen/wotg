local Keybinding = class("Keybinding")

function Keybinding:initialize()
	self.actions = {}
end

function Keybinding:add(action, key)
	self.actions[action] = key
end

function Keybinding:get(action)
	return self.actions[action]
end

return Keybinding
