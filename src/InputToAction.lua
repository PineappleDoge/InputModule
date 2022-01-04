--[[
	* InputToAction Module
	* Handles converting inputs (based on keybinds) to actions
	* PineappleDoge (PineappleDoge@protonmail.com)
	* Written (1-4-22), Last Revised (1-4-22)
]]
----------------------------------------------------------------------
-- Dependencies & Services
local Keybinds = require(script.Parent.Keybinds)
local ActionConvert = {}
local ActionsArray do 
	ActionsArray = {}
	ActionsDictionary = {} 
	
	for i, v in pairs(Keybinds.MouseKeyboard) do 
		if type(i) ~= "string" then continue end 
		table.insert(ActionsArray, i)
		ActionsDictionary[i] = true 
	end
end

function ActionConvert:GetActions(): {string}
	return ActionsArray
end

function ActionConvert:GetActionsDictionary(): {[string]: boolean}
	return ActionsDictionary
end

function ActionConvert:InputToAction(input: Enum.KeyCode | Enum.UserInputType): string | nil 
	for i, v in pairs(Keybinds) do 
		if v[input] ~= nil then 
			return v[input], i 
		end
	end
	
	return nil
end

function ActionConvert:ActionToInput(action: string, keybindScheme: string): Enum.KeyCode | Enum.UserInputType
	assert(Keybinds[keybindScheme], ("No keybind scheme exists, got %s"):format(tostring(keybindScheme)))
	return Keybinds[keybindScheme][action]
end

function ActionConvert:OverwriteInputDevice(keybindScheme: string, newKeybinds: {[string]: Enum.KeyCode})
	assert(Keybinds[keybindScheme], ("No keybind scheme exists, got %s"):format(tostring(keybindScheme)))
	Keybinds[keybindScheme] = {} 
	
	for action, keybind in pairs(newKeybinds) do 
		Keybinds[keybindScheme][action] = keybind 
		Keybinds[keybindScheme][keybind] = action 
	end
	
	return Keybinds[keybindScheme] 
end


----------------------------------------------------------------------
return ActionConvert