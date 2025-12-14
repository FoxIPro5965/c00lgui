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
  
local attackIds = {  
    -- Animation IDs  
    ["126830014841198"] = true,  
    ["126355327951215"] = true,  
    ["121086746534252"] = true,  
    ["18885909645"] = true,  
    ["98456918873918"] = true,  
    ["105458270463374"] = true,  
    ["83829782357897"] = true,  
    ["125403313786645"] = true,  
    ["118298475669935"] = true,  
    ["82113744478546"] = true,  
    ["70371667919898"] = true,  
    ["99135633258223"] = true,  
    ["97167027849946"] = true,  
    ["109230267448394"] = true,  
    ["139835501033932"] = true,  
    ["126896426760253"] = true,  
    ["109667959938617"] = true,  
    ["126681776859538"] = true,  
    ["129976080405072"] = true,  
    ["121293883585738"] = true,  
    ["81639435858902"] = true,  
    ["137314737492715"] = true,  
    ["92173139187970"] = true,  
    ["122709416391"] = true,  
    ["879895330952"] = true,  
  
    -- Sound IDs  
    ["102228729296384"] = true,  
    ["140242176732868"] = true,  
    ["112809109188560"] = true,  
    ["136323728355613"] = true,  
    ["115026634746636"] = true,  
    ["84116622032112"] = true,  
    ["108907358619313"] = true,  
    ["127793641088496"] = true,  
    ["86174610237192"] = true,  
    ["95079963655241"] = true,  
    ["101199185291628"] = true,  
    ["119942598489800"] = true,  
    ["84307400688050"] = true,  
    ["113037804008732"] = true,  
    ["105200830849301"] = true,  
    ["75330693422988"] = true,  
    ["82221759983649"] = true,  
    ["81702359653578"] = true,  
    ["108610718831698"] = true,  
    ["112395455254818"] = true,  
    ["109431876587852"] = true,  
    ["109348678063422"] = true,  
    ["85853080745515"] = true,  
    ["12222216"] = true,  
    ["105840448036441"] = true,  
    ["114742322778642"] = true,  
    ["119583605486352"] = true,  
    ["79980897195554"] = true,  
    ["71805956520207"] = true,  
    ["79391273191671"] = true,  
    ["89004992452376"] = true,  
    ["101553872555606"] = true,  
    ["101698569375359"] = true,  
    ["106300477136129"] = true,  
    ["116581754553533"] = true,  
    ["117231507259853"] = true,  
    ["119089145505438"] = true,  
    ["121954639447247"] = true,  
    ["125213046326879"] = true,  
    ["131406927389838"] = true,  
    ["71834552297085"] = true,  
    ["805165833096"] = true,  
}  
  
local autoBlockOn = false  
local strictRangeOn = false  
local detectionRange = 12  
  
local predictiveBlockOn = false  
local predictiveDetectionRange = 10  
local edgeKillerDelay = 3  
local killerInRangeSince = nil  
local predictiveCooldown = 0  
  
local autoPunchOn = false  
local aimPunch = false  
local predictionValue = 0.8  
  
local facingCheckEnabled = true

local hitboxEnabled=false
local HitboxModule=nil

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
  
AutoBlockTab:CreateInput({  
    Name = "Detection Range",  
    PlaceholderText = "12",  
    Callback = function(txt) detectionRange = tonumber(txt) or detectionRange end  
})  
  
-- (Các tab khác giữ nguyên)  
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
    CurrentValue = 0.8,  
    Suffix = "studs",  
    Callback = function(v) predictionValue = v end  
})  
  
-- Infinite Stamina, ESP, Fake Block... (giữ nguyên hoàn toàn)  
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
    while task.wait(5) do  
        if infStaminaEnabled and sprintModule.Stamina < 100 then  
            sprintModule.Stamina = 100  
        end  
    end  
end)  
  
-- ESP + FullBright (giữ nguyên)  
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
OtherTab:CreateToggle({
    Name="Hitbox Extender",
    CurrentValue=false,
    Callback=function(v)
        hitboxEnabled=v
        if v then
            if not HitboxModule then
                HitboxModule=loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxIPro5965/c00lgui/main/Hitbox.lua"))()
            end
            pcall(function()
                HitboxModule:StopExtendingHitbox()
                HitboxModule:ExtendHitbox(1,2e2)
            end)
        else
            if HitboxModule then
                pcall(function()
                    HitboxModule:StopExtendingHitbox()
                end)
            end
        end
    end
})

  
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
  
-- Hàm click block button (giống script cũ)  
local function clickBlockButton()  
    local gui = lp:FindFirstChild("PlayerGui")  
    if not gui then return end  
    local mainUI = gui:FindFirstChild("MainUI")  
    local container = mainUI and mainUI:FindFirstChild("AbilityContainer")  
    local blockButton = container and container:FindFirstChild("Block")  
    if blockButton and blockButton:IsA("ImageButton") and blockButton.Visible then  
        if blockButton.BackgroundTransparency == 0 then return end  
        pcall(function()  
            for _, conn in ipairs(getconnections(blockButton.MouseButton1Click) or {}) do  
                pcall(function() conn:Fire() end)  
            end  
        end)  
        pcall(function() blockButton:Activate() end)  
    end  
end  
  
-- Facing check (giống script cũ: dot > 0)  
local function isFacing(localRoot, targetRoot)  
    if not facingCheckEnabled then return true end  
    if not localRoot or not targetRoot then return false end  
    local directionToPlayer = (localRoot.Position - targetRoot.Position)  
    if directionToPlayer.Magnitude == 0 then return false end  
    directionToPlayer = directionToPlayer.Unit  
    local facingDirection = targetRoot.CFrame.LookVector  
    return facingDirection:Dot(directionToPlayer) > 0  
end  
  
-- Phát hiện attack (animation + sound) với checked table  
local checked = {}  
  
local function detectAttack(char)  
    if checked[char] then return false end  
  
    -- Check animation  
    local humanoid = char:FindFirstChildOfClass("Humanoid")  
    if humanoid then  
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do  
            local id = track.Animation and track.Animation.AnimationId and string.match(track.Animation.AnimationId, "%d+")  
            if id and attackIds[id] then  
                checked[char] = { type = "animation", track = track }  
                task.spawn(function()  
                    pcall(function() track.Stopped:Wait() end)  
                    checked[char] = nil  
                end)  
                return true  
            end  
        end  
    end  
  
    -- Check sounds  
    for _, d in ipairs(char:GetDescendants()) do  
        if d:IsA("Sound") and d.IsPlaying then  
            local id = string.match(d.SoundId or "", "%d+")  
            if id and attackIds[id] then  
                checked[char] = true  
                task.delay(0, function()  
                    checked[char] = nil  
                end)  
                return true  
            end  
        end  
    end  
  
    return false  
end  
  
-- Main loop (chỉ thay phần Auto Block)  
RunService.RenderStepped:Connect(function()  
    local char = lp.Character  
    if not char then return end  
    local myRoot = char:FindFirstChild("HumanoidRootPart")  
    Humanoid = char:FindFirstChild("Humanoid")  
  
    -- === AUTO BLOCK MỚI (giống script cũ) ===  
    if autoBlockOn then  
        if myRoot then  
            for _, p in ipairs(Players:GetPlayers()) do  
                if p ~= lp and p.Character then  
                    local root = p.Character:FindFirstChild("HumanoidRootPart")  
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")  
                    if root and hum and hum.Health > 0 then  
                        local dist = (root.Position - myRoot.Position).Magnitude  
                        if dist <= detectionRange then  
                            if strictRangeOn and not isFacing(myRoot, root) then continue end  
                            if detectAttack(p.Character) then  
                                clickBlockButton()  
                            end  
                        end  
                    end  
                end  
            end  
        end  
    end  
  
    -- === Predictive Block (giữ nguyên) ===  
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
                    clickBlockButton()  -- Dùng clickBlockButton cho đồng bộ  
                    predictiveCooldown = tick() + 2  
                    killerInRangeSince = nil  
                end  
            else  
                killerInRangeSince = nil  
            end  
        end  
    end  
  
    -- === Auto Punch (giữ nguyên) ===  
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
