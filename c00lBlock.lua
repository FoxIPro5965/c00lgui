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
local AutoPunchTab = Window:CreateTab("Auto Punch")
local MiscTab = Window:CreateTab("Misc")

-- ===================== Variables =====================
local autoPunchOn = false
local aimPunch = true
local predictionValue = 4

local autoBlockAnim = false
local autoBlockAudio = false
local detectionRange = 12
local strictRange = false
local espEnabled = false
local infStaminaEnabled = false

-- ALL KILLERS
local killerList = {"Slasher","Jason","c00lkidd","JohnDoe","Noli","1x1x1x1","Sixer","Nosferatu"}

-- ===================== AUTO PUNCH CHECK HIT FUNCTION =====================
local punchRemote = nil
task.spawn(function()
    -- tìm remote đúng
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Modules")
            :WaitForChild("Network")
            :WaitForChild("RemoteEvent")
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

-- ===================== AIM PUNCH (aim khi CHÍNH BẠN đang punch) =====================
local function isPunching(humanoid)
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local animId = track.Animation.AnimationId
        if animId:lower():find("punch") then
            return true
        end
    end
    return false
end

local function getNearestKiller()
    local fold = workspace:FindFirstChild("Players")
    if not fold then return end

    fold = fold:FindFirstChild("Killers")
    if not fold then return end

    for _, name in ipairs(killerList) do
        local killer = fold:FindFirstChild(name)
        if killer and killer:FindFirstChild("HumanoidRootPart") then
            return killer
        end
    end
end

-- ===================== AUTO PUNCH + AIM =====================
RunService.RenderStepped:Connect(function()
    if not autoPunchOn then return end

    local char = localPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    local killer = getNearestKiller()
    if not killer then return end

    local kRoot = killer:FindFirstChild("HumanoidRootPart")
    if not kRoot then return end

    local dist = (kRoot.Position - root.Position).Magnitude
    if dist > 12 then return end

    -- PUNCH
    firePunch()

    -- AIM PUNCH LOGIC (chỉ aim khi đang đấm)
    if aimPunch and isPunching(humanoid) then
        humanoid.AutoRotate = false
        task.spawn(function()
            local start = tick()
            while tick() - start < 0.4 do
                if kRoot and root then
                    local pred = kRoot.Position + kRoot.CFrame.LookVector * predictionValue
                    root.CFrame = CFrame.lookAt(root.Position, pred)
                end
                task.wait()
            end
            humanoid.AutoRotate = true
        end)
    end

    task.wait(0.35)
end)

-- ===================== ESP TỐI ƯU (refresh mỗi 0.25s thay vì mỗi frame) =====================
task.spawn(function()
    while task.wait(0.25) do
        if espEnabled then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 4
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Brightness = 2
        end
    end
end)

-- ===================== Infinite Stamina Loop =====================
task.spawn(function()
    local sprintModule = ReplicatedStorage:WaitForChild("Systems")
        :WaitForChild("Character")
        :WaitForChild("Game")
        :WaitForChild("Sprinting")

    local sprintReq = require(sprintModule)

    while task.wait(0.5) do
        if infStaminaEnabled then
            if sprintReq.Stamina < 100 then sprintReq.Stamina = 100 end
        end
    end
end)

-- ===================== GUI =====================
AutoPunchTab:CreateToggle({
    Name = "Auto Punch",
    CurrentValue = false,
    Callback = function(v) autoPunchOn = v end
})

AutoPunchTab:CreateToggle({
    Name = "Punch Aimbot",
    CurrentValue = true,
    Callback = function(v) aimPunch = v end
})

AutoPunchTab:CreateSlider({
    Name = "Aim Prediction",
    Range = {0, 10},
    CurrentValue = predictionValue,
    Increment = 0.1,
    Callback = function(v) predictionValue = v end
})

MiscTab:CreateToggle({
    Name = "Killer/Survivor ESP (Low Lag)",
    CurrentValue = false,
    Callback = function(v) espEnabled = v end
})

Rayfield:LoadConfiguration()
