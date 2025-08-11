local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local floating = false
local floatHeight = humanoidRootPart.Position.Y

-- Use BodyPosition to force the character at a fixed height
local bodyPosition = Instance.new("BodyPosition")
bodyPosition.MaxForce = Vector3.new(1e6, 1e6, 1e6)
bodyPosition.P = 1e4
bodyPosition.D = 1000
bodyPosition.Position = Vector3.new(humanoidRootPart.Position.X, floatHeight, humanoidRootPart.Position.Z)
bodyPosition.Parent = humanoidRootPart
bodyPosition.Enabled = false

-- Toggle floating with Q key
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		floating = not floating
		bodyPosition.Enabled = floating
		if floating then
			print("Floating enabled")
			-- Fix float height on toggle
			floatHeight = humanoidRootPart.Position.Y
			bodyPosition.Position = Vector3.new(humanoidRootPart.Position.X, floatHeight, humanoidRootPart.Position.Z)
			humanoid.PlatformStand = true -- disables physics to prevent falling
		else
			print("Floating disabled")
			humanoid.PlatformStand = false
			bodyPosition.Enabled = false
		end
	end
end)

-- Keep updating BodyPosition X,Z to follow the player movement, but fix Y to floatHeight
RunService.Heartbeat:Connect(function()
	if floating then
		local currentPos = humanoidRootPart.Position
		bodyPosition.Position = Vector3.new(currentPos.X, floatHeight, currentPos.Z)
	end
end)

-- Reset on character respawn
player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	bodyPosition.Parent = humanoidRootPart
	bodyPosition.Enabled = false
	floating = false
	humanoid.PlatformStand = false
end)

