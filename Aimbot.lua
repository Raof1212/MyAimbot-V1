-- LocalScript in StarterPlayerScripts
-- Raof v1 Dashboard (Expanded with Buttons & Keybinds)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaofDashboard"
screenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main Frame (bigger now)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
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
title.TextSize = 22
title.Parent = mainFrame

-- UIListLayout for sections
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainFrame

-- Utility function: Create Section
local function createSection(name, height)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -20, 0, height or 100)
	section.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	section.BorderSizePixel = 0
	section.Parent = mainFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 25)
	label.Position = UDim2.new(0, 5, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = section

	return section
end

-- Utility function: Create Button Toggle
local function createButton(section, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 0, 35)
	button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = section

	local enabled = false
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		if enabled then
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- green when ON
			button.Text = text .. " [ON]"
		else
			button.BackgroundColor3 = Color3.fromRGB(70, 70, 70) -- grey when OFF
			button.Text = text .. " [OFF]"
		end
		if callback then
			callback(enabled)
		end
	end)
end

-- ESP Section
local espSection = createSection("ESP Settings")
createButton(espSection, "Enable ESP", function(state)
	print("ESP:", state)
end)

-- Aimbot Section
local aimbotSection = createSection("Aimbot Settings")
createButton(aimbotSection, "Enable Aimbot", function(state)
	print("Aimbot:", state)
end)

-- Hitbox Section
local hitboxSection = createSection("Hitbox Settings")
createButton(hitboxSection, "Extend Hitbox", function(state)
	print("Hitbox:", state)
end)

-- Keybinds Section
local keybindsSection = createSection("Keybinds", 130)

-- Example Keybind Button
local function createKeybind(section, actionName, defaultKey)
	local keyButton = Instance.new("TextButton")
	keyButton.Size = UDim2.new(1, -20, 0, 35)
	keyButton.Position = UDim2.new(0, 10, 0, 35)
	keyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	keyButton.Text = actionName .. ": " .. defaultKey.Name
	keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyButton.Font = Enum.Font.Gotham
	keyButton.TextSize = 14
	keyButton.Parent = section

	local currentKey = defaultKey
	local waitingForKey = false

	keyButton.MouseButton1Click:Connect(function()
		keyButton.Text = actionName .. ": [Press Key]"
		waitingForKey = true
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
			currentKey = input.KeyCode
			keyButton.Text = actionName .. ": " .. currentKey.Name
			waitingForKey = false
			print(actionName .. " bound to", currentKey.Name)
		elseif input.KeyCode == currentKey then
			print(actionName, "triggered with", currentKey.Name)
		end
	end)
end

createKeybind(keybindsSection, "Toggle ESP", Enum.KeyCode.E)
createKeybind(keybindsSection, "Toggle Aimbot", Enum.KeyCode.Q)
createKeybind(keybindsSection, "Toggle Hitbox", Enum.KeyCode.H)

-- Keybind: Show/Hide UI (LeftCtrl)
UserInputService.InputBegan:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.LeftControl then
		mainFrame.Visible = not mainFrame.Visible
	end
end)









