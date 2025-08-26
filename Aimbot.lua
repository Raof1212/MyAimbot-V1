-- ESP + Aim Assist + Hitbox Extension (LocalScript)
-- Place in StarterPlayerScripts in your own game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------------
-- CONFIG (edit these values)
-------------------------------------------------------
local Config = {
    ESP = {
        Enabled = true,
        ShowName = true,
        ShowHealth = true,
        MaxDistance = 200, -- studs
        BillboardSize = UDim2.fromOffset(120, 40),
    },
    AIM = {
        Enabled = true,
        AimKey = Enum.UserInputType.MouseButton1, -- left mouse
        TargetPart = "Head", -- or "HumanoidRootPart"
        MaxFOV = 200, -- pixels
        Smoothness = 0.18, -- 0 = instant, 1 = very slow
        IgnoreTeam = true,
        RequireVisible = true,
    },
    HITBOX = {
        Enabled = true,
        TargetPart = "Head", -- or "HumanoidRootPart"
        Size = Vector3.new(4, 4, 4),
        Transparency = 0.6,
    }
}

-------------------------------------------------------
-- ESP setup
-------------------------------------------------------
local espData = {}

local function createESP(player)
    if espData[player] then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character or workspace
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.8

    -- Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = Config.ESP.BillboardSize
    billboard.AlwaysOnTop = true
    billboard.Adornee = nil

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.new(0,0,0)

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1,-4,0.5,-2)
    nameLabel.Position = UDim2.new(0,2,0,1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = Color3.new(1,1,1)

    local healthLabel = Instance.new("TextLabel", frame)
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1,-4,0.5,-2)
    healthLabel.Position = UDim2.new(0,2,0.5,0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextScaled = true
    healthLabel.TextColor3 = Color3.new(0,1,0)

    espData[player] = {
        highlight = highlight,
        billboard = billboard,
        name = nameLabel,
        health = healthLabel,
    }
end

local function removeESP(player)
    local data = espData[player]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        espData[player] = nil
    end
end

-------------------------------------------------------
-- Hitbox Extension
-------------------------------------------------------
local function expandHitbox(char)
    if not Config.HITBOX.Enabled then return end
    local part = char:FindFirstChild(Config.HITBOX.TargetPart)
    if part and part:IsA("BasePart") then
        part.Size = Config.HITBOX.Size
        part.Transparency = Config.HITBOX.Transparency
        part.CanCollide = false
    end
end

-------------------------------------------------------
-- Aim Assist
-------------------------------------------------------
local aiming = false

local function getClosestTarget()
    local closest, bestMag = nil, Config.AIM.MaxFOV+1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character or not plr.Character:FindFirstChild(Config.AIM.TargetPart) then continue end
        if Config.AIM.IgnoreTeam and plr.Team == LocalPlayer.Team then continue end

        local target = plr.Character[Config.AIM.TargetPart]
        local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
        if onScreen then
            local mousePos = UserInputService:GetMouseLocation()
            local mag = (Vector2.new(pos.X,pos.Y) - mousePos).Magnitude
            if mag < bestMag and mag <= Config.AIM.MaxFOV then
                closest, bestMag = target, mag
            end
        end
    end
    return closest
end

-------------------------------------------------------
-- Connections
-------------------------------------------------------
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        if Config.ESP.Enabled then createESP(plr) end
        expandHitbox(char)
        if espData[plr] then
            espData[plr].highlight.Parent = char
            espData[plr].highlight.Adornee = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            espData[plr].billboard.Adornee = char:FindFirstChild("Head")
            espData[plr].billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

for _,plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then createESP(plr) end
    if plr.Character then expandHitbox(plr.Character) end
end

-- Aim + ESP loop
RunService.RenderStepped:Connect(function(dt)
    -- Update ESP text
    for plr,data in pairs(espData) do
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local hum = plr.Character.Humanoid
            data.name.Text = (Config.ESP.ShowName and plr.Name) or ""
            data.health.Text = (Config.ESP.ShowHealth and math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)) or ""
        end
    end

    -- Aim assist
    if Config.AIM.Enabled and aiming then
        local target = getClosestTarget()
        if target then
            local cam = Camera.CFrame
            local goal = CFrame.lookAt(cam.Position, target.Position)
            local smooth = 1 - math.clamp(Config.AIM.Smoothness,0,0.99)
            Camera.CFrame = cam:Lerp(goal, smooth * dt * 60)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Config.AIM.AimKey then aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AIM.AimKey then aiming = false end
end)









