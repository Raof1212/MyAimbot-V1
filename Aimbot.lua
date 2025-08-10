local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local aiming = false
local tabToggle = true -- Assuming toggle is ON by default like your aimbot

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

-- Function to get equipped tool (melee or otherwise)
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

-- Try to spam activate the tool every frame while aiming & aimbot enabled
RunService.RenderStepped:Connect(function()
    if tabToggle and aiming then
        local tool = GetEquippedTool()
        if tool then
            -- If tool has Activate method, call it (common for melee tools)
            if tool.Activate then
                tool:Activate()
            end

            -- If tool has 'Swing' or 'Hit' function (custom), try those too:
            if typeof(tool.Swing) == "function" then
                tool:Swing()
            end
            if typeof(tool.Hit) == "function" then
                tool:Hit()
            end
        end
    end
end)

