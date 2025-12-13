-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local Humanoid

-- GUI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "c00lBlock",
    LoadingTitle = "c00lBlock Script",
    LoadingSubtitle = "by FoxOfficial",
    ConfigurationSaving = {Enabled = true, FolderName = "Auto Block", FileName = "Settings"},
    Discord = {Enabled = false},
    KeySystem = false
})

local AutoBlockTab = Window:CreateTab("Auto Block", 4483362458)
local PredictiveTab = Window:CreateTab("Predictive Auto Block", 4483362458)
local AutoPunchTab = Window:CreateTab("Auto Punch", 4483362458)
local HitboxDragTab = Window:CreateTab("Tech", 4483362458)
local OtherTab = Window:CreateTab("Other", 4483362458)

-- Attack IDs
local attackIds = {
    "126830014841198","126355327951215","121086746534252","18885909645",
    "98456918873918","105458270463374","83829782357897","125403313786645",
    "118298475669935","82113744478546","70371667919898","99135633258223",
    "97167027849946","109230267448394","139835501033932","126896426760253",
    "109667959938617","126681776859538","129976080405072","121293883585738",
    "81639435858902","137314737492715","92173139187970","122709416391",
    "879895330952","102228729296384","140242176732868","112809109188560",
    "136323728355613","115026634746636","84116622032112","108907358619313",
    "127793641088496","86174610237192","95079963655241","101199185291628",
    "119942598489800","84307400688050","113037804008732","105200830849301",
    "75330693422988","82221759983649","81702359653578","108610718831698",
    "112395455254818","109431876587852","109348678063422","85853080745515",
    "12222216","105840448036441","114742322778642","119583605486352",
    "79980897195554","71805956520207","79391273191671","89004992452376",
    "101553872555606","101698569375359","106300477136129","116581754553533",
    "117231507259853","119089145505438","121954639447247","125213046326879",
    "131406927389838","71834552297085","805165833096"
}

local blockAnimIds = {"72722244508749","96959123077498","95802026624883"}
local punchAnimIds = {"87259391926321","140703210927645","136007065400978","129843313690921","86709774283672","108807732150251","138040001965654","86096387000557"}

-- Variables
local autoBlockOn, strictRangeOn, facingCheckEnabled = false, false, true
local detectionRange = 12
local predictiveBlockOn, predictiveDetectionRange, edgeKillerDelay, killerInRangeSince, predictiveCooldown = false, 10, 3, nil, 0
local autoPunchOn, aimPunch, predictionValue = false, false, 0.8
local infStaminaEnabled, espEnabled = false, false
local hitboxDraggingTech, _hitboxDraggingDebounce = false, false
local HITBOX_DRAG_DURATION, HITBOX_DETECT_RADIUS, Dspeed, Ddelay = 1.4, 6, 8.6, 0

-- Save old lighting
local oldAmbient, oldOutdoor, oldBrightness, oldFogEnd, oldFogStart = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.Brightness, Lighting.FogEnd, Lighting.FogStart

-- GUI toggles/sliders
AutoBlockTab:CreateToggle({Name="Auto Block", CurrentValue=false, Callback=function(v) autoBlockOn=v end})
AutoBlockTab:CreateToggle({Name="Strict Range", CurrentValue=false, Callback=function(v) strictRangeOn=v end})
AutoBlockTab:CreateToggle({Name="Enable Facing Check", CurrentValue=true, Callback=function(v) facingCheckEnabled=v end})
AutoBlockTab:CreateInput({Name="Detection Range", PlaceholderText="12", Callback=function(txt) detectionRange=tonumber(txt) or detectionRange end})

PredictiveTab:CreateToggle({Name="Predictive Auto Block", CurrentValue=false, Callback=function(v) predictiveBlockOn=v end})
PredictiveTab:CreateInput({Name="Detection Range", PlaceholderText="10", Callback=function(txt)local n=tonumber(txt) if n then predictiveDetectionRange=n end end})
PredictiveTab:CreateSlider({Name="Edge Killer", Range={0,7}, Increment=0.1, CurrentValue=3, Callback=function(v) edgeKillerDelay=v end})

AutoPunchTab:CreateToggle({Name="Auto Punch", CurrentValue=false, Callback=function(v) autoPunchOn=v end})
AutoPunchTab:CreateToggle({Name="Punch Aimbot", CurrentValue=false, Callback=function(v) aimPunch=v end})
AutoPunchTab:CreateSlider({Name="Aim Prediction", Range={0,10}, Increment=0.1, CurrentValue=1, Suffix="studs", Callback=function(v) predictionValue=v end})

OtherTab:CreateToggle({Name="Infinite Stamina", CurrentValue=false, Callback=function(v) infStaminaEnabled=v end})
OtherTab:CreateToggle({Name="ESP + FullBright", CurrentValue=false, Callback=function(v) espEnabled=v if v then Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1) Lighting.Brightness=6 else Lighting.Ambient=oldAmbient Lighting.OutdoorAmbient=oldOutdoor Lighting.Brightness=oldBrightness end end})
OtherTab:CreateButton({Name="Load Fake Block", Callback=function() pcall(function() local gui=PlayerGui:FindFirstChild("FakeBlockGui") if not gui then loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidi399/Auto-block-script/main/fakeblock"))() else gui.Enabled=true end end) end})

HitboxDragTab:CreateToggle({Name="Hitbox Drag Tech", CurrentValue=false, Callback=function(v) hitboxDraggingTech=v end})
HitboxDragTab:CreateSlider({Name="Drag Speed", Range={1,100}, Increment=16, CurrentValue=Dspeed, Callback=function(v) Dspeed=v end})
HitboxDragTab:CreateSlider({Name="Drag Delay", Range={0,5}, Increment=0.01, CurrentValue=Ddelay, Suffix="s", Callback=function(v) Ddelay=v end})
HitboxDragTab:CreateSlider({Name="Detect Radius", Range={1,100}, Increment=30, CurrentValue=HITBOX_DETECT_RADIUS, Suffix="studs", Callback=function(v) HITBOX_DETECT_RADIUS=v end})
HitboxDragTab:CreateSlider({Name="Drag Duration", Range={0.3,3}, Increment=0.1, CurrentValue=HITBOX_DRAG_DURATION, Suffix="s", Callback=function(v) HITBOX_DRAG_DURATION=v end})

-- Functions
local function clickBlockButton()
    local gui = lp:FindFirstChild("PlayerGui")
    if not gui then return end
    local mainUI = gui:FindFirstChild("MainUI")
    local container = mainUI and mainUI:FindFirstChild("AbilityContainer")
    local blockButton = container and container:FindFirstChild("Block")
    if blockButton and blockButton.Visible then
        pcall(function()
            for _, conn in ipairs(getconnections(blockButton.MouseButton1Click) or {}) do
                conn:Fire()
            end
        end)
    end
end

local function isFacing(localRoot,targetRoot)
    if not facingCheckEnabled then return true end
    if not localRoot or not targetRoot then return false end
    local dir=(localRoot.Position-targetRoot.Position).Unit
    local dot=targetRoot.CFrame.LookVector:Dot(dir)
    return dot>0
end

local checked={}
local function detectAttack(char)
    if checked[char] then return false end
    local humanoid=char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _,track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            local id=track.Animation and tostring(track.Animation.AnimationId):match("%d+")
            if id and table.find(attackIds,id) then
                checked[char]=true
                task.spawn(function() pcall(function() track.Stopped:Wait() end) checked[char]=nil end)
                return true
            end
        end
    end
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("Sound") and d.IsPlaying then
            local id=tostring(d.SoundId):match("%d+")
            if id and table.find(attackIds,id) then
                checked[char]=true
                task.delay(0.001,function() checked[char]=nil end)
                return true
            end
        end
    end
    return false
end

local function getKillerHRP(killerModel)
    return killerModel and (killerModel:FindFirstChild("HumanoidRootPart") or killerModel.PrimaryPart or killerModel:FindFirstChildWhichIsA("BasePart",true))
end

local function getNearestKillerModel()
    local myRoot=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest=nil
    local closestDist=HITBOX_DETECT_RADIUS
    local killersFolder=workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        for _,killer in ipairs(killersFolder:GetChildren()) do
            local kRoot=getKillerHRP(killer)
            if kRoot then
                local dist=(kRoot.Position-myRoot.Position).Magnitude
                if dist<closestDist then closestDist=dist closest=killer end
            end
        end
    end
    return closest
end

local function beginDragIntoKiller(killerModel)
    if _hitboxDraggingDebounce or not killerModel or not killerModel.Parent then return end
    local char=lp.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local humanoid=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    local targetHRP=getKillerHRP(killerModel)
    if not targetHRP then return end

    _hitboxDraggingDebounce=true
    local oldWalk=humanoid.WalkSpeed
    local oldJump=humanoid.JumpPower
    humanoid.WalkSpeed=0
    humanoid.JumpPower=0

    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,0,1e5)
    bv.Velocity=Vector3.zero
    bv.Parent=hrp

    local startTime=tick()
    local conn
    conn=RunService.Heartbeat:Connect(function()
        if not _hitboxDraggingDebounce or tick()-startTime>HITBOX_DRAG_DURATION then
            _hitboxDraggingDebounce=false
            if bv and bv.Parent then bv:Destroy() end
            humanoid.WalkSpeed=oldWalk
            humanoid.JumpPower=oldJump
            if conn then conn:Disconnect() end
            return
        end
        if not (char.Parent and killerModel.Parent) then _hitboxDraggingDebounce=false return end
        targetHRP=getKillerHRP(killerModel)
        if not targetHRP then _hitboxDraggingDebounce=false return end
        local toTarget=(targetHRP.Position-hrp.Position)
        local horiz=Vector3.new(toTarget.X,0,toTarget.Z)
        if horiz.Magnitude>0.3 then bv.Velocity=horiz.Unit*Dspeed else bv.Velocity=Vector3.zero _hitboxDraggingDebounce=false end
    end)
end

local cachedAnimator=nil
local function refreshAnimator()
    local char=lp.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then cachedAnimator=hum:FindFirstChildOfClass("Animator") end
    end
end

-- Main loop
RunService.RenderStepped:Connect(function()
    local char=lp.Character
    if not char then return end
    local myRoot=char:FindFirstChild("HumanoidRootPart")
    Humanoid=char:FindFirstChild("Humanoid")
    refreshAnimator()

    -- AutoBlock
    if autoBlockOn and myRoot then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local root=p.Character:FindFirstChild("HumanoidRootPart")
                local hum=p.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health>0 then
                    local dist=(root.Position-myRoot.Position).Magnitude
                    if dist<=detectionRange then
                        if strictRangeOn and not isFacing(myRoot,root) then continue end
                        if detectAttack(p.Character) then clickBlockButton() end
                    end
                end
            end
        end
    end

    -- Predictive AutoBlock
    if predictiveBlockOn and tick()>predictiveCooldown and myRoot then
        local pf=workspace:FindFirstChild("Players")
        local killers=pf and pf:FindFirstChild("Killers")
        if killers then
            local inRange=false
            for _,k in ipairs(killers:GetChildren()) do
                local hrp=k:FindFirstChild("HumanoidRootPart")
                if hrp and (myRoot.Position-hrp.Position).Magnitude<=predictiveDetectionRange then inRange=true break end
            end
            if inRange then
                if not killerInRangeSince then killerInRangeSince=tick() end
                if tick()-killerInRangeSince>=edgeKillerDelay then
                    clickBlockButton()
                    predictiveCooldown=tick()+2
                    killerInRangeSince=nil
                end
            else killerInRangeSince=nil end
        end
    end

    -- AutoPunch
    if autoPunchOn and myRoot then
        local gui=PlayerGui:FindFirstChild("MainUI")
        local punch=gui and gui.AbilityContainer and gui.AbilityContainer:FindFirstChild("Punch")
        local charges=punch and punch:FindFirstChild("Charges")
        if charges and charges.Text=="1" then
            for _,k in ipairs(workspace.Players.Killers:GetChildren()) do
                local root=k:FindFirstChild("HumanoidRootPart")
                if root and (root.Position-myRoot.Position).Magnitude<=10 then
                    if aimPunch and Humanoid then
                        Humanoid.AutoRotate=false
                        task.spawn(function()
                            local st=tick()
                            while tick()-st<2 do
                                if myRoot and root then
                                    local predicted=root.Position+root.CFrame.LookVector*predictionValue
                                    myRoot.CFrame=CFrame.lookAt(myRoot.Position,predicted)
                                end
                                task.wait()
                            end
                            Humanoid.AutoRotate=true
                        end)
                    end
                    for _,c in ipairs(getconnections(punch.MouseButton1Click)) do pcall(function() c:Fire() end) end
                    break
                end
            end
        end
    end

    -- Hitbox Drag
    if hitboxDraggingTech and cachedAnimator then
        for _,track in ipairs(cachedAnimator:GetPlayingAnimationTracks()) do
            local id=track.Animation and tostring(track.Animation.AnimationId):match("%d+")
            if id and table.find(blockAnimIds,id) and track.TimePosition<=0.05 then
                local nearest=getNearestKillerModel()
                if nearest then
                    task.delay(Ddelay,function() task.spawn(function() beginDragIntoKiller(nearest) end) end)
                end
                break
            end
        end
    end
end)
