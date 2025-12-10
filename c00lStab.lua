local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackstabToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

-- Toggle Backstab Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.BorderSizePixel = 2
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Text = "Backstab: OFF"
toggleButton.Parent = screenGui

-- Range Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0, 120, 0, 20)
rangeLabel.Position = UDim2.new(0, 10, 0, 50)
rangeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rangeLabel.BorderColor3 = Color3.fromRGB(255, 0, 0)
rangeLabel.BorderSizePixel = 2
rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeLabel.Font = Enum.Font.SourceSans
rangeLabel.TextSize = 16
rangeLabel.Text = "Range:"
rangeLabel.Parent = screenGui

-- Range TextBox
local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0, 120, 0, 25)
rangeBox.Position = UDim2.new(0, 10, 0, 75)
rangeBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rangeBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
rangeBox.BorderSizePixel = 2
rangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeBox.Font = Enum.Font.SourceSans
rangeBox.TextSize = 16
rangeBox.PlaceholderText = "1-10 recommended 8"
rangeBox.Text = "8"
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = screenGui

-- Mode Button
local mode = "Behind"
local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 120, 0, 20)
modeButton.Position = UDim2.new(0, 10, 0, 105)
modeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
modeButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
modeButton.BorderSizePixel = 2
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Font = Enum.Font.SourceSans
modeButton.TextSize = 16
modeButton.Text = "Mode: Behind"
modeButton.Parent = screenGui

-- Infinite Stamina Button
local infStamButton = Instance.new("TextButton")
infStamButton.Size = UDim2.new(0, 120, 0, 25)
infStamButton.Position = UDim2.new(0, 10, 0, 130)
infStamButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infStamButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
infStamButton.BorderSizePixel = 2
infStamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
infStamButton.Font = Enum.Font.SourceSans
infStamButton.TextSize = 16
infStamButton.Text = "Inf Stamina: OFF"
infStamButton.Parent = screenGui

-- ESP Toggle Button
local Lighting = game:GetService("Lighting")
local PlayersFolder = workspace:WaitForChild("Players")

local espEnabled = false
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 120, 0, 25)
espButton.Position = UDim2.new(0, 10, 0, 160)
espButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
espButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
espButton.BorderSizePixel = 2
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Font = Enum.Font.SourceSansBold
espButton.TextSize = 16
espButton.Text = "ESP: OFF"
espButton.Parent = screenGui

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

-- Highlight ESP
local function createESP(model, outline, fill)
    local h = Instance.new("Highlight")
    h.Parent = model
    h.Adornee = model
    h.FillTransparency = 0.75
    h.FillColor = fill
    h.OutlineColor = outline
end

local function clearESP()
    for _, grp in ipairs(PlayersFolder:GetChildren()) do
        for _, plr in ipairs(grp:GetChildren()) do
            for _, obj in ipairs(plr:GetChildren()) do
                if obj:IsA("Highlight") then obj:Destroy() end
            end
        end
    end
end

local function applyESP()
    local killers = PlayersFolder:FindFirstChild("Killers")
    if killers then
        for _, m in ipairs(killers:GetChildren()) do
            if m:FindFirstChild("Humanoid") then
                createESP(m, Color3.new(1,0,0), Color3.new(1,0.3,0.3))
            end
        end
    end

    local survivors = PlayersFolder:FindFirstChild("Survivors")
    if survivors then
        for _, m in ipairs(survivors:GetChildren()) do
            if m:FindFirstChild("Humanoid") then
                createESP(m, Color3.new(0,1,0), Color3.new(0.4,1,0.4))
            end
        end
    end

    local genFolder = workspace.Map.Ingame.Map
    for _, obj in ipairs(genFolder:GetChildren()) do
        if obj.Name == "Generator" then
            createESP(obj, Color3.new(1,1,0), Color3.new(1,1,0.4))
        end
    end
end

-- Nút bật ESP
espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")

    if espEnabled then
        enableFullBright()
        applyESP()
    else
        disableFullBright()
        clearESP()
    end
end)

-- Auto refresh ESP
task.spawn(function()
    while task.wait(1) do
        if espEnabled then
            enableFullBright()
            clearESP()
            applyESP()
        end
    end
end)

-- Variables
local enabled = false
local cooldown = false
local lastTarget = nil
local range = 4
local daggerRemote = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local killerNames = { "Slasher", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Nosferatu", "Guest666" }
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

-- Infinite Stamina Setup
local infStaminaEnabled = false
local rs = cloneref(ReplicatedStorage)
local sprint = rs.Systems.Character.Game.Sprinting
local m = require(sprint)
task.spawn(function()
    while task.wait(1) do
        if infStaminaEnabled and m.Stamina < 100 then
            m.Stamina = 100
        end
    end
end)

-- GUI Button Logic
toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleButton.Text = "Backstab: " .. (enabled and "ON" or "OFF")
end)

rangeBox.FocusLost:Connect(function()
    local input = tonumber(rangeBox.Text)
    if input and input >= 1 and input <= 10 then
        range = input
    else
        rangeBox.Text = tostring(range)
    end
end)

modeButton.MouseButton1Click:Connect(function()
    mode = (mode == "Behind") and "Around" or "Behind"
    modeButton.Text = "Mode: " .. mode
end)

infStamButton.MouseButton1Click:Connect(function()
    infStaminaEnabled = not infStaminaEnabled
    infStamButton.Text = "Inf Stamina: " .. (infStaminaEnabled and "ON" or "OFF")
end)

-- Helper function
local function isBehindTarget(hrp, targetHRP)
    local distance = (hrp.Position - targetHRP.Position).Magnitude
    if distance > range then return false end

    if mode == "Around" then
        return true
    else
        local direction = -targetHRP.CFrame.LookVector
        local toPlayer = (hrp.Position - targetHRP.Position)
        return toPlayer:Dot(direction) > 0.5
    end
end

-- Main Backstab Loop
RunService.Heartbeat:Connect(function()
    if not enabled or cooldown then return end

    local char = lp.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart

    for _, name in ipairs(killerNames) do
        local killer = killersFolder:FindFirstChild(name)
        if killer and killer:FindFirstChild("HumanoidRootPart") then
            local kHRP = killer.HumanoidRootPart

            if isBehindTarget(hrp, kHRP) and killer ~= lastTarget then
                cooldown = true
                lastTarget = killer
                local start = tick()
                local didDagger = true

                local connection
                connection = RunService.Heartbeat:Connect(function()
                    if not (char and char.Parent and kHRP and kHRP.Parent) then
                        if connection then connection:Disconnect() end
                        return
                    end
                    local elapsed = tick() - start
                    if elapsed >= 0.5 then
                        if connection then connection:Disconnect() end
                        return
                    end

                    local behindPos = kHRP.Position - (kHRP.CFrame.LookVector * 0.3)
                    hrp.CFrame = CFrame.new(behindPos, behindPos + kHRP.CFrame.LookVector)

                    if not didDagger then
                        didDagger = true
                        local faceStart = tick()
                        local faceConn
                        faceConn = RunService.Heartbeat:Connect(function()
                            if tick() - faceStart >= 0.7 or not kHRP or not kHRP.Parent then
                                if faceConn then faceConn:Disconnect() end
                                return
                            end
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + kHRP.CFrame.LookVector)
                        end)
                        daggerRemote:FireServer("UseActorAbility", "Dagger")
                    end
                end)

                task.delay(2, function()
                    RunService.Heartbeat:Wait()
                    while isBehindTarget(hrp, kHRP) do
                        RunService.Heartbeat:Wait()
                    end
                    lastTarget = nil
                    cooldown = false
                end)

                break
            end
        end
    end
end)
