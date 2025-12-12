local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local Humanoid

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

local AutoBlockTab = Window:CreateTab("Auto Block", 4483362458)
local PredictiveTab = Window:CreateTab("Predictive Auto Block", 4483362458)
local AutoPunchTab = Window:CreateTab("Auto Punch", 4483362458)
local OtherTab = Window:CreateTab("Other", 4483362458)

local autoBlockTriggerAnims = {
    "126830014841198","126355327951215","121086746534252","18885909645",
    "98456918873918","105458270463374","83829782357897","125403313786645",
    "118298475669935","82113744478546","70371667919898","99135633258223",
    "97167027849946","109230267448394","139835501033932","126896426760253",
    "109667959938617","126681776859538","129976080405072","121293883585738",
    "81639435858902","137314737492715","92173139187970"
}

local autoBlockOn = false
local strictRangeOn = false
local looseFacing = true
local detectionRange = 12

local predictiveBlockOn = false
local predictiveDetectionRange = 10
local edgeKillerDelay = 3
local killerInRangeSince = nil
local predictiveCooldown = 0

local autoPunchOn = false
local aimPunch = false
local predictionValue = 1

local facingCheckEnabled = true

AutoBlockTab:CreateToggle({
    Name = "Auto Block",
    CurrentValue = false,
    Callback = function(v) autoBlockOn = v end
})

AutoBlockTab:CreateToggle({
    Name = "Strict Range",
    CurrentValue = false,
    Callback = function(v) strictRangeOn = v end
})

AutoBlockTab:CreateToggle({
    Name = "Enable Facing Check",
    CurrentValue = true,
    Callback = function(v) facingCheckEnabled = v end
})

AutoBlockTab:CreateDropdown({
    Name = "Facing Check",
    Options = {"Loose","Strict"},
    CurrentOption = "Loose",
    Callback = function(opt) looseFacing = opt == "Loose" end
})

AutoBlockTab:CreateInput({
    Name = "Detection Range",
    PlaceholderText = "12",
    Callback = function(txt) detectionRange = tonumber(txt) or detectionRange end
})

PredictiveTab:CreateToggle({
    Name = "Predictive Auto Block",
    CurrentValue = false,
    Callback = function(v) predictiveBlockOn = v end
})

PredictiveTab:CreateInput({
    Name = "Detection Range",
    PlaceholderText = "10",
    Callback = function(txt)
        local n = tonumber(txt)
        if n then predictiveDetectionRange = n end
    end
})

PredictiveTab:CreateSlider({
    Name = "Edge Killer",
    Range = {0,7},
    Increment = 0.1,
    CurrentValue = 3,
    Callback = function(v) edgeKillerDelay = v end
})

AutoPunchTab:CreateToggle({
    Name = "Auto Punch",
    CurrentValue = false,
    Callback = function(v) autoPunchOn = v end
})

AutoPunchTab:CreateToggle({
    Name = "Punch Aimbot",
    CurrentValue = false,
    Callback = function(v) aimPunch = v end
})

AutoPunchTab:CreateSlider({
    Name = "Aim Prediction",
    Range = {0,10},
    Increment = 0.1,
    CurrentValue = 1,
    Suffix = "studs",
    Callback = function(v) predictionValue = v end
})

local infStaminaEnabled = false
local rs = cloneref(ReplicatedStorage)
local sprint = rs.Systems.Character.Game.Sprinting
local sprintModule = require(sprint)

OtherTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Callback = function(v) infStaminaEnabled = v end
})

task.spawn(function()
    while task.wait(1) do
        if infStaminaEnabled and sprintModule.Stamina < 100 then
            sprintModule.Stamina = 100
        end
    end
end)

local espEnabled = false
local oldAmbient = Lighting.Ambient
local oldOutdoor = Lighting.OutdoorAmbient
local oldBrightness = Lighting.Brightness
local oldFogEnd = Lighting.FogEnd
local oldFogStart = Lighting.FogStart

local function enableFB()
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.Brightness = 6
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
end

local function disableFB()
    Lighting.Ambient = oldAmbient
    Lighting.OutdoorAmbient = oldOutdoor
    Lighting.Brightness = oldBrightness
    Lighting.FogEnd = oldFogEnd
    Lighting.FogStart = oldFogStart
end

local function highlight(m,o,f)
    local h = Instance.new("Highlight")
    h.Parent = m
    h.Adornee = m
    h.FillTransparency = 0.75
    h.FillColor = f
    h.OutlineColor = o
end

local function clearESP()
    local pf = workspace:FindFirstChild("Players")
    if not pf then return end
    for _,grp in ipairs(pf:GetChildren()) do
        for _,pl in ipairs(grp:GetChildren()) do
            for _,obj in ipairs(pl:GetChildren()) do
                if obj:IsA("Highlight") then obj:Destroy() end
            end
        end
    end
end

local function applyESP()
    local pf = workspace:FindFirstChild("Players")
    if not pf then return end
    local killers = pf:FindFirstChild("Killers")
    if killers then
        for _,m in ipairs(killers:GetChildren()) do
            if m:FindFirstChild("Humanoid") then highlight(m,Color3.new(1,0,0),Color3.new(1,0.3,0.3)) end
        end
    end
    local survivors = pf:FindFirstChild("Survivors")
    if survivors then
        for _,m in ipairs(survivors:GetChildren()) do
            if m:FindFirstChild("Humanoid") then highlight(m,Color3.new(0,1,0),Color3.new(0.4,1,0.4)) end
        end
    end
end

OtherTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v)
        espEnabled = v
        if v then
            enableFB()
            clearESP()
            applyESP()
        else
            disableFB()
            clearESP()
        end
    end
})

task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            enableFB()
            clearESP()
            applyESP()
        end
    end
end)

OtherTab:CreateButton({
    Name = "Load Fake Block",
    Callback = function()
        pcall(function()
            local gui = PlayerGui:FindFirstChild("FakeBlockGui")
            if not gui then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidi399/Auto-block-script/main/fakeblock"))()
            else
                gui.Enabled = true
            end
        end)
    end
})

local function fireBlock()
    local args = {"UseActorAbility","Block"}
    ReplicatedStorage.Modules.Network.RemoteEvent:FireServer(unpack(args))
end

local function isFacing(localRoot,targetRoot)
    if not facingCheckEnabled then return true end
    local dir = (localRoot.Position - targetRoot.Position).Unit
    local dot = targetRoot.CFrame.LookVector:Dot(dir)
    return looseFacing and dot > -0.3 or dot > 0
end

RunService.RenderStepped:Connect(function()
    local char = lp.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    Humanoid = char:FindFirstChild("Humanoid")
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            local anim = hum and hum:FindFirstChild("Animator")
            local tracks = anim and anim:GetPlayingAnimationTracks() or {}
            if hrp and myRoot and (hrp.Position - myRoot.Position).Magnitude <= detectionRange then
                for _,t in ipairs(tracks) do
                    local id = tostring(t.Animation.AnimationId):match("%d+")
                    if table.find(autoBlockTriggerAnims,id) then
                        if autoBlockOn and (not strictRangeOn or (hrp.Position - myRoot.Position).Magnitude <= detectionRange) then
                            if isFacing(myRoot,hrp) then fireBlock() end
                        end
                    end
                end
            end
        end
    end

    if predictiveBlockOn and tick() > predictiveCooldown then
        local pf = workspace:FindFirstChild("Players")
        local killers = pf and pf:FindFirstChild("Killers")
        local myHRP = myRoot
        if killers and myHRP then
            local inRange = false
            for _,k in ipairs(killers:GetChildren()) do
                local hrp = k:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if (myHRP.Position - hrp.Position).Magnitude <= predictiveDetectionRange then
                        inRange = true
                        break
                    end
                end
            end
            if inRange then
                if not killerInRangeSince then killerInRangeSince = tick()
                elseif tick() - killerInRangeSince >= edgeKillerDelay then
                    fireBlock()
                    predictiveCooldown = tick() + 2
                    killerInRangeSince = nil
                end
            else
                killerInRangeSince = nil
            end
        end
    end

    if autoPunchOn then
        local gui = PlayerGui:FindFirstChild("MainUI")
        local punch = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
        local charges = punch and punch:FindFirstChild("Charges")
        if charges and charges.Text == "1" then
            local names = {"Slasher","c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Nosferatu","Sixer"}
            for _,n in ipairs(names) do
                local k = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers") and workspace.Players.Killers:FindFirstChild(n)
                if k and k:FindFirstChild("HumanoidRootPart") then
                    local root = k.HumanoidRootPart
                    if (root.Position - myRoot.Position).Magnitude <= 10 then
                        if aimPunch then
                            if Humanoid then Humanoid.AutoRotate = false end
                            task.spawn(function()
                                local st = tick()
                                while tick() - st < 2 do
                                    if myRoot and root then
                                        local predicted = root.Position + root.CFrame.LookVector * predictionValue
                                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, predicted)
                                    end
                                    task.wait()
                                end
                                if Humanoid then Humanoid.AutoRotate = true end
                            end)
                        end
                        for _,c in ipairs(getconnections(punch.MouseButton1Click)) do pcall(function() c:Fire() end) end
                        break
                    end
                end
            end
        end
    end
end)
