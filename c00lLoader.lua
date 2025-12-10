--// Drag Toggle Loader //--
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "c00lToggleLoader"
gui.ResetOnSpawn = false

-- Track load states
local stabLoaded = false
local blockLoaded = false

-- References to loaded scripts
local loadedStabScript = nil
local loadedBlockScript = nil

--// Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 120)
frame.Position = UDim2.new(0.5, -90, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

--// Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "c00l Toggle Loader"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true

--// Dragging
local dragging = false
local dragStart, startPos
local UIS = game:GetService("UserInputService")

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// Button Creator
local function MakeButton(text, order)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 30 + (order * 40))
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- Buttons
local stabBtn = MakeButton("Backstab: OFF", 0)
local blockBtn = MakeButton("Block: OFF", 1)

---------------------------------------
--   Toggle Logic
---------------------------------------

stabBtn.MouseButton1Click:Connect(function()
    if not stabLoaded then
        loadedStabScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxIPro5965/c00lgui/main/c00lStab.lua"))()
        stabLoaded = true
        stabBtn.Text = "Backstab: ON"
        stabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    else
        -- remove old script if possible
        if typeof(loadedStabScript) == "Instance" and loadedStabScript.Destroy then
            loadedStabScript:Destroy()
        end
        stabLoaded = false
        stabBtn.Text = "Backstab: OFF"
        stabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

blockBtn.MouseButton1Click:Connect(function()
    if not blockLoaded then
        loadedBlockScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxIPro5965/c00lgui/main/c00lBlock.lua"))()
        blockLoaded = true
        blockBtn.Text = "Block: ON"
        blockBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    else
        if typeof(loadedBlockScript) == "Instance" and loadedBlockScript.Destroy then
            loadedBlockScript:Destroy()
        end
        blockLoaded = false
        blockBtn.Text = "Block: OFF"
        blockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)
