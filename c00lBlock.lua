--------------------------------------------------
-- SERVICES
--------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local Humanoid

--------------------------------------------------
-- UI
--------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "c00lBlock",
    LoadingTitle = "c00lBlock Script",
    LoadingSubtitle = "by FoxOfficial",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Auto Block",
        FileName = "Settings"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

local AutoBlockTab   = Window:CreateTab("Auto Block", 4483362458)
local PredictiveTab  = Window:CreateTab("Predictive Auto Block", 4483362458)
local AutoPunchTab   = Window:CreateTab("Auto Punch", 4483362458)
local VisualTab      = Window:CreateTab("Visual", 4483362458)
local OtherTab       = Window:CreateTab("Other", 4483362458)

--------------------------------------------------
-- ATTACK IDS
--------------------------------------------------
local attackIds = {
    ["126830014841198"]=true,["126355327951215"]=true,["121086746534252"]=true,
    ["18885909645"]=true,["98456918873918"]=true,["105458270463374"]=true,
    ["83829782357897"]=true,["125403313786645"]=true,["118298475669935"]=true,
    ["82113744478546"]=true,["70371667919898"]=true,["99135633258223"]=true,
    ["97167027849946"]=true,["109230267448394"]=true,["139835501033932"]=true,
    ["126896426760253"]=true,["109667959938617"]=true,["126681776859538"]=true,
    ["129976080405072"]=true,["121293883585738"]=true,["81639435858902"]=true,
    ["137314737492715"]=true,["92173139187970"]=true,["122709416391"]=true,
    ["879895330952"]=true,
}

--------------------------------------------------
-- AUTOBLOCK SETTINGS
--------------------------------------------------
local autoBlockOn = false
local strictRangeOn = false
local facingCheckEnabled = true
local detectionRange = 12

--------------------------------------------------
-- PREDICTIVE
--------------------------------------------------
local predictiveBlockOn = false
local predictiveDetectionRange = 10
local edgeKillerDelay = 3
local killerInRangeSince = nil
local predictiveCooldown = 0

--------------------------------------------------
-- AUTOPUNCH
--------------------------------------------------
local autoPunchOn = false
local aimPunch = false
local predictionValue = 0.8

--------------------------------------------------
-- HITBOX
--------------------------------------------------
local hitboxEnabled = false
local HitboxModule

--------------------------------------------------
-- AUTOBLOCK UI
--------------------------------------------------
AutoBlockTab:CreateToggle({
    Name="Auto Block",
    CurrentValue=false,
    Callback=function(v) autoBlockOn=v end
})

AutoBlockTab:CreateToggle({
    Name="Strict Range",
    CurrentValue=false,
    Callback=function(v) strictRangeOn=v end
})

AutoBlockTab:CreateToggle({
    Name="Facing Check",
    CurrentValue=true,
    Callback=function(v) facingCheckEnabled=v end
})

AutoBlockTab:CreateInput({
    Name="Detection Range",
    PlaceholderText="12",
    Callback=function(t)
        detectionRange = tonumber(t) or detectionRange
    end
})

--------------------------------------------------
-- PREDICTIVE UI
--------------------------------------------------
PredictiveTab:CreateToggle({
    Name="Predictive Auto Block",
    CurrentValue=false,
    Callback=function(v) predictiveBlockOn=v end
})

PredictiveTab:CreateInput({
    Name="Detection Range",
    PlaceholderText="10",
    Callback=function(t)
        predictiveDetectionRange = tonumber(t) or predictiveDetectionRange
    end
})

PredictiveTab:CreateSlider({
    Name="Edge Killer Delay",
    Range={0,7},
    Increment=0.1,
    CurrentValue=3,
    Callback=function(v) edgeKillerDelay=v end
})

--------------------------------------------------
-- AUTOPUNCH UI
--------------------------------------------------
AutoPunchTab:CreateToggle({
    Name="Auto Punch",
    CurrentValue=false,
    Callback=function(v) autoPunchOn=v end
})

AutoPunchTab:CreateToggle({
    Name="Punch Aimbot",
    CurrentValue=false,
    Callback=function(v) aimPunch=v end
})

AutoPunchTab:CreateSlider({
    Name="Aim Prediction",
    Range={0,10},
    Increment=0.1,
    CurrentValue=0.8,
    Callback=function(v) predictionValue=v end
})

--------------------------------------------------
-- VISUAL (ESP + BRIGHT)
--------------------------------------------------
local visualEnabled=false
local showKiller=false
local showSurvivor=false
local showItems=false
local showGen=false

local oldAmbient=Lighting.Ambient
local oldOutdoor=Lighting.OutdoorAmbient
local oldBrightness=Lighting.Brightness
local oldFogEnd=Lighting.FogEnd
local oldFogStart=Lighting.FogStart

local function enableBright()
    Lighting.Ambient=Color3.new(1,1,1)
    Lighting.OutdoorAmbient=Color3.new(1,1,1)
    Lighting.Brightness=8
    Lighting.FogEnd=1e6
    Lighting.FogStart=0
end

local function disableBright()
    Lighting.Ambient=oldAmbient
    Lighting.OutdoorAmbient=oldOutdoor
    Lighting.Brightness=oldBrightness
    Lighting.FogEnd=oldFogEnd
    Lighting.FogStart=oldFogStart
end

local function addHL(obj,color)
    if obj:FindFirstChild("VisualHL") then return end
    local h=Instance.new("Highlight")
    h.Name="VisualHL"
    h.FillTransparency=0.4
    h.FillColor=color
    h.OutlineColor=color
    h.Parent=obj
    h.Adornee=obj
end

local function clearVisual()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name=="VisualHL" then
            v:Destroy()
        end
    end
end

local function applyVisual()
    clearVisual()
    if not visualEnabled then return end

    local pf=workspace:FindFirstChild("Players")
    if pf then
        if showKiller and pf:FindFirstChild("Killers") then
            for _,k in ipairs(pf.Killers:GetChildren()) do
                if k:FindFirstChild("Humanoid") then
                    addHL(k,Color3.fromRGB(255,0,0))
                end
            end
        end
        if showSurvivor and pf:FindFirstChild("Survivors") then
            for _,s in ipairs(pf.Survivors:GetChildren()) do
                if s:FindFirstChild("Humanoid") then
                    addHL(s,Color3.fromRGB(0,255,0))
                end
            end
        end
    end

    if showItems then
        for _,i in ipairs(workspace:GetDescendants()) do
            if i.Name=="Medkit" or i.Name=="BloxyCola" then
                addHL(i,Color3.fromRGB(170,0,255))
            end
        end
    end

    if showGen then
        for _,g in ipairs(workspace:GetDescendants()) do
            if string.lower(g.Name):find("generator") then
                addHL(g,Color3.fromRGB(255,255,0))
            end
        end
    end
end

local infStaminaEnabled = false
local staminaModule

pcall(function()
    local sprint = ReplicatedStorage:WaitForChild("Systems")
        :WaitForChild("Character")
        :WaitForChild("Game")
        :WaitForChild("Sprinting")
    staminaModule = require(sprint)
end)
VisualTab:CreateToggle({
    Name="Highlight On / Off",
    Callback=function(v)
        visualEnabled=v
        if v then enableBright() else disableBright() end
        applyVisual()
    end
})

VisualTab:CreateToggle({Name="Killer",Callback=function(v) showKiller=v applyVisual() end})
VisualTab:CreateToggle({Name="Survivor",Callback=function(v) showSurvivor=v applyVisual() end})
VisualTab:CreateToggle({Name="Medkit & BloxyCola",Callback=function(v) showItems=v applyVisual() end})
VisualTab:CreateToggle({Name="Generator",Callback=function(v) showGen=v applyVisual() end})

task.spawn(function()
    while task.wait(1) do
        if visualEnabled then applyVisual() end
    end
end)

--------------------------------------------------
-- OTHER TAB
--------------------------------------------------
OtherTab:CreateToggle({
    Name="Hitbox Extender",
    Callback=function(v)
        hitboxEnabled=v
        if v then
            if not HitboxModule then
                HitboxModule=loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxIPro5965/c00lgui/main/Hitbox.lua"))()
            end
            HitboxModule:ExtendHitbox(1.2,3000)
        elseif HitboxModule then
            HitboxModule:StopExtendingHitbox()
        end
    end
})
OtherTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Callback = function(v)
        infStaminaEnabled = v
    end
})

OtherTab:CreateButton({
    Name="Load Fake Block",
    Callback=function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidi399/Auto-block-script/main/fakeblock"))()
    end
})
task.spawn(function()
    while task.wait(1) do
        if infStaminaEnabled and staminaModule and staminaModule.Stamina then
            staminaModule.Stamina = staminaModule.MaxStamina or 100
        end
    end
end)

--------------------------------------------------
-- CORE LOGIC
--------------------------------------------------
local checked={}
local function detectAttack(char)
    if checked[char] then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _,tr in ipairs(hum:GetPlayingAnimationTracks()) do
            local id=tr.Animation and tr.Animation.AnimationId:match("%d+")
            if id and attackIds[id] then
                checked[char]=true
                task.delay(0.2,function() checked[char]=nil end)
                return true
            end
        end
    end
end

local function clickBlock()
    local ui=PlayerGui:FindFirstChild("MainUI")
    local btn=ui and ui:FindFirstChild("AbilityContainer") and ui.AbilityContainer:FindFirstChild("Block")
    if btn then
        for _,c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
    end
end

RunService.RenderStepped:Connect(function()
    local char=lp.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if autoBlockOn then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health>0 then
                    if (r.Position-root.Position).Magnitude<=detectionRange then
                        if detectAttack(p.Character) then
                            clickBlock()
                        end
                    end
                end
            end
        end
    end
end)
