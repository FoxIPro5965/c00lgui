--// c00lgui v0.4 - Dark Red Theme //--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "c00lgui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 340) 
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0) -- nền đen
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "c00lgui v0.4"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255) -- chữ trắng

-- Hitbox Label & Input
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Parent = MainFrame
BoxLabel.Position = UDim2.new(0,10,0,45)
BoxLabel.Size = UDim2.new(0,100,0,25)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Hack Hitbox :"
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 14
BoxLabel.TextColor3 = Color3.fromRGB(255,255,255) -- chữ trắng

local Box = Instance.new("TextBox")
Box.Parent = MainFrame
Box.Size = UDim2.new(0,60,0,25)
Box.Position = UDim2.new(0,120,0,45)
Box.BackgroundColor3 = Color3.fromRGB(30,0,0) -- nền đỏ tối
Box.Text = "20"
Box.TextColor3 = Color3.fromRGB(255,255,255) -- chữ trắng
Box.Font = Enum.Font.Gotham
Box.TextSize = 14
Instance.new("UICorner",Box).CornerRadius = UDim.new(0,6)

local Toggle = Instance.new("TextButton")
Toggle.Parent = MainFrame
Toggle.Size = UDim2.new(0,220,0,35)
Toggle.Position = UDim2.new(0,20,0,85)
Toggle.BackgroundColor3 = Color3.fromRGB(150,0,0) -- nút đỏ
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255,255,255) -- chữ trắng
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Instance.new("UICorner",Toggle).CornerRadius = UDim.new(0,8)

-- Speed / Jump
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Position = UDim2.new(0,10,0,130)
SpeedLabel.Size = UDim2.new(0,100,0,25)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed:"
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(0,70,0,25)
SpeedBox.Position = UDim2.new(0,140,0,130)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30,0,0)
SpeedBox.Text = "16"
SpeedBox.TextColor3 = Color3.fromRGB(255,255,255)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
Instance.new("UICorner",SpeedBox).CornerRadius = UDim.new(0,6)

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Parent = MainFrame
JumpLabel.Position = UDim2.new(0,10,0,165)
JumpLabel.Size = UDim2.new(0,100,0,25)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump:"
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.TextSize = 14
JumpLabel.TextColor3 = Color3.fromRGB(255,255,255)

local JumpBox = Instance.new("TextBox")
JumpBox.Parent = MainFrame
JumpBox.Size = UDim2.new(0,70,0,25)
JumpBox.Position = UDim2.new(0,140,0,165)
JumpBox.BackgroundColor3 = Color3.fromRGB(30,0,0)
JumpBox.Text = "50"
JumpBox.TextColor3 = Color3.fromRGB(255,255,255)
JumpBox.Font = Enum.Font.Gotham
JumpBox.TextSize = 14
Instance.new("UICorner",JumpBox).CornerRadius = UDim.new(0,6)

-- Apply speed / jump
local function applyStats()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local speed = tonumber(SpeedBox.Text)
        local jump = tonumber(JumpBox.Text)
        if speed then char.Humanoid.WalkSpeed = speed end
        if jump then char.Humanoid.JumpPower = jump end
    end
end
SpeedBox.FocusLost:Connect(applyStats)
JumpBox.FocusLost:Connect(applyStats)

--=====================
-- MODE BUTTON
--=====================
local ModeButton = Instance.new("TextButton")
ModeButton.Parent = MainFrame
ModeButton.Size = UDim2.new(0,220,0,35)
ModeButton.Position = UDim2.new(0,20,0,205)
ModeButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
ModeButton.TextColor3 = Color3.fromRGB(255,255,255)
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 16
ModeButton.Text = "Mode: DEFAULT"
Instance.new("UICorner",ModeButton).CornerRadius = UDim.new(0,8)

--=====================
-- PERFECT FLY + INF JUMP
--=====================
local flying = false
local infjump = false
local mode = 1

local bv, bg, flyConn, infConn = nil, nil, nil, nil
local flySpeed = 80
local ctrl = {f=0, b=0, l=0, r=0, upd=0, down=0}

--=== INFINITE JUMP ===
local function enableInfJump()
    if infjump then return end
    infjump = true
    infConn = UIS.JumpRequest:Connect(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end)
end

local function disableInfJump()
    infjump = false
    if infConn then infConn:Disconnect() infConn = nil end
end

--=== AUTO SHIFT LOCK ===
local function setShiftLock(state)
    pcall(function()
        LocalPlayer.DevEnableMouseLock = state
        LocalPlayer.DevMouseLockMode = state and Enum.DevMouseLockMode.LockCenter or Enum.DevMouseLockMode.None
    end)
end

--=== PERFECT FLY ===
local function startFly()
    if flying then return end
    flying = true
    setShiftLock(true)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    hum.PlatformStand = true
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 20000
    bg.CFrame = root.CFrame
    local controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then return end
        local cam = workspace.CurrentCamera
        local moveVec = controls:GetMoveVector()
        ctrl = {f=0,b=0,l=0,r=0,upd=0,down=0}
        if moveVec.Z<-0.1 then ctrl.f=1 end
        if moveVec.Z>0.1 then ctrl.b=1 end
        if moveVec.X<-0.1 then ctrl.l=1 end
        if moveVec.X>0.1 then ctrl.r=1 end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then ctrl.upd=1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then ctrl.down=1 end
        local speed = flySpeed
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed *=2 end
        local dir = Vector3.zero
        dir += (ctrl.f==1 and cam.CFrame.LookVector or Vector3.zero)
        dir -= (ctrl.b==1 and cam.CFrame.LookVector or Vector3.zero)
        dir += (ctrl.r==1 and cam.CFrame.RightVector or Vector3.zero)
        dir -= (ctrl.l==1 and cam.CFrame.RightVector or Vector3.zero)
        dir += (ctrl.upd==1 and cam.CFrame.UpVector or Vector3.zero)
        dir -= (ctrl.down==1 and cam.CFrame.UpVector or Vector3.zero)
        if dir.Magnitude>0.01 then
            dir = dir.Unit
            bv.Velocity = dir*speed
            bg.CFrame = CFrame.lookAt(root.Position, root.Position+dir)
        else
            bv.Velocity = Vector3.zero
        end
    end)
end

local function stopFly()
    flying = false
    setShiftLock(false)
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if bv then bv:Destroy() bv=nil end
    if bg then bg:Destroy() bg=nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand=false end
end

ModeButton.MouseButton1Click:Connect(function()
    mode = mode+1
    if mode>3 then mode=1 end
    stopFly()
    disableInfJump()
    if mode==1 then
        ModeButton.Text="Mode: DEFAULT"
    elseif mode==2 then
        ModeButton.Text="Mode: INF JUMP"
        enableInfJump()
    elseif mode==3 then
        ModeButton.Text="Mode: FLY"
        startFly()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)
    stopFly()
    disableInfJump()
    if mode==2 then enableInfJump() end
    if mode==3 then startFly() end
end)

--=====================
-- HITBOX
--=====================
local Enabled=false
local Size = tonumber(Box.Text) or 20
local function ExpandHitbox(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.Size = Vector3.new(Size,Size,Size)
        hrp.Transparency = 0.7
        hrp.Material = Enum.Material.Neon
        hrp.BrickColor = BrickColor.new("Really red")
    end
end
local function ResetHitbox(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.Size = Vector3.new(2,2,1)
        hrp.Transparency=0
        hrp.Material = Enum.Material.Plastic
    end
end
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        Toggle.Text="ON"
        Toggle.BackgroundColor3=Color3.fromRGB(0,150,0)
    else
        Toggle.Text="OFF"
        Toggle.BackgroundColor3=Color3.fromRGB(150,0,0)
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then ResetHitbox(plr.Character) end
        end
    end
end)
Box.FocusLost:Connect(function()
    local val = tonumber(Box.Text)
    if val and val>0 then Size=val else Box.Text=tostring(Size) end
end)
RunService.RenderStepped:Connect(function()
    if Enabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then ExpandHitbox(plr.Character) end
        end
    end
end)

--=====================
-- FULLBRIGHT
--=====================
local FBButton = Instance.new("TextButton")
FBButton.Parent=MainFrame
FBButton.Size=UDim2.new(0,220,0,35)
FBButton.Position=UDim2.new(0,20,0,245)
FBButton.BackgroundColor3=Color3.fromRGB(150,0,0)
FBButton.Text="FullBright: OFF"
FBButton.TextColor3=Color3.fromRGB(255,255,255)
FBButton.Font=Enum.Font.GothamBold
FBButton.TextSize=16
Instance.new("UICorner",FBButton).CornerRadius=UDim.new(0,8)

local fbOn=false
local ob=Lighting.Brightness
local oa=Lighting.Ambient
local oo=Lighting.OutdoorAmbient
local oc=Lighting.ClockTime

local function applyDaySky()
    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    local sky=Instance.new("Sky",Lighting)
    sky.SkyboxBk="rbxassetid://7018684000"
    sky.SkyboxDn="rbxassetid://7018684000"
    sky.SkyboxFt="rbxassetid://7018684000"
    sky.SkyboxLf="rbxassetid://7018684000"
    sky.SkyboxRt="rbxassetid://7018684000"
    sky.SkyboxUp="rbxassetid://7018684000"
end

FBButton.MouseButton1Click:Connect(function()
    fbOn = not fbOn
    if fbOn then
        FBButton.Text="FullBright: ON"
        FBButton.BackgroundColor3=Color3.fromRGB(0,180,0)
        Lighting.Brightness=2
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        Lighting.ClockTime=12
        applyDaySky()
    else
        FBButton.Text="FullBright: OFF"
        FBButton.BackgroundColor3=Color3.fromRGB(150,0,0)
        Lighting.Brightness=ob
        Lighting.Ambient=oa
        Lighting.OutdoorAmbient=oo
        Lighting.ClockTime=oc
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
    end
end)

--=====================
-- HIDE / SHOW UI 
--=====================
local Circle = Instance.new("TextButton", ScreenGui)
Circle.Size = UDim2.new(0, 36, 0, 36)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.BackgroundColor3 = Color3.fromRGB(150,0,0)
Circle.Text = "+"
Circle.Visible = false
Circle.Font = Enum.Font.GothamBold
Circle.TextSize = 24
Circle.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
Circle.Active = true
Circle.Draggable = true

local HideBtn = Instance.new("TextButton")
HideBtn.Parent = MainFrame
HideBtn.Size = UDim2.new(0,25,0,25)
HideBtn.Position = UDim2.new(1,-30,0,5)
HideBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
Instance.new("UICorner",HideBtn).CornerRadius = UDim.new(0,6)

local uiHidden = false
HideBtn.MouseButton1Click:Connect(function()
    uiHidden = true
    MainFrame.Visible = false
    Circle.Visible = true
end)
Circle.MouseButton1Click:Connect(function()
    uiHidden = false
    MainFrame.Visible = true
    Circle.Visible = false
end)
