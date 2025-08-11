local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local floating = false
local floatSpeedUp = 5       -- How fast you float upward continuously
local moveSpeed = 30         -- Horizontal movement speed while floating

local bodyPosition = Instance.new("BodyPosition")
bodyPosition.MaxForce = Vector3.new(1e6, 1e6, 1e6)
bodyPosition.P = 1e4
bodyPosition.D = 1000
bodyPosition.Position = humanoidRootPart.Position
bodyPosition.Parent = humanoidRootPart
bodyPosition.Enabled = false

local function toggleFloating()
	floating = not floating
	bodyPosition.Enabled = floating
	humanoid.PlatformStand = floating
	if floating then
		print("Floating enabled")
		-- Start floating at current position
		bodyPosition.Position = humanoidRootPart.Position
	else
		print("Floating disabled")
		humanoid.PlatformStand = false
		bodyPosition.Enabled = false
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		toggleFloating()
	end
end)

RunService.Heartbeat:Connect(function()
	if floating then
		local moveDirection = Vector3.new(0, 0, 0)
		local camera = workspace.CurrentCamera
		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + Vector3.new(forward.X, 0, forward.Z)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - Vector3.new(forward.X, 0, forward.Z)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - Vector3.new(right.X, 0, right.Z)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + Vector3.new(right.X, 0, right.Z)
		end

		-- Normalize horizontal movement to avoid faster diagonal speed
		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit * moveSpeed
		end

		-- Add constant upward floating velocity
		local currentPos = humanoidRootPart.Position
		local targetPos = currentPos + Vector3.new(moveDirection.X, floatSpeedUp * RunService.Heartbeat:Wait(), moveDirection.Z)

		bodyPosition.Position = targetPos
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	bodyPosition.Parent = humanoidRootPart
	bodyPosition.Enabled = false
	floating = false
	humanoid.PlatformStand = false
end)


