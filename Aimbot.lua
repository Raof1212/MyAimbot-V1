-- Exunys Aimbot V3 (Modified: Tab toggle, right-click aim, target lock, crosshair tracking)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- List of teammate usernames to ignore (up to 10)
local TeammatesUsernames = {
    "hamza_x007j",
    "Roben121200",
    "ALG_DZ3",
    "mikey7y77",
    "haithem123k",
    "Player6",
    "Player7",
    "Player8",
    "Player9",
    "Player10",
}

local function IsTeammate(username)
    for _, name in ipairs(TeammatesUsernames) do
        if name == username then
            return true
        end
    end
    return false
end

-- Aimbot Settings
local Aimbot = {
    Enabled = true,
    AimPart = "Head",
    Sensitivity = 1.0, -- 1 is instant, lower is smoother
    Prediction = 0.0,
    MaxRange = 300,
}

local aiming = false
local tabToggle = true

local currentTarget = nil

-- Toggle system with Tab
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Enum.KeyCode.Tab then
            tabToggle = not tabToggle
            print("Aimbot " .. (tabToggle and "Enabled" or "Disabled"))
            if not tabToggle then
                currentTarget = nil -- clear target when aimbot off
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        currentTarget = nil -- stop targeting when right click released
    end
end)

local function IsValidTarget(plr)
    if not plr or not plr.Character or not plr.Character:FindFirstChild(Aimbot.AimPart) or not plr.Character:FindFirstChild("Humanoid") then
        return false
    end
    if plr.Character.Humanoid.Health <= 0 then
        return false
    end
    if IsTeammate(plr.Name) then
        return false
    end
    return true
end

local function GetClosestToCrosshair()
    local bestTarget = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsValidTarget(plr) then
            local head = plr.Character[Aimbot.AimPart]
            local dist3D = (head.Position - myPos).Magnitude
            if dist3D <= Aimbot.MaxRange then
                local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if screenDist < closestDist then
                        closestDist = screenDist
                        bestTarget = plr
                    end
                end
            end
        end
    end

    return bestTarget
end

RunService.RenderStepped:Connect(function()
    if tabToggle and aiming and Aimbot.Enabled then
        -- If no target or target invalid, find new
        if not IsValidTarget(currentTarget) then
            currentTarget = GetClosestToCrosshair()
        end

        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(Aimbot.AimPart) then
            local head = currentTarget.Character[Aimbot.AimPart]
            local predictedPos = head.Position + (head.Velocity * Aimbot.Prediction)
            local aimCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Aimbot.Sensitivity)
        end
    else
        currentTarget = nil
    end
end)

    button.Parent = tabHolder
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1,0,1,0)
    tabFrame.CanvasSize = UDim2.new(0,0,0,0)
    tabFrame.ScrollBarThickness = 6
    tabFrame.BackgroundTransparency = 1
    tabFrame.ClipsDescendants = false
    tabFrame.Visible = false
    tabFrame.Parent = contentFrame

    local listLayout = Instance.new("UIListLayout", tabFrame)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 15)
    end)

    button.MouseButton1Click:Connect(function()
        if currentTab then currentTab.Visible = false end
        tabFrame.Visible = true
        currentTab = tabFrame
    end)

    if not currentTab then
        currentTab = tabFrame
        tabFrame.Visible = true
    end

    tabs[name] = tabFrame
    return tabFrame
end

-- Helpers for controls
local function makeSlider(parent, text, min, max, default)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = text .. ": " .. tostring(default)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,0,0,0)
    label.Size = UDim2.new(1,0,0,20)

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1,0,0,15)
    slider.Position = UDim2.new(0,0,0,22)
    slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
    slider.AutoButtonColor = false

    local bar = Instance.new("Frame", slider)
    bar.Size = UDim2.new((default-min)/(max-min),0,1,0)
    bar.BackgroundColor3 = Color3.fromRGB(100,180,255)
    bar.BorderSizePixel = 0
    bar.Name = "Fill"

    slider.MouseButton1Down:Connect(function(x,y)
        local moveConn, releaseConn
        moveConn = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
                bar.Size = UDim2.new(rel,0,1,0)
                local value = math.floor(min + (max-min)*rel)
                label.Text = text .. ": " .. tostring(value)
            end
        end)
        releaseConn = game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
end

local function makeToggle(parent, text, default)
    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(1,-10,0,30)
    button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    button.Text = text .. ": " .. tostring(default)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(220,220,220)
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0,6)

    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = text .. ": " .. tostring(state)
    end)
end

local function makeDropdown(parent, text, options, default)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,-10,0,30)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = false

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1,0,1,0)
    button.Text = text .. ": " .. default
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(220,220,220)
    button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0,6)

    local dropFrame = Instance.new("Frame", frame)
    dropFrame.Size = UDim2.new(1,0,0,#options*25)
    dropFrame.Position = UDim2.new(0,0,1,0)
    dropFrame.Visible = false
    dropFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    dropFrame.ClipsDescendants = false
    local dropList = Instance.new("UIListLayout", dropFrame)
    dropList.SortOrder = Enum.SortOrder.LayoutOrder

    for _,opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropFrame)
        optBtn.Size = UDim2.new(1,0,0,25)
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 14
        optBtn.TextColor3 = Color3.fromRGB(220,220,220)
        optBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)

        optBtn.MouseButton1Click:Connect(function()
            button.Text = text .. ": " .. opt
            dropFrame.Visible = false
        end)
    end

    button.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
end

-- Build tabs
local movementTab = createTab("Movement")
makeSlider(movementTab,"WalkSpeed",0,200,16)
makeSlider(movementTab,"JumpPower",0,300,50)
makeSlider(movementTab,"Gravity",0,300,196)
makeSlider(movementTab,"Fly Speed",0,200,50)
makeSlider(movementTab,"Walk Method Speed",0,200,16)
makeDropdown(movementTab,"Fly Mode",{"CFrame","Velocity"},"CFrame")
makeDropdown(movementTab,"Walk Method",{"CFrame","Velocity"},"Velocity")
makeToggle(movementTab,"Infinite Jump",true)

createTab("Keybinds")
createTab("Misc")
createTab("Themes")
createTab("Credits")







