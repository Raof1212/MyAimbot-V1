-- Exunys Aimbot V3 (Modified: Right-click activation, closest target priority, no FOV circle)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Aimbot Settings
local Aimbot = {
    Enabled = true,
    AimPart = "Head", -- "Head", "UpperTorso", etc.
    TeamCheck = false,
    Sensitivity = 0.08, -- Smoothing (lower is faster)
    Prediction = 0.165, -- Adjust for projectile travel time
    MaxRange = 150 -- Max 3D studs
}

local aiming = false

-- Right-click activation
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Get best target: closest to you AND closest to screen center
local function GetBestTarget()
    local bestTarget = nil
    local closestScreenDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Aimbot.AimPart) and plr.Character:FindFirstChild("Humanoid") then
            if Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end
            if plr.Character.Humanoid.Health <= 0 then
                continue
            end

            local partPos = plr.Character[Aimbot.AimPart].Position
            local dist3D = (partPos - myPos).Magnitude
            if dist3D <= Aimbot.MaxRange then
                local predictedPos = partPos + (plr.Character:FindFirstChild("HumanoidRootPart").Velocity * Aimbot.Prediction)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if screenDist < closestScreenDist then
                        closestScreenDist = screenDist
                        bestTarget = plr
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Main aim loop
RunService.RenderStepped:Connect(function()
    if aiming and Aimbot.Enabled then
        local target = GetBestTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local predictedPos = target.Character[Aimbot.AimPart].Position +
                (target.Character:FindFirstChild("HumanoidRootPart").Velocity * Aimbot.Prediction)
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            -- Smoothly interpolate
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Aimbot.Sensitivity)
        end
    end
end)
