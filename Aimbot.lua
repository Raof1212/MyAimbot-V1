-- Roben V1 UI (Scrollable + Dropdown Fix)

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Destroy old GUI if it exists
if playerGui:FindFirstChild("RobenV1") then
    playerGui.RobenV1:Destroy()
end

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RobenV1"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- UICorner + Shadow
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel")
title.Text = "Roben V1"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(220,220,220)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 15, 0, 10)
title.Size = UDim2.new(0, 200, 0, 25)
title.Parent = mainFrame

-- Tab Buttons Holder
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(0, 120, 1, -40)
tabHolder.Position = UDim2.new(0, 0, 0, 40)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = mainFrame

local tabList = Instance.new("UIListLayout", tabHolder)
tabList.Padding = UDim.new(0, 6)
tabList.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Holder
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -130, 1, -40)
contentFrame.Position = UDim2.new(0, 130, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = false
contentFrame.Parent = mainFrame

-- Tab system
local tabs = {}
local currentTab = nil

local function createTab(name)
    local button = Instance.new("TextButton")
    button.Text = name
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.fromRGB(220,220,220)
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(35,35,35)
    button.AutoButtonColor = true
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






