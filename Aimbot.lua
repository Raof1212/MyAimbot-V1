-- StarterGui > ScreenGui > LocalScript

local UserInputService = game:GetService("UserInputService")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatDashboard"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 350) -- Bigger window
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🔥 Raof Cheat Dashboard 🔥"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame

-- Section title function
local function createSection(name, yPos)
	local section = Instance.new("TextLabel")
	section.Size = UDim2.new(1, -20, 0, 25)
	section.Position = UDim2.new(0, 10, 0, yPos)
	section.BackgroundTransparency = 1
	section.Text = name
	section.Font = Enum.Font.GothamBold
	section.TextSize = 18
	section.TextColor3 = Color3.fromRGB(200, 200, 200)
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.Parent = MainFrame
	return section
end

-- Toggle button function
local function createToggle(name, yPos, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 150, 0, 30)
	button.Position = UDim2.new(0, 20, 0, yPos)
	button.BackgroundColor3 = Color3.fromRGB(70, 0, 0) -- OFF state
	button.Text = name.." [OFF]"
	button.Font = Enum.Font.Gotham
	button.TextSize = 16
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = MainFrame
	
	local UIC = Instance.new("UICorner")
	UIC.CornerRadius = UDim.new(0, 8)
	UIC.Parent = button
	
	local enabled = false
	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		if enabled then
			button.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
			button.Text = name.." [ON]"
		else
			button.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
			button.Text = name.." [OFF]"
		end
		callback(enabled)
	end)
end

-- Keybind display
local function createKeybind(name, yPos, defaultKey)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 150, 0, 30)
	label.Position = UDim2.new(0, 200, 0, yPos)
	label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	label.Text = name.." : ["..defaultKey.Name.."]"
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Parent = MainFrame
	
	local UIC = Instance.new("UICorner")
	UIC.CornerRadius = UDim.new(0, 8)
	UIC.Parent = label
	
	-- For later: You can add click-to-rebind here
end

-- Build UI
createSection("⚡ Features", 50)
createToggle("ESP", 80, function(state) print("ESP = ", state) end)
createToggle("Aimbot", 120, function(state) print("Aimbot = ", state) end)
createToggle("Hitbox Expander", 160, function(state) print("Hitbox = ", state) end)

createSection("🎮 Keybinds", 210)
createKeybind("Toggle UI", 240, Enum.KeyCode.Insert)
createKeybind("ESP Toggle", 280, Enum.KeyCode.E)
createKeybind("Aimbot Hold", 320, Enum.KeyCode.Q)









