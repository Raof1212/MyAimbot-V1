-- Roben Fancy Dashboard - Single file (loadstring-ready)
-- Features: WalkSpeed, JumpPower, Gravity, InfJump, Noclip, DisableVoid, Velocity Spoofer, Fly (CFrame/Velocity),
-- Walking movement (CFrame / Velocity), Keybinds, Dark/Light theme
-- Author: RaOf (adapted)

-- ===== Services & basic refs =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- ===== Config / state =====
local S = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = workspace.Gravity or 196.2,
    InfiniteJump = false,
    Noclip = false,
    DisableVoid = true,
    VoidY = -50,
    VelocitySpoofer = false,
    Fly = false,
    FlyMode = "CFrame", -- or "Velocity"
    FlySpeed = 50,
    WalkMethod = "Velocity", -- or "CFrame"
    WalkMethodSpeed = 16,
    Theme = "Dark", -- "Dark" or "Light"
    Keybinds = {
        UI_Toggle = Enum.KeyCode.RightShift,
        Fly = Enum.KeyCode.E,
        Noclip = Enum.KeyCode.N,
        InfJump = Enum.KeyCode.LeftControl,
        VoidToggle = Enum.KeyCode.V
    }
}

-- helper to get character safely
local function getCharacter()
    local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    return char, hrp, humanoid
end

-- ensure humanoid exists
local function safeHumanoid()
    local char = localPlayer.Character
    if not char then
        char = localPlayer.CharacterAdded:Wait()
    end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid") or char:WaitForChild("Humanoid")
    return humanoid
end

-- ===== GUI creation utilities =====
local function mk(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v else obj[k] = v end
        end
    end
    return obj
end

local function applyTheme(frame,theme)
    local dark = theme == "Dark"
    local bg = dark and Color3.fromRGB(18,18,20) or Color3.fromRGB(245,245,245)
    local panel = dark and Color3.fromRGB(28,28,30) or Color3.fromRGB(235,235,235)
    local text = dark and Color3.fromRGB(230,230,230) or Color3.fromRGB(20,20,20)
    for _,v in pairs(frame:GetDescendants()) do
        if v:IsA("Frame") or v:IsA("ImageLabel") then
            if v.Name == "Window" then v.BackgroundColor3 = bg end
            if v.Name == "Panel" then v.BackgroundColor3 = panel end
        elseif v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            v.TextColor3 = text
            if v:IsA("TextButton") then
                v.BackgroundColor3 = dark and Color3.fromRGB(36,36,38) or Color3.fromRGB(220,220,220)
            end
        elseif v:IsA("UICorner") then end
    end
end

-- ===== Build UI =====
local GUI = playerGui:FindFirstChild("RobenFancyDashboard")
if GUI then GUI:Destroy() end
GUI = mk("ScreenGui",{Name="RobenFancyDashboard",Parent=playerGui,ResetOnSpawn=false})

-- outer window
local Window = mk("Frame",{Name="Window",Parent=GUI,Size=UDim2.new(0,720,0,460),Position=UDim2.new(0.5,-360,0.5,-230),BackgroundColor3=Color3.fromRGB(18,18,20),BorderSizePixel=0,ClipsDescendants=true})
mk("UICorner",{Parent=Window,CornerRadius=UDim.new(0,6)})
-- left nav
local Nav = mk("Frame",{Name="Nav",Parent=Window,Size=UDim2.new(0,160,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(28,28,30)})
mk("UICorner",{Parent=Nav,CornerRadius=UDim.new(0,6)})

local Title = mk("TextLabel",{Parent=Nav,Text="Roben V1",Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,TextSize=20,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(230,230,230)})
Title.TextYAlignment = Enum.TextYAlignment.Center

-- nav buttons container
local navLayout = mk("UIListLayout",{Parent=Nav,Padding=UDim.new(0,8)})
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.VerticalAlignment = Enum.VerticalAlignment.Top
navLayout.Padding = UDim.new(0,8)
-- create sections
local sections = {"Movement","Keybinds","Misc","Themes","Credits"}
local Panels = {}

local function createNavButton(name,order)
    local btn = mk("TextButton",{Parent=Nav,Text=name,Size=UDim2.new(1,-16,0,40),Position=UDim2.new(0,8,0,70+(order-1)*48),BackgroundColor3=Color3.fromRGB(36,36,38),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=16})
    mk("UICorner",{Parent=btn,CornerRadius=UDim.new(0,6)})
    btn.LayoutOrder = order
    return btn
end

-- right content area
local Content = mk("Frame",{Name="Content",Parent=Window,Size=UDim2.new(1,-160,1,0),Position=UDim2.new(0,160,0,0),BackgroundColor3=Color3.fromRGB(24,24,26)})
mk("UICorner",{Parent=Content,CornerRadius=UDim.new(0,6)})

-- helper to clear content
local function clearContent()
    for _,c in pairs(Content:GetChildren()) do
        if not (c:IsA("UIListLayout") or c:IsA("UIPadding")) then
            c:Destroy()
        end
    end
end

-- create panels for each section
for i,name in ipairs(sections) do
    local btn = createNavButton(name,i)
    local panel = mk("Frame",{Name=name .. "Panel",Parent=Content,Size=UDim2.new(1, -20, 1, -20),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Visible=(name=="Movement")})
    Panels[name] = panel
    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(Panels) do v.Visible=false end
        panel.Visible = true
    end)
end

-- ===== Movement Panel content =====
local Mov = Panels["Movement"]
local mvLayout = mk("UIListLayout",{Parent=Mov,Padding=UDim.new(0,8)})
mvLayout.Padding = UDim.new(0,10)
mvLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- helper builders for controls
local function makeRow(parent, labelText)
    local row = mk("Frame",{Parent=parent,Name="Panel",Size=UDim2.new(1,0,0,44),BackgroundColor3=Color3.fromRGB(30,30,30)})
    mk("UICorner",{Parent=row,CornerRadius=UDim.new(0,6)})
    local lbl = mk("TextLabel",{Parent=row,Text=labelText,Size=UDim2.new(0,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextSize=15,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(230,230,230)})
    lbl.Size = UDim2.new(0.4, -20, 1, 0)
    local right = mk("Frame",{Parent=row,Size=UDim2.new(0.6, -20,1,0),Position=UDim2.new(0.4,10,0,0),BackgroundTransparency=1})
    return row,lbl,right
end

-- slider factory (nice looking)
local function sliderFactory(parent, label, min, max, initial, onChange)
    local row,labelObj,right = makeRow(parent,label)
    local bar = mk("Frame",{Parent=right,Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,12),BackgroundColor3=Color3.fromRGB(44,44,46)})
    mk("UICorner",{Parent=bar,CornerRadius=UDim.new(0,6)})
    local fill = mk("Frame",{Parent=bar,Size=UDim2.new((initial-min)/(max-min),0,1,0),BackgroundColor3=Color3.fromRGB(96,169,255)})
    mk("UICorner",{Parent=fill,CornerRadius=UDim.new(0,6)})
    local valueLabel = mk("TextLabel",{Parent=right,Text=tostring(initial),Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-55,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(230,230,230),TextSize=14,Font=Enum.Font.Gotham})
    -- clicking cycles + dragging
    local dragging = false
    local function setValue(normalized)
        normalized = math.clamp(normalized,0,1)
        local val = math.floor(min + (max-min)*normalized + 0.5)
        fill.Size = UDim2.new(normalized,0,1,0)
        valueLabel.Text = tostring(val)
        if onChange then pcall(onChange,val) end
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local rx = input.Position.X - bar.AbsolutePosition.X
            setValue(rx / bar.AbsoluteSize.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rx = input.Position.X - bar.AbsolutePosition.X
            setValue(rx / bar.AbsoluteSize.X)
        end
    end)
    -- return function to set programmatically
    return function(v)
        local norm = (v-min)/(max-min)
        fill.Size = UDim2.new(math.clamp(norm,0,1),0,1,0)
        valueLabel.Text = tostring(v)
        if onChange then pcall(onChange,v) end
    end
end

-- toggle factory
local function toggleFactory(parent,label,initial,onChange)
    local row,labelObj,right = makeRow(parent,label)
    local btn = mk("TextButton",{Parent=right,Text=tostring(initial),Size=UDim2.new(0,120,0,28),Position=UDim2.new(1,-130,0,8),BackgroundColor3=Color3.fromRGB(46,46,48),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=14})
    mk("UICorner",{Parent=btn,CornerRadius=UDim.new(0,6)})
    local state = initial
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = tostring(state)
        pcall(onChange,state)
    end)
    return function(v)
        state = v
        btn.Text = tostring(state)
        pcall(onChange,state)
    end
end

-- dropdown factory (simple)
local function dropdownFactory(parent,label, options, initial, onChange)
    local row,labelObj,right = makeRow(parent,label)
    local box = mk("TextButton",{Parent=right,Text=tostring(initial),Size=UDim2.new(0,160,0,28),Position=UDim2.new(1,-180,0,8),BackgroundColor3=Color3.fromRGB(46,46,48),Font=Enum.Font.Gotham,TextSize=14})
    mk("UICorner",{Parent=box,CornerRadius=UDim.new(0,6)})
    local menu = mk("Frame",{Parent=box,Visible=false,Size=UDim2.new(1,0,0,#options*28),Position=UDim2.new(0,0,1,6),BackgroundColor3=Color3.fromRGB(36,36,38)})
    mk("UICorner",{Parent=menu,CornerRadius=UDim.new(0,6)})
    for i,opt in ipairs(options) do
        local it = mk("TextButton",{Parent=menu,Text=opt,Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,(i-1)*28),BackgroundColor3=Color3.fromRGB(46,46,48),Font=Enum.Font.Gotham,TextSize=14})
        it.MouseButton1Click:Connect(function()
            box.Text = opt
            menu.Visible = false
            if onChange then pcall(onChange,opt) end
        end)
    end
    box.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
    return function(v)
        box.Text = tostring(v)
        if onChange then pcall(onChange,v) end
    end
end

-- Movement controls
local setWalk = sliderFactory(Mov,"WalkSpeed",0,500,S.WalkSpeed,function(v)
    S.WalkSpeed = v
    pcall(function()
        local _,_,h = getCharacter()
        if h then h.WalkSpeed = v end
    end)
end)

local setJump = sliderFactory(Mov,"JumpPower",0,500,S.JumpPower,function(v)
    S.JumpPower = v
    pcall(function() local _,_,h = getCharacter(); if h then h.UseJumpPower = true; h.JumpPower = v end end)
end)

local setGravity = sliderFactory(Mov,"Gravity",0,500,S.Gravity,function(v)
    S.Gravity = v
    workspace.Gravity = v
end)

local setFlySpeed = sliderFactory(Mov,"Fly Speed",1,300,S.FlySpeed,function(v) S.FlySpeed = v end)
local setWalkMethodSpeed = sliderFactory(Mov,"Walk Method Speed",1,300,S.WalkMethodSpeed,function(v) S.WalkMethodSpeed = v end)

local setFlyMode = dropdownFactory(Mov,"Fly Mode",{"CFrame","Velocity"},S.FlyMode,function(v) S.FlyMode = v end)
local setWalkMethod = dropdownFactory(Mov,"Walk Method",{"Velocity","CFrame"},S.WalkMethod,function(v) S.WalkMethod = v end)

local infJumpToggle = toggleFactory(Mov,"Infinite Jump",S.InfiniteJump,function(v) S.InfiniteJump = v end)
local noclipToggle = toggleFactory(Mov,"Noclip",S.Noclip,function(v) S.Noclip = v end)
local voidToggle = toggleFactory(Mov,"Disable Void",S.DisableVoid,function(v) S.DisableVoid = v end)
local velSpoofToggle = toggleFactory(Mov,"Velocity Spoofer",S.VelocitySpoofer,function(v) S.VelocitySpoofer = v end)

-- Fly toggle button (quick)
local function createBigButton(parent, text, cb)
    local row = mk("Frame",{Parent=parent,Size=UDim2.new(1,0,0,60),BackgroundTransparency=1})
    local btn = mk("TextButton",{Parent=row,Text=text,Size=UDim2.new(0,220,0,40),Position=UDim2.new(0,10,0,10),BackgroundColor3=Color3.fromRGB(96,169,255),Font=Enum.Font.GothamBold,TextSize=16,BorderSizePixel=0})
    mk("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)})
    btn.MouseButton1Click:Connect(cb)
    return btn
end

local flyBtn = createBigButton(Mov,"Toggle Fly (Keybind E)",function()
    S.Fly = not S.Fly
end)

-- ===== Keybinds panel =====
local KB = Panels["Keybinds"]
local kbLayout = mk("UIListLayout",{Parent=KB,Padding=UDim.new(0,8)})
kbLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function keybindRow(parent,label,keyRefName)
    local row,labelObj,right = makeRow(parent,label)
    local keyBox = mk("TextButton",{Parent=right,Text=tostring(S.Keybinds[keyRefName]),Size=UDim2.new(0,180,0,28),Position=UDim2.new(1,-190,0,8),BackgroundColor3=Color3.fromRGB(46,46,48),Font=Enum.Font.Gotham,TextSize=14})
    mk("UICorner",{Parent=keyBox,CornerRadius=UDim.new(0,6)})
    local binding = false
    keyBox.MouseButton1Click:Connect(function()
        keyBox.Text = "Press a key..."
        binding = true
        local conn
        conn = UserInputService.InputBegan:Connect(function(i,gp)
            if not gp and binding then
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    S.Keybinds[keyRefName] = i.KeyCode
                    keyBox.Text = tostring(i.KeyCode)
                    binding = false
                    conn:Disconnect()
                end
            end
        end)
    end)
end

keybindRow(KB,"UI Toggle","UI_Toggle")
keybindRow(KB,"Fly Toggle","Fly")
keybindRow(KB,"Noclip","Noclip")
keybindRow(KB,"Infinite Jump","InfJump")
keybindRow(KB,"Disable Void","VoidToggle")

-- ===== Misc panel (placeholders/wipes) =====
local Misc = Panels["Misc"]
local miscLayout = mk("UIListLayout",{Parent=Misc,Padding=UDim.new(0,10)})
miscLayout.SortOrder = Enum.SortOrder.LayoutOrder
local resetBtn = createBigButton(Misc,"Reset Movement To Default",function()
    S.WalkSpeed = 16; S.JumpPower = 50; S.Gravity = 196.2; S.FlySpeed = 50; S.WalkMethodSpeed = 16
    setWalk(16); setJump(50); setGravity(196); setFlySpeed(50); setWalkMethodSpeed(16)
end)
local teleportBtn = createBigButton(Misc,"Teleport to Spawn",function()
    local char,hrp = getCharacter()
    if hrp and char then
        pcall(function() hrp.CFrame = workspace:FindFirstChild("SpawnLocation") and workspace.SpawnLocation.CFrame or workspace:FindFirstChildOfClass("SpawnLocation") and workspace:FindFirstChildOfClass("SpawnLocation").CFrame or hrp.CFrame end)
    end
end)

-- ===== Themes panel =====
local Themes = Panels["Themes"]
local themeLayout = mk("UIListLayout",{Parent=Themes,Padding=UDim.new(0,10)})
themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
local themeToggle = createBigButton(Themes,"Toggle Dark/Light Theme",function()
    if S.Theme == "Dark" then S.Theme = "Light" else S.Theme = "Dark" end
    applyTheme(Window,S.Theme)
end)
-- initialize theme
applyTheme(Window,S.Theme)

-- ===== Credits panel =====
local Credits = Panels["Credits"]
local credTxt = mk("TextLabel",{Parent=Credits,Text="Roben Fancy Dashboard\nBy RaOf\nUse responsibly",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(230,230,230),Font=Enum.Font.Gotham,TextSize=18})
credTxt.TextWrapped = true
credTxt.TextYAlignment = Enum.TextYAlignment.Top

-- ===== Movement runtime logic =====
-- maintain fly and walk method with RunService
local bodyVelFly = nil
local lastJumpTick = 0

-- Noclip loop
local function noclipLoop()
    spawn(function()
        while S.Noclip do
            local char,hrp = getCharacter()
            if char then
                for _,p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p ~= hrp then
                        p.CanCollide = false
                    end
                end
            end
            task.wait(0.5)
        end
        -- restore on disable (best-effort)
        local char,hrp = getCharacter()
        if char then
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
    end)
end

-- Velocity spoofer: attach BodyVelocity to HRP and update it
local velSpoofBV = nil
local function enableVelocitySpoof(enable)
    local char,hrp = pcall(getCharacter) and getCharacter() or nil
    if not hrp then return end
    if enable then
        if not velSpoofBV then
            velSpoofBV = Instance.new("BodyVelocity")
            velSpoofBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            velSpoofBV.P = 3000
            velSpoofBV.Velocity = Vector3.new(0,0,0)
            velSpoofBV.Parent = hrp
        end
    else
        if velSpoofBV then
            velSpoofBV:Destroy()
            velSpoofBV = nil
        end
    end
end

-- Fly implementation
local function updateFly(dt)
    if not S.Fly then
        if bodyVelFly then
            bodyVelFly:Destroy()
            bodyVelFly = nil
        end
        return
    end
    local char,hrp = getCharacter()
    if not hrp then return end
    local cam = workspace.CurrentCamera
    if S.FlyMode == "Velocity" then
        if not bodyVelFly then
            bodyVelFly = Instance.new("BodyVelocity")
            bodyVelFly.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVelFly.P = 3000
            bodyVelFly.Velocity = Vector3.new(0,0,0)
            bodyVelFly.Parent = hrp
        end
        local moveVec = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0,1,0) end
        bodyVelFly.Velocity = moveVec.Unit == moveVec and moveVec * S.FlySpeed or Vector3.new(0,0,0)
    else -- CFrame move
        if bodyVelFly then bodyVelFly:Destroy(); bodyVelFly=nil end
        local speed = S.FlySpeed * dt * 60
        local cf = hrp.CFrame
        local forward = workspace.CurrentCamera.CFrame.LookVector
        local right = workspace.CurrentCamera.CFrame.RightVector
        local dest = cf
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dest = dest + forward * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dest = dest - forward * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dest = dest - right * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dest = dest + right * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dest = dest + Vector3.new(0, speed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dest = dest - Vector3.new(0, speed, 0) end
        hrp.CFrame = CFrame.new(dest.Position, dest.Position + workspace.CurrentCamera.CFrame.LookVector)
    end
end

-- Walk method implementation (Velocity / CFrame)
local walkBV = nil
local function updateWalk(dt)
    local char,hrp,h = getCharacter()
    if not hrp or not h then return end
    if S.WalkMethod == "Velocity" then
        if not walkBV then
            walkBV = Instance.new("BodyVelocity")
            walkBV.MaxForce = Vector3.new(1e5,0,1e5)
            walkBV.P = 2500
            walkBV.Velocity = Vector3.new(0,0,0)
            walkBV.Parent = hrp
        end
        local mv = Vector3.new()
        local cam = workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
        if mv.Magnitude > 0 then
            walkBV.Velocity = Vector3.new(mv.Unit.X,0,mv.Unit.Z) * S.WalkMethodSpeed
        else
            walkBV.Velocity = Vector3.new(0,0,0)
        end
    else
        if walkBV then walkBV:Destroy(); walkBV=nil end
        -- CFrame walk is handled by direct HRP movement - we won't teleport constantly here to avoid anti-cheat
        -- We'll nudge when keys are pressed
        local delta = S.WalkMethodSpeed * dt * 60
        local cam = workspace.CurrentCamera
        local cur = hrp.CFrame
        local moved = false
        local pos = cur.Position
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then pos = pos + cam.CFrame.LookVector * delta; moved = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then pos = pos - cam.CFrame.LookVector * delta; moved = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then pos = pos - cam.CFrame.RightVector * delta; moved = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then pos = pos + cam.CFrame.RightVector * delta; moved = true end
        if moved then
            hrp.CFrame = CFrame.new(pos, pos + cam.CFrame.LookVector)
        end
    end
end

-- Infinite jump connection
UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump then
        local char,hrp,h = getCharacter()
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
            -- small anti-spam guard
            lastJumpTick = tick()
        end
    end
end)

-- Input keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for name,key in pairs(S.Keybinds) do
            if input.KeyCode == key then
                if name == "UI_Toggle" then
                    GUI.Enabled = not GUI.Enabled
                elseif name == "Fly" then
                    S.Fly = not S.Fly
                elseif name == "Noclip" then
                    S.Noclip = not S.Noclip
                    if S.Noclip then noclipLoop() end
                elseif name == "InfJump" then
                    S.InfiniteJump = not S.InfiniteJump
                elseif name == "VoidToggle" then
                    S.DisableVoid = not S.DisableVoid
                end
            end
        end
    end
end)

-- apply noclip toggle changes
spawn(function()
    while true do
        if S.Noclip then
            -- ensure parts are non-collidable
            local char = localPlayer.Character
            if char then
                for _,part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- disable void handling
spawn(function()
    while true do
        if S.DisableVoid then
            local char,hrp = pcall(getCharacter) and getCharacter() or nil
            if hrp and hrp.Position.Y < (S.VoidY or -50) then
                -- teleport up
                pcall(function()
                    hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0,150,0))
                end)
            end
        end
        task.wait(0.5)
    end
end)

-- Velocity Spoofer loop adjust
spawn(function()
    while true do
        if S.VelocitySpoofer then
            local ok,hrp = pcall(function() return getCharacter() end)
            if ok and hrp then
                local _,hrpRef = getCharacter()
                if hrpRef and velSpoofBV then
                    -- sync spoof BV with current HRP velocity to "spoof"
                    velSpoofBV.Velocity = hrpRef.Velocity
                end
            else
                -- nothing
            end
        end
        task.wait(0.05)
    end
end)

-- main run loop
RunService.Heartbeat:Connect(function(dt)
    -- update fly
    if S.Fly then
        updateFly(dt)
    end
    -- update walk method if not flying (or if WalkMethod still desired)
    updateWalk(dt)
    -- update velocity spoofer BV parent if needed
    if S.VelocitySpoofer then
        -- ensure velSpoofBV exists and parented to HRP
        local char,hrp = getCharacter()
        if hrp and not velSpoofBV then
            velSpoofBV = Instance.new("BodyVelocity")
            velSpoofBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            velSpoofBV.P = 3000
            velSpoofBV.Velocity = hrp.Velocity
            velSpoofBV.Parent = hrp
        elseif velSpoofBV and velSpoofBV.Parent ~= hrp then
            velSpoofBV.Parent = hrp
        end
    else
        if velSpoofBV then
            velSpoofBV:Destroy()
            velSpoofBV = nil
        end
    end
end)

-- initial apply
pcall(function() workspace.Gravity = S.Gravity end)
pcall(function() local _,_,h = getCharacter(); if h then h.WalkSpeed = S.WalkSpeed; h.UseJumpPower=true; h.JumpPower=S.JumpPower end end)

print("Roben Fancy Dashboard loaded - Movement features active. Toggle UI with", tostring(S.Keybinds.UI_Toggle))

-- End of script









