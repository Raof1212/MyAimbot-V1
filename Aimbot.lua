-- StarterGui > ScreenGui > LocalScript

local UserInputService = game:GetService("UserInputService")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RaofUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Raof v1"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame

-- Glow toggle button
local function createToggle(icon, yPos, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 100, 0, 40)
	button.Position = UDim2.new(0, 40, 0, yPos)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Text = icon
	button.Font = Enum.Font.GothamBold
	button.TextSize = 22
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.Parent = MainFrame
	
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
	
	local enabled = false
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		if enabled then
			button.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			button.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		callback(enabled)
	end)
end

-- Keybind display
local function createKeybind(icon, yPos, key)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 100, 0, 40)
	label.Position = UDim2.new(0, 200, 0, yPos)
	label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	label.Text = icon.." ["..key.Name.."]"
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Parent = MainFrame
	
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)
end

-- Features
createToggle("👁️", 60, function(state) print("ESP:", state) end)
createToggle("🎯", 110, function(state) print("Aimbot:", state) end)
createToggle("📦", 160, function(state) print("Hitbox:", state) end)

-- Keybinds
createKeybind("⌨️ UI", 60, Enum.KeyCode.Insert)
createKeybind("E", 110, Enum.KeyCode.E)
createKeybind("Q", 160, Enum.KeyCode.Q)









