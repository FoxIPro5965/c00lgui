local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local workspace = workspace

local localPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "c00lBlock",
    LoadingTitle = "c00lBlock Script",
    LoadingSubtitle = "By FoxIPro5965",
    ConfigurationSaving = {Enabled = true, FolderName = "c00lBlock", FileName = "Settings"},
    KeySystem = false
})

local AutoBlockTab = Window:CreateTab("Auto Block")
local MiscTab = Window:CreateTab("Misc")
local AutoPunchTab = Window:CreateTab("Auto Punch")

local attackIds = {
    ["126830014841198"]=true,["126355327951215"]=true,["121086746534252"]=true,
    ["18885909645"]=true,["98456918873918"]=true,["105458270463374"]=true,
    ["83829782357897"]=true,["125403313786645"]=true,["118298475669935"]=true,
    ["82113744478546"]=true,["70371667919898"]=true,["99135633258223"]=true,
    ["97167027849946"]=true,["109230267448394"]=true,["139835501033932"]=true,
    ["126896426760253"]=true,["109667959938617"]=true,["126681776859538"]=true,
    ["129976080405072"]=true,["121293883585738"]=true,["81639435858902"]=true,
    ["137314737492715"]=true,["92173139187970"]=true,
    ["102228729296384"]=true,["140242176732868"]=true,["112809109188560"]=true,
    ["136323728355613"]=true,["115026634746636"]=true,["84116622032112"]=true,
    ["108907358619313"]=true,["127793641088496"]=true,["86174610237192"]=true,
    ["95079963655241"]=true,["101199185291628"]=true,["119942598489800"]=true
}

local autoBlockAnim = false
local autoBlockAudio = false
local detectionRange = 12
local strictRange = false
local espEnabled = false
local infStaminaEnabled = false

local autoPunchOn = false
local aimPunch = true
local predictionValue = 4
local killerList = {"Slasher","Jason","c00lkidd","JohnDoe","Noli","1x1x1x1","Sixer","Nosferatu"}

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title="c00lBlock",Text=text,Duration=1.5})
    end)
end

local function clickBlockButton()
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    local mainUI = gui:FindFirstChild("MainUI")
    local container = mainUI and mainUI:FindFirstChild("AbilityContainer")
    local blockButton = container and container:FindFirstChild("Block")
    if blockButton and blockButton:IsA("ImageButton") and blockButton.Visible then
        pcall(function() blockButton:Activate() end)
        pcall(function()
            for _, conn in ipairs(getconnections(blockButton.MouseButton1Click) or {}) do
                pcall(function() conn:Fire() end)
            end
        end)
        return true
    end
    return false
end

local function isFacing(localRoot, targetRoot)
    if not localRoot or not targetRoot then return false end
    local dir = (localRoot.Position - targetRoot.Position)
    if dir.Magnitude == 0 then return false end
    dir = dir.Unit
    local facing = targetRoot.CFrame.LookVector
    return facing:Dot(dir) > 0
end

local function detectAttackByChar(char)
    if autoBlockAnim then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                local id = track.Animation and track.Animation.AnimationId and string.match(track.Animation.AnimationId,"%d+")
                if id and attackIds[id] then return true end
            end
        end
    end
    if autoBlockAudio then
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("Sound") and d.IsPlaying then
                local id = string.match(d.SoundId or "","%d+")
                if id and attackIds[id] then return true end
            end
        end
    end
    return false
end

local punchRemote = nil
task.spawn(function()
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
    end)
    if ok then punchRemote = remote end
end)

local function firePunch()
    if punchRemote then
        pcall(function()
            punchRemote:FireServer("UseActorAbility", {"Punch"})
        end)
    end
end

local function isPunching(humanoid)
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local ok, id = pcall(function() return track.Animation and track.Animation.AnimationId end)
        if ok and id and tostring(id):lower():find("punch") then
            return true
        end
    end
    return false
end

local function aimAtTargetDuring(duration, targetRoot)
    local char = localPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or not targetRoot then return end
    humanoid.AutoRotate = false
    local start = tick()
    task.spawn(function()
        while tick() - start < duration do
            if root and targetRoot then
                local pred = targetRoot.Position + (targetRoot.CFrame.LookVector * predictionValue)
                root.CFrame = CFrame.lookAt(root.Position, pred)
            end
            task.wait()
        end
        if humanoid then humanoid.AutoRotate = true end
    end)
end

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and humanoid and humanoid.Health > 0 then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist <= detectionRange then
                    if strictRange and not isFacing(root, targetRoot) then goto cont end
                    if detectAttackByChar(plr.Character) then
                        local didBlock = clickBlockButton()
                        if didBlock and autoPunchOn then
                            task.delay(0.04, function()
                                if aimPunch then
                                    aimAtTargetDuring(0.45, targetRoot)
                                end
                                firePunch()
                            end)
                        end
                        ::cont::
                    end
                end
            end
        end
    end
end)

local function getNearestKiller()
    local fold = workspace:FindFirstChild("Players")
    if not fold then return nil end
    local killers = fold:FindFirstChild("Killers")
    if not killers then return nil end
    local best, bestDist = nil, math.huge
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, name in ipairs(killerList) do
        local k = killers:FindFirstChild(name)
        if k and k:FindFirstChild("HumanoidRootPart") then
            local d = (k.HumanoidRootPart.Position - myRoot.Position).Magnitude
            if d < bestDist then bestDist = d best = k end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not autoPunchOn then return end
    local char = localPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    local killer = getNearestKiller()
    if not killer then return end
    local kRoot = killer:FindFirstChild("HumanoidRootPart")
    if not kRoot then return end
    local dist = (kRoot.Position - root.Position).Magnitude
    if dist > 12 then return end
    -- autoPunch here is manual fallback: if user enabled autoPunch and no block-triggered punch happened, we can also punch periodically
    -- keep it subtle to avoid spam
    firePunch()
    if aimPunch then
        local started = tick()
        while tick() - started < 0.2 do
            if kRoot and root then
                local pred = kRoot.Position + (kRoot.CFrame.LookVector * predictionValue)
                root.CFrame = CFrame.lookAt(root.Position, pred)
            end
            task.wait()
        end
    end
    task.wait(0.1)
end)

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
    while task.wait(0.5) do
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

task.spawn(function()
    local ok, sprintModule = pcall(function()
        return ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
    end)
    if not ok then return end
    local ok2, sprintReq = pcall(function() return require(sprintModule) end)
    if not ok2 then return end
    while task.wait(0.5) do
        if infStaminaEnabled and sprintReq then
            if sprintReq.Stamina < 100 then sprintReq.Stamina = 100 end
        end
    end
end)

AutoBlockTab:CreateToggle({Name="Auto Block (Animation)",CurrentValue=false,Callback=function(v) autoBlockAnim=v end})
AutoBlockTab:CreateToggle({Name="Auto Block (Audio)",CurrentValue=false,Callback=function(v) autoBlockAudio=v end})
AutoBlockTab:CreateInput({Name="Detection Range",PlaceholderText=tostring(detectionRange),Callback=function(v) local num = tonumber(v) if num then detectionRange = math.clamp(num,1,1000) end end})
AutoBlockTab:CreateToggle({Name="Strict Range (Facing Only)",CurrentValue=false,Callback=function(v) strictRange=v end})

AutoPunchTab:CreateToggle({Name="Auto Punch (on block)",CurrentValue=false,Callback=function(v) autoPunchOn=v end})
AutoPunchTab:CreateToggle({Name="Punch Aimbot (aim when punching)",CurrentValue=true,Callback=function(v) aimPunch=v end})
AutoPunchTab:CreateSlider({Name="Aim Prediction",Range={0,10},CurrentValue=predictionValue,Increment=0.1,Callback=function(v) predictionValue=v end})

MiscTab:CreateToggle({Name="Infinite Stamina",CurrentValue=false,Callback=function(v) infStaminaEnabled=v end})
MiscTab:CreateToggle({Name="ESP: Killers/Survivors/Items",CurrentValue=false,Callback=function(v) espEnabled=v end})

Rayfield:LoadConfiguration()
