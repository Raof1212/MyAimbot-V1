local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to get equipped tool
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

-- Function to zero cooldown values if present
local function RemoveCooldown(tool)
    if not tool then return end

    if tool:FindFirstChild("FireRate") and typeof(tool.FireRate.Value) == "number" then
        tool.FireRate.Value = 10
    end

    if tool:FindFirstChild("ReloadTime") and typeof(tool.ReloadTime.Value) == "number" then
        tool.ReloadTime.Value = 10
    end

    if tool:FindFirstChild("Cooldown") and typeof(tool.Cooldown.Value) == "number" then
        tool.Cooldown.Value = 10
    end

    if tool:FindFirstChild("Auto") and typeof(tool.Auto.Value) == "boolean" then
        tool.Auto.Value = true
    end
end

-- Periodically check equipped tool and remove cooldowns
while true do
    local tool = GetEquippedTool()
    RemoveCooldown(tool)
    wait(0.1) -- Adjust frequency if needed
end

