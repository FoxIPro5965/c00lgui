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
local PlayersFolder = workspace:WaitForChild("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local killersLabel = Instance.new("TextLabel")
killersLabel.Size = UDim2.new(0, 200, 0, 50)
killersLabel.Position = UDim2.new(0, 10, 0, 10)
killersLabel.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
killersLabel.TextColor3 = Color3.new(1, 1, 1)
killersLabel.TextScaled = true
killersLabel.Font = Enum.Font.SourceSansBold
killersLabel.Parent = screenGui

local survivorsLabel = Instance.new("TextLabel")
survivorsLabel.Size = UDim2.new(0, 200, 0, 50)
survivorsLabel.Position = UDim2.new(0, 10, 0, 70)
survivorsLabel.BackgroundColor3 = Color3.fromRGB(40, 255, 40)
survivorsLabel.TextColor3 = Color3.new(1, 1, 1)
survivorsLabel.TextScaled = true
survivorsLabel.Font = Enum.Font.SourceSansBold
survivorsLabel.Parent = screenGui

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 200, 0, 40)
espButton.Position = UDim2.new(0, 10, 0, 130)
espButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
espButton.BorderSizePixel = 2
espButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
espButton.TextColor3 = Color3.new(1, 1, 1)
espButton.TextScaled = true
espButton.Font = Enum.Font.SourceSansBold
espButton.Text = "ESP: ON"
espButton.Parent = screenGui

local espEnabled = true

local function clearESP()
	for _, obj in pairs(PlayersFolder:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
			for _, h in ipairs(obj:GetChildren()) do
				if h:IsA("Highlight") then
					h:Destroy()
				end
			end
		end
	end

	local generators = workspace:FindFirstChild("Map") 
		and workspace.Map:FindFirstChild("Ingame") 
		and workspace.Map.Ingame:FindFirstChild("Map")

	if generators then
		for _, g in pairs(generators:GetChildren()) do
			if g:IsA("Model") then
				for _, h in pairs(g:GetChildren()) do
					if h:IsA("Highlight") then
						h:Destroy()
					end
				end
			end
		end
	end
end

local function createESP(model, outlineColor, fillColor)
	local highlight = Instance.new("Highlight")
	highlight.Parent = model
	highlight.Adornee = model
	highlight.FillTransparency = 0.75
	highlight.FillColor = fillColor
	highlight.OutlineColor = outlineColor
	highlight.OutlineTransparency = 0
end

local function espGroup(group, oc, fc)
	for _, obj in pairs(group:GetChildren()) do
		local hum = obj:FindFirstChildOfClass("Humanoid")
		if hum and obj:FindFirstChild("HumanoidRootPart") then
			createESP(obj, oc, fc)
		end
	end
end

local function espGenerators()
	local folder = workspace:FindFirstChild("Map") 
		and workspace.Map:FindFirstChild("Ingame") 
		and workspace.Map.Ingame:FindFirstChild("Map")

	if folder then
		for _, obj in pairs(folder:GetChildren()) do
			if obj:IsA("Model") and obj.Name == "Generator" then
				createESP(obj, Color3.new(1, 1, 0), Color3.new(1, 1, 0.5))
			end
		end
	end
end

local function updateESP()
	while true do
		if espEnabled then
			clearESP()

			local killers = PlayersFolder:FindFirstChild("Killers")
			if killers then
				espGroup(killers, Color3.new(1, 0, 0), Color3.new(1, 0.5, 0.5))
				killersLabel.Text = "Killers: " .. #killers:GetChildren()
			else
				killersLabel.Text = "Killers: 0"
			end

			local survivors = PlayersFolder:FindFirstChild("Survivors")
			if survivors then
				espGroup(survivors, Color3.new(0, 1, 0), Color3.new(0.5, 1, 0.5))
				survivorsLabel.Text = "Survivors: " .. #survivors:GetChildren()
			else
				survivorsLabel.Text = "Survivors: 0"
			end

			espGenerators()
		end

		wait(5)
	end
end

espButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
	if not espEnabled then
		clearESP()
	end
end)

task.spawn(updateESP)

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
    while task.wait(0.5) do
        if infStaminaEnabled and m.Stamina < 99 then
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
