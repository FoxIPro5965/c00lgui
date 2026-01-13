local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LocalPlayer=Players.LocalPlayer

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="c00lgui"
ScreenGui.Parent=game.CoreGui
ScreenGui.ResetOnSpawn=false

local MainFrame=Instance.new("Frame")
MainFrame.Parent=ScreenGui
MainFrame.Size=UDim2.new(0,300,0,420)
MainFrame.Position=UDim2.new(0.35,0,0.3,0)
MainFrame.BackgroundColor3=Color3.fromRGB(0,0,0)
MainFrame.BorderSizePixel=2
MainFrame.BorderColor3=Color3.fromRGB(180,0,0)
MainFrame.Active=true
MainFrame.Draggable=true

local Title=Instance.new("TextLabel")
Title.Parent=MainFrame
Title.Size=UDim2.new(1,0,0,30)
Title.BackgroundTransparency=1
Title.Text="c00lgui"
Title.Font=Enum.Font.GothamBold
Title.TextSize=18
Title.TextColor3=Color3.fromRGB(255,255,255)

local function button(y,text)
    local b=Instance.new("TextButton")
    b.Parent=MainFrame
    b.Size=UDim2.new(0,260,0,35)
    b.Position=UDim2.new(0,20,0,y)
    b.BackgroundColor3=Color3.fromRGB(120,0,0)
    b.BorderSizePixel=0
    b.Text=text
    b.Font=Enum.Font.GothamBold
    b.TextSize=15
    b.TextColor3=Color3.fromRGB(255,255,255)
    return b
end

local function box(y,text,def)
    local l=Instance.new("TextLabel")
    l.Parent=MainFrame
    l.Size=UDim2.new(0,120,0,25)
    l.Position=UDim2.new(0,20,0,y)
    l.BackgroundTransparency=1
    l.Text=text
    l.Font=Enum.Font.Gotham
    l.TextSize=14
    l.TextColor3=Color3.fromRGB(255,255,255)

    local b=Instance.new("TextBox")
    b.Parent=MainFrame
    b.Size=UDim2.new(0,80,0,25)
    b.Position=UDim2.new(0,180,0,y)
    b.BackgroundColor3=Color3.fromRGB(30,0,0)
    b.BorderSizePixel=0
    b.Text=def
    b.Font=Enum.Font.Gotham
    b.TextSize=14
    b.TextColor3=Color3.fromRGB(255,255,255)
    return b
end

local HitboxSizeBox=box(45,"Hitbox Size","20")
local HitboxToggle=button(80,"Hitbox: OFF")

local SpeedBox=box(125,"Speed","16")
local JumpBox=box(160,"Jump","50")

local ModeButton=button(200,"Mode: DEFAULT")
local GodButton=button(240,"GodMode: OFF")
local FullBrightButton=button(280,"FullBright: OFF")
local HideButton=button(320,"Hide UI")

local Circle=Instance.new("TextButton")
Circle.Parent=ScreenGui
Circle.Size=UDim2.new(0,36,0,36)
Circle.Position=UDim2.new(0.5,0,0.5,0)
Circle.BackgroundColor3=Color3.fromRGB(120,0,0)
Circle.Text="+"
Circle.Font=Enum.Font.GothamBold
Circle.TextSize=22
Circle.TextColor3=Color3.fromRGB(255,255,255)
Circle.Visible=false
Circle.Active=true
Circle.Draggable=true

local function applyStats()
    local c=LocalPlayer.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then
        local s=tonumber(SpeedBox.Text)
        local j=tonumber(JumpBox.Text)
        if s then h.WalkSpeed=s end
        if j then h.JumpPower=j end
    end
end
SpeedBox.FocusLost:Connect(applyStats)
JumpBox.FocusLost:Connect(applyStats)

local Hitboxes={}
local HitboxOn=false
local HitboxSize=20

local function createHitbox(char)
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp or Hitboxes[char] then return end
    local p=Instance.new("Part")
    p.Size=Vector3.new(HitboxSize,HitboxSize,HitboxSize)
    p.Transparency=0.6
    p.Material=Enum.Material.Neon
    p.Color=Color3.fromRGB(255,0,0)
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.Massless=true
    p.Parent=char
    local w=Instance.new("WeldConstraint",p)
    w.Part0=hrp
    w.Part1=p
    p.CFrame=hrp.CFrame
    Hitboxes[char]=p
end

local function removeHitbox(char)
    if Hitboxes[char] then
        Hitboxes[char]:Destroy()
        Hitboxes[char]=nil
    end
end

HitboxToggle.MouseButton1Click:Connect(function()
    HitboxOn=not HitboxOn
    HitboxToggle.Text=HitboxOn and "Hitbox: ON" or "Hitbox: OFF"
    HitboxToggle.BackgroundColor3=HitboxOn and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    if not HitboxOn then
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then removeHitbox(p.Character) end
        end
    end
end)

HitboxSizeBox.FocusLost:Connect(function()
    local v=tonumber(HitboxSizeBox.Text)
    if v and v>0 then
        HitboxSize=v
        for _,h in pairs(Hitboxes) do
            if h then h.Size=Vector3.new(v,v,v) end
        end
    else
        HitboxSizeBox.Text=tostring(HitboxSize)
    end
end)

RunService.RenderStepped:Connect(function()
    if HitboxOn then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                createHitbox(p.Character)
            end
        end
    end
end)

local godOn=false
local godConn

GodButton.MouseButton1Click:Connect(function()
    godOn=not godOn
    GodButton.Text=godOn and "GodMode: ON" or "GodMode: OFF"
    GodButton.BackgroundColor3=godOn and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    if godOn then
        godConn=RunService.Stepped:Connect(function()
            local c=LocalPlayer.Character
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _,p in ipairs(workspace:GetPartBoundsInRadius(hrp.Position,12)) do
                if p:IsA("BasePart") then
                    p.CanTouch=false
                end
            end
        end)
    else
        if godConn then godConn:Disconnect() godConn=nil end
    end
end)

local fbOn=false
local ob,oa,oo,oc=Lighting.Brightness,Lighting.Ambient,Lighting.OutdoorAmbient,Lighting.ClockTime

FullBrightButton.MouseButton1Click:Connect(function()
    fbOn=not fbOn
    FullBrightButton.Text=fbOn and "FullBright: ON" or "FullBright: OFF"
    FullBrightButton.BackgroundColor3=fbOn and Color3.fromRGB(0,150,0) or Color3.fromRGB(120,0,0)
    if fbOn then
        Lighting.Brightness=2
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        Lighting.ClockTime=12
    else
        Lighting.Brightness=ob
        Lighting.Ambient=oa
        Lighting.OutdoorAmbient=oo
        Lighting.ClockTime=oc
    end
end)

HideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible=false
    Circle.Visible=true
end)

Circle.MouseButton1Click:Connect(function()
    MainFrame.Visible=true
    Circle.Visible=false
end)
