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
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
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

--=====================
-- HITBOX
--=====================
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Parent = MainFrame
BoxLabel.Position = UDim2.new(0,10,0,45)
BoxLabel.Size = UDim2.new(0,100,0,25)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Hack Hitbox :"
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 14
BoxLabel.TextColor3 = Color3.fromRGB(255,255,255)

local Box = Instance.new("TextBox")
Box.Parent = MainFrame
Box.Size = UDim2.new(0,60,0,25)
Box.Position = UDim2.new(0,120,0,45)
Box.BackgroundColor3 = Color3.fromRGB(30,0,0)
Box.Text = "20"
Box.TextColor3 = Color3.fromRGB(255,255,255)
Box.Font = Enum.Font.Gotham
Box.TextSize = 14
Instance.new("UICorner",Box).CornerRadius = UDim.new(0,6)

local Toggle = Instance.new("TextButton")
Toggle.Parent = MainFrame
Toggle.Size = UDim2.new(0,220,0,35)
Toggle.Position = UDim2.new(0,20,0,85)
Toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Instance.new("UICorner",Toggle).CornerRadius = UDim.new(0,8)

--=====================
-- SPEED / JUMP
--=====================
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

local function applyStats()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local s = tonumber(SpeedBox.Text)
        local j = tonumber(JumpBox.Text)
        if s then char.Humanoid.WalkSpeed = s end
        if j then char.Humanoid.JumpPower = j end
    end
end
SpeedBox.FocusLost:Connect(applyStats)
JumpBox.FocusLost:Connect(applyStats)

--=====================
-- MODE (DEFAULT / INF JUMP / FLY)
--=====================
local ModeButton = Instance.new("TextButton")
ModeButton.Parent = MainFrame
ModeButton.Size = UDim2.new(0,220,0,35)
ModeButton.Position = UDim2.new(0,20,0,205)
ModeButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
ModeButton.Text = "Mode: DEFAULT"
ModeButton.TextColor3 = Color3.fromRGB(255,255,255)
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 16
Instance.new("UICorner",ModeButton).CornerRadius = UDim.new(0,8)

local mode = 1
local infConn
local flying = false
local bv,bg,flyConn

local function enableInfJump()
    infConn = UIS.JumpRequest:Connect(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end)
end

local function disableInfJump()
    if infConn then infConn:Disconnect() infConn=nil end
end

local function startFly()
    if flying then return end
    flying=true
    local char=LocalPlayer.Character
    local root=char.HumanoidRootPart
    local hum=char.Humanoid
    hum.PlatformStand=true
    bv=Instance.new("BodyVelocity",root)
    bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    bg=Instance.new("BodyGyro",root)
    bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
    flyConn=RunService.RenderStepped:Connect(function()
        bv.Velocity=workspace.CurrentCamera.CFrame.LookVector*80
        bg.CFrame=workspace.CurrentCamera.CFrame
    end)
end

local function stopFly()
    flying=false
    if flyConn then flyConn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand=false end
end

ModeButton.MouseButton1Click:Connect(function()
    mode+=1
    if mode>3 then mode=1 end
    disableInfJump()
    stopFly()
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

local fb=false
FBButton.MouseButton1Click:Connect(function()
    fb=not fb
    FBButton.Text=fb and "FullBright: ON" or "FullBright: OFF"
    Lighting.Brightness=fb and 2 or 1
end)

--=====================
-- KILLBRICK (ONLY ADDED)
--=====================
local KillButton = Instance.new("TextButton")
KillButton.Parent=MainFrame
KillButton.Size=UDim2.new(0,220,0,35)
KillButton.Position=UDim2.new(0,20,0,285)
KillButton.BackgroundColor3=Color3.fromRGB(150,0,0)
KillButton.Text="KillBrick: OFF"
KillButton.TextColor3=Color3.fromRGB(255,255,255)
KillButton.Font=Enum.Font.GothamBold
KillButton.TextSize=16
Instance.new("UICorner",KillButton).CornerRadius=UDim.new(0,8)

local kill=false
KillButton.MouseButton1Click:Connect(function()
    kill=not kill
    KillButton.Text=kill and "KillBrick: ON" or "KillBrick: OFF"
    KillButton.BackgroundColor3=kill and Color3.fromRGB(0,180,0) or Color3.fromRGB(150,0,0)
end)

RunService.RenderStepped:Connect(function()
    if kill then
        local char=LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _,p in ipairs(workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position,10)) do
                if p:IsA("BasePart") then
                    p.CanTouch=false
                end
            end
        end
    end
end)
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
