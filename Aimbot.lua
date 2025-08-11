local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Aimbot = {
    Enabled = true,
    AimPart = "Head",
    Sensitivity = 0.15,       -- Smooth tracking speed
    SnapSensitivity = 1,      -- Instant snap on shoot
    MaxRange = 200,
}

-- Add your teammates' names here (up to 10 slots)
local Teammates = {
    "PlayerName1", -- slot 1
    "PlayerName2", -- slot 2
    "PlayerName3", -- slot 3
    "PlayerName4", -- slot 4
    "PlayerName5", -- slot 5
    "PlayerName6", -- slot 6
    "PlayerName7", -- slot 7
    "PlayerName8", -- slot 8
    "PlayerName9", -- slot 9
    "PlayerName10" -- slot 10
}

local aiming = false
local toggle = false -- Start disabled
local shooting = false

-- UI Dot Indicator (12x12 green dot)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Dot = Instance.new("Frame")
Dot.Name = "AimDot"
Dot.Size = UDim2.new(0, 12, 0, 12)
Dot.Position = UDim2.new(1, -20, 0, 10)
Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Dot.BorderSizePixel = 0
Dot.AnchorPoint = Vector2.new(1, 0)
Dot.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Dot

Dot.Parent = ScreenGui
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function updateDot()
    Dot.Visible = toggle and Aimbot.Enabled
end

local function isTeammate(player)
    for _, name in ipairs(Teammates) do
        if player.Name == name then
            return true
        end
    end
    return false
end

local function hasLineOfSight(origin, targetPos, ignoreList)
    ignoreList = ignoreList or {}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local direction = (targetPos - origin)
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)

    if not raycastResult then
        return true
    end

    local hitPart = raycastResult.Instance
    if hitPart and hitPart:IsDescendantOf(LocalPlayer.Character) then
        return true
    end

    if hitPart then
        local distanceToTarget = (targetPos - origin).Magnitude
        local distanceToHit = (raycastResult.Position - origin).Magnitude
        if distanceToHit + 0.1 >= distanceToTarget then
            return true
        end
    end

    return false
end

local function GetClosestVisibleTarget()
    local bestTarget = nil
    local shortestScore = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Aimbot.AimPart) and plr.Character:FindFirstChild("Humanoid") then
            if isTeammate(plr) then
                continue
            end
            if plr.Character.Humanoid.Health <= 0 then
                continue
            end

            local head = plr.Character[Aimbot.AimPart]
            local dist3D = (head.Position - myPos).Magnitude
            if dist3D <= Aimbot.MaxRange then
                if hasLineOfSight(myChar.HumanoidRootPart.Position, head.Position, {myChar}) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local score = dist3D + (screenDist / 50)
                        if score < shortestScore then
                            shortestScore = score
                            bestTarget = plr
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt then
        toggle = not toggle
        updateDot()
        print("Aimbot " .. (toggle and "Enabled" or "Disabled"))
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
        updateDot()
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = true
        updateDot()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        updateDot()
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = false
        updateDot()
    end
end)

RunService.RenderStepped:Connect(function()
    if toggle and Aimbot.Enabled and (aiming or shooting) then
        local target = GetClosestVisibleTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            local aimPos = head.Position
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, aimPos)

            if shooting then
                -- Instant snap to head when shooting
                Camera.CFrame = targetCFrame
            else
                -- Smooth tracking when aiming only
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, Aimbot.Sensitivity)
            end
        end
    end
end)


