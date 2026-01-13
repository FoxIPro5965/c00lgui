local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LocalPlayer=Players.LocalPlayer

local ScreenGui=Instance.new("ScreenGui",game.CoreGui)
ScreenGui.ResetOnSpawn=false

local MainFrame=Instance.new("Frame",ScreenGui)
MainFrame.Size=UDim2.new(0,300,0,500)
MainFrame.Position=UDim2.new(0.35,0,0.25,0)
MainFrame.BackgroundColor3=Color3.fromRGB(0,0,0)
MainFrame.BorderSizePixel=2
MainFrame.BorderColor3=Color3.fromRGB(180,0,0)
MainFrame.Active=true
MainFrame.Draggable=true

local Title=Instance.new("TextLabel",MainFrame)
Title.Size=UDim2.new(1,-30,0,30)
Title.BackgroundTransparency=1
Title.Text="c00lgui"
Title.Font=Enum.Font.GothamBold
Title.TextSize=18
Title.TextColor3=Color3.fromRGB(255,255,255)

local Close=Instance.new("TextButton",MainFrame)
Close.Size=UDim2.new(0,30,0,30)
Close.Position=UDim2.new(1,-30,0,0)
Close.Text="X"
Close.Font=Enum.Font.GothamBold
Close.TextSize=18
Close.BackgroundColor3=Color3.fromRGB(120,0,0)
Close.TextColor3=Color3.fromRGB(255,255,255)

local Circle=Instance.new("TextButton",ScreenGui)
Circle.Size=UDim2.new(0,36,0,36)
Circle.Position=UDim2.new(0.02,0,0.5,0)
Circle.BackgroundColor3=Color3.fromRGB(120,0,0)
Circle.Text="+"
Circle.Font=Enum.Font.GothamBold
Circle.TextSize=22
Circle.TextColor3=Color3.fromRGB(255,255,255)
Circle.Visible=false
Circle.Active=true
Circle.Draggable=true

local function btn(y,t)
    local b=Instance.new("TextButton",MainFrame)
    b.Size=UDim2.new(0,260,0,35)
    b.Position=UDim2.new(0,20,0,y)
    b.Text=t
    b.Font=Enum.Font.GothamBold
    b.TextSize=15
    b.BackgroundColor3=Color3.fromRGB(120,0,0)
    b.TextColor3=Color3.fromRGB(255,255,255)
    return b
end

local function box(y,t,d)
    local l=Instance.new("TextLabel",MainFrame)
    l.Size=UDim2.new(0,120,0,25)
    l.Position=UDim2.new(0,20,0,y)
    l.BackgroundTransparency=1
    l.Text=t
    l.Font=Enum.Font.Gotham
    l.TextSize=14
    l.TextColor3=Color3.fromRGB(255,255,255)
    local b=Instance.new("TextBox",MainFrame)
    b.Size=UDim2.new(0,80,0,25)
    b.Position=UDim2.new(0,180,0,y)
    b.Text=d
    b.Font=Enum.Font.Gotham
    b.TextSize=14
    b.BackgroundColor3=Color3.fromRGB(30,0,0)
    b.TextColor3=Color3.fromRGB(255,255,255)
    return b
end

local Box=box(45,"Hitbox Size","20")
local Toggle=btn(80,"Hitbox: OFF")
local SpeedBox=box(125,"Speed","16")
local JumpBox=box(160,"Jump","50")
local ModeButton=btn(200,"Mode: DEFAULT")
local GodButton=btn(240,"GodMode: OFF")
local FBButton=btn(280,"FullBright: OFF")
local KiddButton=btn(320,"C00Lkidd Mode: OFF")

Close.MouseButton1Click:Connect(function()
    MainFrame.Visible=false
    Circle.Visible=true
end)
Circle.MouseButton1Click:Connect(function()
    MainFrame.Visible=true
    Circle.Visible=false
end)

local Enabled=false
local Size=tonumber(Box.Text) or 20

local function ExpandHitbox(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp=char.HumanoidRootPart
        hrp.Size=Vector3.new(Size,Size,Size)
        hrp.Transparency=0.7
        hrp.Material=Enum.Material.Neon
        hrp.BrickColor=BrickColor.new("Really red")
    end
end

local function ResetHitbox(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp=char.HumanoidRootPart
        hrp.Size=Vector3.new(2,2,1)
        hrp.Transparency=0
        hrp.Material=Enum.Material.Plastic
    end
end

Toggle.MouseButton1Click:Connect(function()
    Enabled=not Enabled
    Toggle.Text=Enabled and "Hitbox: ON" or "Hitbox: OFF"
    Toggle.BackgroundColor3=Enabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    if not Enabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                ResetHitbox(plr.Character)
            end
        end
    end
end)

Box.FocusLost:Connect(function()
    local v=tonumber(Box.Text)
    if v then Size=v else Box.Text=tostring(Size) end
end)

RunService.RenderStepped:Connect(function()
    if Enabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                ExpandHitbox(plr.Character)
            end
        end
    end
end)

SpeedBox.FocusLost:Connect(function()
    local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=tonumber(SpeedBox.Text) or h.WalkSpeed end
end)

JumpBox.FocusLost:Connect(function()
    local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.JumpPower=tonumber(JumpBox.Text) or h.JumpPower end
end)

local flying=false
local infjump=false
local mode=1
local bv,bg,flyConn,infConn=nil,nil,nil,nil
local flySpeed=80
local ctrl={}

local function enableInfJump()
    if infjump then return end
    infjump=true
    infConn=UIS.JumpRequest:Connect(function()
        local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState("Jumping") end
    end)
end

local function disableInfJump()
    infjump=false
    if infConn then infConn:Disconnect() infConn=nil end
end

local function startFly()
    if flying then return end
    flying=true
    local char=LocalPlayer.Character
    local root=char:WaitForChild("HumanoidRootPart")
    local hum=char:WaitForChild("Humanoid")
    hum.PlatformStand=true
    bv=Instance.new("BodyVelocity",root)
    bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    bg=Instance.new("BodyGyro",root)
    bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
    flyConn=RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        bv.Velocity=cam.CFrame.LookVector*flySpeed
        bg.CFrame=cam.CFrame
    end)
end

local function stopFly()
    flying=false
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if bv then bv:Destroy() bv=nil end
    if bg then bg:Destroy() bg=nil end
    local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand=false end
end

ModeButton.MouseButton1Click:Connect(function()
    mode+=1
    if mode>3 then mode=1 end
    stopFly()
    disableInfJump()
    if mode==1 then ModeButton.Text="Mode: DEFAULT"
    elseif mode==2 then ModeButton.Text="Mode: INF JUMP" enableInfJump()
    elseif mode==3 then ModeButton.Text="Mode: FLY" startFly() end
end)

local god=false
local godConn

GodButton.MouseButton1Click:Connect(function()
    god=not god
    GodButton.Text=god and "GodMode: ON" or "GodMode: OFF"
    GodButton.BackgroundColor3=god and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    if god then
        godConn=RunService.Stepped:Connect(function()
            local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _,p in ipairs(workspace:GetPartBoundsInRadius(hrp.Position,12)) do
                if p:IsA("BasePart") then p.CanTouch=false end
            end
        end)
    else
        if godConn then godConn:Disconnect() godConn=nil end
    end
end)
