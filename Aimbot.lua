local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local AimbotEnabled = true
local AimKey = Enum.UserInputType.MouseButton1 -- Left Click
local AimPart = "Head"
local FOV = 150
local Smoothness = 0.2
local TeammatesCheck = true

-- ESP Drawing Storage
local ESPObjects = {}

-- Function to draw ESP
function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
    }
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 0, 0)

    esp.Name.Size = 14
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Center = true

    esp.Health.Thickness = 2
    esp.Health.Color = Color3.fromRGB(0, 255, 0)

    ESPObjects[player] = esp
end

-- Remove ESP when player leaves
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end)

-- Update loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local Humanoid = player.Character:FindFirstChild("Humanoid")
            local RootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local Head = player.Character:FindFirstChild("Head")

            local pos, onScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if onScreen then
                local esp = ESPObjects[player] or CreateESP(player)

                -- Box
                esp.Box.Size = Vector2.new(1000 / pos.Z, 2000 / pos.Z)
                esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                esp.Box.Visible = true

                -- Name
                esp.Name.Text = player.Name .. " [" .. math.floor(Humanoid.Health) .. "]"
                esp.Name.Position = Vector2.new(pos.X, pos.Y - esp.Box.Size.Y / 2 - 15)
                esp.Name.Visible = true

                -- Health bar
                esp.Health.From = Vector2.new(pos.X - esp.Box.Size.X / 2 - 5, pos.Y + esp.Box.Size.Y / 2)
                esp.Health.To = Vector2.new(pos.X - esp.Box.Size.X / 2 - 5, pos.Y + esp.Box.Size.Y / 2 - (Humanoid.Health / Humanoid.MaxHealth) * esp.Box.Size.Y)
                esp.Health.Visible = true
            else
                if ESPObjects[player] then
                    ESPObjects[player].Box.Visible = false
                    ESPObjects[player].Name.Visible = false
                    ESPObjects[player].Health.Visible = false
                end
            end
        end
    end
end)

-- Aimbot
function GetClosestTarget()
    local closest, dist = nil, FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            if TeammatesCheck and player.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if mag < dist then
                    dist = mag
                    closest = player.Character[AimPart]
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == AimKey and AimbotEnabled then
        RunService.RenderStepped:Connect(function()
            local target = GetClosestTarget()
            if target then
                local aimPos = Camera:WorldToViewportPoint(target.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local move = (Vector2.new(aimPos.X, aimPos.Y) - mousePos) * Smoothness
                mousemoverel(move.X, move.Y) -- executor function
            end
        end)
    end
end)











