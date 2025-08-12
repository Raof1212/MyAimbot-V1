-- Exunys Aimbot V3 (Modified: Tab toggle, right-click aim, target lock, crosshair tracking)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- List of teammate usernames to ignore (up to 10)
local TeammatesUsernames = {
    "hamza_x007j",
    "Roben121200",
    "ALG_DZ3",
    "mikey7y77",
    "haithem123k",
    "Player6",
    "Player7",
    "Player8",
    "Player9",
    "Player10",
}

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
    Enabled = true,
    AimPart = "Head",
    Sensitivity = 1.0, -- 1 is instant, lower is smoother
    Prediction = 0.0,
    MaxRange = 300,
}

local aiming = false
local tabToggle = true

local currentTarget = nil

-- Toggle system with Tab
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Enum.KeyCode.Tab then
            tabToggle = not tabToggle
            print("Aimbot " .. (tabToggle and "Enabled" or "Disabled"))
            if not tabToggle then
                currentTarget = nil -- clear target when aimbot off
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        currentTarget = nil -- stop targeting when right click released
    end
end)

local function IsValidTarget(plr)
    if not plr or not plr.Character or not plr.Character:FindFirstChild(Aimbot.AimPart) or not plr.Character:FindFirstChild("Humanoid") then
        return false
    end
    if plr.Character.Humanoid.Health <= 0 then
        return false
    end
    if IsTeammate(plr.Name) then
        return false
    end
    return true
end

local function GetClosestToCrosshair()
    local bestTarget = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsValidTarget(plr) then
            local head = plr.Character[Aimbot.AimPart]
            local dist3D = (head.Position - myPos).Magnitude
            if dist3D <= Aimbot.MaxRange then
                local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if screenDist < closestDist then
                        closestDist = screenDist
                        bestTarget = plr
                    end
                end
            end
        end
    end

    return bestTarget
end

RunService.RenderStepped:Connect(function()
    if tabToggle and aiming and Aimbot.Enabled then
        -- If no target or target invalid, find new
        if not IsValidTarget(currentTarget) then
            currentTarget = GetClosestToCrosshair()
        end

        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(Aimbot.AimPart) then
            local head = currentTarget.Character[Aimbot.AimPart]
            local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Aimbot.Sensitivity)
        end
    else
        currentTarget = nil
    end
end)













