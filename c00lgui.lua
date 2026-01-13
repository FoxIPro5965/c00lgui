local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LocalPlayer=Players.LocalPlayer

local ScreenGui=Instance.new("ScreenGui",game.CoreGui)
ScreenGui.ResetOnSpawn=false

local MainFrame=Instance.new("Frame",ScreenGui)
MainFrame.Size=UDim2.new(0,280,0,380)
MainFrame.Position=UDim2.new(0.35,0,0.3,0)
MainFrame.BackgroundColor3=Color3.fromRGB(0,0,0)
MainFrame.BorderSizePixel=2
MainFrame.BorderColor3=Color3.fromRGB(180,0,0)
MainFrame.Active=true
MainFrame.Draggable=true

local Title=Instance.new("TextLabel",MainFrame)
Title.Size=UDim2.new(1,0,0,30)
Title.BackgroundTransparency=1
Title.Text="c00lgui v0.4"
Title.Font=Enum.Font.GothamBold
Title.TextSize=19
Title.TextColor3=Color3.new(1,1,1)

local function mkBtn(y,t)
 local b=Instance.new("TextButton",MainFrame)
 b.Size=UDim2.new(0,240,0,34)
 b.Position=UDim2.new(0,20,0,y)
 b.BackgroundColor3=Color3.fromRGB(150,0,0)
 b.BorderSizePixel=0
 b.Text=t
 b.Font=Enum.Font.GothamBold
 b.TextSize=16
 b.TextColor3=Color3.new(1,1,1)
 return b
end

local function mkBox(x,y,txt)
 local b=Instance.new("TextBox",MainFrame)
 b.Size=UDim2.new(0,70,0,25)
 b.Position=UDim2.new(0,x,0,y)
 b.BackgroundColor3=Color3.fromRGB(30,0,0)
 b.BorderSizePixel=0
 b.Text=txt
 b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.Gotham
 b.TextSize=14
 return b
end

local SpeedBox=mkBox(160,45,"16")
local JumpBox=mkBox(160,75,"50")

local function applyStats()
 local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
 if h then
  h.WalkSpeed=tonumber(SpeedBox.Text) or h.WalkSpeed
  h.JumpPower=tonumber(JumpBox.Text) or h.JumpPower
 end
end
SpeedBox.FocusLost:Connect(applyStats)
JumpBox.FocusLost:Connect(applyStats)

local ModeBtn=mkBtn(110,"Mode: DEFAULT")
local flying=false
local infjump=false
local mode=1
local bv,bg,flyConn,infConn

local function infOn()
 if infjump then return end
 infjump=true
 infConn=UIS.JumpRequest:Connect(function()
  local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
  if h then h:ChangeState("Jumping") end
 end)
end

local function infOff()
 infjump=false
 if infConn then infConn:Disconnect() infConn=nil end
end

local function flyOn()
 if flying then return end
 flying=true
 local c=LocalPlayer.Character
 local hrp=c.HumanoidRootPart
 local h=c.Humanoid
 h.PlatformStand=true
 bv=Instance.new("BodyVelocity",hrp)
 bv.MaxForce=Vector3.new(9e9,9e9,9e9)
 bg=Instance.new("BodyGyro",hrp)
 bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
 local controls=require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
 flyConn=RunService.RenderStepped:Connect(function()
  local cam=workspace.CurrentCamera
  local mv=controls:GetMoveVector()
  local dir=cam.CFrame:VectorToWorldSpace(Vector3.new(mv.X,0,mv.Z))
  bv.Velocity=dir*80
  bg.CFrame=cam.CFrame
 end)
end

local function flyOff()
 flying=false
 if flyConn then flyConn:Disconnect() flyConn=nil end
 if bv then bv:Destroy() bv=nil end
 if bg then bg:Destroy() bg=nil end
 local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
 if h then h.PlatformStand=false end
end

ModeBtn.MouseButton1Click:Connect(function()
 mode+=1
 if mode>3 then mode=1 end
 flyOff()
 infOff()
 if mode==1 then ModeBtn.Text="Mode: DEFAULT" end
 if mode==2 then ModeBtn.Text="Mode: INF JUMP" infOn() end
 if mode==3 then ModeBtn.Text="Mode: FLY" flyOn() end
end)

local HitBtn=mkBtn(150,"Hitbox: OFF")
local hitOn=false
local hitSize=20

RunService.RenderStepped:Connect(function()
 if hitOn then
  for _,p in ipairs(Players:GetPlayers()) do
   if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
    local h=p.Character.HumanoidRootPart
    h.Size=Vector3.new(hitSize,hitSize,hitSize)
    h.Transparency=1
    h.Material=Enum.Material.Neon
    h.BrickColor=BrickColor.new("Really red")
   end
  end
 end
end)

HitBtn.MouseButton1Click:Connect(function()
 hitOn=not hitOn
 HitBtn.Text=hitOn and "Hitbox: ON" or "Hitbox: OFF"
 HitBtn.BackgroundColor3=hitOn and Color3.fromRGB(0,170,0) or Color3.fromRGB(150,0,0)
end)

local FBBtn=mkBtn(190,"FullBright: OFF")
local fb=false
local ob,oa,oo,oc=Lighting.Brightness,Lighting.Ambient,Lighting.OutdoorAmbient,Lighting.ClockTime

FBBtn.MouseButton1Click:Connect(function()
 fb=not fb
 FBBtn.Text=fb and "FullBright: ON" or "FullBright: OFF"
 FBBtn.BackgroundColor3=fb and Color3.fromRGB(0,170,0) or Color3.fromRGB(150,0,0)
 if fb then
  Lighting.Brightness=5
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

local GodBtn=mkBtn(230,"GodMode: OFF")
local god=false
local godConn

GodBtn.MouseButton1Click:Connect(function()
 god=not god
 GodBtn.Text=god and "GodMode: ON" or "GodMode: OFF"
 GodBtn.BackgroundColor3=god and Color3.fromRGB(0,170,0) or Color3.fromRGB(150,0,0)
 if god then
  godConn=RunService.Heartbeat:Connect(function()
   local c=LocalPlayer.Character
   if c and c:FindFirstChild("HumanoidRootPart") then
    for _,p in ipairs(workspace:GetPartBoundsInRadius(c.HumanoidRootPart.Position,10)) do
     p.CanTouch=false
    end
   end
  end)
 else
  if godConn then godConn:Disconnect() godConn=nil end
 end
end)

local Hide=Instance.new("TextButton",MainFrame)
Hide.Size=UDim2.new(0,25,0,25)
Hide.Position=UDim2.new(1,-30,0,5)
Hide.Text="-"
Hide.Font=Enum.Font.GothamBold
Hide.TextSize=18
Hide.TextColor3=Color3.new(1,1,1)
Hide.BackgroundColor3=Color3.fromRGB(150,0,0)
Hide.BorderSizePixel=0

local Mini=Instance.new("TextButton",ScreenGui)
Mini.Size=UDim2.new(0,36,0,36)
Mini.Position=UDim2.new(0.5,0,0.5,0)
Mini.Text="+"
Mini.Visible=false
Mini.Font=Enum.Font.GothamBold
Mini.TextSize=24
Mini.TextColor3=Color3.new(1,1,1)
Mini.BackgroundColor3=Color3.fromRGB(150,0,0)
Mini.BorderSizePixel=0
Mini.Active=true
Mini.Draggable=true

Hide.MouseButton1Click:Connect(function()
 MainFrame.Visible=false
 Mini.Visible=true
end)

Mini.MouseButton1Click:Connect(function()
 MainFrame.Visible=true
 Mini.Visible=false
end)
