local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local PlayerGui=lp:WaitForChild("PlayerGui")
local testRemote=ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local KillersFolder=workspace:WaitForChild("Players"):WaitForChild("Killers")

local Rayfield=loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window=Rayfield:CreateWindow({Name="c00lBlock Script",KeySystem=false,ConfigurationSaving={Enabled=true,FolderName="by FoxOfficial",FileName="Settings"}})

local AutoBlockTab=Window:CreateTab("Auto Block")
local AutoPunchTab=Window:CreateTab("Auto Punch")
local TechTab=Window:CreateTab("Tech")
local OtherTab=Window:CreateTab("Other")

local autoBlockOn=false
local autoBlockAudioOn=false
local antiFlickOn=false
local autoPunchOn=false
local doubleblocktech=false
local hitboxDraggingTech=false
local detectionRange=12
local blockdelay=0
local antiFlickParts=4
local blockPartsSizeMultiplier=1
local predictionStrength=1
local predictionTurnStrength=1
local antiFlickDelay=0
local stagger=0.02
local antiFlickBaseOffset=2.7
local Dspeed=8.6
local Ddelay=0
local flingPunchOn=false
local flingPower=10000
local aimPunch=false
local predictionValue=1

local infStamina=false
local espEnabled=false

local killerNames={"c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher","Sixer","Nosferatu"}
local triggerSounds={["102228729296384"]=true,["140242176732868"]=true,["112809109188560"]=true,["136323728355613"]=true,["115026634746636"]=true,["84116622032112"]=true,["108907358619313"]=true,["127793641088496"]=true,["86174610237192"]=true,["95079963655241"]=true,["101199185291628"]=true,["119942598489800"]=true,["84307400688050"]=true,["113037804008732"]=true,["105200830849301"]=true,["75330693422988"]=true,["82221759983649"]=true,["81702359653578"]=true,["108610718831698"]=true,["112395455254818"]=true,["109431876587852"]=true,["109348678063422"]=true,["85853080745515"]=true,["12222216"]=true,["105840448036441"]=true,["114742322778642"]=true,["119583605486352"]=true,["79980897195554"]=true,["71805956520207"]=true,["79391273191671"]=true,["89004992452376"]=true,["101553872555606"]=true,["101698569375359"]=true,["106300477136129"]=true,["116581754553533"]=true,["117231507259853"]=true,["119089145505438"]=true,["121954639447247"]=true,["125213046326879"]=true,["131406927389838"]=true}
local triggerAnims={"126830014841198","126355327951215","121086746534252","18885909645","98456918873918","105458270463374","83829782357897","125403313786645","118298475669935","82113744478546","70371667919898","99135633258223","97167027849946","109230267448394","139835501033932","126896426760253","109667959938617","126681776859538","129976080405072","121293883585738","81639435858902","137314737492715","92173139187970"}

local cachedBlockBtn,cachedPunchBtn,cachedCharges,cachedCooldown
local function r()
    local m=PlayerGui:FindFirstChild("MainUI")
    if m then
        local a=m:FindFirstChild("AbilityContainer")
        cachedPunchBtn=a and a:FindFirstChild("Punch")
        cachedBlockBtn=a and a:FindFirstChild("Block")
        cachedCharges=cachedPunchBtn and cachedPunchBtn:FindFirstChild("Charges")
        cachedCooldown=cachedBlockBtn and cachedBlockBtn:FindFirstChild("CooldownTime")
    end
end
r()
PlayerGui.ChildAdded:Connect(function(c)if c.Name=="MainUI"then task.delay(0.02,r)end end)

local function fireBlock()testRemote:FireServer("UseActorAbility",{buffer.fromstring("\"Block\"")})end
local function firePunch()testRemote:FireServer("UseActorAbility",{buffer.fromstring("\"Punch\"")})end

AutoBlockTab:CreateToggle({Name="Auto Block (Animation)",Callback=function(v)autoBlockOn=v end})
AutoBlockTab:CreateToggle({Name="Auto Block (Audio)",Callback=function(v)autoBlockAudioOn=v end})
AutoBlockTab:CreateToggle({Name="Anti-Flick",Callback=function(v)antiFlickOn=v end})
AutoBlockTab:CreateSlider({Name="Range",Range={5,40},Increment=1,CurrentValue=18,Callback=function(v)detectionRange=v end})
AutoBlockTab:CreateInput({Name="Delay",PlaceholderText="0",Callback=function(t)blockdelay=tonumber(t)or 0 end})
AutoBlockTab:CreateSlider({Name="Parts",Range={1,16},Increment=1,CurrentValue=4,Callback=function(v)antiFlickParts=v end})
AutoBlockTab:CreateSlider({Name="Size",Range={0.1,5},Increment=0.1,CurrentValue=1,Callback=function(v)blockPartsSizeMultiplier=v end})
AutoBlockTab:CreateSlider({Name="Fwd Pred",Range={0,10},Increment=0.1,CurrentValue=1,Callback=function(v)predictionStrength=v end})
AutoBlockTab:CreateSlider({Name="Turn Pred",Range={0,10},Increment=0.1,CurrentValue=1,Callback=function(v)predictionTurnStrength=v end})
AutoBlockTab:CreateInput({Name="AF Delay",PlaceholderText="0",Callback=function(t)antiFlickDelay=tonumber(t)or 0 end})
AutoBlockTab:CreateInput({Name="Stagger",PlaceholderText="0.02",Callback=function(t)stagger=tonumber(t)or 0.02 end})

AutoPunchTab:CreateToggle({Name="Auto Punch",Callback=function(v)autoPunchOn=v end})
AutoPunchTab:CreateToggle({Name="Fling Punch",Callback=function(v)flingPunchOn=v end})
AutoPunchTab:CreateToggle({Name="Aimbot",Callback=function(v)aimPunch=v end})
AutoPunchTab:CreateSlider({Name="Fling Power",Range={5000,500000},Increment=5000,CurrentValue=10000,Callback=function(v)flingPower=v end})
AutoPunchTab:CreateSlider({Name="Aim Pred",Range={0,10},Increment=0.1,CurrentValue=4,Callback=function(v)predictionValue=v end})

TechTab:CreateToggle({Name="Double Punch",Callback=function(v)doubleblocktech=v end})
TechTab:CreateToggle({Name="HDT",Callback=function(v)hitboxDraggingTech=v end})
TechTab:CreateInput({Name="HDT Speed",PlaceholderText="5.6",Callback=function(t)Dspeed=tonumber(t)or 5.6 end})
TechTab:CreateInput({Name="HDT Delay",PlaceholderText="0",Callback=function(t)Ddelay=tonumber(t)or 0 end})

OtherTab:CreateButton({Name="Fake Block",Callback=function()loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidi399/Auto-block-script/main/fakeblock"))()end})
OtherTab:CreateToggle({Name="Infinite Stamina",Callback=function(v)infStamina=v end})
OtherTab:CreateToggle({Name="ESP Killers",Callback=function(v)espEnabled=v end})

local oldAmbient = Lighting.Ambient
local oldOutdoor = Lighting.OutdoorAmbient
local oldBrightness = Lighting.Brightness
local oldFogEnd = Lighting.FogEnd
local oldFogStart = Lighting.FogStart

local function enableFullBright()
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.Brightness = 4
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
end

local function disableFullBright()
    Lighting.Ambient = oldAmbient
    Lighting.OutdoorAmbient = oldOutdoor
    Lighting.Brightness = oldBrightness
    Lighting.FogEnd = oldFogEnd
    Lighting.FogStart = oldFogStart
end

local function createESP(model, outline, fill)
    if not model:FindFirstChildOfClass("Highlight") then
        local h = Instance.new("Highlight")
        h.Parent = model
        h.Adornee = model
        h.FillTransparency = 0.75
        h.FillColor = fill
        h.OutlineColor = outline
    end
end

local function clearESP()
    local PlayersFolder = workspace:FindFirstChild("Players")
    if PlayersFolder then
        for _, grp in ipairs(PlayersFolder:GetChildren()) do
            for _, plr in ipairs(grp:GetChildren()) do
                for _, obj in ipairs(plr:GetChildren()) do
                    if obj:IsA("Highlight") then obj:Destroy() end
                end
            end
        end
    end
    local mapFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
    if mapFolder then
        for _, obj in ipairs(mapFolder:GetChildren()) do
            for _, item in ipairs(obj:GetChildren()) do
                if item:IsA("Highlight") then item:Destroy() end
            end
        end
    end
end

local function applyESP()
    local PlayersFolder = workspace:FindFirstChild("Players")
    local killers = PlayersFolder and PlayersFolder:FindFirstChild("Killers")
    if killers then
        for _, m in ipairs(killers:GetChildren()) do
            if m:FindFirstChild("Humanoid") then
                createESP(m, Color3.new(1,0,0), Color3.new(1,0.3,0.3))
            end
        end
    end
    local survivors = PlayersFolder and PlayersFolder:FindFirstChild("Survivors")
    if survivors then
        for _, m in ipairs(survivors:GetChildren()) do
            if m:FindFirstChild("Humanoid") then
                createESP(m, Color3.new(0,1,0), Color3.new(0.4,1,0.4))
            end
        end
    end
    local mapFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
    if mapFolder then
        for _, obj in ipairs(mapFolder:GetChildren()) do
            if obj.Name == "Generator" then
                createESP(obj, Color3.new(1,1,0), Color3.new(1,1,0.4))
            elseif obj.Name == "BloxyCola" or obj.Name == "Medkit" then
                createESP(obj, Color3.fromRGB(0,255,255), Color3.fromRGB(0,200,255))
            end
        end
    end
end

task.spawn(function()
    local sprintModule = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
    local sprintReq = require(sprintModule)
    while task.wait(0.5) do
        if infStamina then
            if sprintReq.Stamina < 100 then sprintReq.Stamina=100 end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            enableFullBright()
            clearESP()
            applyESP()
        else
            disableFullBright()
            clearESP()
        end
    end
end)

local killerState={}
RunService.RenderStepped:Connect(function(dt)
for _,k in ipairs(KillersFolder:GetChildren())do
local hrp=k:FindFirstChild("HumanoidRootPart")
if hrp then
local s=killerState[k]or{prev=hrp.Position,vel=Vector3.new()}
s.vel=s.vel:Lerp((hrp.Position-s.prev)/dt,0.22)
s.prev=hrp.Position
killerState[k]=s
end
end
end)

local soundHooks={}
KillersFolder.DescendantAdded:Connect(function(d)
if d:IsA("Sound")and not soundHooks[d]then
local id=tostring(d.SoundId):match("%d+")
if triggerSounds[id]and autoBlockAudioOn then
soundHooks[d]=true
d.Played:Connect(function()
task.wait(blockdelay)
if cachedCooldown and cachedCooldown.Text==""then
fireBlock()
if doubleblocktech and cachedCharges and cachedCharges.Text=="1"then firePunch()end
end
end)
end
end
end)

local function af(killer)
if not antiFlickOn then return end
task.wait(antiFlickDelay)
for i=1,antiFlickParts do
local hrp=killer:FindFirstChild("HumanoidRootPart")
local my=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
if not hrp or not my then break end
local st=killerState[killer]or{vel=Vector3.new()}
local pred=hrp.Position+hrp.CFrame.LookVector*(antiFlickBaseOffset+(i-1)*0.2+st.vel.Magnitude*0.08*predictionStrength)
local p=Instance.new("Part",workspace)
p.Size=Vector3.new(5.5,7.5,8.5)*blockPartsSizeMultiplier
p.Transparency=0.5
p.Anchored=true
p.CanCollide=false
p.CFrame=CFrame.new(pred,hrp.Position)
p.Color=Color3.new(0,0.5,1)
game.Debris:AddItem(p,0.2)
if(p.Position-my.Position).Magnitude<8 then
fireBlock()
if doubleblocktech then firePunch()end
break
end
task.wait(stagger)
end
end

RunService.RenderStepped:Connect(function()
local my=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
if not my then return end

for _,k in ipairs(KillersFolder:GetChildren())do
local hrp=k:FindFirstChild("HumanoidRootPart")
if hrp and(hrp.Position-my.Position).Magnitude<=detectionRange then
for _,t in ipairs(k:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks())do
if table.find(triggerAnims,tostring(t.Animation.AnimationId):match("%d+"))and autoBlockOn then
task.wait(blockdelay)
if cachedCooldown and cachedCooldown.Text==""then
fireBlock()
if doubleblocktech then firePunch()end
af(k)
end
end
end
end
end

if autoPunchOn and cachedCharges and cachedCharges.Text=="1"then
for _,n in ipairs(killerNames)do
local k=KillersFolder:FindFirstChild(n)
if k and k:FindFirstChild("HumanoidRootPart")and(k.HumanoidRootPart.Position-my.Position).Magnitude<=10 then
firePunch()
if flingPunchOn then
task.spawn(function()
for i=1,30 do
if my and k:FindFirstChild("HumanoidRootPart")then
my.CFrame=CFrame.new(k.HumanoidRootPart.Position+k.HumanoidRootPart.CFrame.LookVector*2)
end
task.wait()
end
end)
end
break
end
end
end

if aimPunch then
lp.Character:FindFirstChildOfClass("Humanoid").AutoRotate=false
for _,n in ipairs(killerNames)do
local k=KillersFolder:FindFirstChild(n)
if k and k:FindFirstChild("HumanoidRootPart")then
my.CFrame=CFrame.lookAt(my.Position,k.HumanoidRootPart.Position+k.HumanoidRootPart.CFrame.LookVector*predictionValue)
end
end
end
end)

Rayfield:LoadConfiguration()
