--// c00lgui v0.4 + flowers mode just for fun//--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "c00lgui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 340) 
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
Title.Text = "c00lgui v0.4"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)

-- Hitbox Label & Input
local BoxLabel = Instance.new("TextLabel")
BoxLabel.Parent = MainFrame
BoxLabel.Position = UDim2.new(0,10,0,45)
BoxLabel.Size = UDim2.new(0,100,0,25)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Hack Hitbox :"
BoxLabel.Font = Enum.Font.Gotham
BoxLabel.TextSize = 14
BoxLabel.TextColor3 = Color3.fromRGB(255,220,220)

local Box = Instance.new("TextBox")
Box.Parent = MainFrame
Box.Size = UDim2.new(0,60,0,25)
Box.Position = UDim2.new(0,120,0,45)
Box.BackgroundColor3 = Color3.fromRGB(90,20,20)
Box.Text = "20"
Box.TextColor3 = Color3.fromRGB(255,255,255)
Box.Font = Enum.Font.Gotham
Box.TextSize = 14
Instance.new("UICorner",Box).CornerRadius = UDim.new(0,6)

local Toggle = Instance.new("TextButton")
Toggle.Parent = MainFrame
Toggle.Size = UDim2.new(0,220,0,35)
Toggle.Position = UDim2.new(0,20,0,85)
Toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Instance.new("UICorner",Toggle).CornerRadius = UDim.new(0,8)

-- Speed / Jump
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Position = UDim2.new(0,10,0,130)
SpeedLabel.Size = UDim2.new(0,100,0,25)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed:"
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextColor3 = Color3.fromRGB(255,240,240)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = MainFrame
SpeedBox.Size = UDim2.new(0,70,0,25)
SpeedBox.Position = UDim2.new(0,140,0,130)
SpeedBox.BackgroundColor3 = Color3.fromRGB(90,20,20)
SpeedBox.Text = "16"
SpeedBox.TextColor3 = Color3.fromRGB(255,255,255)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.TextSize = 14
Instance.new("UICorner",SpeedBox).CornerRadius = UDim.new(0,6)

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Parent = MainFrame
JumpLabel.Position = UDim2.new(0,10,0,165)
JumpLabel.Size = UDim2.new(0,100,0,25)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump:"
JumpLabel.Font = Enum.Font.Gotham
JumpLabel.TextSize = 14
JumpLabel.TextColor3 = Color3.fromRGB(255,240,240)

local JumpBox = Instance.new("TextBox")
JumpBox.Parent = MainFrame
JumpBox.Size = UDim2.new(0,70,0,25)
JumpBox.Position = UDim2.new(0,140,0,165)
JumpBox.BackgroundColor3 = Color3.fromRGB(90,20,20)
JumpBox.Text = "50"
JumpBox.TextColor3 = Color3.fromRGB(255,255,255)
JumpBox.Font = Enum.Font.Gotham
JumpBox.TextSize = 14
Instance.new("UICorner",JumpBox).CornerRadius = UDim.new(0,6)

local function applyStats()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local speed = tonumber(SpeedBox.Text)
        local jump = tonumber(JumpBox.Text)
        if speed then char.Humanoid.WalkSpeed = speed end
        if jump then char.Humanoid.JumpPower = jump end
    end
end
SpeedBox.FocusLost:Connect(applyStats)
JumpBox.FocusLost:Connect(applyStats)

--=====================
-- MODE BUTTON
--=====================
local ModeButton = Instance.new("TextButton")
ModeButton.Parent = MainFrame
ModeButton.Size = UDim2.new(0,220,0,35)
ModeButton.Position = UDim2.new(0,20,0,205)
ModeButton.BackgroundColor3 = Color3.fromRGB(100,0,0)
ModeButton.TextColor3 = Color3.fromRGB(255,255,255)
ModeButton.Font = Enum.Font.GothamBold
ModeButton.TextSize = 16
ModeButton.Text = "Mode: DEFAULT"
Instance.new("UICorner",ModeButton).CornerRadius = UDim.new(0,8)

--=====================
-- BETTER FLY / INF JUMP
--=====================

local flying = false
local infjump = false
local mode = 1

local BodyGyro = nil
local BodyVelocity = nil
local flyConnection = nil
local flySpeed = 70  -- Adjust this for faster/slower flight
local verticalSpeed = 70

-- Direction based on camera (HD Admin style)
local function getCameraDirection()
    local camera = workspace.CurrentCamera
    local move = Vector3.new(0,0,0)

    -- Get movement input (WASD or mobile joystick)
    if UIS.TouchEnabled then
        -- Mobile: use PlayerModule move vector (same as PC)
        local controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
        move = controls:GetMoveVector()
    else
        -- PC: keyboard
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Vector3.new(1,0,0) end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
    end

    if move.Magnitude > 0 then
        move = move.Unit
        -- Convert local movement to world direction based on camera
        local camLook = camera.CFrame.LookVector
        local camRight = camera.CFrame.RightVector
        local camUp = Vector3.new(0,1,0)

        -- Project movement onto horizontal plane (ignore Y)
        local horizontalDir = (camRight * move.X + camLook * move.Z).Unit

        return horizontalDir, move.Y -- return horizontal + up/down intent
    end

    return Vector3.new(0,0,0), 0
end

local function startFly()
    if flying then return end
    flying = true

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    hum.PlatformStand = true -- Prevents default movement

    -- BodyGyro for rotation
    if BodyGyro then BodyGyro:Destroy() end
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 15000
    BodyGyro.MaxTorque = Vector3.new(4000, 0, 4000) -- Only rotate on Y axis (optional)
    BodyGyro.CFrame = hrp.CFrame
    BodyGyro.Parent = hrp

    -- BodyVelocity for movement
    if BodyVelocity then BodyVelocity:Destroy() end
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BodyVelocity.Velocity = Vector3.new(0,0,0)
    BodyVelocity.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not hrp or not hrp.Parent then return end

        local cam = workspace.CurrentCamera
        local moveDir, verticalInput = getCameraDirection()

        -- Vertical movement (Space = up, Ctrl = down)
        local vertical = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical = vertical + 1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = vertical - 1 end

        -- Combine horizontal + vertical
        local finalVelocity = (moveDir * flySpeed) + (Vector3.new(0, vertical * verticalSpeed, 0))

        BodyVelocity.Velocity = finalVelocity

        -- Face the direction you're moving (smooth look)
        if moveDir.Magnitude > 0 then
            BodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + moveDir)
        end
    end)
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

-- Infinite Jump
local infJumpConn
local function enableInfJump()
    infjump = true
    if infJumpConn then infJumpConn:Disconnect() end
    infJumpConn = UIS.JumpRequest:Connect(function()
        if infjump and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function disableInfJump()
    infjump = false
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
end

-- Mode Switching (assuming you have a ModeButton in a ScreenGui)
ModeButton.MouseButton1Click:Connect(function()
    mode = (mode % 3) + 1

    if mode == 1 then
        ModeButton.Text = "Mode: DEFAULT"
        stopFly()
        disableInfJump()
    elseif mode == 2 then
        ModeButton.Text = "Mode: INF JUMP"
        stopFly()
        enableInfJump()
    elseif mode == 3 then
        ModeButton.Text = "Mode: FLY"
        disableInfJump()
        startFly()
    end
end)

-- Re-enable fly on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)
    if mode == 3 then
        startFly()
    end
end)

--=====================
-- HITBOX
--=====================
local Enabled=false
local Size = tonumber(Box.Text) or 20
local function ExpandHitbox(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.Size = Vector3.new(Size,Size,Size)
        hrp.Transparency = 0.7
        hrp.Material = Enum.Material.Neon
        hrp.BrickColor = BrickColor.new("Really red")
    end
end
local function ResetHitbox(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.Size = Vector3.new(2,2,1)
        hrp.Transparency=0
        hrp.Material = Enum.Material.Plastic
    end
end
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        Toggle.Text="ON"
        Toggle.BackgroundColor3=Color3.fromRGB(0,150,0)
    else
        Toggle.Text="OFF"
        Toggle.BackgroundColor3=Color3.fromRGB(150,0,0)
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then ResetHitbox(plr.Character) end
        end
    end
end)
Box.FocusLost:Connect(function()
    local val = tonumber(Box.Text)
    if val and val>0 then Size=val else Box.Text=tostring(Size) end
end)
RunService.RenderStepped:Connect(function()
    if Enabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then ExpandHitbox(plr.Character) end
        end
    end
end)

--=====================
-- FULLBRIGHT
--=====================
local FBButton = Instance.new("TextButton")
FBButton.Parent=MainFrame
FBButton.Size=UDim2.new(0,220,0,35)
FBButton.Position=UDim2.new(0,20,0,245)
FBButton.BackgroundColor3=Color3.fromRGB(120,100,0)
FBButton.Text="FullBright: OFF"
FBButton.TextColor3=Color3.fromRGB(255,255,255)
FBButton.Font=Enum.Font.GothamBold
FBButton.TextSize=16
Instance.new("UICorner",FBButton).CornerRadius=UDim.new(0,8)
local fbOn=false
local ob=Lighting.Brightness
local oa=Lighting.Ambient
local oo=Lighting.OutdoorAmbient
local oc=Lighting.ClockTime
local function applyDaySky()
    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    local sky=Instance.new("Sky",Lighting)
    sky.SkyboxBk="rbxassetid://7018684000"
    sky.SkyboxDn="rbxassetid://7018684000"
    sky.SkyboxFt="rbxassetid://7018684000"
    sky.SkyboxLf="rbxassetid://7018684000"
    sky.SkyboxRt="rbxassetid://7018684000"
    sky.SkyboxUp="rbxassetid://7018684000"
end
FBButton.MouseButton1Click:Connect(function()
    fbOn = not fbOn
    if fbOn then
        FBButton.Text="FullBright: ON"
        FBButton.BackgroundColor3=Color3.fromRGB(0,180,0)
        Lighting.Brightness=2
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        Lighting.ClockTime=12
        applyDaySky()
    else
        FBButton.Text="FullBright: OFF"
        FBButton.BackgroundColor3=Color3.fromRGB(120,100,0)
        Lighting.Brightness=ob
        Lighting.Ambient=oa
        Lighting.OutdoorAmbient=oo
        Lighting.ClockTime=oc
        for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
    end
end)

--=====================
-- BACKLOOK BUTTON
--=====================
local BackBtn = Instance.new("TextButton")
BackBtn.Parent = MainFrame
BackBtn.Size = UDim2.new(0,220,0,35)
BackBtn.Position = UDim2.new(0,20,0,280)
BackBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
BackBtn.Text = "BackLook: OFF"
BackBtn.TextColor3 = Color3.fromRGB(255,255,255)
BackBtn.Font = Enum.Font.GothamBold
BackBtn.TextSize = 16
Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0,8)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local backLookOn = false
local followConnection = nil

local function getNearestEnemy()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local closest = nil
    local closestDist = 12 -- check trong 10 studs, để 12 dư 1 chút chống lỗi

    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then

            -- KIỂM TRA TEAM
            if plr.Team ~= LocalPlayer.Team then
                local enemyHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if enemyHRP then
                    local dist = (enemyHRP.Position - hrp.Position).Magnitude

                    if dist < closestDist then
                        closest = enemyHRP
                        closestDist = dist
                    end
                end
            end
        end
    end

    return closest
end

local function startBackLook()
    backLookOn = true
    BackBtn.Text = "BackLook: ON"

    followConnection = RunService.Heartbeat:Connect(function()
        local enemyHRP = getNearestEnemy()
        if not enemyHRP then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Lấy hướng nhìn của enemy
        local forward = enemyHRP.CFrame.LookVector

        -- Tính vị trí sau lưng 3 studs
        local targetPos = enemyHRP.Position - forward * 3

        -- Dịch chuyển mượt (không snap)
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos, enemyHRP.Position), 0.25)
    end)
end

local function stopBackLook()
    backLookOn = false
    BackBtn.Text = "BackLook: OFF"

    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

BackBtn.MouseButton1Click:Connect(function()
    if backLookOn then
        stopBackLook()
    else
        startBackLook()
    end
end)
--=====================
-- HIDE / SHOW UI 
--=====================
local Circle = Instance.new("TextButton", ScreenGui)
Circle.Size = UDim2.new(0, 36, 0, 36)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
Circle.Text = "+"
Circle.Visible = false
Circle.Font = Enum.Font.GothamBold
Circle.TextSize = 24
Circle.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
Circle.Active = true
Circle.Draggable = true

local HideBtn = Instance.new("TextButton")
HideBtn.Parent = MainFrame
HideBtn.Size = UDim2.new(0,25,0,25)
HideBtn.Position = UDim2.new(1,-30,0,5)
HideBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
Instance.new("UICorner",HideBtn).CornerRadius = UDim.new(0,6)

local uiHidden = false

-- Ẩn menu khi nhấn HideBtn
HideBtn.MouseButton1Click:Connect(function()
    uiHidden = true
    MainFrame.Visible = false
    Circle.Visible = true
end)

-- Hiện menu khi nhấn Circle
Circle.MouseButton1Click:Connect(function()
    uiHidden = false
    MainFrame.Visible = true
    Circle.Visible = false
end)
