local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

local Aimbot = {
    Enabled = true,
    AimPart = "Head",
    TeamCheck = false,
    Sensitivity = 0.2,       -- Normal tracking speed (smooth & slow)
    SnapSensitivity = 0.8,   -- Fast snap speed when shooting
    MaxRange = 200
}

local aiming = false
local toggle = true
local shooting = false

-- Create the aiming circle UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Ensure it's above all UI

local Circle = Instance.new("Frame")
Circle.Name = "AimCircle"
Circle.Size = UDim2.new(0, 60, 0, 60) -- 60x60 pixels
Circle.Position = UDim2.new(1, -70, 0, 10) -- Top-right corner with 10px margin
Circle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
Circle.BackgroundTransparency = 0.7
Circle.BorderSizePixel = 0
Circle.AnchorPoint = Vector2.new(1, 0) -- Right aligned

-- Make it a circle shape
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Circle

Circle.Parent = ScreenGui
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Function to update circle color based on aimbot state
local function updateCircle()
    if toggle and Aimbot.Enabled then
        Circle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green when enabled
        Circle.BackgroundTransparency = 0.3
    else
        Circle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red when disabled
        Circle.BackgroundTransparency = 0.7
    end
end

updateCircle()

-- Line of sight raycast check
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
            if Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then
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
    if input.KeyCode == Enum.KeyCode.Tab then
        toggle = not toggle
        updateCircle()
        print("Aimbot " .. (toggle and "Enabled" or "Disabled"))
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        shooting = false
    end
end)

RunService.RenderStepped:Connect(function()
    if toggle and aiming and Aimbot.Enabled then
        local target = GetClosestVisibleTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            local aimPos = head.Position
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, aimPos)

            local lerpAmount = shooting and Aimbot.SnapSensitivity or Aimbot.Sensitivity

            Camera.CFrame = currentCFrame:Lerp(targetCFrame, lerpAmount)
        end
    end
end)

