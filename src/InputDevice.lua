--!strict
-- PreferredInput
-- Stephen Leitnick
-- April 05, 2021

local Signal = require(script.Parent.Util.Signal)
local EnumList = require(script.Parent.Util.EnumList)
local UserInputService = game:GetService("UserInputService")

local touchUserInputType = Enum.UserInputType.Touch
local keyboardUserInputType = Enum.UserInputType.Keyboard
local PreferredInput = {}

function PreferredInput:GetPreferredDevice()
	return self.Current 
end


PreferredInput.Changed = Signal.new()
PreferredInput.InputType = EnumList.new("InputType", {"MouseKeyboard", "Touch", "Gamepad"})
PreferredInput.Current = PreferredInput.InputType.MouseKeyboard

local function SetPreferred(preferred)
	if preferred ~= PreferredInput.Current then
		PreferredInput.Current = preferred
		PreferredInput.Changed:Fire(preferred)
	end
end


local function DeterminePreferred(inputType: Enum.UserInputType)
	if inputType == touchUserInputType then
		SetPreferred(PreferredInput.InputType.Touch)
	elseif inputType == keyboardUserInputType or inputType.Name:sub(1, 5) == "Mouse" then
		SetPreferred(PreferredInput.InputType.MouseKeyboard)
	elseif inputType.Name:sub(1, 7) == "Gamepad" then
		SetPreferred(PreferredInput.InputType.Gamepad)
	end
end


DeterminePreferred(UserInputService:GetLastInputType())
UserInputService.LastInputTypeChanged:Connect(DeterminePreferred)


return PreferredInput
