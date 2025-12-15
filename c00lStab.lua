--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

--------------------------------------------------
-- GUI SETUP
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackstabToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

local function createBtn(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,120,0,25)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.BorderColor3 = Color3.fromRGB(255,0,0)
    b.BorderSizePixel = 2
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.Text = text
    b.Parent = screenGui
    return b
end

local toggleButton = createBtn("Backstab: OFF",10)
toggleButton.Size = UDim2.new(0,120,0,35)

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0,120,0,20)
rangeLabel.Position = UDim2.new(0,10,0,50)
rangeLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
rangeLabel.BorderColor3 = Color3.fromRGB(255,0,0)
rangeLabel.BorderSizePixel = 2
rangeLabel.TextColor3 = Color3.fromRGB(255,255,255)
rangeLabel.Font = Enum.Font.SourceSans
rangeLabel.TextSize = 16
rangeLabel.Text = "Range:"
rangeLabel.Parent = screenGui

local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0,120,0,25)
rangeBox.Position = UDim2.new(0,10,0,75)
rangeBox.BackgroundColor3 = Color3.fromRGB(0,0,0)
rangeBox.BorderColor3 = Color3.fromRGB(255,0,0)
rangeBox.BorderSizePixel = 2
rangeBox.TextColor3 = Color3.fromRGB(255,255,255)
rangeBox.Font = Enum.Font.SourceSans
rangeBox.TextSize = 16
rangeBox.Text = "8"
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = screenGui

local modeButton = createBtn("Mode: Behind",105)
local infStamButton = createBtn("Inf Stamina: OFF",130)
local espButton = createBtn("ESP: OFF",160)

--------------------------------------------------
-- BACKSTAB SETTINGS
--------------------------------------------------
local enabled = false
local range = 8
local mode = "Behind"

local BACKSTAB_DISTANCE = 1.8
local BACKSTAB_HOLD_TIME = 0.35
local BACKSTAB_COOLDOWN = 10
local lastBackstabTime = 0

local killerNames = {
    "Slasher","Jason","c00lkidd","JohnDoe","1x1x1x1","Noli","Nosferatu","Sixer"
}

local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

--------------------------------------------------
-- DAGGER CLICK
--------------------------------------------------
local function clickDaggerButton()
    local gui = lp.PlayerGui:FindFirstChild("MainUI")
    local btn = gui and gui:FindFirstChild("AbilityContainer")
        and gui.AbilityContainer:FindFirstChild("Dagger")

    if not btn or btn.BackgroundTransparency == 0 then return end

    for _,c in ipairs(getconnections(btn.MouseButton1Click)) do
        pcall(function() c:Fire() end)
    end
    pcall(function() btn:Activate() end)
end

--------------------------------------------------
-- BEHIND CHECK
--------------------------------------------------
local function isBehind(hrp, targetHRP)
    if (hrp.Position - targetHRP.Position).Magnitude > range then return false end
    if mode == "Around" then return true end
    local dir = -targetHRP.CFrame.LookVector
    return (hrp.Position - targetHRP.Position):Dot(dir) > 0.5
end

--------------------------------------------------
-- BACKSTAB CORE
--------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    if tick() - lastBackstabTime < BACKSTAB_COOLDOWN then return end

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _,name in ipairs(killerNames) do
        local killer = killersFolder:FindFirstChild(name)
        local kHRP = killer and killer:FindFirstChild("HumanoidRootPart")

        if kHRP and isBehind(hrp, kHRP) then
            lastBackstabTime = tick()

            local start = tick()
            local offset = kHRP.CFrame.LookVector * BACKSTAB_DISTANCE

            clickDaggerButton()

            local conn
            conn = RunService.Heartbeat:Connect(function()
                if tick() - start > BACKSTAB_HOLD_TIME or not killer.Parent then
                    conn:Disconnect()
                    return
                end
                hrp.CFrame = CFrame.new(
                    kHRP.Position - offset,
                    kHRP.Position
                )
            end)
            break
        end
    end
end)

--------------------------------------------------
-- INF STAMINA
--------------------------------------------------
local infStaminaEnabled = false
local sprint = ReplicatedStorage.Systems.Character.Game.Sprinting
local stamina = require(sprint)

task.spawn(function()
    while task.wait(1) do
        if infStaminaEnabled then
            stamina.Stamina = stamina.MaxStamina or 100
        end
    end
end)

--------------------------------------------------
-- ESP + BRIGHT
--------------------------------------------------
local espEnabled = false
local PlayersFolder = workspace:WaitForChild("Players")

local old = {
    Ambient = Lighting.Ambient,
    Outdoor = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart
}

local function bright(on)
    if on then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Brightness = 4
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 0
    else
        for i,v in pairs(old) do Lighting[i] = v end
    end
end

local function clearESP()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") then v:Destroy() end
    end
end

local function addESP(m,c)
    if m:FindFirstChild("Humanoid") and not m:FindFirstChild("HL") then
        local h = Instance.new("Highlight",m)
        h.Name="HL"
        h.FillTransparency=0.6
        h.FillColor=c
        h.OutlineColor=c
    end
end

task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            clearESP()
            for _,k in ipairs(PlayersFolder.Killers:GetChildren()) do
                addESP(k,Color3.new(1,0,0))
            end
            for _,s in ipairs(PlayersFolder.Survivors:GetChildren()) do
                addESP(s,Color3.new(0,1,0))
            end
        end
    end
end)

--------------------------------------------------
-- UI CALLBACKS
--------------------------------------------------
toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleButton.Text = "Backstab: "..(enabled and "ON" or "OFF")
end)

rangeBox.FocusLost:Connect(function()
    range = tonumber(rangeBox.Text) or range
end)

modeButton.MouseButton1Click:Connect(function()
    mode = (mode=="Behind" and "Around" or "Behind")
    modeButton.Text = "Mode: "..mode
end)

infStamButton.MouseButton1Click:Connect(function()
    infStaminaEnabled = not infStaminaEnabled
    infStamButton.Text = "Inf Stamina: "..(infStaminaEnabled and "ON" or "OFF")
end)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: "..(espEnabled and "ON" or "OFF")
    bright(espEnabled)
    if not espEnabled then clearESP() end
end)
