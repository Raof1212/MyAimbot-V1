-- CombinedServer_AllPlayers.lua
-- Put this Script into ServerScriptService in your own private place.
-- This script expands hitboxes server-side for all players and injects
-- a LocalScript into each player's PlayerGui that provides ESP + AimAssist.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

----------------------------------------------------------------
-- CONFIG (edit values here)
----------------------------------------------------------------
local Config = {
    -- Hitbox (server-side)
    HITBOX = {
        Enabled = true,
        TargetPart = "Head", -- "Head" or "HumanoidRootPart"
        Size = Vector3.new(5, 5, 5),
        Transparency = 0.6,
    },

    -- Client-side ESP settings (mirrored into client script automatically)
    ESP = {
        Enabled = true,
        ShowName = true,
        ShowHealth = true,
        MaxDistance = 300, -- studs
        BillboardSizeW = 140, -- used to create UDim2.fromOffset(w,h)
        BillboardSizeH = 48,
        NameOffsetY = 2.2,
    },

    -- Client-side Aim settings (mirrored into client script automatically)
    AIM = {
        Enabled = true,
        AimKey = "MouseButton1", -- valid: "MouseButton1","MouseButton2","KeyboardButton" etc. (client maps to Enum.UserInputType)
        TargetPart = "Head",
        MaxFOV = 220, -- pixels radius from cursor
        Smoothness = 0.18, -- 0 = instant snap, 1 = very slow
        IgnoreTeam = true,
        RequireVisible = true,
    }
}

----------------------------------------------------------------
-- Utility: serialize Config to Lua source for client injection
----------------------------------------------------------------
local function serializeValue(v, indent)
    indent = indent or ""
    local t = typeof(v)
    if t == "number" then
        return tostring(v)
    elseif t == "string" then
        return ("%q"):format(v)
    elseif t == "boolean" then
        return v and "true" or "false"
    elseif t == "Vector3" then
        return ("Vector3.new(%s,%s,%s)"):format(v.X, v.Y, v.Z)
    elseif t == "table" then
        local parts = {}
        parts[#parts+1] = "{"
        local nextIndent = indent .. "    "
        for key, val in pairs(v) do
            local keyRep
            if type(key) == "string" and key:match("^%a[%w_]*$") then
                keyRep = key
            else
                keyRep = "[" .. serializeValue(key) .. "]"
            end
            parts[#parts+1] = nextIndent .. keyRep .. " = " .. serializeValue(val, nextIndent) .. ","
        end
        parts[#parts+1] = indent .. "}"
        return table.concat(parts, "\n")
    else
        -- fallback: tostring
        return ("%q"):format(tostring(v))
    end
end

local clientConfigLua = "local Config = " .. serializeValue({
    ESP = {
        Enabled = Config.ESP.Enabled,
        ShowName = Config.ESP.ShowName,
        ShowHealth = Config.ESP.ShowHealth,
        MaxDistance = Config.ESP.MaxDistance,
        BillboardSizeW = Config.ESP.BillboardSizeW,
        BillboardSizeH = Config.ESP.BillboardSizeH,
        NameOffsetY = Config.ESP.NameOffsetY,
    },
    AIM = {
        Enabled = Config.AIM.Enabled,
        AimKey = Config.AIM.AimKey,
        TargetPart = Config.AIM.TargetPart,
        MaxFOV = Config.AIM.MaxFOV,
        Smoothness = Config.AIM.Smoothness,
        IgnoreTeam = Config.AIM.IgnoreTeam,
        RequireVisible = Config.AIM.RequireVisible,
    }
}) .. "\n\n"

----------------------------------------------------------------
-- Client LocalScript source (will be injected into PlayerGui for each player)
-- Note: the 'Config' table is injected above into this source
----------------------------------------------------------------
local clientSource = clientConfigLua .. [[
-- Injected client LocalScript: ESP + AimAssist
-- This code runs as a LocalScript inside each player's PlayerGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- map AimKey string to enum; support common names:
local function mapAimKey(name)
    if name == "MouseButton1" then return Enum.UserInputType.MouseButton1 end
    if name == "MouseButton2" then return Enum.UserInputType.MouseButton2 end
    if name == "Touch" then return Enum.UserInputType.Touch end
    -- for keyboards, user can pass string like "KeyboardKey_E"; we fallback to MouseButton1
    return Enum.UserInputType.MouseButton1
end

-- Derived config values
local AIM_KEY = mapAimKey(Config.AIM.AimKey)
local BILLBOARD_SIZE = UDim2.fromOffset(Config.ESP.BillboardSizeW, Config.ESP.BillboardSizeH)

-- Storage
local espData = {} -- player -> {highlight, billboard, nameLabel, healthLabel}

-- Helper: safe create highlight + billboard for a player's character
local function ensureESPForPlayer(player)
    if espData[player] then return espData[player] end
    local data = {}

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.8

    -- BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = BILLBOARD_SIZE
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, Config.ESP.NameOffsetY, 0)
    billboard.Adornee = nil

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.45
    frame.BackgroundColor3 = Color3.new(0,0,0)

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, -6, 0.5, -2)
    nameLabel.Position = UDim2.new(0, 3, 0, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0.7

    local healthLabel = Instance.new("TextLabel", frame)
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1, -6, 0.5, -2)
    healthLabel.Position = UDim2.new(0, 3, 0.5, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextScaled = true
    healthLabel.TextColor3 = Color3.new(0,1,0)
    healthLabel.TextStrokeTransparency = 0.7

    data.highlight = highlight
    data.billboard = billboard
    data.nameLabel = nameLabel
    data.healthLabel = healthLabel

    espData[player] = data
    return data
end

-- Cleanup
local function removeESPForPlayer(player)
    local d = espData[player]
    if not d then return end
    if d.highlight and d.highlight.Parent then pcall(function() d.highlight:Destroy() end) end
    if d.billboard and d.billboard.Parent then pcall(function() d.billboard:Destroy() end) end
    espData[player] = nil
end

-- When character appears, parent GUI elements
local function onCharacterAddedForPlayer(player, character)
    if not Config.ESP.Enabled then return end
    local d = ensureESPForPlayer(player)
    -- Parent highlight & billboard onto the character and PlayerGui respectively
    d.highlight.Parent = character
    d.highlight.Adornee = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

    d.billboard.Adornee = character:FindFirstChild("Head") or character.PrimaryPart
    d.billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- apply to existing players
for _, pl in ipairs(Players:GetPlayers()) do
    if pl ~= LocalPlayer then
        if pl.Character then onCharacterAddedForPlayer(pl, pl.Character) end
        pl.CharacterAdded:Connect(function(ch) onCharacterAddedForPlayer(pl, ch) end)
    end
end

-- watch for players added/removed
Players.PlayerAdded:Connect(function(pl)
    if pl == LocalPlayer then return end
    pl.CharacterAdded:Connect(function(ch) onCharacterAddedForPlayer(pl, ch) end)
end)
Players.PlayerRemoving:Connect(function(pl)
    removeESPForPlayer(pl)
end)

-- Utility: world->screen check
local function worldToScreen(pos)
    local p = Camera:WorldToViewportPoint(pos)
    return Vector2.new(p.X, p.Y), p.Z > 0
end

-- Visibility check (raycast from camera to target part)
local function isVisibleToClient(targetPart)
    if not Config.AIM.RequireVisible then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true
    local res = workspace:Raycast(origin, dir, rayParams)
    if not res then return true end
    return res.Instance:IsDescendantOf(targetPart.Parent)
end

-- find closest valid target to cursor within FOV and distance
local function getClosestTargetToCursor()
    local best, bestMag = nil, Config.AIM.MaxFOV + 1
    local mousePos = UserInputService:GetMouseLocation()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        if Config.AIM.IgnoreTeam then
            if pl.Team == LocalPlayer.Team then continue end
        end
        local ch = pl.Character
        if not ch then continue end
        local part = ch:FindFirstChild(Config.AIM.TargetPart)
        if not part or not part:IsA("BasePart") then continue end
        local screenPos, onScreen = worldToScreen(part.Position)
        if not onScreen then continue end
        local mag = (screenPos - mousePos).Magnitude
        if mag <= Config.AIM.MaxFOV and mag < bestMag then
            if not isVisibleToClient(part) then
                if Config.AIM.RequireVisible then continue end
            end
            if (part.Position - Camera.CFrame.Position).Magnitude > Config.ESP.MaxDistance then
                continue
            end
            best = part
            bestMag = mag
        end
    end
    return best
end

-- Aim assist state
local aiming = false

-- Smooth look-at helper (lerp camera toward target)
local function smoothLookAt(targetPos, dt)
    local cam = Camera.CFrame
    local goal = CFrame.lookAt(cam.Position, targetPos)
    local smooth = 1 - math.clamp(Config.AIM.Smoothness, 0, 0.99)
    Camera.CFrame = cam:Lerp(goal, smooth * dt * 60)
end

-- Input
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType[Config.AIM.AimKey] or inp.UserInputType == mapAimKey then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType[Config.AIM.AimKey] then
        aiming = false
    end
end)

-- Render loop: update ESP labels & aim assist
RunService.RenderStepped:Connect(function(dt)
    -- update ESP labels (name, health)
    if Config.ESP.Enabled then
        for pl, d in pairs(espData) do
            if not pl or not pl.Character then
                if d then
                    removeESPForPlayer(pl)
                end
            else
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    d.nameLabel.Text = (Config.ESP.ShowName and pl.Name) and pl.Name or ""
                    d.healthLabel.Text = (Config.ESP.ShowHealth and hum.Health and tostring(math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)) ) or ""
                end
            end
        end
    end

    -- aim assist
    if Config.AIM.Enabled and aiming then
        local targetPart = getClosestTargetToCursor()
        if targetPart and targetPart.Parent then
            smoothLookAt(targetPart.Position, dt)
        end
    end
end)
]]

----------------------------------------------------------------
-- Server-side hitbox expansion and LocalScript injection
----------------------------------------------------------------

-- Function to expand target part safely (preserves original values if present)
local function expandPartSafe(part, size, transparency)
    if not part or not part:IsA("BasePart") then return end
    -- store original if not stored
    if not part:FindFirstChild("___orig_size") then
        local v = Instance.new("Vector3Value")
        v.Name = "___orig_size"
        v.Value = part.Size
        v.Parent = part
    end
    if not part:FindFirstChild("___orig_trans") then
        local n = Instance.new("NumberValue")
        n.Name = "___orig_trans"
        n.Value = part.Transparency
        n.Parent = part
    end
    -- apply
    part.Size = size
    part.Transparency = transparency
    part.CanCollide = false
end

local function onCharacterAddedServer(character)
    if not Config.HITBOX.Enabled then return end
    task.wait(0.05)
    local target = character:FindFirstChild(Config.HITBOX.TargetPart)
    if target and target:IsA("BasePart") then
        expandPartSafe(target, Config.HITBOX.Size, Config.HITBOX.Transparency)
    end
end

local function onPlayerAddedServer(player)
    -- Connect to future characters
    player.CharacterAdded:Connect(onCharacterAddedServer)
    if player.Character then
        onCharacterAddedServer(player.Character)
    end

    -- Inject the client LocalScript into the player's PlayerGui
    -- Create new LocalScript and set its Source to 'clientSource' above
    local ok, err = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local ls = Instance.new("LocalScript")
        ls.Name = "ESP_Aim_ClientInjected"
        ls.Source = clientSource
        ls.Parent = playerGui
    end)
    if not ok then
        warn("Failed to inject client LocalScript for player", player.Name, err)
    end
end

-- Connect players
Players.PlayerAdded:Connect(onPlayerAddedServer)
for _, pl in ipairs(Players:GetPlayers()) do
    onPlayerAddedServer(pl)
end

-- Optional: restore parts when player leaves (cleanup)
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        local target = player.Character:FindFirstChild(Config.HITBOX.TargetPart)
        if target then
            local orig = target:FindFirstChild("___orig_size")
            local otr = target:FindFirstChild("___orig_trans")
            if orig then
                target.Size = orig.Value
                orig:Destroy()
            end
            if otr then
                target.Transparency = otr.Value
                otr:Destroy()
            end
        end
    end
end)

print("CombinedServer_AllPlayers.lua loaded. Config loaded and injection enabled.")





