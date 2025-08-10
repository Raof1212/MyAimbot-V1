-- Exunys Aimbot V3 (Modified: Tab to aim only)
-- Original by Exunys | Modified to require Tab hold for aiming

--// Services
local UserInputService = game:GetService("UserInputService")

--// Tab key control
local aiming = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Tab then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Tab then
        aiming = false
    end
end)

--// Original Aimbot Code (Exunys Aimbot V3)
-- Pasted exactly from the GitHub source, with one edit:
-- Where the camera sets its aim, wrapped inside: if aiming then ... end

-- Variables
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Settings
local Settings = {
    Enabled = true,
    AimPart = "Head",
    TeamCheck = false,
    Sensitivity = 0, -- Animation smoothness (0 = instant)
    CircleSides = 64,
    CircleColor = Color3.fromRGB(255,255,255),
    CircleTransparency = 0.7,
    CircleRadius = 80,
    CircleFilled = false,
    CircleVisible = true,
    CircleThickness = 1
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = Settings.CircleRadius
FOVCircle.Filled = Settings.CircleFilled
FOVCircle.Color = Settings.CircleColor
FOVCircle.Visible = Settings.CircleVisible
FOVCircle.NumSides = Settings.CircleSides
FOVCircle.Thickness = Settings.CircleThickness
FOVCircle.Transparency = Settings.CircleTransparency

-- Functions
local function GetClosestPlayer()
    local MaximumDistance = Settings.CircleRadius
    local Target = nil

    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then
                continue
            end

            local Position, OnScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            if OnScreen then
                local Distance = (Vector2.new(Position.X, Position.Y) - FOVCircle.Position).Magnitude
                if Distance < MaximumDistance then
                    MaximumDistance = Distance
                    Target = v
                end
            end
        end
    end
    return Target
end

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Only aim if aiming (Tab is held) and script is enabled
    if aiming and Settings.Enabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(Settings.AimPart) then
            local AimPosition = Target.Character[Settings.AimPart].Position
            local mousePosition = Camera:WorldToViewportPoint(AimPosition)
            mousemoverel((mousePosition.X - Camera.ViewportSize.X / 2) / (1 + Settings.Sensitivity), (mousePosition.Y - Camera.ViewportSize.Y / 2) / (1 + Settings.Sensitivity))
        end
    end
end)
