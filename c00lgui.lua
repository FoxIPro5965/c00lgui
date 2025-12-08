--// c00lgui v0.3 fixFly //-- 
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
MainFrame.Size = UDim2.new(0, 260, 0, 295)
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
Title.Text = "c00lgui v0.3"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- Label
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Parent = MainFrame
BoxLabel.Position = UDim2.new(0,10,0,45)
BoxLabel.Size = UDim2.new(0,100,0,25)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Hack Hitbox :"
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 14
BoxLabel.TextColor3 = Color3.fromRGB(255,220,220)

-- Input
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

-- Toggle Hitbox
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

-- SPEED
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

-- JUMP
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

-- Apply Speed/Jump
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

local mode = 1
local flying = false
local infjump = false

local BodyGyro = nil
local BodyVelocity = nil
local flySpeed = 60

--=====================
-- FLY HD ADMIN MOBILE
--=====================
local function applyFlyForces(char)
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BodyGyro.P = 30000
    BodyGyro.Parent = hrp

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    BodyVelocity.Parent = hrp
end

local flyLoop = nil

local function enableFly()
    flying = true

    local char = LocalPlayer.Character
    if not char then return end

    applyFlyForces(char)

    flyLoop = RunService.RenderStepped:Connect(function()
        if not flying then return end

        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        local cam = workspace.CurrentCamera
        local moveDir = hum.MoveDirection
        local camDir = cam.CFrame.LookVector

        -- HD ADMIN STYLE
        local horizontal = Vector3.new(moveDir.X,0,moveDir.Z)
        local vertical = Vector3.new(0,camDir.Y,0)

        local flyVector = (horizontal + vertical) * flySpeed
        BodyVelocity.Velocity = flyVector

        if flyVector.Magnitude > 0.2 then
            BodyGyro.CFrame = CFrame.new(Vector3.zero, flyVector)
        end
    end)
end

local function disableFly()
    flying = false
    if flyLoop then flyLoop:Disconnect() end
    flyLoop = nil

    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    wait(1)
    if mode == 3 then
        enableFly()
    end
end)

--=====================
-- INF JUMP
--=====================
local jumpConnection = nil
local function enableInfJump()
    infjump = true
    if jumpConnection then jumpConnection:Disconnect() end
    jumpConnection = UIS.JumpRequest:Connect(function()
        if infjump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end)
end

local function disableInfJump()
    infjump = false
    if jumpConnection then jumpConnection:Disconnect() end
end

-- Switch mode
ModeButton.MouseButton1Click:Connect(function()
    mode += 1
    if mode > 3 then mode = 1 end

    if mode == 1 then
        ModeButton.Text = "Mode: DEFAULT"
        disableFly()
        disableInfJump()

    elseif mode == 2 then
        ModeButton.Text = "Mode: INF JUMP"
        disableFly()
        enableInfJump()

    elseif mode == 3 then
        ModeButton.Text = "Mode: FLY"
        disableInfJump()
        enableFly()
    end
end)

--=====================
-- HITBOX
--=====================
local Enabled = false
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
        hrp.Transparency = 0
        hrp.Material = Enum.Material.Plastic
    end
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,150,0)
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)

        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                ResetHitbox(plr.Character)
            end
        end
    end
end)

Box.FocusLost:Connect(function()
    local val = tonumber(Box.Text)
    if val and val > 0 then
        Size = val
    else
        Box.Text = tostring(Size)
    end
end)

RunService.RenderStepped:Connect(function()
    if Enabled then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                ExpandHitbox(plr.Character)
            end
        end
    end
end)

--=====================
-- FULLBRIGHT
--=====================
local FBButton = Instance.new("TextButton")
FBButton.Parent = MainFrame
FBButton.Size = UDim2.new(0,220,0,35)
FBButton.Position = UDim2.new(0,20,0,245)
FBButton.BackgroundColor3 = Color3.fromRGB(120,100,0)
FBButton.Text = "FullBright: OFF"
FBButton.TextColor3 = Color3.fromRGB(255,255,255)
FBButton.Font = Enum.Font.GothamBold
FBButton.TextSize = 16
Instance.new("UICorner",FBButton).CornerRadius = UDim.new(0,8)

local fbOn = false
local ob = Lighting.Brightness
local oa = Lighting.Ambient
local oo = Lighting.OutdoorAmbient
local oc = Lighting.ClockTime

local function applyDaySky()
    for _,v in pairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    local sky = Instance.new("Sky", Lighting)
    sky.SkyboxBk = "rbxassetid://7018684000"
    sky.SkyboxDn = "rbxassetid://7018684000"
    sky.SkyboxFt = "rbxassetid://7018684000"
    sky.SkyboxLf = "rbxassetid://7018684000"
    sky.SkyboxRt = "rbxassetid://7018684000"
    sky.SkyboxUp = "rbxassetid://7018684000"
end

FBButton.MouseButton1Click:Connect(function()
    fbOn = not fbOn
    if fbOn then
        FBButton.Text = "FullBright: ON"
        FBButton.BackgroundColor3 = Color3.fromRGB(0,180,0)

        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.ClockTime = 12
        applyDaySky()
    else
        FBButton.Text = "FullBright: OFF"
        FBButton.BackgroundColor3 = Color3.fromRGB(120,100,0)

        Lighting.Brightness = ob
        Lighting.Ambient = oa
        Lighting.OutdoorAmbient = oo
        Lighting.ClockTime = oc

        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
    end
end)

--=====================
-- HIDE UI
--=====================
local HideBtn = Instance.new("TextButton")
HideBtn.Parent = MainFrame
HideBtn.Size = UDim2.new(0,25,0,25)
HideBtn.Position = UDim2.new(1,-30,0,5)
HideBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
Instance.new("UICorner",HideBtn).CornerRadius = UDim.new(1,0)

local Circle = Instance.new("TextButton")
Circle.Parent = ScreenGui
Circle.Size = UDim2.new(0,40,0,40)
Circle.Position = UDim2.new(0.5,0,0.5,0)
Circle.BackgroundColor3 = Color3.fromRGB(200,0,0)
Circle.Text = "+"
Circle.TextColor3 = Color3.fromRGB(255,255,255)
Circle.Font = Enum.Font.GothamBold
Circle.TextSize = 24
Circle.Visible = false
Instance.new("UICorner",Circle).CornerRadius = UDim.new(1,0)
Circle.Active = true
Circle.Draggable = true

HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Circle.Visible = true
end)

Circle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    Circle.Visible = false
end)
