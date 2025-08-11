local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Aimbot = {
    Enabled = true,
    AimPart = "Head",
    TeamCheck = true, -- enable team check by default
    Sensitivity = 11111,
    Prediction = 0.0,
    MaxRange = 150,
}

local aiming = false
local tabToggle = true -- aimbot ON by default

-- Teammates 10 slots list, fill with teammates’ Roblox usernames or leave empty ("")
local Teammates = {
    "PlayerName1",
    "PlayerName2",
    "PlayerName3",
    "PlayerName4",
    "PlayerName5",
    "PlayerName6",
    "PlayerName7",
    "PlayerName8",
    "PlayerName9",
    "PlayerName10"
}

-- Store markers for enemies behind walls
local markers = {}

-- Function to check if player is a teammate by name
local function isTeammate(player)
    for _, name in ipairs(Teammates) do
        if name ~= "" and player.Name == name then
            return true
        end
    end
    return false
end

-- Check line of sight between two points (ignore character parts)
local function hasLineOfSight(origin, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local direction = (targetPos - origin)
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)

    if not raycastResult then
        return true -- nothing blocking line
    end

    local hitPart = raycastResult.Instance
    if hitPart and hitPart:IsDescendantOf(LocalPlayer.Character) then
        return true
    end

    -- Check if hit position is very close to target (tolerance 0.1)
    local distToTarget = (targetPos - origin).Magnitude
    local distToHit = (raycastResult.Position - origin).Magnitude
    if distToHit + 0.1 >= distToTarget then
        return true
    end

    return false
end

-- Create or update marker (a small red dot) above enemy heads behind walls
local function updateMarkerForPlayer(player)
    if not player.Character or not player.Character:FindFirstChild(Aimbot.AimPart) then
        if markers[player] then
            markers[player]:Destroy()
            markers[player] = nil
        end
        return
    end

    local head = player.Character[Aimbot.AimPart]
    local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not origin then return end

    local visible = hasLineOfSight(origin, head.Position)

    if visible then
        -- Enemy is visible, remove marker if exists
        if markers[player] then
            markers[player]:Destroy()
            markers[player] = nil
        end
    else
        -- Enemy behind wall, create or update marker
        if not markers[player] then
            local marker = Instance.new("BillboardGui")
            marker.Name = "WallMarker"
            marker.Adornee = head
            marker.Size = UDim2.new(0, 20, 0, 20)
            marker.StudsOffset = Vector3.new(0, 0.5, 0)
            marker.AlwaysOnTop = true

            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- red dot
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BorderSizePixel = 0
            frame.Parent = marker

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = frame

            marker.Parent = player.Character
            markers[player] = marker
        end
    end
end

-- Get best target who is visible and not teammate, within range
local function GetBestTarget()
    local bestTarget = nil
    local closestScore = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
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
                if hasLineOfSight(myPos, head.Position) then
                    local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
                    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local score = dist3D + (screenDist / 50) -- weight center more
                        if score < closestScore then
                            closestScore = score
                            bestTarget = plr
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- Handle input toggling and aiming state
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

-- Main loop, update markers and aim if toggled
RunService.RenderStepped:Connect(function()
    -- Update markers for all players except teammates and local player
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Aimbot.AimPart) then
            if not isTeammate(plr) and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                updateMarkerForPlayer(plr)
            elseif markers[plr] then
                markers[plr]:Destroy()
                markers[plr] = nil
            end
        end
    end

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




