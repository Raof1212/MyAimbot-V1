-- Exunys Aimbot V3 (Modified: Right-click to aim only, FOV circle removed, dual priority targeting)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    Enabled = true,
    AimPart = "Head", -- Default aim part
    TeamCheck = false,
    Sensitivity = 0, -- 0 = instant
    MaxRange = 150 -- Maximum 3D studs distance
}

-- Aim control (Right mouse button = MouseButton2)
local aiming = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Function to get best target
local function GetBestTarget()
    local bestTarget = nil
    local closestScreenDist = math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

    if not myPos then return nil end

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then
                continue
            end

            local partPos = v.Character[Settings.AimPart].Position
            local dist3D = (partPos - myPos).Magnitude

            if dist3D <= Settings.MaxRange then
                local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    -- Prioritize closer to screen center
                    if screenDist < closestScreenDist then
                        closestScreenDist = screenDist
                        bestTarget = v
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if aiming and Settings.Enabled then
        local target = GetBestTarget()
        if target and target.Character and target.Character:FindFirstChild(Settings.AimPart) then
            local aimPos = target.Character[Settings.AimPart].Position
            local screenPos = Camera:WorldToViewportPoint(aimPos)
            mousemoverel((screenPos.X - Camera.ViewportSize.X / 2) / (1 + Settings.Sensitivity),
                         (screenPos.Y - Camera.ViewportSize.Y / 2) / (1 + Settings.Sensitivity))
        end
    end
end)
