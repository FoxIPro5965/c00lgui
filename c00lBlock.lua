local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local workspace = workspace
local localPlayer = Players.LocalPlayer

local attackIds = {
    ["126830014841198"]=true,["126355327951215"]=true,["121086746534252"]=true,
    ["18885909645"]=true,["98456918873918"]=true,["105458270463374"]=true,
    ["83829782357897"]=true,["125403313786645"]=true,["118298475669935"]=true,
    ["82113744478546"]=true,["70371667919898"]=true,["99135633258223"]=true,
    ["97167027849946"]=true,["109230267448394"]=true,["139835501033932"]=true,
    ["126896426760253"]=true,["109667959938617"]=true,["126681776859538"]=true,
    ["129976080405072"]=true,["121293883585738"]=true,["81639435858902"]=true,
    ["137314737492715"]=true,["92173139187970"]=true,["122709416391"]=true,
    ["879895330952"]=true,["102228729296384"]=true,["140242176732868"]=true,
    ["112809109188560"]=true,["136323728355613"]=true,["115026634746636"]=true,
    ["84116622032112"]=true,["108907358619313"]=true,["127793641088496"]=true,
    ["86174610237192"]=true,["95079963655241"]=true,["101199185291628"]=true,
    ["119942598489800"]=true,["84307400688050"]=true,["113037804008732"]=true,
    ["105200830849301"]=true,["75330693422988"]=true,["82221759983649"]=true,
    ["81702359653578"]=true,["108610718831698"]=true,["112395455254818"]=true,
    ["109431876587852"]=true,["109348678063422"]=true,["85853080745515"]=true,
    ["12222216"]=true,["105840448036441"]=true,["114742322778642"]=true,
    ["119583605486352"]=true,["79980897195554"]=true,["71805956520207"]=true,
    ["79391273191671"]=true,["89004992452376"]=true,["101553872555606"]=true,
    ["101698569375359"]=true,["106300477136129"]=true,["116581754553533"]=true,
    ["117231507259853"]=true,["119089145505438"]=true,["121954639447247"]=true,
    ["125213046326879"]=true,["131406927389838"]=true,["71834552297085"]=true,
    ["805165833096"]=true,
}

local toggleOn = false
local strictRangeOn = false
local detectionRange = 18
local screenGui, toggleButton, strictButton, rangeBox

local function clickBlockButton()
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local mainUI = gui:FindFirstChild("MainUI")
    local container = mainUI and mainUI:FindFirstChild("AbilityContainer")
    local blockButton = container and container:FindFirstChild("Block")
    if blockButton and blockButton:IsA("ImageButton") and blockButton.Visible then
        if blockButton.BackgroundTransparency == 0 then return end
        pcall(function()
            for _, c in ipairs(getconnections(blockButton.MouseButton1Click) or {}) do
                pcall(function() c:Fire() end)
            end
        end)
        pcall(function() blockButton:Activate() end)
    end
end

local function isFacing(localRoot, targetRoot)
    local dir = (localRoot.Position - targetRoot.Position)
    if dir.Magnitude == 0 then return false end
    return targetRoot.CFrame.LookVector:Dot(dir.Unit) > 0
end

local function getBoolFlag(n)
    local f = localPlayer:FindFirstChild(n)
    if not f then f = Instance.new("BoolValue"); f.Name=n; f.Parent=localPlayer end
    return f
end

local function getNumberFlag(n)
    local f = localPlayer:FindFirstChild(n)
    if not f then f = Instance.new("NumberValue"); f.Name=n; f.Value=12; f.Parent=localPlayer end
    return f
end

local function Dragify(frame)
    local UIS = game:GetService("UserInputService")
    local dragging, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function createToggleGui()
    if screenGui then screenGui:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockAutoToggleGui"
    screenGui.ResetOnSpawn = true
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 170)
    frame.Position = UDim2.new(0, 20, 0, 200)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderColor3 = Color3.fromRGB(255,0,0)
    frame.BorderSizePixel = 2
    frame.Parent = screenGui

    Dragify(frame)

    local function makeBtn(text, y, h)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 130, 0, h)
        b.Position = UDim2.new(0, 10, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(0,0,0)
        b.BorderColor3 = Color3.fromRGB(255,0,0)
        b.BorderSizePixel = 2
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 16
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = text
        b.Parent = frame
        return b
    end

    toggleButton = makeBtn("Auto Block: OFF", 10, 25)
    strictButton = makeBtn("Strict Range: OFF", 40, 25)

    rangeBox = Instance.new("TextBox")
    rangeBox.Size = UDim2.new(0, 130, 0, 22)
    rangeBox.Position = UDim2.new(0, 10, 0, 70)
    rangeBox.BackgroundColor3 = Color3.new(0,0,0)
    rangeBox.BorderColor3 = Color3.fromRGB(255,0,0)
    rangeBox.BorderSizePixel = 2
    rangeBox.Font = Enum.Font.SourceSansBold
    rangeBox.TextSize = 16
    rangeBox.TextColor3 = Color3.new(1,1,1)
    rangeBox.Text = tostring(detectionRange)
    rangeBox.ClearTextOnFocus = false
    rangeBox.Parent = frame

    local inf = makeBtn("Inf Stamina: OFF", 100, 25)
    local infEnabled = false
    local rs = cloneref(ReplicatedStorage)
    local sprint = rs.Systems.Character.Game.Sprinting
    local m = require(sprint)

    inf.MouseButton1Click:Connect(function()
        infEnabled = not infEnabled
        inf.Text = "Inf Stamina: " .. (infEnabled and "ON" or "OFF")
    end)

    task.spawn(function()
        while task.wait(1) do
            if infEnabled and m.Stamina < 100 then m.Stamina = 100 end
        end
    end)

    local espButton = makeBtn("ESP: OFF", 130, 25)
    local espEnabled = false
    local oldAmbient = Lighting.Ambient
    local oldOutdoor = Lighting.OutdoorAmbient
    local oldBrightness = Lighting.Brightness
    local oldFogEnd = Lighting.FogEnd
    local oldFogStart = Lighting.FogStart
    local PlayersFolder = workspace:WaitForChild("Players")

    local function fbOn()
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Brightness = 4
        Lighting.FogEnd = 999999
        Lighting.FogStart = 0
    end

    local function fbOff()
        Lighting.Ambient = oldAmbient
        Lighting.OutdoorAmbient = oldOutdoor
        Lighting.Brightness = oldBrightness
        Lighting.FogEnd = oldFogEnd
        Lighting.FogStart = oldFogStart
    end

    local function clearESP()
        for _, grp in ipairs(PlayersFolder:GetChildren()) do
            for _, m in ipairs(grp:GetChildren()) do
                for _, o in ipairs(m:GetChildren()) do
                    if o:IsA("Highlight") then o:Destroy() end
                end
            end
        end
    end

    local function makeESP(model, o, f)
        local h = Instance.new("Highlight")
        h.Parent = model
        h.Adornee = model
        h.FillTransparency = .75
        h.FillColor = f
        h.OutlineColor = o
    end

    local function doESP()
        local killers = PlayersFolder:FindFirstChild("Killers")
        if killers then
            for _, m in ipairs(killers:GetChildren()) do
                if m:FindFirstChild("Humanoid") then
                    makeESP(m, Color3.new(1,0,0), Color3.new(1,0.3,0.3))
                end
            end
        end
        local survivors = PlayersFolder:FindFirstChild("Survivors")
        if survivors then
            for _, m in ipairs(survivors:GetChildren()) do
                if m:FindFirstChild("Humanoid") then
                    makeESP(m, Color3.new(0,1,0), Color3.new(0.4,1,0.4))
                end
            end
        end
    end

    espButton.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
        if espEnabled then fbOn(); doESP() else fbOff(); clearESP() end
    end)

    task.spawn(function()
        while task.wait(1) do
            if espEnabled then fbOn(); clearESP(); doESP() end
        end
    end)
end

local toggleFlag = getBoolFlag("AutoBlockToggle")
local strictFlag = getBoolFlag("AutoBlockStrictRange")
local rangeFlag = getNumberFlag("AutoBlockRange")

toggleOn = toggleFlag.Value
strictRangeOn = strictFlag.Value
detectionRange = rangeFlag.Value

local function applyGuiTexts()
    if toggleButton then toggleButton.Text = toggleOn and "Auto Block: ON" or "Auto Block: OFF" end
    if strictButton then strictButton.Text = strictRangeOn and "Strict Range: ON" or "Strict Range: OFF" end
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createToggleGui()
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
    rangeBox.Text = tostring(detectionRange)
    rangeBox.FocusLost:Connect(function()
        local n = tonumber(rangeBox.Text)
        if n then detectionRange = math.clamp(n,1,1000); rangeFlag.Value=detectionRange end
        rangeBox.Text = tostring(detectionRange)
    end)
    applyGuiTexts()
end)

if localPlayer.Character then
    createToggleGui()
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
    rangeBox.Text = tostring(detectionRange)
    rangeBox.FocusLost:Connect(function()
        local n = tonumber(rangeBox.Text)
        if n then detectionRange = math.clamp(n,1,1000); rangeFlag.Value=detectionRange end
        rangeBox.Text = tostring(detectionRange)
    end)
    applyGuiTexts()
end

local checked = {}

local function detectAttack(char)
    if checked[char] then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _,t in ipairs(hum:GetPlayingAnimationTracks()) do
            local id = t.Animation and t.Animation.AnimationId and string.match(t.Animation.AnimationId,"%d+")
            if id and attackIds[id] then
                checked[char]={t}
                task.spawn(function() pcall(function() t.Stopped:Wait() end) checked[char]=nil end)
                return true
            end
        end
    end
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("Sound") and d.IsPlaying then
            local id = string.match(d.SoundId or "","%d+")
            if id and attackIds[id] then
                checked[char]=true
                task.delay(.5,function() checked[char]=nil end)
                return true
            end
        end
    end
    return false
end

RunService.Heartbeat:Connect(function()
    if not toggleOn then return end
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health>0 then
                local dist = (r.Position - myRoot.Position).Magnitude
                if dist <= detectionRange then
                    if strictRangeOn and not isFacing(myRoot, r) then continue end
                    if detectAttack(plr.Character) then clickBlockButton() end
                end
            end
        end
    end
end)
