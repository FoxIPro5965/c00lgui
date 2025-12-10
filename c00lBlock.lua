-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer

-- AutoBlock animations list (giữ nguyên)
local autoBlockTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738",
    "81639435858902", "137314737492715",
    "92173139187970", "122709416391", "879895330952"
}

-- Variables (AutoBlock core kept nguyên)
local toggleOn = false
local strictRangeOn = false
local detectionRange = 18
local screenGui, toggleButton, strictButton, rangeBox
local clickedTracks = {}

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

-- Notifications
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Auto Block", Text = text, Duration = 1.5 })
    end)
end

-- Click Block Button (giữ nguyên)
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

-- Facing 90° (giữ nguyên)
local function isFacing(localRoot, targetRoot)
    if not localRoot or not targetRoot then return false end
    local directionToPlayer = (localRoot.Position - targetRoot.Position).Unit
    local facingDirection = targetRoot.CFrame.LookVector
    return facingDirection:Dot(directionToPlayer) > 0
end

-- GUI creator (style c00lstab), thêm ESP + InfStamina
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

    local fakeBlockToggle = makeBtn("Fake Block: OFF", 115)
    local modeButton = makeBtn("Mode: Normal", 150)
    modeButton.Visible = false

    -- Inf Stamina button (KEEP behavior same as c00lstab)
    local infStaminaEnabled = false
    local infStamBtn = makeBtn("Inf Stamina: OFF", 185)

    infStamBtn.MouseButton1Click:Connect(function()
        infStaminaEnabled = not infStaminaEnabled
        infStamBtn.Text = infStaminaEnabled and "Inf Stamina: ON" or "Inf Stamina: OFF"
    end)

    -- ESP button (Highlight + FullBright + Fog off)
    local espEnabled = false
    local espBtn = makeBtn("ESP: OFF", 220)

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

        -- Generators highlight if exist
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
    fakeBlockToggle.Text = "Fake Block: OFF"
    modeButton.Text = "Mode: Normal"

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

    fakeBlockToggle.MouseButton1Click:Connect(function()
        local currently = fakeBlockToggle.Text:find("ON") and true or false
        currently = not currently
        fakeBlockToggle.Text = currently and "Fake Block: ON" or "Fake Block: OFF"
        fakeBlockToggle.BackgroundColor3 = currently and Color3.fromRGB(0,170,0) or Color3.fromRGB(0,0,0)
        modeButton.Visible = currently
    end)

    modeButton.MouseButton1Click:Connect(function()
        if modeButton.Text == "Mode: Normal" then
            modeButton.Text = "Mode: M3&4"
        else
            modeButton.Text = "Mode: Normal"
        end
    end)

    -- Fake block button visual (kept)
    local fakeBlockButton = Instance.new("TextButton")
    fakeBlockButton.Size = UDim2.new(0, 50, 0, 50)
    fakeBlockButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fakeBlockButton.BorderColor3 = Color3.fromRGB(255,0,0)
    fakeBlockButton.BorderSizePixel = 2
    fakeBlockButton.TextColor3 = Color3.new(1,1,1)
    fakeBlockButton.Text = "Fake Block"
    fakeBlockButton.Visible = false
    fakeBlockButton.Parent = screenGui
    fakeBlockButton.AnchorPoint = Vector2.new(0.5, 0.5)
    fakeBlockButton.Position = UDim2.new(0.5, 0, 0.7, 0)

    local dragging = false
    local dragStart, startPos
    local function updateInput(input)
        local delta = input.Position - dragStart
        fakeBlockButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                             startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    fakeBlockButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = fakeBlockButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    fakeBlockButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)

    fakeBlockButton.MouseButton1Click:Connect(function()
        -- play fake block animation if wanted (kept original mapping)
        local char = localPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://72722244508749"
        humanoid:LoadAnimation(anim):Play()
    end)

    RunService.Heartbeat:Connect(function()
        -- manage fakeBlockButton visibility based on MainUI Block button
        local gui = localPlayer:FindFirstChild("PlayerGui")
        local mainUI = gui and gui:FindFirstChild("MainUI")
        local container = mainUI and mainUI:FindFirstChild("AbilityContainer")
        local blockButton = container and container:FindFirstChild("Block")
        if blockButton and blockButton:IsA("ImageButton") and blockButton.Visible and fakeBlockToggle.Text:find("ON") then
            fakeBlockButton.Visible = true
            fakeBlockButton.Size = blockButton.Size
        else
            fakeBlockButton.Visible = false
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

-- Auto Block Loop (kept nguyên bản)
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
                            if not facing then continue end
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

-- Provide a simple binding so GUI InfStamina button toggles this variable
-- (This binding uses the button created in createToggleGui; if GUI already exists it's hooked)
task.spawn(function()
    while not screenGui do task.wait(0.1) end
    -- try to find the Inf Stamina button we created
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
