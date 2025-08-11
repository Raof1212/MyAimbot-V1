--[[

	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	Modified for head-only, prediction, smoothing, improved target selection (experimental).
	Added character speed control.

]]


--// Cache

local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick
local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	__index = function(self, Index)
		return self[Index]
	end,
	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local getrenderproperty, setrenderproperty = getrenderproperty or __index, setrenderproperty or __newindex

local GetService = __index(game, "GetService")

--// Services

local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")

--// Service Methods

local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")

local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}
local Connect, Disconnect = __index(game, "DescendantAdded").Connect

--// Checking for multiple processes

if ExunysDeveloperAimbot and ExunysDeveloperAimbot.Exit then
	ExunysDeveloperAimbot:Exit()
end

--// Environment

getgenv().ExunysDeveloperAimbot = {
	DeveloperSettings = {
		UpdateMode = "RenderStepped",
		TeamCheckOption = "TeamColor",
		RainbowSpeed = 1 -- Bigger = Slower
	},

	Settings = {
		Enabled = true,

		Speed = 30, -- <-- NEW: character speed control (default Roblox walk speed)

		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,

		-- Predictive aiming & smoothing (added)
		Prediction = true,
		PredictionFactor = 0.165, -- multiply target velocity by this to approximate lead
		Smoothing = 0.14,         -- between 0 (instant) and 1 (very slow); used for mousemoverel smoothing

		OffsetToMoveDirection = false,
		OffsetIncrement = 15,

		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target (camera tween)
		Sensitivity2 = 3.5, -- mousemoverel sensitivity divisor

		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		LockPart = "Head", -- Body part to lock on (default: Head)

		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,

		Radius = 90,
		NumSides = 60,

		Thickness = 1,
		Transparency = 1,
		Filled = false,

		RainbowColor = false,
		RainbowOutlineColor = false,
		Color = Color3fromRGB(255, 255, 255),
		OutlineColor = Color3fromRGB(0, 0, 0),
		LockedColor = Color3fromRGB(255, 150, 150)
	},

	Blacklisted = {},
	FOVCircleOutline = Drawingnew("Circle"),
	FOVCircle = Drawingnew("Circle")
}

local Environment = getgenv().ExunysDeveloperAimbot

setrenderproperty(Environment.FOVCircle, "Visible", false)
setrenderproperty(Environment.FOVCircleOutline, "Visible", false)

--// Helper function: Update player speed

local function UpdateSpeed()
    local speed = Environment.Settings.Speed or 16
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= speed then
            humanoid.WalkSpeed = speed
        end
    end
end

--// Core Functions

local FixUsername = function(String)
	local Result
	for _, Value in next, GetPlayers(Players) do
		local Name = __index(Value, "Name")
		if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
			Result = Name
		end
	end
	return Result
end

local GetRainbowColor = function()
	local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed
	return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
	return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
	Environment.Locked = nil
	local FOVCircle = Environment.FOVCircle
	setrenderproperty(FOVCircle, "Color", Environment.FOVSettings.Color)
	__newindex(UserInputService, "MouseDeltaSensitivity", OriginalSensitivity)
	if Animation then Animation:Cancel() end
end

-- Improved visibility check helper
local IsVisible = function(part)
	if not part then return false end
	local camera = Camera
	local localCharacterDescendants = GetDescendants(__index(LocalPlayer, "Character") or workspace)
	local BlacklistTable = {}
	for _, v in next, localCharacterDescendants do
		BlacklistTable[#BlacklistTable + 1] = v
	end
	local parts = GetPartsObscuringTarget(camera, { part.Position }, BlacklistTable)
	return #parts == 0
end

local GetClosestPlayer = function()
	local Settings = Environment.Settings
	local LockPart = Settings.LockPart

	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000

		for _, Value in next, GetPlayers(Players) do
			local Character = __index(Value, "Character")
			local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")

			if Value ~= LocalPlayer and not tablefind(Environment.Blacklisted, __index(Value, "Name")) and Character and FindFirstChild(Character, LockPart) and Humanoid then
				local Part = Character[LockPart]
				local PartPosition, TeamCheckOption = __index(Part, "Position"), Environment.DeveloperSettings.TeamCheckOption

				if Settings.TeamCheck and __index(Value, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) then
					continue
				end

				if Settings.AliveCheck and __index(Humanoid, "Health") <= 0 then
					continue
				end

				if Settings.WallCheck and not IsVisible(Part) then
					continue
				end

				local Vector, OnScreen = WorldToViewportPoint(Camera, PartPosition)
				local ScreenPos = ConvertVector(Vector)
				local MousePos = GetMouseLocation(UserInputService)
				local Distance = (MousePos - ScreenPos).Magnitude

				-- prefer visible heads slightly closer to crosshair
				if OnScreen and Distance < RequiredDistance then
					RequiredDistance, Environment.Locked = Distance, Value
				end
			end
		end
	elseif (GetMouseLocation(UserInputService) - ConvertVector(WorldToViewportPoint(Camera, __index(__index(__index(Environment.Locked, "Character"), LockPart), "Position")))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

local Load = function()
	OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")

	local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings

	ServiceConnections.RenderSteppedConnection = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
		local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart

		if FOVSettings.Enabled and Settings.Enabled then
			for Index, Value in next, FOVSettings do
				if Index == "Color" then continue end
				if pcall(getrenderproperty, FOVCircle, Index) then
					setrenderproperty(FOVCircle, Index, Value)
					setrenderproperty(FOVCircleOutline, Index, Value)
				end
			end

			setrenderproperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
			setrenderproperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)

			setrenderproperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
			setrenderproperty(FOVCircle, "Position", GetMouseLocation(UserInputService))
			setrenderproperty(FOVCircleOutline, "Position", GetMouseLocation(UserInputService))
		else
			setrenderproperty(FOVCircle, "Visible", false)
			setrenderproperty(FOVCircleOutline, "Visible", false)
		end

		if Running and Settings.Enabled then
			GetClosestPlayer()
			UpdateSpeed()  -- <-- NEW: Update player speed here

			Offset = OffsetToMoveDirection and __index(FindFirstChildOfClass(__index(Environment.Locked, "Character"), "Humanoid"), "MoveDirection") * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero

			if Environment.Locked then
				local LockedChar = __index(Environment.Locked, "Character")
				local LockedPart = LockedChar and LockedChar[LockPart]
				if not LockedPart then CancelLock() return end

				-- Predictive position calculation (if enabled)
				local targetPos = __index(LockedPart, "Position")
				if Settings.Prediction then
					local hrp = LockedChar:FindFirstChild("HumanoidRootPart")
					if hrp then
						local vel = hrp.Velocity or Vector3zero
						targetPos = targetPos + (vel * Settings.PredictionFactor)
					end
				end

				local LockedPosition = WorldToViewportPoint(Camera, targetPos + Offset)

				if Environment.Settings.LockMode == 2 then
					-- mousemoverel mode with smoothing
					local mousePos = GetMouseLocation(UserInputService)
					local dx = (LockedPosition.X - mousePos.X) / Settings.Sensitivity2
					local dy = (LockedPosition.Y - mousePos.Y) / Settings.Sensitivity2

					-- apply smoothing: we move a fraction each frame towards the target delta
					local smoothing = mathclamp(Settings.Smoothing, 0.01, 0.98)
					mousemoverel(dx * (1 - smoothing), dy * (1 - smoothing))
				else
					if Settings.Sensitivity > 0 then
						Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, targetPos)})
						Animation:Play()
					else
						-- slight smoothing for instant CFrame set — use lerp-ish approach
						local current = Camera.CFrame
						local aimCFrame = CFramenew(current.Position, targetPos + Offset)
						local smoothing = mathclamp(Settings.Smoothing, 0, 0.95)
						if smoothing > 0 then
							-- non-destructive smoothing via small steps
							local step = 1 - smoothing
							__newindex(Camera, "CFrame", current:Lerp(aimCFrame, step))
						else
							__newindex(Camera, "CFrame", aimCFrame)
						end
					end

					__newindex(UserInputService, "MouseDeltaSensitivity", 0)
				end

				setrenderproperty(FOVCircle, "Color", FOVSettings.LockedColor)
			end
		end
	end)

	ServiceConnections.InputBeganConnection = Connect(__index(UserInputService, "InputBegan"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Typing then return end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			if Toggle then
				Running = not Running
				if not Running then CancelLock() end
			else
				Running = true
			end
		end
	end)

	ServiceConnections.InputEndedConnection = Connect(__index(UserInputService, "InputEnded"), function(Input)
		local TriggerKey, Toggle = Settings.TriggerKey, Settings.Toggle

		if Toggle or Typing then return end

		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == TriggerKey or Input.UserInputType == TriggerKey then
			Running = false
			CancelLock()
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = Connect(__index(UserInputService, "TextBoxFocused"), function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = Connect(__index(UserInputService, "TextBoxFocusReleased"), function()
	Typing = false
end)

--// Functions

function Environment.Exit(self)
	assert(self, "EXUNYS_AIMBOT-V3.Exit: Missing parameter #1 \"self\" <table>.")
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil; GetRainbowColor = nil; FixUsername = nil
	self.FOVCircle:Remove()
	self.FOVCircleOutline:Remove()
	getgenv().ExunysDeveloperAimbot = nil
end

function Environment.Restart()
	for Index, _ in next, ServiceConnections do
		Disconnect(ServiceConnections[Index])
	end
	Load()
end

function Environment.Blacklist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Blacklist: Missing parameter #2 \"Username\" <string>.")
	Username = FixUsername(Username)
	assert(self, "EXUNYS_AIMBOT-V3.Blacklist: User "..Username.." couldn't be found.")
	self.Blacklisted[#self.Blacklisted + 1] = Username
end

function Environment.Whitelist(self, Username)
	assert(self, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #1 \"self\" <table>.")
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: Missing parameter #2 \"Username\" <string>.")
	Username = FixUsername(Username)
	assert(Username, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." couldn't be found.")
	local Index = tablefind(self.Blacklisted, Username)
	assert(Index, "EXUNYS_AIMBOT-V3.Whitelist: User "..Username.." is not blacklisted.")
	tableremove(self.Blacklisted, Index)
end

function Environment.GetClosestPlayer()
	GetClosestPlayer()
	local Value = Environment.Locked
	CancelLock()
	return Value
end

Environment.Load = Load
setmetatable(Environment, {__call = Load})

return Environment


