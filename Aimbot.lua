local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Set your speed value here
local SPEED = 100

-- Create the green dot
local function createGreenDot()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SpeedIndicatorGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Dot = Instance.new("Frame")
    Dot.Name = "GreenDot"
    Dot.Size = UDim2.new(0, 10, 0, 10) -- 10x10 pixels
    Dot.Position = UDim2.new(1, -20, 0, 10) -- Top-right corner with 20 pixels from right, 10 pixels from top
    Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Bright green
    Dot.BorderSizePixel = 0
    Dot.AnchorPoint = Vector2.new(1, 0) -- Anchor to top-right
    Dot.Parent = ScreenGui
end

-- Set high speed function
local function setHighSpeed(speed)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speed
end

-- Apply speed and create the green dot
setHighSpeed(SPEED)
createGreenDot()

-- Reapply speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    setHighSpeed(SPEED)
end)
