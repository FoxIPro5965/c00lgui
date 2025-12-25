do
    local JasonEnabled = false
    local OriginalParts = {}

    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    local Jason = game:GetService("ReplicatedStorage").Assets.Killers.Jason
    local Slasher = game:GetService("ReplicatedStorage").Assets.Killers.Slasher

    local function ApplyJason()
        require(Slasher.Behavior).Abilities.Slash.Icon = require(Jason.Behavior).Abilities.Slash.Icon
        require(Slasher.Behavior).Abilities.Behead.Icon = require(Jason.Behavior).Abilities.Behead.Icon
        require(Slasher.Behavior).Abilities.GashingWound.Icon = require(Jason.Behavior).Abilities.GashingWound.Icon
        require(Slasher.Behavior).Abilities.RagingPace.Icon = require(Jason.Behavior).Abilities.RagingPace.Icon
        local SoundsSlasher = require(Slasher.Config).Sounds
        SoundsSlasher.TerrorRadiusThemes = require(Jason.Config).Sounds.TerrorRadiusThemes
        require(Slasher.Config).DisplayName = "Jason"
        require(Slasher.Config).RenderImage = require(Jason.Config).RenderImage
    end

    local function AddJasonMask(char)
        local head = char:FindFirstChild("Head")
        if not head then return end
        if head:FindFirstChild("JasonMask") then return end

        local mask = Instance.new("Part")
        mask.Name = "JasonMask"
        mask.Size = Vector3.new(1,1,1)
        mask.CanCollide = false
        mask.Massless = true
        mask.Transparency = 0
        mask.Parent = head

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://17176629012"
        mesh.TextureId = "rbxassetid://17176629042"
        mesh.Scale = Vector3.new(1.05,1.05,1.05)
        mesh.Parent = mask

        local motor = Instance.new("Motor6D")
        motor.Part0 = head
        motor.Part1 = mask
        motor.C0 = CFrame.new(0, 0.05, -0.6)
        motor.Parent = head

        return mask
    end

    local function OnCharacter(char)
        if char.Name ~= "Slasher" or char.Parent ~= workspace.Players.Killers or char:GetAttribute("SkinName") ~= "" then return end

        OriginalParts[char] = {
            Shirt = char:FindFirstChildOfClass("Shirt"),
            Pants = char:FindFirstChildOfClass("Pants"),
            OldMask = char:FindFirstChild("Mask"),
            ChainsawNote = char:FindFirstChild("Chainsaw") and char.Chainsaw:FindFirstChild("Note"),
            SlasherExport = char:FindFirstChild("Slasher Export"),
            LimbsTransparency = {}
        }

        local orig = OriginalParts[char]
        for _, limb in pairs({"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}) do
            local part = char:FindFirstChild(limb)
            if part then orig.LimbsTransparency[limb] = part.Transparency end
        end

        if JasonEnabled then
            if orig.SlasherExport then orig.SlasherExport:Destroy() end
            if orig.ChainsawNote then orig.ChainsawNote:Destroy() end
            if orig.OldMask then orig.OldMask:Destroy() end

            for _, limb in pairs({"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}) do
                local part = char:FindFirstChild(limb)
                if part then part.Transparency = 0 end
            end

            local shirt = Instance.new("Shirt", char)
            shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=1502643168"
            local pants = Instance.new("Pants", char)
            pants.PantsTemplate = "http://www.roblox.com/asset/?id=1502651303"

            AddJasonMask(char)
        end
    end

    local function RevertJason(char)
        local orig = OriginalParts[char]
        if not orig then return end

        if char:FindFirstChildOfClass("Shirt") and char:FindFirstChildOfClass("Shirt") ~= orig.Shirt then
            char:FindFirstChildOfClass("Shirt"):Destroy()
        end
        if char:FindFirstChildOfClass("Pants") and char:FindFirstChildOfClass("Pants") ~= orig.Pants then
            char:FindFirstChildOfClass("Pants"):Destroy()
        end

        local mask = char:FindFirstChild("Head") and char.Head:FindFirstChild("JasonMask")
        if mask then mask:Destroy() end

        for limb, trans in pairs(orig.LimbsTransparency) do
            local part = char:FindFirstChild(limb)
            if part then part.Transparency = trans end
        end

        OriginalParts[char] = nil
    end

    lp.CharacterAdded:Connect(function(char)
        if JasonEnabled then ApplyJason() end
        task.wait(1)
        OnCharacter(char)
    end)

    if lp.Character then
        task.wait(1)
        OnCharacter(lp.Character)
    end

    local SkinGroup = RoleTab:AddLeftGroupbox("Skin")

    SkinGroup:AddToggle("JasonSkin", {
        Text = "Jason",
        Default = false,
        Callback = function(v)
            JasonEnabled = v
            if v then
                ApplyJason()
                Library:Notify("Jason skin enabled!", 4)
                if lp.Character then OnCharacter(lp.Character) end
            else
                Library:Notify("Jason skin disabled - reverted to default Slasher", 4)
                if lp.Character then RevertJason(lp.Character) end
            end
        end
    })
end
