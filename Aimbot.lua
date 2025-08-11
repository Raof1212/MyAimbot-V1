local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Flying control variables
local flying = false
local flySpeed = 50
local velocity = Vector3.new(0,0,0)

local lastSpaceTapTime = 0
local doubleTapThreshold = 0.3 -- seconds between taps to count as double tap

-- To move character smoothly while flying
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
bodyVelocity.Velocity = Vector3.new(0,0,0)
bodyVelocity.P = 1250
bodyVelocity.Parent = rootPart
bodyVelocity.Enabled = false

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Space then
			local currentTime = tick()
			if currentTime - lastSpaceTapTime <= doubleTapThreshold then
				-- Double tapped space - toggle flying
				flying = not flying
				bodyVelocity.Enabled = flying
				if flying then
					print("Fly mode activated")
				else
					print("Fly mode deactivated")
					bodyVelocity.Velocity = Vector3.new(0,0,0)
				end
			end
			lastSpaceTapTime = currentTime
		end
	end
end

-- Update flying velocity every frame while flying
RunService.Heartbeat:Connect(function()
	if flying then
		local moveDirection = Vector3.new(0,0,0)
		local camera = workspace.CurrentCamera
		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector

		-- WASD controls for flying direction
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

		moveDirection = moveDirection.Unit
		if moveDirection ~= moveDirection then -- check for NaN (when no keys pressed)
			moveDirection = Vector3.new(0,0,0)
		end

		-- Up and down control: Space to go up, LeftShift to go down
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0,1,0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDirection = moveDirection + Vector3.new(0,-1,0)
		end

		bodyVelocity.Velocity = moveDirection * flySpeed
	else
		-- Not flying, disable velocity
		bodyVelocity.Velocity = Vector3.new(0,0,0)
	end
end)

UserInputService.InputBegan:Connect(onInputBegan)

-- Reset flying on character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	bodyVelocity.Parent = rootPart
	bodyVelocity.Enabled = false
	flying = false
end)
