-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local workspace = workspace

local localPlayer = Players.LocalPlayer

-- Rayfield UI
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

-- Attack IDs / Sound IDs
local attackIds = {
    -- Animation IDs
    ["126830014841198"]=true,["126355327951215"]=true,["121086746534252"]=true,
    ["18885909645"]=true,["98456918873918"]=true,["105458270463374"]=true,
    ["83829782357897"]=true,["125403313786645"]=true,["118298475669935"]=true,
    ["82113744478546"]=true,["70371667919898"]=true,["99135633258223"]=true,
    ["97167027849946"]=true,["109230267448394"]=true,["139835501033932"]=true,
    ["126896426760253"]=true,["109667959938617"]=true,["126681776859538"]=true,
    ["129976080405072"]=true,["121293883585738"]=true,["81639435858902"]=true,
    ["137314737492715"]=true,["92173139187970"]=true,
    -- Sound IDs
    ["102228729296384"]=true,["140242176732868"]=true,["112809109188560"]=true,
    ["136323728355613"]=true,["115026634746636"]=true,["84116622032112"]=true,
    ["108907358619313"]=true,["127793641088496"]=true,["86174610237192"]=true,
    ["95079963655241"]=true,["101199185291628"]=true,["119942598489800"]=true
}

-- ===================== Variables =====================
local autoBlockAnim = false
local autoBlockAudio = false
local detectionRange = 18
local strictRange = false
local espEnabled = false
local infStaminaEnabled = false

local autoPunchOn = false
local aimPunch = true
local predictionValue = 4
local killerList = {"Slasher","Jason","c00lkidd","JohnDoe","Noli","1x1x1x1","Sixer","Nosferatu"}

-- ===================== Functions =====================
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title="c00lBlock",Text=text,Duration=1.5})
    end)
end

local function clickBlockButton()
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
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
    end
end

local function isFacing(localRoot, targetRoot)
    if not localRoot or not targetRoot then return false end
    local direction = (localRoot.Position - targetRoot.Position)
    if direction.Magnitude == 0 then return false end
    direction = direction.Unit
    local facing = targetRoot.CFrame.LookVector
    return facing:Dot(direction) > 0
end

local function detectAttack(char)
    -- Animation
    if autoBlockAnim then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                local id = track.Animation and track.Animation.AnimationId and string.match(track.Animation.AnimationId,"%d+")
                if id and attackIds[id] then return true end
            end
        end
    end
    -- Audio
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

-- ===================== Auto Block Loop =====================
RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and humanoid and humanoid.Health>0 then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist <= detectionRange then
                    if strictRange and not isFacing(root,targetRoot) then continue end
                    if detectAttack(plr.Character) then
                        clickBlockButton()
                    end
                end
            end
        end
    end
end)

-- ===================== Auto Punch Loop =====================
RunService.RenderStepped:Connect(function()
    if not autoPunchOn then return end
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local KillersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if not KillersFolder then return end

    for _, name in ipairs(killerList) do
        local killer = KillersFolder:FindFirstChild(name)
        if killer and killer:FindFirstChild("HumanoidRootPart") then
            local kRoot = killer.HumanoidRootPart
            local dist = (kRoot.Position - root.Position).Magnitude
            if dist <= 12 then
                -- Fire Punch
                local ok, testRemote = pcall(function() return ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent") end)
                if ok then
                    pcall(function() testRemote:FireServer("UseActorAbility",{"Punch"}) end)
                end

                -- Aim Punch
                if aimPunch then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.AutoRotate=false end
                    task.spawn(function()
                        local start = tick()
                        while tick()-start<0.5 do
                            if root and killer:FindFirstChild("HumanoidRootPart") then
                                local pred = kRoot.Position + kRoot.CFrame.LookVector*predictionValue
                                root.CFrame = CFrame.lookAt(root.Position,pred)
                            end
                            task.wait()
                        end
                        if humanoid then humanoid.AutoRotate=true end
                    end)
                end
                task.wait(0.35)
                return
            end
        end
    end
end)

-- ===================== GUI =====================
-- Auto Block Tab
AutoBlockTab:CreateToggle({
    Name="Auto Block (Animation)",
    CurrentValue=false,
    Callback=function(v) autoBlockAnim=v end
})

AutoBlockTab:CreateToggle({
    Name="Auto Block (Audio)",
    CurrentValue=false,
    Callback=function(v) autoBlockAudio=v end
})

AutoBlockTab:CreateInput({
    Name="Detection Range",
    PlaceholderText=tostring(detectionRange),
    Callback=function(v)
        local num = tonumber(v)
        if num then detectionRange = math.clamp(num,1,1000) end
    end
})

AutoBlockTab:CreateToggle({
    Name="Strict Range (Facing Only)",
    CurrentValue=false,
    Callback=function(v) strictRange=v end
})

-- Auto Punch Tab
AutoPunchTab:CreateToggle({
    Name="Auto Punch",
    CurrentValue=false,
    Callback=function(v) autoPunchOn=v end
})

AutoPunchTab:CreateToggle({
    Name="Punch Aimbot",
    CurrentValue=true,
    Callback=function(v) aimPunch=v end
})

AutoPunchTab:CreateSlider({
    Name="Aim Prediction",
    Range={0,10},
    CurrentValue=predictionValue,
    Increment=0.1,
    Callback=function(v) predictionValue=v end
})

-- Misc Tab
MiscTab:CreateToggle({
    Name="Infinite Stamina",
    CurrentValue=false,
    Callback=function(v) infStaminaEnabled=v end
})

MiscTab:CreateToggle({
    Name="Killer/Survivor ESP",
    CurrentValue=false,
    Callback=function(v)
        espEnabled=v
        if espEnabled then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.Brightness = 4
        else
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
            Lighting.Brightness = 2
        end
    end
})

-- ===================== Infinite Stamina Loop =====================
task.spawn(function()
    local sprintModule = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
    local sprintReq = require(sprintModule)
    while task.wait(0.5) do
        if infStaminaEnabled then
            if sprintReq.Stamina < 100 then sprintReq.Stamina=100 end
        end
    end
end)

Rayfield:LoadConfiguration()
