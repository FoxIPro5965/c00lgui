--// c00lgui v0.4 + flowers mode just for fun//--
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
MainFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- Hitbox Label & Input
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Parent = MainFrame
BoxLabel.Position = UDim2.new(0,10,0,45)
BoxLabel.Size = UDim2.new(0,100,0,25)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Hack Hitbox :"
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 14
BoxLabel.TextColor3 = Color3.fromRGB(255,220,220)

local Box = Instance.new("TextBox")
Box.Parent = MainFrame
Box.Size = UDim2.new(0,60,0,25)
Box.Position = UDim2.new(0,120,0,45)
Box.BackgroundColor3 = Color3.fromRGB(90,20,20)
Box.Text = "20"
Box.TextColor3 = Color3.fromRGB(255,255,255)
Box.Font = Enum.Font.Gotham
Box.TextSize = 14
Instance.new("UICorner",Box).CornerRadius = UDim.new(0,6)

local Toggle = Instance.new("TextButton")
Toggle.Parent = MainFrame
Toggle.Size = UDim2.new(0,220,0,35)
Toggle.Position = UDim2.new(0,20,0,85)
Toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
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
SpeedLabel.TextColor3 = Color3.fromRGB(255,240,240)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(0,70,0,25)
SpeedBox.Position = UDim2.new(0,140,0,130)
SpeedBox.BackgroundColor3 = Color3.fromRGB(90,20,20)
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
JumpLabel.TextColor3 = Color3.fromRGB(255,240,240)

local JumpBox = Instance.new("TextBox")
JumpBox.Parent = MainFrame
JumpBox.Size = UDim2.new(0,70,0,25)
JumpBox.Position = UDim2.new(0,140,0,165)
JumpBox.BackgroundColor3 = Color3.fromRGB(90,20,20)
JumpBox.Text = "50"
JumpBox.TextColor3 = Color3.fromRGB(255,255,255)
JumpBox.Font = Enum.Font.Gotham
JumpBox.TextSize = 14
Instance.new("UICorner",JumpBox).CornerRadius = UDim.new(0,6)

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
ModeButton.BackgroundColor3 = Color3.fromRGB(100,0,0)
ModeButton.TextColor3 = Color3.fromRGB(255,255,255)
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 16
ModeButton.Text = "Mode: DEFAULT"
Instance.new("UICorner",ModeButton).CornerRadius = UDim.new(0,8)

--=============
-- PERFECT FLY
--=============
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local flying = false
local ctrl = { f = 0, b = 0, l = 0, r = 0, upd = 0, down = 0 }
local flySpeed = 80
local maxSpeed = 80
local connection

local bv, bg

local function startFly()
    if flying then return end
    flying = true

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    hum.PlatformStand = true

    -- BodyVelocity & BodyGyro
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 15000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    -- Input handling (works on mobile too because it reads PlayerModule)
    local controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()

    connection = RunService.RenderStepped:Connect(function()
        if not flying or not hrp or not hrp.Parent then return end

        local cam = workspace.CurrentCamera
        local moveDir = controls:GetMoveVector() -- works on PC + mobile joystick

        -- Reset directions
        ctrl.f, ctrl.b, ctrl.l, ctrl.r = 0,0,0,0
        if moveDir.Z < -0.1 then ctrl.f = 1 end
        if moveDir.Z > 0.1 then ctrl.b = 1 end
        if moveDir.X < -0.1 then ctrl.l = 1 end
        if moveDir.X > 0.1 then ctrl.r = 1 end

        -- Vertical (Space = up relative to camera, Ctrl = down)
        if UIS:IsKeyDown(Enum.KeyCode.Space) then ctrl.upd = 1 else ctrl.upd = 0 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.E) then ctrl.down = 1 else ctrl.down = 0 end

        local speed = flySpeed
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 2 end -- sprint in air

        -- Calculate final direction in camera space
        local camLook = cam.CFrame.LookVector
        local camRight = cam.CFrame.RightVector
        local camUp = cam.CFrame.UpVector

        local move = Vector3.new()
        if ctrl.f == 1 then move = move + camLook end
        if ctrl.b == 1 then move = move - camLook end
        if ctrl.r == 1 then move = move + camRight end
        if ctrl.l == 1 then move = move - camRight end
        if ctrl.upd == 1 then move = move + camUp end
        if ctrl.down == 1 then move = move - camUp end

        if move.Magnitude > 0 then
            move = move.Unit
            bv.Velocity = move * speed

            -- Rotate to face movement direction
            bg.CFrame = CFrame.new(Vector3.new(), move) * CFrame.new(hrp.Position)
        else
            bv.Velocity = Vector3.new(0,0,0)
        end
    end)
end

local function stopFly()
    flying = false
    if connection then connection:Disconnect() connection = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- Toggle with your mode button (mode 3 = fly)
ModeButton.MouseButton1Click:Connect(function()
    mode = mode % 3 + 1
    if mode == 1 then
        ModeButton.Text = "Mode: DEFAULT"
        stopFly()
        disableInfJump()
    elseif mode == 2 then
        ModeButton.Text = "Mode: INF JUMP"
        stopFly()
        enableInfJump()
    elseif mode == 3 then
        ModeButton.Text = "Mode: FLY"
        disableInfJump()
        startFly()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)
    if mode == 3 then startFly() end
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
FBButton.BackgroundColor3=Color3.fromRGB(120,100,0)
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
        FBButton.BackgroundColor3=Color3.fromRGB(120,100,0)
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
Circle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
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
HideBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
Instance.new("UICorner",HideBtn).CornerRadius = UDim.new(0,6)

local uiHidden = false

-- Ẩn menu khi nhấn HideBtn
HideBtn.MouseButton1Click:Connect(function()
    uiHidden = true
    MainFrame.Visible = false
    Circle.Visible = true
end)

-- Hiện menu khi nhấn Circle
Circle.MouseButton1Click:Connect(function()
    uiHidden = false
    MainFrame.Visible = true
    Circle.Visible = false
end)
