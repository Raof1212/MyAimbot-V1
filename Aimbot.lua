-- LocalScript in StarterPlayerScripts
-- Raof v1 Dashboard

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaofDashboard"
screenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "Raof v1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

-- UIListLayout for sections
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainFrame

-- Utility function: Create Section
local function createSection(name)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -20, 0, 80)
	section.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	section.BorderSizePixel = 0
	section.Parent = mainFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = section

	return section
end

-- Utility function: Create Toggle
local function createToggle(section, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 30)
	button.Position = UDim2.new(0, 10, 0, 25)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.Text = text .. " [OFF]"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = section

	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = text .. (state and " [ON]" or " [OFF]")
		if callback then
			callback(state)
		end
	end)
end

-- ESP Section
local espSection = createSection("ESP Settings")
createToggle(espSection, "Enable ESP", function(state)
	print("ESP toggled:", state)
end)

-- Aimbot Section
local aimbotSection = createSection("Aimbot Settings")
createToggle(aimbotSection, "Enable Aimbot", function(state)
	print("Aimbot toggled:", state)
end)

-- Hitbox Section
local hitboxSection = createSection("Hitbox Settings")
createToggle(hitboxSection, "Extend Hitbox", function(state)
	print("Hitbox toggled:", state)
end)

-- Keybind: Show/Hide UI (LeftCtrl)
UserInputService.InputBegan:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		mainFrame.Visible = not mainFrame.Visible
	end
end)





