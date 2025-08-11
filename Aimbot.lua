local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 50

local bodyPosition = Instance.new("BodyPosition")
bodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
bodyPosition.P = 10000
bodyPosition.D = 1000
bodyPosition.Parent = rootPart
bodyPosition.Position = rootPart.Position
bodyPosition.Enabled = false

local function toggleFly()
	flying = not flying
	bodyPosition.Enabled = flying
	humanoid.PlatformStand = flying

	if flying then
		print("Fly mode activated")
	else
		print("Fly mode deactivated")
	end
end

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Q then
			toggleFly()
		end
	end
end

RunService.Heartbeat:Connect(function()
	if flying then
		local moveDirection = Vector3.new(0,0,0)
		local camera = workspace.CurrentCamera
		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + forward
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - forward
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - right
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + right
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0,1,0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDirection = moveDirection + Vector3.new(0,-1,0)
		end

		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
			bodyPosition.Position = rootPart.Position + moveDirection * flySpeed
		else
			bodyPosition.Position = rootPart.Position
		end
	else
		bodyPosition.Position = rootPart.Position
	end
end)

UserInputService.InputBegan:Connect(onInputBegan)

LocalPlayer.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	bodyPosition.Parent = rootPart
	bodyPosition.Enabled = false
	humanoid.PlatformStand = false
	flying = false
end)

