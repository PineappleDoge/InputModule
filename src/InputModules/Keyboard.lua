--[[
	* Keyboard Input Module
	* Handles keyboard inputs + QOL keyboard functions
	* PineappleDoge (PineappleDoge@protonmail.com)
	* Written (1-4-22), Last Revised (1-4-22)
]]
----------------------------------------------------------------------
-- Dependencies & Services
local Util = script.Parent.Parent.Util 
local Signal = require(Util.Signal)
local Janitor = require(Util.Janitor)
local USER_INPUT_SERVICE = game:GetService("UserInputService") 

local Keyboard = {}
Keyboard.__index = Keyboard


----------------------------------------------------------------------
-- Functions
function Keyboard.new()
	local self = setmetatable({
		Janitor = Janitor.new();
		KeyDown = Signal.new(); 
		KeyUp = Signal.new(); 
	}, {
		__index = Keyboard; 
		__tostring = function()
			return ("Keyboard InputDevice")
		end,
	})
	
	self.Janitor:Add(self.KeyDown)
	self.Janitor:Add(self.KeyUp)
	self:Init()
	return self 
end

function Keyboard:Init() 
	self.Janitor:Add(USER_INPUT_SERVICE.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then return end 
		if input.UserInputType == Enum.UserInputType.Keyboard then 
			self.KeyDown:Fire(input.KeyCode)
		end
	end))
	
	self.Janitor:Add(USER_INPUT_SERVICE.InputEnded:Connect(function(input: InputObject, processed: boolean)
		if processed then return end 
		if input.UserInputType == Enum.UserInputType.Keyboard then 
			self.KeyUp:Fire(input.KeyCode)
		end
	end))
end

function Keyboard:IsKeyDown(key: Enum.KeyCode): boolean
	return USER_INPUT_SERVICE:IsKeyDown(key) 
end

function Keyboard:AreKeysDown(keys: {Enum.KeyCode}): boolean
	for i, key in ipairs(keys) do 
		if not self:IsKeyDown(key) then return false end 
	end
	
	return true 
end

function Keyboard:Destroy()
	self.Janitor:Destroy() 
end 


----------------------------------------------------------------------
export type Keyboard = typeof(Keyboard.new())
return Keyboard