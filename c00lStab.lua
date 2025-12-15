--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

--------------------------------------------------
-- OBSIDIAN GUI
--------------------------------------------------
local Obsidian = loadstring(game:HttpGet("https://raw.githubusercontent.com/Scriptobsidian/Obsidian/main/source.lua"))()
local Window = Obsidian:CreateWindow({
    Title = "c00lStab",
    Footer = "by FoxOfficial",
    Size = UDim2.fromOffset(520, 420),
    Theme = "Dark"
})

--------------------------------------------------
-- TABS
--------------------------------------------------
local AutoTab = Window:AddTab("Auto Backstab")
local VisualTab = Window:AddTab("Visual")
local OtherTab = Window:AddTab("Other")

--------------------------------------------------
-- AUTOBACKSTAB VARS
--------------------------------------------------
local autoStab = false
local range = 8
local mode = "Behind"
local cooldown = false
local cooldownTime = 30

local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
local killerNames = { "Slasher","Jason","c00lkidd","JohnDoe","1x1x1x1","Noli","Nosferatu","Sixer" }

--------------------------------------------------
-- UI DAGGER CLICK
--------------------------------------------------
local function clickDagger()
    local gui = lp.PlayerGui:FindFirstChild("MainUI")
    local btn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Dagger")
    if not btn or btn.BackgroundTransparency == 0 then return end

    for _,c in ipairs(getconnections(btn.MouseButton1Click)) do
        pcall(function() c:Fire() end)
    end
    pcall(function() btn:Activate() end)
end

--------------------------------------------------
-- BACK CHECK
--------------------------------------------------
local function validBehind(hrp, targetHRP)
    if (hrp.Position - targetHRP.Position).Magnitude > range then
        return false
    end
    if mode == "Around" then return true end

    local dir = -targetHRP.CFrame.LookVector
    local toMe = (hrp.Position - targetHRP.Position).Unit
    return toMe:Dot(dir) > 0.6
end

--------------------------------------------------
-- AUTOBACKSTAB CORE
--------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not autoStab or cooldown then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _,name in ipairs(killerNames) do
        local k = killersFolder:FindFirstChild(name)
        local kHRP = k and k:FindFirstChild("HumanoidRootPart")
        if kHRP and validBehind(hrp, kHRP) then
            cooldown = true

            -- TP ra sau 2 studs
            local behindPos = kHRP.Position - (kHRP.CFrame.LookVector * 2)
            hrp.CFrame = CFrame.new(behindPos, kHRP.Position)

            task.delay(0.02, clickDagger)

            -- giữ 0.5s
            local start = tick()
            local conn; conn = RunService.Heartbeat:Connect(function()
                if tick() - start >= 0.5 then
                    conn:Disconnect()
                else
                    hrp.CFrame = CFrame.new(
                        kHRP.Position - (kHRP.CFrame.LookVector * 2),
                        kHRP.Position
                    )
                end
            end)

            -- cooldown 30s
            task.delay(cooldownTime, function()
                cooldown = false
            end)
            break
        end
    end
end)

--------------------------------------------------
-- AUTOBACKSTAB UI
--------------------------------------------------
AutoTab:AddToggle({
    Label = "Auto Backstab",
    Default = false,
    Callback = function(v) autoStab = v end
})

AutoTab:AddSlider({
    Label = "Range",
    Min = 1,
    Max = 16,
    Default = 8,
    Callback = function(v) range = v end
})

AutoTab:AddButton({
    Label = "Mode: Behind / Around",
    Callback = function()
        mode = (mode == "Behind") and "Around" or "Behind"
        Obsidian:Notify("Mode", mode, 2)
    end
})

--------------------------------------------------
-- VISUAL VARS
--------------------------------------------------
local visualOn=false
local showKiller=false
local showSurv=false
local showItem=false
local showGen=false

local old = {
    Ambient = Lighting.Ambient,
    Outdoor = Lighting.OutdoorAmbient,
    Bright = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart
}

local function bright(on)
    if on then
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        Lighting.Brightness=6
        Lighting.FogEnd=1e6
        Lighting.FogStart=0
    else
        for k,v in pairs(old) do Lighting[k]=v end
    end
end

local function clearHL()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name=="c00lHL" then v:Destroy() end
    end
end

local function hl(obj,color)
    if obj:FindFirstChild("c00lHL") then return end
    local h=Instance.new("Highlight",obj)
    h.Name="c00lHL"
    h.FillTransparency=0.5
    h.FillColor=color
    h.OutlineColor=color
    h.Adornee=obj
end

local function applyVisual()
    clearHL()
    if not visualOn then return end

    local pf=workspace:FindFirstChild("Players")
    if pf then
        if showKiller and pf:FindFirstChild("Killers") then
            for _,k in ipairs(pf.Killers:GetChildren()) do
                if k:FindFirstChild("Humanoid") then hl(k,Color3.fromRGB(255,0,0)) end
            end
        end
        if showSurv and pf:FindFirstChild("Survivors") then
            for _,s in ipairs(pf.Survivors:GetChildren()) do
                if s:FindFirstChild("Humanoid") then hl(s,Color3.fromRGB(0,255,0)) end
            end
        end
    end

    if showItem then
        for _,i in ipairs(workspace:GetDescendants()) do
            if i.Name=="Medkit" or i.Name=="BloxyCola" then
                hl(i,Color3.fromRGB(170,0,255))
            end
        end
    end

    if showGen then
        for _,g in ipairs(workspace:GetDescendants()) do
            if g.Name:lower():find("generator") then
                hl(g,Color3.fromRGB(255,255,0))
            end
        end
    end
end

--------------------------------------------------
-- VISUAL UI
--------------------------------------------------
VisualTab:AddToggle({Label="Highlight",Callback=function(v) visualOn=v bright(v) applyVisual() end})
VisualTab:AddToggle({Label="Killer",Callback=function(v) showKiller=v applyVisual() end})
VisualTab:AddToggle({Label="Survivor",Callback=function(v) showSurv=v applyVisual() end})
VisualTab:AddToggle({Label="Medkit & Cola",Callback=function(v) showItem=v applyVisual() end})
VisualTab:AddToggle({Label="Generator",Callback=function(v) showGen=v applyVisual() end})

--------------------------------------------------
-- OTHER
--------------------------------------------------
local infStam=false
local sprint=require(cloneref(ReplicatedStorage).Systems.Character.Game.Sprinting)

OtherTab:AddToggle({
    Label="Infinite Stamina",
    Callback=function(v) infStam=v end
})

task.spawn(function()
    while task.wait(1) do
        if infStam and sprint.Stamina<100 then
            sprint.Stamina=100
        end
    end
end)

OtherTab:AddToggle({
    Label="Hitbox",
    Callback=function(v)
        if v then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxIPro5965/c00lgui/main/Hitbox.lua"))():ExtendHitbox(1.2,3000)
        end
    end
})
