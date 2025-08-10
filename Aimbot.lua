-- Exunys Aimbot V3 (Modified: Mouse Button 4 to aim only, FOV circle removed)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    Enabled = true,
    AimPart = "Head", -- Keep all hitbox options; default is Head
    TeamCheck = false,
    Sensitivity = 0, -- 0 = instant
    CircleRadius = 80 -- Still used for target range
}

-- Aim control (Mouse Button 4 = Forward side button)
local aiming = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton4 then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton4 then
        aiming = false
    end
end)

-- Function to get closest target
local function GetClosestPlayer()
    local MaximumDistance = Settings.CircleRadius
    local Target = nil

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then
                continue
            end

            local Position, OnScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            if OnScreen then
                local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
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
    if aiming and Settings.Enabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(Settings.AimPart) then
            local AimPosition = Target.Character[Settings.AimPart].Position
            local mousePosition = Camera:WorldToViewportPoint(AimPosition)
            mousemoverel((mousePosition.X - Camera.ViewportSize.X / 2) / (1 + Settings.Sensitivity),
                         (mousePosition.Y - Camera.ViewportSize.Y / 2) / (1 + Settings.Sensitivity))
        end
    end
end)
