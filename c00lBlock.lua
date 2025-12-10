-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer

-- [ Animation IDs ]
local animationIds = {
    ["126830014841198"] = true, ["126355327951215"] = true, ["121086746534252"] = true,
    ["18885909645"] = true, ["98456918873918"] = true, ["105458270463374"] = true,
    ["83829782357897"] = true, ["125403313786645"] = true, ["118298475669935"] = true,
    ["82113744478546"] = true, ["70371667919898"] = true, ["99135633258223"] = true,
    ["97167027849946"] = true, ["109230267448394"] = true, ["139835501033932"] = true,
    ["126896426760253"] = true, ["109667959938617"] = true, ["126681776859538"] = true,
    ["129976080405072"] = true, ["121293883585738"] = true, ["81639435858902"] = true,
    ["137314737492715"] = true, ["92173139187970"] = true, ["122709416391"] = true,
    ["879895330952"] = true,
}

-- Variables
local toggleOn = false
local strictRangeOn = false
local detectionRange = 18
local screenGui, toggleButton, strictButton, rangeBox
local clickedTracks = {}

-- Notifications
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Auto Block", Text = text, Duration = 1.5 })
    end)
end

-- Click Block Button
local function clickBlockButton()
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local mainUI = gui:FindFirstChild("MainUI")
    local container = mainUI and mainUI:FindFirstChild("AbilityContainer")
    local blockButton = container and container:FindFirstChild("Block")
    if blockButton and blockButton:IsA("ImageButton") and blockButton.Visible then
        if blockButton.BackgroundTransparency == 0 then return end
        for _, conn in ipairs(getconnections(blockButton.MouseButton1Click)) do
            pcall(function() conn:Fire() end)
        end
        pcall(function() blockButton:Activate() end)
    end
end

-- Facing 90°
local function isFacing(localRoot, targetRoot)
    if not localRoot or not targetRoot then return false end
    local directionToPlayer = (localRoot.Position - targetRoot.Position)
    if directionToPlayer.Magnitude == 0 then return false end
    directionToPlayer = directionToPlayer.Unit
    local facingDirection = targetRoot.CFrame.LookVector
    return facingDirection:Dot(directionToPlayer) > 0
end

-- Saved Toggles helpers
local function getBoolFlag(name)
    local flag = localPlayer:FindFirstChild(name)
    if not flag then
        flag = Instance.new("BoolValue")
        flag.Name = name
        flag.Value = false
        flag.Parent = localPlayer
    end
    return flag
end

local function getNumberFlag(name)
    local flag = localPlayer:FindFirstChild(name)
    if not flag then
        flag = Instance.new("NumberValue")
        flag.Name = name
        flag.Value = 18
        flag.Parent = localPlayer
    end
    return flag
end

-- GUI creator (style c00lstab), NO Fake Block
local function createToggleGui()
    if screenGui then screenGui:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockAutoToggleGui"
    screenGui.ResetOnSpawn = true
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

    local function makeBtn(text, y)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 130, 0, 30)
        b.Position = UDim2.new(0, 10, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        b.BorderColor3 = Color3.fromRGB(255, 0, 0)
        b.BorderSizePixel = 2
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 16
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = text
        b.Parent = screenGui
        return b
    end

    toggleButton = makeBtn("Auto Block: OFF", 10)
    strictButton = makeBtn("Strict Range: OFF", 45)

    rangeBox = Instance.new("TextBox")
    rangeBox.Size = UDim2.new(0, 130, 0, 30)
    rangeBox.Position = UDim2.new(0, 10, 0, 80)
    rangeBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    rangeBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
    rangeBox.BorderSizePixel = 2
    rangeBox.Font = Enum.Font.SourceSansBold
    rangeBox.TextSize = 16
    rangeBox.TextColor3 = Color3.new(1,1,1)
    rangeBox.Text = tostring(detectionRange)
    rangeBox.ClearTextOnFocus = false
    rangeBox.Parent = screenGui

    -- Inf Stamina button (keeps c00lstab behavior)
    local infStaminaEnabled = false
    local infStamBtn = makeBtn("Inf Stamina: OFF", 115)

    infStamBtn.MouseButton1Click:Connect(function()
        infStaminaEnabled = not infStaminaEnabled
        infStamBtn.Text = infStaminaEnabled and "Inf Stamina: ON" or "Inf Stamina: OFF"
    end)

    -- ESP button (Highlight + FullBright + Fog off)
    local espEnabled = false
    local espBtn = makeBtn("ESP: OFF", 150)

    local oldAmbient = Lighting.Ambient
    local oldOutdoor = Lighting.OutdoorAmbient
    local oldBrightness = Lighting.Brightness
    local oldFogEnd = Lighting.FogEnd
    local oldFogStart = Lighting.FogStart

    local highlights = {}

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

    local function applyHighlights()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer then
                local char = plr.Character
                if char and not highlights[plr] then
                    local h = Instance.new("Highlight")
                    h.Parent = char
                    h.Adornee = char
                    h.FillTransparency = 0.75
                    h.FillColor = Color3.new(1,0,0)
                    h.OutlineColor = Color3.new(1,1,1)
                    highlights[plr] = h
                end
            end
        end

        pcall(function()
            local genFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
            if genFolder then
                for _, obj in ipairs(genFolder:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == "Generator" and not highlights[obj] then
                        local hg = Instance.new("Highlight")
                        hg.Parent = obj
                        hg.Adornee = obj
                        hg.FillTransparency = 0.75
                        hg.FillColor = Color3.new(1,1,0)
                        hg.OutlineColor = Color3.new(1,1,1)
                        highlights[obj] = hg
                    end
                end
            end
        end)
    end

    local function clearHighlights()
        for k,v in pairs(highlights) do
            if v and v.Parent then
                pcall(function() v:Destroy() end)
            end
        end
        highlights = {}
    end

    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        if espEnabled then
            enableFullBright()
            applyHighlights()
        else
            disableFullBright()
            clearHighlights()
        end
    end)

    -- Auto refresh ESP while enabled
    task.spawn(function()
        while true do
            task.wait(1)
            if espEnabled then
                enableFullBright()
                clearHighlights()
                applyHighlights()
            end
        end
    end)

    -- Setup saved flags
    local toggleFlag = getBoolFlag("AutoBlockToggle")
    local strictFlag = getBoolFlag("AutoBlockStrictRange")
    local rangeFlag = getNumberFlag("AutoBlockRange")

    toggleOn = toggleFlag.Value
    strictRangeOn = strictFlag.Value
    detectionRange = rangeFlag.Value
    rangeBox.Text = tostring(detectionRange)

    -- update initial texts
    toggleButton.Text = toggleOn and "Auto Block: ON" or "Auto Block: OFF"
    strictButton.Text = strictRangeOn and "Strict Range: ON" or "Strict Range: OFF"

    -- Events wiring (AutoBlock GUI)
    toggleButton.MouseButton1Click:Connect(function()
        toggleOn = not toggleOn
        toggleFlag.Value = toggleOn
        toggleButton.Text = toggleOn and "Auto Block: ON" or "Auto Block: OFF"
    end)

    strictButton.MouseButton1Click:Connect(function()
        strictRangeOn = not strictRangeOn
        strictFlag.Value = strictRangeOn
        strictButton.Text = strictRangeOn and "Strict Range: ON" or "Strict Range: OFF"
    end)

    rangeBox.FocusLost:Connect(function()
        local num = tonumber(rangeBox.Text)
        if num then
            detectionRange = math.clamp(num, 1, 1000)
            rangeFlag.Value = detectionRange
            rangeBox.Text = tostring(detectionRange)
        else
            rangeBox.Text = tostring(detectionRange)
        end
    end)
end

-- Respawn GUI
localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createToggleGui()
end)
if localPlayer.Character then
    createToggleGui()
end

-- Auto Block Loop (kept, but uses animationIds table)
RunService.Heartbeat:Connect(function()
    if not toggleOn then return end
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= localPlayer and otherPlayer.Character then
            local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist <= detectionRange then
                    local facing = isFacing(myRoot, root)
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        local anim = track.Animation
                        local id = anim and anim.AnimationId and string.match(anim.AnimationId, "%d+")
                        if id and animationIds[id] and not clickedTracks[track] then
                            if strictRangeOn and not facing then
                                -- strict requires facing; skip if not facing
                                continue
                            end
                            clickedTracks[track] = true
                            notify(otherPlayer.Name .. " started animation " .. id)
                            clickBlockButton()
                            task.spawn(function()
                                track.Stopped:Wait()
                                clickedTracks[track] = nil
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Inf Stamina Setup (keep c00lstab behavior)
local infStaminaEnabled = false
local rs_clone = cloneref(ReplicatedStorage)
local sprintModule = nil
pcall(function()
    sprintModule = rs_clone.Systems.Character.Game.Sprinting
end)
local m = nil
if sprintModule then
    local ok, req = pcall(function() return require(sprintModule) end)
    if ok then m = req end
end

task.spawn(function()
    while task.wait(0.5) do
        if infStaminaEnabled and m and m.Stamina then
            if m.Stamina < 99 then
                pcall(function() m.Stamina = 100 end)
            end
        end
    end
end)

-- Bind Inf Stamina GUI button to the internal variable (works after GUI created)
task.spawn(function()
    while not screenGui do task.wait(0.1) end
    local function bindInfStam()
        local gui = localPlayer:FindFirstChild("PlayerGui")
        if not gui then return end
        local g = gui:FindFirstChild("BlockAutoToggleGui")
        if not g then return end
        for _, child in ipairs(g:GetChildren()) do
            if child:IsA("TextButton") and child.Text:match("Inf Stamina") then
                child.MouseButton1Click:Connect(function()
                    infStaminaEnabled = not infStaminaEnabled
                    child.Text = infStaminaEnabled and "Inf Stamina: ON" or "Inf Stamina: OFF"
                end)
                return
            end
        end
    end
    while task.wait(0.5) do
        pcall(bindInfStam)
    end
end)
