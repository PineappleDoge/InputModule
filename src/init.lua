--[[
	* InputModule
	* Handles mouse inputs + QOL mouse functions
	* PineappleDoge (PineappleDoge@protonmail.com)
	* Written (1-4-22), Last Revised (1-4-22)
]]
----------------------------------------------------------------------
-- Dependencies & Services
local Signal = require(script.Util.Signal) 
local Janitor = require(script.Util.Janitor)
local EnumList = require(script.Util.EnumList)
local InputToAction = require(script.InputToAction)
local InputDevice = require(script.InputDevice)
local InputModule = {
	Mouse = require(script.InputModules.Mouse);
	Keyboard = require(script.InputModules.Keyboard);
	Gamepad = require(script.InputModules.Gamepad);
	Touch = require(script.InputModules.Touch);
	
	ActionState = {};
	ActionSignals = {
		Begin = {};
		End = {};
	};
}


----------------------------------------------------------------------
-- Stuff
local ActionsArray = InputToAction:GetActions()
local ActionsDictionary = InputToAction:GetActionsDictionary()
local PreferredDevice = InputDevice:GetPreferredDevice()
local CurrentDevice = {
	Janitor = Janitor.new();
} 

for i, v in ipairs(ActionsArray) do 
	InputModule.ActionState[v] = "End" 
	InputModule.ActionSignals[v] = Signal.new() 
	InputModule.ActionSignals['Begin'][v] = Signal.new()
	InputModule.ActionSignals['End'][v] = Signal.new()
end

function SetupPreferredDevice(preferredDevice: Enum.RaycastFilterType)
	-- TODO: Add touch + gamepad support
	if CurrentDevice and CurrentDevice.Janitor then 
		CurrentDevice.Janitor:Destroy()
	end
	
	if preferredDevice.Name == "MouseKeyboard" then 
		CurrentDevice.Janitor = Janitor.new()
		CurrentDevice.Mouse = CurrentDevice.Janitor:Add(InputModule.Mouse.new())
		CurrentDevice.Keyboard = CurrentDevice.Janitor:Add(InputModule.Keyboard.new())
		
		local function InputBegan(key, input, state)
			local Action = InputToAction:InputToAction(key) 

			if Action then 
				InputModule.ActionState[Action] = "Begin"
				InputModule.ActionSignals[Action]:Fire("Begin", key, input)
				InputModule.ActionSignals['Begin'][Action]:Fire(key, input)
			end
		end
		
		local function InputEnded(key, input, state)
			local Action = InputToAction:InputToAction(key) 

			if Action then 
				InputModule.ActionState[Action] = "End"
				InputModule.ActionSignals[Action]:Fire("End", key, input)
				InputModule.ActionSignals['End'][Action]:Fire(key, input)
			end
		end
		
		CurrentDevice.Janitor:Add(CurrentDevice.Keyboard.KeyDown:Connect(InputBegan))
		CurrentDevice.Janitor:Add(CurrentDevice.Keyboard.KeyUp:Connect(InputEnded))
		CurrentDevice.Janitor:Add(CurrentDevice.Mouse.LeftDown:Connect(InputBegan))
		CurrentDevice.Janitor:Add(CurrentDevice.Mouse.LeftUp:Connect(InputEnded))
		CurrentDevice.Janitor:Add(CurrentDevice.Mouse.RightDown:Connect(InputBegan))
		CurrentDevice.Janitor:Add(CurrentDevice.Mouse.RightUp:Connect(InputEnded))
	end
end

function InputModule:GetActionBegunSignal(action: string)
	assert(ActionsDictionary[action], string.format("Action isn't valid, got %s", action))
	return InputModule.ActionSignals['Begin'][action]
end

function InputModule:GetActionEndedSignal(action: string)
	assert(ActionsDictionary[action], string.format("Action isn't valid, got %s", action))
	return InputModule.ActionSignals['End'][action]
end

function InputModule:ActionStateChangedSignal(action: string)
	assert(ActionsDictionary[action], string.format("Action isn't valid, got %s", action))
	return InputModule.ActionSignals[action]
end


InputModule.InputDeviceChangedSignal = InputDevice.Changed
InputDevice.Changed:Connect(SetupPreferredDevice)
SetupPreferredDevice(PreferredDevice)


----------------------------------------------------------------------
return InputModule 