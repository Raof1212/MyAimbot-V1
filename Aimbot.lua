-- Exunys Aimbot V3 (Modified: Tab toggle, right-click aim, smooth head-lock)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- List of teammate usernames to ignore (up to 10)
local TeammatesUsernames = {
    "Player1",
    "Player2",
    "Player3",
    "Player4",
    "Player5",
    "Player6",
    "Player7",
    "Player8",
    "Player9",
    "Player10",
}

-- Helper function to check if a player username is in the teammates list
local function IsTeammate(username)
    for _, name in ipairs(TeammatesUsernames) do
        if name == username then
            return true
        end
    end
    return false
end

-- Aimbot Settings
local Aimbot = {
    Enabled = true, -- Master toggle, changed via Tab
    AimPart = "Head", -- Always target head
    Sensitivity = 1.00, -- Lower = smoother (0.03–0.06 recommended)
    Prediction = 0.0, -- Adjust for projectile travel time
    MaxRange = 150
}

local aiming = false -- Active while right-click held
local tabToggle = true -- Master ON by default

-- Toggle system with Tab
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Enum.KeyCode.Tab then
            tabToggle = not tabToggle
            print("Aimbot " .. (tabToggle and "Enabled" or "Disabled"))
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Find player whose head is closest to screen center (with max range check)
local function GetBestTarget()
    local bestTarget = nil
    local closestScreenDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Aimbot.AimPart) and plr.Character:FindFirstChild("Humanoid") then
            if IsTeammate(plr.Name) then
                continue
            end
            if plr.Character.Humanoid.Health <= 0 then
                continue
            end

            local head = plr.Character[Aimbot.AimPart]
            local dist3D = (head.Position - myPos).Magnitude
            if dist3D <= Aimbot.MaxRange then
                local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
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

-- Main loop
RunService.RenderStepped:Connect(function()
    if tabToggle and aiming and Aimbot.Enabled then
        local target = GetBestTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Aimbot.Sensitivity)
        end
    end
end)



