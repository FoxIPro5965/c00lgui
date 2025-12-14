local hit = {}
if getgenv().emergency_stop == nil or not getgenv().emergency_stop then
getgenv().emergency_stop = false
end

function StudsIntoPower(studs)
return (studs * 1.2)
end

function hit:ExtendHitbox(studs, time)
local distance = StudsIntoPower(studs)
local start = tick()
local connection = nil
if getgenv().emergency_stop == true then
getgenv().emergency_stop = false
end
repeat game:GetService("RunService").Heartbeat:Wait()
local velocity = nil
while not (game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Parent and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Parent) do
game:GetService("RunService").Heartbeat:Wait()
end
velocity = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = velocity * distance + (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * distance)
game:GetService("RunService").RenderStepped:Wait()
if (game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Parent and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Parent) then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = velocity
end
until tick() - start > tonumber(time) or getgenv().emergency_stop == true
if getgenv().emergency_stop == true then
getgenv().emergency_stop = false
end
end

function hit:StopExtendingHitbox()
getgenv().emergency_stop = true
end

return hit
