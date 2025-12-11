-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local workspace = workspace

local localPlayer = Players.LocalPlayer

-- [ Attack IDs: animation + sound ]
local attackIds = {
    -- Animation IDs
    ["126830014841198"] = true, ["126355327951215"] = true, ["121086746534252"] = true,
    ["18885909645"] = true, ["98456918873918"] = true, ["105458270463374"] = true,
    ["83829782357897"] = true, ["125403313786645"] = true, ["118298475669935"] = true,
    ["82113744478546"] = true, ["70371667919898"] = true, ["99135633258223"] = true,
    ["97167027849946"] = true, ["109230267448394"] = true, ["139835501033932"] = true,
    ["126896426760253"] = true, ["109667959938617"] = true, ["126681776859538"] = true,
    ["129976080405072"] = true, ["121293883585738"] = true, ["81639435858902"] = true,
    ["137314737492715"] = true, ["92173139187970"] = true, ["122709416391"] = true,
    ["879895330952"] = true,

    -- Sound IDs
    ["102228729296384"] = true, ["140242176732868"] = true, ["112809109188560"] = true,
    ["136323728355613"] = true, ["115026634746636"] = true, ["84116622032112"] = true,
    ["108907358619313"] = true, ["127793641088496"] = true, ["86174610237192"] = true,
    ["95079963655241"] = true, ["101199185291628"] = true, ["119942598489800"] = true,
    ["84307400688050"] = true, ["113037804008732"] = true, ["105200830849301"] = true,
    ["75330693422988"] = true, ["82221759983649"] = true, ["81702359653578"] = true,
    ["108610718831698"] = true, ["112395455254818"] = true, ["109431876587852"] = true,
    ["109348678063422"] = true, ["85853080745515"] = true, ["12222216"] = true,
    ["105840448036441"] = true, ["114742322778642"] = true, ["119583605486352"] = true,
    ["79980897195554"] = true, ["71805956520207"] = true, ["79391273191671"] = true,
    ["89004992452376"] = true, ["101553872555606"] = true, ["101698569375359"] = true,
    ["106300477136129"] = true, ["116581754553533"] = true, ["117231507259853"] = true,
    ["119089145505438"] = true, ["121954639447247"] = true, ["125213046326879"] = true,
    ["131406927389838"] = true, ["71834552297085"] = true, ["805165833096"] = true,
}

-- Variables
local toggleOn = false
local strictRangeOn = false
local detectionRange = 18
local screenGui, toggleButton, strictButton, rangeBox

-- Notifications
local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Auto Block", Text = text, Duration = 1.5 })
    end)
end

-- Click Block Button
local function clickBlockButton()
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then
        -- debug helper if PlayerGui absent
        warn("AutoBlock: PlayerGui not found when trying to click block.")
        return
    end
    local mainUI = gui:FindFirstChild("MainUI")
    local container = mainUI and mainUI:FindFirstChild("AbilityContainer")
    local blockButton = container and container:FindFirstChild("Block")
    if blockButton and blockButton:IsA("ImageButton") and blockButton.Visible then
        -- some environments expose BackgroundTransparency as number; keep the original guard
        if blockButton.BackgroundTransparency == 0 then return end
        -- getconnections is exploit-specific; keep, but protect with pcall
        pcall(function()
            for _, conn in ipairs(getconnections(blockButton.MouseButton1Click) or {}) do
                pcall(function() conn:Fire() end)
            end
        end)
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
        flag.Value = 12
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
        b.Size = UDim2.new(0, 120, 0, 30)
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
    rangeBox.Size = UDim2.new(0, 120, 0, 20)
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

    -- Inf Stamina Button
    local infStamButton = Instance.new("TextButton")
    infStamButton.Size = UDim2.new(0, 120, 0, 25)
    infStamButton.Position = UDim2.new(0, 10, 0, 105)
    infStamButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infStamButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    infStamButton.BorderSizePixel = 2
    infStamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    infStamButton.Font = Enum.Font.SourceSans
    infStamButton.TextSize = 16
    infStamButton.Text = "Inf Stamina: OFF"
    infStamButton.Parent = screenGui
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
    infStamButton.MouseButton1Click:Connect(function()
        infStaminaEnabled = not infStaminaEnabled
        infStamButton.Text = "Inf Stamina: " .. (infStaminaEnabled and "ON" or "OFF")
    end)

    -- ESP Toggle Button
    local PlayersFolder = workspace:WaitForChild("Players")
    local espEnabled = false
    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 120, 0, 25)
    espButton.Position = UDim2.new(0, 10, 0, 135)
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

    task.spawn(function()
        while task.wait(1) do
            if espEnabled then
                enableFullBright()
                clearESP()
                applyESP()
            end
        end
    end)

    -- update UI elements that are persistent (exposed outside function)
    -- these will be set later when flags are read
end -- <<-- CORRECTLY CLOSE createToggleGui() HERE

-- Saved flags
local toggleFlag = getBoolFlag("AutoBlockToggle")
local strictFlag = getBoolFlag("AutoBlockStrictRange")
local rangeFlag = getNumberFlag("AutoBlockRange")

-- apply saved flags to values (and create UI if player already spawned)
toggleOn = toggleFlag.Value
strictRangeOn = strictFlag.Value
detectionRange = rangeFlag.Value

-- create GUI when character exists / respawn
local function applyGuiTexts()
    if toggleButton then
        toggleButton.Text = toggleOn and "Auto Block: ON" or "Auto Block: OFF"
    end
    if strictButton then
        strictButton.Text = strictRangeOn and "Strict Range: ON" or "Strict Range: OFF"
    end
end

-- create GUI on spawn
localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createToggleGui()
    -- rebind saved flags to UI elements inside newly created gui
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

    if rangeBox then
        rangeBox.Text = tostring(detectionRange)
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

    applyGuiTexts()
end)

-- if character already present when script runs
if localPlayer.Character then
    createToggleGui()
    -- bind events same as above
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

    if rangeBox then
        rangeBox.Text = tostring(detectionRange)
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

    applyGuiTexts()
end

-- ========================
-- AutoBlock: unified animation + audio
-- ========================
local checked = {}

local function detectAttack(char)
    if checked[char] then return false end

    -- 1. Check animation
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            local id = track.Animation and track.Animation.AnimationId and string.match(track.Animation.AnimationId, "%d+")
            if id and attackIds[id] then
                checked[char] = { type = "animation", track = track }
                task.spawn(function()
                    -- wait safely for track stopped
                    pcall(function() track.Stopped:Wait() end)
                    checked[char] = nil
                end)
                return true
            end
        end
    end

    -- 2. Check sounds
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Sound") and d.IsPlaying then
            local id = string.match(d.SoundId or "", "%d+")
            if id and attackIds[id] then
                checked[char] = true
                task.spawn(function()
                    checked[char] = nil
                end)
                return true
            end
        end
    end

    return false
end

-- Unified AutoBlock Loop
RunService.Heartbeat:Connect(function()
    if not toggleOn then return end
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= localPlayer and other.Character then
            local root = other.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = other.Character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist <= detectionRange then
                    if strictRangeOn and not isFacing(myRoot, root) then continue end
                    if detectAttack(other.Character) then
                        clickBlockButton()
                    end
                end
            end
        end
    end
end)
