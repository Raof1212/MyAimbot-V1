local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local tabToggle = true -- toggle ON/OFF with Tab key
local aiming = false

-- Input handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Tab then
        tabToggle = not tabToggle
        print("Auto-attack " .. (tabToggle and "Enabled" or "Disabled"))
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

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

-- Spam attack functions to bypass cooldowns
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

    -- For guns: call Shoot() if it exists
    if typeof(tool.Shoot) == "function" then
        tool:Shoot()
    end

    -- Try to zero cooldown properties if present
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

-- Main loop: spam attack every frame when toggled on and aiming
RunService.RenderStepped:Connect(function()
    if tabToggle and aiming then
        local tool = GetEquippedTool()
        SpamTool(tool)
    end
end)

