local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration (adjust as needed)
local Aimbot = {
    Enabled = true,
    AimPart = "Head",
    Sensitivity = 0.3,
    Prediction = 0.15
}

local tabToggle = true -- Aimbot ON/OFF toggle with Tab
local aiming = false

-- Input handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Tab then
        tabToggle = not tabToggle
        print("Aimbot " .. (tabToggle and "Enabled" or "Disabled"))
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Utility: Get best target function (closest to center screen)
local function GetBestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.AimPart) then
            local head = player.Character[Aimbot.AimPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = player
                end
            end
        end
    end
    return closestTarget
end

-- Get equipped tool (gun, melee weapon, fists)
local function GetEquippedTool()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

-- Try to spam activate/shoot/hit tool functions to bypass cooldown
local function SpamTool(tool)
    if not tool then return end

    -- Try common attack functions
    if tool.Activate then
        tool:Activate()
    end
    if typeof(tool.Swing) == "function" then
        tool:Swing()
    end
    if typeof(tool.Hit) == "function" then
        tool:Hit()
    end

    -- If tool has a Shoot() method, call it (common for guns)
    if typeof(tool.Shoot) == "function" then
        tool:Shoot()
    end

    -- If tool has FireRate or ReloadTime properties, try to zero them (if they are ValueObjects)
    if tool:FindFirstChild("FireRate") and typeof(tool.FireRate.Value) == "number" then
        tool.FireRate.Value = 0
    end
    if tool:FindFirstChild("ReloadTime") and typeof(tool.ReloadTime.Value) == "number" then
        tool.ReloadTime.Value = 0
    end
    if tool:FindFirstChild("Auto") and typeof(tool.Auto.Value) == "boolean" then
        tool.Auto.Value = true
    end
end

-- Main loop: Run every frame to aim and spam hits
RunService.RenderStepped:Connect(function()
    if tabToggle and aiming and Aimbot.Enabled then
        local target = GetBestTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Aimbot.Sensitivity)
        end

        local tool = GetEquippedTool()
        SpamTool(tool)
    end
end)


