--// c00lStab // 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

--// GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "c00lStabGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

-- Backstab Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 130, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleButton.BorderColor3 = Color3.fromRGB(255,0,0)
toggleButton.BorderSizePixel = 2
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 19
toggleButton.Text = "Backstab: OFF"
toggleButton.Parent = screenGui

-- Range Label
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0,130,0,20)
rangeLabel.Position = UDim2.new(0,10,0,50)
rangeLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
rangeLabel.BorderColor3 = Color3.fromRGB(255,0,0)
rangeLabel.BorderSizePixel = 2
rangeLabel.TextColor3 = Color3.fromRGB(255,255,255)
rangeLabel.Font = Enum.Font.SourceSans
rangeLabel.TextSize = 15
rangeLabel.Text = "Range:"
rangeLabel.Parent = screenGui

-- Range TextBox
local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0,130,0,25)
rangeBox.Position = UDim2.new(0,10,0,75)
rangeBox.BackgroundColor3 = Color3.fromRGB(0,0,0)
rangeBox.BorderColor3 = Color3.fromRGB(255,0,0)
rangeBox.BorderSizePixel = 2
rangeBox.TextColor3 = Color3.fromRGB(255,255,255)
rangeBox.Font = Enum.Font.SourceSans
rangeBox.TextSize = 16
rangeBox.PlaceholderText = "1-10 recommended 8"
rangeBox.Text = "8"
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = screenGui

-- Mode Button
local mode = "Behind"
local modeButton = Instance.new("TextButton")
modeButton.Size = UDim2.new(0,130,0,25)
modeButton.Position = UDim2.new(0,10,0,105)
modeButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
modeButton.BorderColor3 = Color3.fromRGB(255,0,0)
modeButton.BorderSizePixel = 2
modeButton.TextColor3 = Color3.fromRGB(255,255,255)
modeButton.Font = Enum.Font.SourceSans
modeButton.TextSize = 16
modeButton.Text = "Mode: Behind"
modeButton.Parent = screenGui

-- Infinite Stamina Button
local infStamButton = Instance.new("TextButton")
infStamButton.Size = UDim2.new(0,130,0,25)
infStamButton.Position = UDim2.new(0,10,0,135)
infStamButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
infStamButton.BorderColor3 = Color3.fromRGB(255,0,0)
infStamButton.BorderSizePixel = 2
infStamButton.TextColor3 = Color3.fromRGB(255,255,255)
infStamButton.Font = Enum.Font.SourceSans
infStamButton.TextSize = 16
infStamButton.Text = "Inf Stamina: OFF"
infStamButton.Parent = screenGui

--// Variables
local enabled = false
local cooldown = false
local lastTarget = nil
local range = 4
local infStaminaEnabled = false
local daggerRemote = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local killerNames = { "Slasher", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Nosferatu", "Guest666" }
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

--// GUI Logic
toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggleButton.Text = "Backstab: " .. (enabled and "ON" or "OFF")
end)

rangeBox.FocusLost:Connect(function()
	local input = tonumber(rangeBox.Text)
	if input and input >=1 and input <=10 then
		range = input
	else
		rangeBox.Text = tostring(range)
	end
end)

modeButton.MouseButton1Click:Connect(function()
	mode = (mode == "Behind") and "Around" or "Behind"
	modeButton.Text = "Mode: "..mode
end)

infStamButton.MouseButton1Click:Connect(function()
	infStaminaEnabled = not infStaminaEnabled
	infStamButton.Text = "Inf Stamina: "..(infStaminaEnabled and "ON" or "OFF")
end)

--// Infinite Stamina Logic
task.spawn(function()
	while task.wait(0.1) do
		if infStaminaEnabled then
			local rs = cloneref(ReplicatedStorage)
			local sprint = rs.Systems.Character.Game.Sprinting
			local m = require(sprint)
			if m.Stamina < 3 then
				m.Stamina = 100
			end
		end
	end
end)

--// Helper Functions
local function getDaggerButton()
	local pg = lp:FindFirstChild("PlayerGui")
	if not pg then return nil end
	local mainUI = pg:FindFirstChild("MainUI")
	if not mainUI then return nil end
	local container = mainUI:FindFirstChild("AbilityContainer")
	if not container then return nil end
	return container:FindFirstChild("Dagger")
end

local daggerCooldownText
local function refreshDaggerRef()
	local mainui = lp:FindFirstChild("PlayerGui"):FindFirstChild("MainUI")
	if mainui and mainui:FindFirstChild("AbilityContainer") then
		local dagger = mainui.AbilityContainer:FindFirstChild("Dagger")
		if dagger and dagger:FindFirstChild("CooldownTime") then
			daggerCooldownText = dagger.CooldownTime
			return
		end
	end
	daggerCooldownText = nil
end

lp.PlayerGui.DescendantAdded:Connect(refreshDaggerRef)
lp.PlayerGui.DescendantRemoving:Connect(function(obj)
	if obj == daggerCooldownText then daggerCooldownText = nil end
end)
refreshDaggerRef()

local function isBehindTarget(hrp, targetHRP)
	local distance = (hrp.Position - targetHRP.Position).Magnitude
	if distance > range then return false end
	if mode == "Around" then return true end
	local direction = -targetHRP.CFrame.LookVector
	local toPlayer = (hrp.Position - targetHRP.Position)
	return toPlayer:Dot(direction) > 0.3
end

local function tryActivateButton(btn)
	if btn and btn:IsA("TextButton") then
		btn:Activate()
	end
end

--// Main Auto Backstab + Auto Dagger
RunService.RenderStepped:Connect(function()
	if not enabled or cooldown then return end
	if not daggerCooldownText or tonumber(daggerCooldownText.Text) then return end

	local char = lp.Character
	if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
	local hrp = char.HumanoidRootPart
	local stats = game:GetService("Stats")

	for _, name in ipairs(killerNames) do
		local killer = killersFolder:FindFirstChild(name)
		if killer and killer:FindFirstChild("HumanoidRootPart") then
			local kHRP = killer.HumanoidRootPart

			if isBehindTarget(hrp,kHRP) and killer ~= lastTarget then
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

					local elapsed = tick() - start
					if elapsed >= 0.5 then
						if connection then connection:Disconnect() end
						return
					end

					-- Predict position
					local ping = tonumber(stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+")) or 50
					local pingSec = ping/1000
					local predPos = kHRP.Position + (kHRP.Velocity.Unit * kHRP.Velocity.Magnitude * pingSec)

					local targetPos
					if mode=="Behind" then
						targetPos = predPos - (kHRP.CFrame.LookVector*0.3)
					else
						targetPos = predPos + kHRP.CFrame.RightVector*0.3
					end

					hrp.CFrame = CFrame.new(targetPos, targetPos+kHRP.CFrame.LookVector)

					if not didDagger then
						didDagger = true
						local daggerBtn = getDaggerButton()
						tryActivateButton(daggerBtn)
					end
				end)

				task.delay(2,function()
					RunService.Heartbeat:Wait()
					while isBehindTarget(hrp,kHRP) do
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
