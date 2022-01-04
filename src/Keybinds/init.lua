local function GatherKeybinds()
	local tbl = {}
	local children = {script.MouseKeyboard, script.Gamepad, script.Touch} -- Typechecking

	for i, v in ipairs(children) do 
		local name = v.Name
		local module = require(v) 
		tbl[name] = {}

		for action, keybind in pairs(module) do 
			tbl[name][action] = keybind 
			tbl[name][keybind] = action 
		end
	end

	return tbl 
end

return GatherKeybinds()