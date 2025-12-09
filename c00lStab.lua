local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "c00lstabGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

-- GUI Toggle Button
local guiToggleButton = Instance.new("TextButton")
guiToggleButton.Size = UDim2.new(0, 60, 0, 25)
guiToggleButton.Position = UDim2.new(0, 10, 0, 0)
guiToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
guiToggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
guiToggleButton.BorderSizePixel = 2
guiToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
guiToggleButton.Font = Enum.Font.SourceSans
guiToggleButton.TextSize = 14
guiToggleButton.Text = "Hide"
guiToggleButton.Parent = screenGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 170, 0, 160)
mainFrame.Position = UDim2.new(0, 10, 0, 25)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- c00lstab Toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.BorderSizePixel = 2
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.Text = "c00lstab: OFF"
toggleButton.Parent = mainFrame

-- Range TextBox
local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0, 150, 0, 25)
rangeBox.Position = UDim2.new(0, 0, 0, 45)
rangeBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rangeBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
rangeBox.BorderSizePixel = 2
rangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeBox.Font = Enum.Font.SourceSans
rangeBox.TextSize = 16
rangeBox.PlaceholderText = "1-10 recommended 8"
rangeBox.Text = "8"
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = mainFrame

-- Mode Button
local mode = "Behind"
local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0, 150, 0, 25)
modeButton.Position = UDim2.new(0, 0, 0, 75)
modeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
modeButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
modeButton.BorderSizePixel = 2
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Font = Enum.Font.SourceSans
modeButton.TextSize = 16
modeButton.Text = "Mode: Behind"
modeButton.Parent = mainFrame

-- Inf Stamina Button
local infStaminaButton = Instance.new("TextButton")
infStaminaButton.Size = UDim2.new(0, 150, 0, 25)
infStaminaButton.Position = UDim2.new(0, 0, 0, 105)
infStaminaButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infStaminaButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
infStaminaButton.BorderSizePixel = 2
infStaminaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
infStaminaButton.Font = Enum.Font.SourceSans
infStaminaButton.TextSize = 16
infStaminaButton.Text = "Inf Stamina: OFF"
infStaminaButton.Parent = mainFrame

-- GUI Toggle Logic
local guiVisible = true
guiToggleButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
    guiToggleButton.Text = guiVisible and "Hide" or "Show"
end)

-- c00lstab & Range Logic
local enabled = false
local cooldown = false
local lastTarget = nil
local range = tonumber(rangeBox.Text) or 8
local daggerRemote = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local killerNames = { "Jason", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Nosferatu", "Guest666" }
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleButton.Text = "c00lstab: " .. (enabled and "ON" or "OFF")
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
    if mode == "Behind" then
        mode = "Around"
    else
        mode = "Behind"
    end
    modeButton.Text = "Mode: " .. mode
end)

local function isBehindTarget(hrp, targetHRP)
    local distance = (hrp.Position - targetHRP.Position).Magnitude
    if distance > range then return false end
    if mode == "Around" then return true end
    local direction = -targetHRP.CFrame.LookVector
    local toPlayer = (hrp.Position - targetHRP.Position)
    return toPlayer:Dot(direction) > 0.5
end

-- Inf Stamina Logic
local infStaminaEnabled = false
infStaminaButton.MouseButton1Click:Connect(function()
    infStaminaEnabled = not infStaminaEnabled
    infStaminaButton.Text = "Inf Stamina: " .. (infStaminaEnabled and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    -- Inf Stamina
    if infStaminaEnabled then
        local char = lp.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if hum:FindFirstChild("Stamina") then
                hum.Stamina.Value = hum.Stamina.MaxValue
            end
        end
    end

    -- c00lstab
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
                local didDagger = false
                local connection
                connection = RunService.Heartbeat:Connect(function()
                    if not (char and char.Parent and kHRP and kHRP.Parent) then
                        if connection then connection:Disconnect() end
                        return
                    end
                    if tick() - start >= 0.5 then
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
