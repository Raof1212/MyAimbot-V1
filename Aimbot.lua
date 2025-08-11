local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

local Aimbot = {
    Enabled = true,
    AimPart = "Head",
    TeamCheck = false,
    Sensitivity = 0.3, -- smaller = smoother
    MaxRange = 200
}

local aiming = false
local toggle = true

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDist = math.huge
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
            local dist = (head.Position - myPos).Magnitude
            if dist <= Aimbot.MaxRange then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if screenDist < shortestDist then
                        shortestDist = screenDist
                        closestTarget = plr
                    end
                end
            end
        end
    end
    return closestTarget
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Tab then
        toggle = not toggle
        print("Aimbot " .. (toggle and "Enabled" or "Disabled"))
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function()
    if toggle and aiming and Aimbot.Enabled then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
            local head = target.Character[Aimbot.AimPart]
            local aimPos = head.Position
            local newCFrame = CFrame.new(Camera.CFrame.Position, aimPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Aimbot.Sensitivity)
        end
    end
end)

-- Redirect mouse aim to head on left click
mouse.Button1Down:Connect(function()
    if not toggle or not Aimbot.Enabled then return end
    local target = GetClosestTarget()
    if target and target.Character and target.Character:FindFirstChild(Aimbot.AimPart) then
        local head = target.Character[Aimbot.AimPart]
        -- This sets mouse.TargetFilter to ignore the target's character so the game registers aiming at their head
        mouse.TargetFilter = target.Character
        -- Note: This only visually redirects your aim.
        -- Actual damage depends on server-side hit detection.
    end
end)


