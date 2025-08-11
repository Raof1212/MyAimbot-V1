local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Aimbot Settings
local Aimbot = {
    Enabled = true, -- Master toggle, changed via Tab
    AimPart = "Head", -- Always target head
    TeamCheck = true, -- Use teammates list instead of team enum
    Prediction = 0.0, -- Projectile prediction (unused here)
    MaxRange = 150
}

local aiming = false -- Active while right-click held
local tabToggle = true -- Master ON by default

-- 10 slots for teammates by username (empty strings = unused)
local Teammates = {
    "Player1",
    "Player2",
    "Player3",
    "Player4",
    "Player5",
    "Player6",
    "Player7",
    "Player8",
    "Player9",
    "Player10"
}

-- Store markers for enemies behind walls
local markers = {}

-- Check if player is in teammates list
local function isTeammate(player)
    for _, name in ipairs(Teammates) do
        if name ~= "" and player.Name == name then
            return true
        end
    end
    return false
end

-- Check line of sight (raycast)
local function hasLineOfSight(origin, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local direction = (targetPos - origin)
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)

    if not raycastResult then
        return true -- nothing blocking
    end

    local hitPart = raycastResult.Instance
    if hitPart and hitPart:IsDescendantOf(LocalPlayer.Character) then
        return true
    end

    local distToTarget = (targetPos - origin).Magnitude
    local distToHit = (raycastResult.Position - origin).Magnitude
    if distToHit + 0.1 >= distToTarget then
        return true
    end

    return false
end

-- Create or update red dot marker above enemy's head
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
        if markers[player] then
            markers[player]:Destroy()
            markers[player] = nil
        end
    else
        if not markers[player] then
            local marker = Instance.new("BillboardGui")
            marker.Name = "WallMarker"
            marker.Adornee = head
            marker.Size = UDim2.new(0, 15, 0, 15)
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

-- Get best visible target excluding teammates
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
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        local score = dist3D + (screenDist / 50)
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

-- Input listeners
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

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update markers for all players
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

    -- Aim instantly at best visible target when aiming
    if tabToggle and aiming and Aimbot.Enabled then
        local target = GetBestTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)



