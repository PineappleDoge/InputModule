--[[
	* Keyboard Input Module
	* Handles mouse inputs + QOL mouse functions
	* PineappleDoge (PineappleDoge@protonmail.com)
	* Written (1-4-22), Last Revised (1-4-22)
]]
----------------------------------------------------------------------
-- Dependencies & Services
local Util = script.Parent.Parent.Util 
local Signal = require(Util.Signal)
local Janitor = require(Util.Janitor)
local USER_INPUT_SERVICE = game:GetService("UserInputService") 

local Mouse = {}
Mouse.__index = Mouse

local RAY_DISTANCE = 1000
local PLR_MOUSE = game.Players.LocalPlayer:GetMouse()
local MouseClicks = {
	[Enum.UserInputType.MouseButton1] = {InputBegan = "LeftDown", InputEnded = "LeftUp"};
	[Enum.UserInputType.MouseButton2] = {InputBegan = "RightDown", InputEnded = "RightUp"};
	[Enum.UserInputType.MouseButton3] = {InputBegan = "MiddleDown", InputEnded = "MiddleUp"};
	[Enum.UserInputType.MouseMovement] = {InputChanged = "Moved"};
	[Enum.UserInputType.MouseWheel] = {InputChanged = "Scrolled"};
}


----------------------------------------------------------------------
-- Functions
function Mouse.new()
	local self = setmetatable({
		Janitor = Janitor.new();
		LeftDown = Signal.new();
		RightDown = Signal.new();
		MiddleDown = Signal.new();
		
		LeftUp = Signal.new();
		RightUp = Signal.new(); 
		MiddleUp = Signal.new();
		Scrolled = Signal.new();
		Moved = Signal.new();
	}, {
		__index = Mouse;
		__tostring = function()
			return ("Mouse InputDevice")
		end,
	})
	
	-- Recursive loop to add signals to janitor
	for i, v in pairs(self) do 
		if Signal.Is(v) then 
			self.Janitor:Add(v) 
		end
	end
	
	self:Init()
	return self 
end

function Mouse:Init()
	self.Janitor:Add(USER_INPUT_SERVICE.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then return end 
		if MouseClicks[input.UserInputType] and self[MouseClicks[input.UserInputType].InputBegan] then
			self[MouseClicks[input.UserInputType].InputBegan]:Fire(input.UserInputType, input) 
		end
	end))
	
	self.Janitor:Add(USER_INPUT_SERVICE.InputChanged:Connect(function(input: InputObject, processed: boolean)
		if processed then return end 
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then 
			self.Moved:Fire(USER_INPUT_SERVICE:GetMouseLocation())
		end
		
		if input.UserInputType == Enum.UserInputType.MouseWheel then 
			self.Scrolled:Fire(input.Position.Z)
		end
	end))
	
	self.Janitor:Add(USER_INPUT_SERVICE.InputEnded:Connect(function(input: InputObject, processed: boolean)
		if processed then return end 
		if MouseClicks[input.UserInputType] and self[MouseClicks[input.UserInputType].InputEnded] then 
			self[MouseClicks[input.UserInputType].InputEnded]:Fire(input.UserInputType, input) 
		end
	end))
end

function Mouse:Lock()
	USER_INPUT_SERVICE.MouseEnabled = Enum.MouseBehavior.LockCurrentPosition
end

function Mouse:LockCenter()
	USER_INPUT_SERVICE.MouseEnabled = Enum.MouseBehavior.LockCenter
end

function Mouse:Unlock()
	USER_INPUT_SERVICE.MouseEnabled = Enum.MouseBehavior.Default
end

function Mouse:IsLeftDown(): boolean
	return USER_INPUT_SERVICE:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

function Mouse:IsRightDown(): boolean
	return USER_INPUT_SERVICE:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

function Mouse:GetRay(overridePos: Vector2): Ray
	local mousePos = overridePos or USER_INPUT_SERVICE:GetMouseLocation()
	local viewportMouseRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
	return viewportMouseRay
end

function Mouse:Raycast(raycastParams, distance, overridePos): RaycastResult
	local viewportMouseRay = self:GetRay(overridePos)
	local result = workspace:Raycast(viewportMouseRay.Origin, viewportMouseRay.Direction * (distance or RAY_DISTANCE), raycastParams)
	
	return result
end

function Mouse:GetDelta()
	return USER_INPUT_SERVICE:GetMouseDelta()
end

function Mouse:GetPosition() 
	return USER_INPUT_SERVICE:GetMouseLocation()
end

function Mouse:Destroy()
	self.Janitor:Destroy() 
end


----------------------------------------------------------------------
export type Mouse = typeof(Mouse.new())
return Mouse