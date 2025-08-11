local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function setHighSpeed(speed)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end

-- Apply speed initially
setHighSpeed(100)

-- Reapply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    setHighSpeed(100)
end)

