local Players = game:GetService("Players")    
local ReplicatedStorage = game:GetService("ReplicatedStorage")    
local RunService = game:GetService("RunService")    
local lp = Players.LocalPlayer    

-- GUI Setup    
local screenGui = Instance.new("ScreenGui")    
screenGui.Name = "BackstabToggleGui"    
screenGui.ResetOnSpawn = false    
screenGui.Parent = lp:WaitForChild("PlayerGui")    

-- Toggle GUI Button (nhỏ ở trên cùng)    
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

-- Container GUI (các nút + textbox khác)    
local mainFrame = Instance.new("Frame")    
mainFrame.Size = UDim2.new(0, 170, 0, 110)    
mainFrame.Position = UDim2.new(0, 10, 0, 25)    
mainFrame.BackgroundTransparency = 1    
mainFrame.Parent = screenGui    

-- Toggle Button    
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

-- TextBox for Range Input    
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
modeButton.Text = "Behind"    
modeButton.Parent = mainFrame    

-- GUI Toggle Logic    
local guiVisible = true    
guiToggleButton.MouseButton1Click:Connect(function()    
    guiVisible = not guiVisible    
    mainFrame.Visible = guiVisible    
    guiToggleButton.Text = guiVisible and "Hide" or "Show"    
end)    

-- Các biến Backstab    
local enabled = false    
local cooldown = false    
local lastTarget = nil    
local range = 8    
local daggerRemote = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")    
local killerNames = { "Jason", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Nosferatu", "Guest666" }    
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")    

-- Toggle Backstab    
toggleButton.MouseButton1Click:Connect(function()    
    enabled = not enabled    
    toggleButton.Text = "c00lstab: " .. (enabled and "ON" or "OFF")    
end)    

-- Range Handling    
rangeBox.FocusLost:Connect(function()    
    local input = tonumber(rangeBox.Text)    
    if input and input >= 1 and input <= 16 then    
        range = input    
    else    
        rangeBox.Text = tostring(range)    
    end    
end)    

-- Mode Button Logic    
modeButton.MouseButton1Click:Connect(function()    
    if mode == "Behind" then    
        mode = "Around"    
    else    
        mode = "Behind"    
    end    
    modeButton.Text = mode    
end)    

-- Helper function    
local function isBehindTarget(hrp, targetHRP)    
    local distance = (hrp.Position - targetHRP.Position).Magnitude    
    if distance > range then return false end    
    if mode == "Around" then return true end    
    local direction = -targetHRP.CFrame.LookVector    
    local toPlayer = (hrp.Position - targetHRP.Position)    
    return toPlayer:Dot(direction) > 0.5    
end    

-- Main loop    
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
                    local behindPos = kHRP.Position - (kHRP.CFrame.LookVector * 0.5)    
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
