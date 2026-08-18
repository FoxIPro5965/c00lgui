local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Kiểm tra vị trí lưu GUI an toàn
local parentGui
local success = pcall(function()
    parentGui = game:GetService("CoreGui")
end)
if not success or not parentGui then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Xóa GUI cũ nếu đã tồn tại để tránh trùng lặp
if parentGui:FindFirstChild("c00lgui") then
    parentGui.c00lgui:Destroy()
end

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "c00lgui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Frame Chính (Tăng chiều cao lên 460 để đủ chỗ chứa thêm UI Fly Speed)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 460)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "c00lgui v0.7 (Fly Speed Custom)"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Utility Function để tạo Button
local function createButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0, 220, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- Hitbox UI
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Parent = MainFrame
BoxLabel.Position = UDim2.new(0, 10, 0, 35)
BoxLabel.Size = UDim2.new(0, 100, 0, 25)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Hitbox Size:"
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 14
BoxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local Box = Instance.new("TextBox")
Box.Parent = MainFrame
Box.Size = UDim2.new(0, 60, 0, 25)
Box.Position = UDim2.new(0, 120, 0, 35)
Box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Box.Text = "20"
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.Font = Enum.Font.Gotham
Box.TextSize = 14
Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

local ToggleHitbox = createButton("Hitbox: OFF", UDim2.new(0, 20, 0, 65))

-- Speed & Jump UI
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Position = UDim2.new(0, 10, 0, 110)
SpeedLabel.Size = UDim2.new(0, 80, 0, 25)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed:"
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(0, 50, 0, 25)
SpeedBox.Position = UDim2.new(0, 75, 0, 110)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.Text = "16"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Parent = MainFrame
JumpLabel.Position = UDim2.new(0, 135, 0, 110)
JumpLabel.Size = UDim2.new(0, 50, 0, 25)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump:"
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.TextSize = 14
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local JumpBox = Instance.new("TextBox")
JumpBox.Parent = MainFrame
JumpBox.Size = UDim2.new(0, 50, 0, 25)
JumpBox.Position = UDim2.new(0, 190, 0, 110)
JumpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
JumpBox.Text = "50"
JumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBox.Font = Enum.Font.Gotham
JumpBox.TextSize = 14
Instance.new("UICorner", JumpBox).CornerRadius = UDim.new(0, 6)

-- Fly Speed UI (Mới thêm)
local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Parent = MainFrame
FlySpeedLabel.Position = UDim2.new(0, 10, 0, 145)
FlySpeedLabel.Size = UDim2.new(0, 100, 0, 25)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "Fly Speed:"
FlySpeedLabel.Font = Enum.Font.Gotham
FlySpeedLabel.TextSize = 14
FlySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Parent = MainFrame
FlySpeedBox.Size = UDim2.new(0, 60, 0, 25)
FlySpeedBox.Position = UDim2.new(0, 120, 0, 145)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlySpeedBox.Text = "80"
FlySpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedBox.Font = Enum.Font.Gotham
FlySpeedBox.TextSize = 14
Instance.new("UICorner", FlySpeedBox).CornerRadius = UDim.new(0, 6)

-- Feature Buttons
local ModeButton = createButton("Mode: DEFAULT", UDim2.new(0, 20, 0, 180))
local FBButton = createButton("FullBright: OFF", UDim2.new(0, 20, 0, 225))
local GodButton = createButton("Godmode: OFF", UDim2.new(0, 20, 0, 270))
local NoclipButton = createButton("Noclip: OFF", UDim2.new(0, 20, 0, 315))

---------------------------------------------------------
-- LOGIC & SYSTEMS
---------------------------------------------------------

local function updateButtonState(btn, state, onText, offText)
    btn.Text = state and onText or offText
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(150, 0, 0)
end

-- 1. SPEED & JUMP SYSTEM
local function applyStats()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local speed = tonumber(SpeedBox.Text)
            local jump = tonumber(JumpBox.Text)
            if speed then hum.WalkSpeed = speed end
            if jump then hum.JumpPower = jump end
        end
    end
end
SpeedBox.FocusLost:Connect(applyStats)
JumpBox.FocusLost:Connect(applyStats)

-- 2. MODES (FLY & INF JUMP)
local flying, infjump = false, false
local mode = 1
local bv, bg, flyConn, infConn
local customFlySpeed = 80

FlySpeedBox.FocusLost:Connect(function()
    local val = tonumber(FlySpeedBox.Text)
    if val and val > 0 then
        customFlySpeed = val
    else
        FlySpeedBox.Text = tostring(customFlySpeed)
    end
end)

local function enableInfJump()
    if infConn then infConn:Disconnect() end
    infConn = UIS.JumpRequest:Connect(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function disableInfJump()
    if infConn then infConn:Disconnect() infConn = nil end
end

local function startFly()
    if flying then return end
    flying = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    hum.PlatformStand = true
    
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 20000
    bg.CFrame = root.CFrame

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not root or not root.Parent then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += cam.CFrame.UpVector end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= cam.CFrame.UpVector end
        
        -- Áp dụng Tốc độ Fly lấy từ TextBox
        local currentSpeed = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and customFlySpeed * 2 or customFlySpeed
        
        if dir.Magnitude > 0 then
            dir = dir.Unit
            bv.Velocity = dir * currentSpeed
            bg.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
        else
            bv.Velocity = Vector3.zero
        end
    end)
end

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

ModeButton.MouseButton1Click:Connect(function()
    mode = (mode % 3) + 1
    stopFly()
    disableInfJump()
    if mode == 1 then
        ModeButton.Text = "Mode: DEFAULT"
    elseif mode == 2 then
        ModeButton.Text = "Mode: INF JUMP"
        enableInfJump()
    elseif mode == 3 then
        ModeButton.Text = "Mode: FLY"
        startFly()
    end
end)

-- 3. NOCLIP SYSTEM
local noclip = false
local noclipConn = nil

local function toggleNoclip(state)
    if state == nil then noclip = not noclip else noclip = state end
    updateButtonState(NoclipButton, noclip, "Noclip: ON", "Noclip: OFF")
    
    if noclipConn then 
        noclipConn:Disconnect() 
        noclipConn = nil 
    end
    
    if noclip then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

NoclipButton.MouseButton1Click:Connect(function()
    toggleNoclip()
end)

-- 4. HITBOX EXPANDER
local hitboxEnabled = false
local hitboxSize = 20
local hitboxConn = nil

local function updateHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if hitboxEnabled then
                hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.Material = Enum.Material.Plastic
            end
        end
    end
end

ToggleHitbox.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    updateButtonState(ToggleHitbox, hitboxEnabled, "Hitbox: ON", "Hitbox: OFF")
    
    if hitboxConn then hitboxConn:Disconnect() hitboxConn = nil end
    if hitboxEnabled then
        hitboxConn = RunService.RenderStepped:Connect(updateHitboxes)
    else
        updateHitboxes()
    end
end)

Box.FocusLost:Connect(function()
    local val = tonumber(Box.Text)
    if val and val > 0 then hitboxSize = val else Box.Text = tostring(hitboxSize) end
end)

-- 5. FULLBRIGHT SYSTEM
local fbOn = false
local origSettings = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime
}

FBButton.MouseButton1Click:Connect(function()
    fbOn = not fbOn
    updateButtonState(FBButton, fbOn, "FullBright: ON", "FullBright: OFF")
    if fbOn then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 12
    else
        Lighting.Brightness = origSettings.Brightness
        Lighting.Ambient = origSettings.Ambient
        Lighting.OutdoorAmbient = origSettings.OutdoorAmbient
        Lighting.ClockTime = origSettings.ClockTime
    end
end)

-- 6. GODMODE (Anti-Touch)
local god = false
local godConn = nil

GodButton.MouseButton1Click:Connect(function()
    god = not god
    updateButtonState(GodButton, god, "Godmode: ON", "Godmode: OFF")
    
    if godConn then godConn:Disconnect() godConn = nil end
    if god then
        godConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local parts = workspace:GetPartBoundsInRadius(hrp.Position, 10)
                for _, p in ipairs(parts) do
                    if p:IsA("BasePart") and not p:IsDescendantOf(char) then
                        p.CanTouch = false
                    end
                end
            end
        end)
    end
end)

-- AUTO RESET ON SPAWN
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyStats()
    if mode == 2 then enableInfJump() end
    if mode == 3 then startFly() end
    if noclip then toggleNoclip(true) end
end)

-- MINIMIZE / CIRCLE BUTTON
local Circle = Instance.new("TextButton", ScreenGui)
Circle.Size = UDim2.new(0, 36, 0, 36)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Circle.Text = "+"
Circle.Visible = false
Circle.Font = Enum.Font.GothamBold
Circle.TextSize = 24
Circle.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
Circle.Active = true
Circle.Draggable = true

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 25, 0, 25)
HideBtn.Position = UDim2.new(1, -30, 0, 5)
HideBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Circle.Visible = true
end)

Circle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    Circle.Visible = false
end)
