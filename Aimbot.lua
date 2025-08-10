-- Find the equipped gun/tool (this part depends on your game, adjust path)
local function GetCurrentGun()
    local character = LocalPlayer.Character
    if not character then return nil end

    -- Usually gun/tool is a child of the character and is a Tool instance
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            -- Here you might check tool name or properties to confirm it's a gun
            return tool
        end
    end
    return nil
end

-- Hook into gun firing to remove cooldown and auto-fire
local gun = nil
local oldShoot = nil

local function HookGun()
    gun = GetCurrentGun()
    if not gun then return end

    -- Assume gun has a 'Shoot' function, adjust if different
    if gun:FindFirstChild("Shoot") and typeof(gun.Shoot) == "function" then
        if not oldShoot then
            oldShoot = gun.Shoot
            gun.Shoot = function(...)
                return oldShoot(...)
            end
        end
    end

    -- Remove cooldowns if available (adjust property names)
    if gun:FindFirstChild("FireRate") then
        gun.FireRate.Value = 0
    end
    if gun:FindFirstChild("ReloadTime") then
        gun.ReloadTime.Value = 0
    end
    if gun:FindFirstChild("Auto") then
        gun.Auto.Value = true
    end
end

-- Auto fire when aiming
RunService.RenderStepped:Connect(function()
    if tabToggle and aiming and Aimbot.Enabled then
        -- Aim part (your existing code)
        local target = GetBestTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Aimbot.Sensitivity)
        end

        -- Hook gun every frame to handle tool switching
        HookGun()

        -- Try to shoot if gun and Shoot method available
        if gun and gun.Shoot then
            gun:Shoot() -- Fire every frame while aiming, no cooldown
        end
    else
        gun = nil
        oldShoot = nil
    end
end)





