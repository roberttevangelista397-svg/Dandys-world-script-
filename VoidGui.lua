-- ==============================================================================
-- 🎈⭐🎪 Looey's Circus Gui — WindUI Edition 🎪⭐🎈
-- ==============================================================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Void Star Gui",
    Icon = "star",
    Theme = "Dark",
    Folder = "LooeyCircus",
})

-- ==============================================================================
-- SERVIÇOS
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character, HumanoidRootPart, Humanoid

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
    Humanoid = char:WaitForChild("Humanoid", 5)
end)

if LocalPlayer.Character then
    Character = LocalPlayer.Character
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

-- ==============================================================================
-- TELEPORT
-- ==============================================================================
local function teleportTo(name, isExact)
    if not Character or not HumanoidRootPart then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        local match = isExact and (obj.Name == name) or obj.Name:lower():find(name:lower())
        if match then
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or (obj:IsA("BasePart") and obj)
            if part then
                HumanoidRootPart.CFrame = (part:IsA("Model") and part:GetPivot() or part.CFrame) + Vector3.new(0, 3, 0)
                return true
            end
        end
    end
    return false
end

-- ==============================================================================
-- NOCLIP
-- ==============================================================================
local NoclipConnection = nil
local function toggleNoclip(state)
    if state then
        local function applyNoclip()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        applyNoclip()
        if not NoclipConnection then
            NoclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    else
        if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- ==============================================================================
-- MAIN TAB
-- ==============================================================================
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })

local speedValue, tpWalkEnabled, tpWalkSpeed = 16, false, 1
local floatEnabled = false
local floatHeight = 3.5
local lockedFloatY = nil
local floatConnection = nil

-- Sliders com sintaxe CORRETA do WindUI ✅
MainTab:Slider({
    Title = "Speed",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(v) speedValue = v end,
})

MainTab:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(v) toggleNoclip(v) end,
})

MainTab:Toggle({
    Title = "Enable Tpwalk",
    Value = false,
    Callback = function(v) tpWalkEnabled = v end,
})

MainTab:Slider({
    Title = "Tpwalk Speed",
    Step = 0.1,
    Value = { Min = 0.1, Max = 5, Default = 1 },
    Callback = function(v) tpWalkSpeed = v end,
})

MainTab:Toggle({
    Title = "Float",
    Value = false,
    Callback = function(v)
        floatEnabled = v
        if floatEnabled then
            if HumanoidRootPart then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {Character}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local rayResult = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -1000, 0), rayParams)
                if rayResult then
                    lockedFloatY = rayResult.Position.Y + floatHeight
                else
                    lockedFloatY = HumanoidRootPart.Position.Y
                end
            end
            floatConnection = RunService.RenderStepped:Connect(function()
                if Character and HumanoidRootPart and lockedFloatY then
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position.X, lockedFloatY, HumanoidRootPart.Position.Z) * (HumanoidRootPart.CFrame - HumanoidRootPart.Position)
                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(HumanoidRootPart.AssemblyLinearVelocity.X, 0, HumanoidRootPart.AssemblyLinearVelocity.Z)
                end
            end)
        else
            if floatConnection then floatConnection:Disconnect() floatConnection = nil end
            lockedFloatY = nil
        end
    end,
})

MainTab:Slider({
    Title = "Float Studs",
    Step = 0.5,
    Value = { Min = 1, Max = 20, Default = 3.5 },
    Callback = function(v)
        floatHeight = v
        if floatEnabled and HumanoidRootPart then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {Character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local rayResult = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -1000, 0), rayParams)
            if rayResult then
                lockedFloatY = rayResult.Position.Y + floatHeight
            end
        end
    end,
})

MainTab:Button({
    Title = "Fly",
    Callback = function() pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-The-best-fly-gui-246203"))() end) end,
})

MainTab:Button({
    Title = "Destroy UI",
    Callback = function() toggleNoclip(false) WindUI:Destroy() end,
})

RunService.RenderStepped:Connect(function(delta)
    if Humanoid and Humanoid.Parent and speedValue > 16 then pcall(function() Humanoid.WalkSpeed = speedValue end) end
    if tpWalkEnabled and Character and HumanoidRootPart and Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
        pcall(function() HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (Humanoid.MoveDirection * tpWalkSpeed * delta * 60) end)
    end
end)

-- ==============================================================================
-- AUTOMATION TAB
-- ==============================================================================
local AutomationTab = Window:Tab({ Title = "Automation", Icon = "cpu" })

local autoGetToElevatorEnabled = false
AutomationTab:Toggle({
    Title = "Auto Get To Elevator",
    Value = false,
    Callback = function(v) autoGetToElevatorEnabled = v end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if autoGetToElevatorEnabled then
            pcall(function()
                local infoFolder = Workspace:FindFirstChild("Info")
                local panicValue = infoFolder and infoFolder:FindFirstChild("Panic")
                local elevatorsFolder = Workspace:FindFirstChild("Elevators")
                if panicValue and panicValue.Value == true and elevatorsFolder and HumanoidRootPart then
                    local elevator = elevatorsFolder:FindFirstChild("Elevator") or elevatorsFolder:FindFirstChildOfClass("Model")
                    if elevator then
                        local targetPart = elevator.PrimaryPart or elevator:FindFirstChild("Hitbox") or elevator:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
            end)
        end
    end
end)

local autoCollectActive = false
AutomationTab:Toggle({
    Title = "Auto Collect Research Capsules",
    Value = false,
    Callback = function(v)
        autoCollectActive = v
        if autoCollectActive then
            task.spawn(function()
                if not Character or not HumanoidRootPart then return end
                while autoCollectActive do
                    local capsules = {}
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "ResearchCapsule" then
                            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if targetPart and prompt then table.insert(capsules, {Part = targetPart, Prompt = prompt}) end
                        end
                    end
                    if #capsules > 0 then
                        local originalPosition = HumanoidRootPart.CFrame
                        local collectedAny = false
                        for _, cap in ipairs(capsules) do
                            if not autoCollectActive then break end
                            collectedAny = true
                            HumanoidRootPart.CFrame = cap.Part.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.3)
                            pcall(function() fireproximityprompt(cap.Prompt) end)
                            task.wait(0.4)
                        end
                        if collectedAny and HumanoidRootPart then HumanoidRootPart.CFrame = originalPosition end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

local autoCollectEventActive = false
AutomationTab:Toggle({
    Title = "Auto Collect Event Currency",
    Value = false,
    Callback = function(v)
        autoCollectEventActive = v
        if autoCollectEventActive then
            task.spawn(function()
                if not Character or not HumanoidRootPart then return end
                while autoCollectEventActive do
                    local eventItems = {}
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Pumpkin" then
                            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if targetPart and prompt then table.insert(eventItems, {Part = targetPart, Prompt = prompt}) end
                        end
                    end
                    if #eventItems > 0 then
                        local originalPosition = HumanoidRootPart.CFrame
                        local collectedAny = false
                        for _, item in ipairs(eventItems) do
                            if not autoCollectEventActive then break end
                            collectedAny = true
                            HumanoidRootPart.CFrame = item.Part.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.3)
                            pcall(function() fireproximityprompt(item.Prompt) end)
                            task.wait(0.4)
                        end
                        if collectedAny and HumanoidRootPart then HumanoidRootPart.CFrame = originalPosition end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

AutomationTab:Button({
    Title = "Autofarm",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/seannstar/voidextractor/refs/heads/main/VoidExtractor.lua"))() end)
    end,
})

AutomationTab:Button({
    Title = "Alternative Autofarm",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/BluuGuy-Sure/BluuHead-Dandy-s-World/refs/heads/main/JustThisOnce.lua"))() end)
    end,
})

local autoUseItemsEnabled = false
AutomationTab:Toggle({
    Title = "Auto Use Items",
    Value = false,
    Callback = function(v) autoUseItemsEnabled = v end,
})

task.spawn(function()
    while true do
        if autoUseItemsEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Inventory") then
                    local inv = char.Inventory
                    for i = 1, 3 do
                        local slot = inv:FindFirstChild("Slot" .. tostring(i))
                        if slot then
                            local args = {[1] = char, [2] = slot}
                            ReplicatedStorage.Events.ItemEvent:InvokeServer(unpack(args))
                        end
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

local autoAbilityEnabled = false
AutomationTab:Toggle({
    Title = "Auto Use Ability",
    Value = false,
    Callback = function(v) autoAbilityEnabled = v end,
})

task.spawn(function()
    while true do
        if autoAbilityEnabled then
            pcall(function()
                if Character and HumanoidRootPart then
                    local args = {[1] = Character, [2] = HumanoidRootPart.CFrame, [3] = false}
                    ReplicatedStorage.Events.AbilityEvent:InvokeServer(unpack(args))
                end
            end)
        end
        task.wait(1.5)
    end
end)

local autoSquirmEnabled = false
AutomationTab:Toggle({
    Title = "Auto Escape Squirm",
    Value = false,
    Callback = function(v) autoSquirmEnabled = v end,
})

task.spawn(function()
    pcall(function()
        local remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("TwistedSquirmGrab")
        local running = false
        local dir = "left"
        remote.OnClientEvent:Connect(function(action)
            if autoSquirmEnabled then
                if action == "GrabStart" then running = true
                elseif action == "GrabEnd" then running = false end
            else running = false end
        end)
        while true do
            task.wait(0.1)
            if autoSquirmEnabled and running then
                if dir == "left" then
                    remote:FireServer("Struggle", "left")
                    dir = "right"
                else
                    remote:FireServer("Struggle", "right")
                    dir = "left"
                end
            end
        end
    end)
end)

-- ==============================================================================
-- ESP TAB
-- ==============================================================================
local EspTab = Window:Tab({ Title = "ESP", Icon = "eye" })

EspTab:Section({ Title = "Twisteds ESP" })

local twistedEspEnabled = false
local twistedDisableNametags = false
local activeTwistedMonsters = {}
local twistedConnection = nil

EspTab:Toggle({
    Title = "Twisted ESP",
    Value = false,
    Callback = function(v)
        twistedEspEnabled = v
        local ColorChangingList = {
            ["GourdyMonster"] = true, ["BassieMonster"] = true, ["BobetteMonster"] = true,
            ["VeeMonster"] = true, ["DyleMonster"] = true, ["DandyMonster"] = true,
            ["AstroMonster"] = true, ["PebbleMonster"] = true, ["ShellyMonster"] = true,
            ["SproutMonster"] = true
        }
        local Colors = {
            Color3.fromRGB(148, 0, 211), Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(255, 165, 0), Color3.fromRGB(0, 0, 255)
        }
        local CommonList = {
            ["BoxtenMonster"] = true, ["PoppyMonster"] = true, ["BrushaMonster"] = true,
            ["ShrimpoMonster"] = true, ["RudieMonster"] = true, ["EggsonMonster"] = true,
            ["RibeccaMonster"] = true, ["YattaMonster"] = true, ["TishaMonster"] = true,
            ["LooeyMonster"] = true, ["CosmoMonster"] = true
        }
        local UncommonList = {
            ["FinnMonster"] = true, ["TeaganMonster"] = true, ["RodgerMonster"] = true,
            ["RazzleDazzleMonster"] = true, ["SoulvesterMonster"] = true,
            ["GingerMonster"] = true, ["FlyteMonster"] = true, ["ConnieMonster"] = true,
            ["BrightneyMonster"] = true, ["ToodlesMonster"] = true
        }
        local RareList = {
            ["GigiMonster"] = true, ["ScrapsMonster"] = true, ["GoobMonster"] = true,
            ["WaxwellMonster"] = true, ["GlistenMonster"] = true, ["FlutterMonster"] = true,
            ["EclipseMonster"] = true, ["CocoaMonster"] = true, ["CoalMonster"] = true,
            ["SquirmMonster"] = true, ["BlottMonster"] = true
        }
        local BlotHandsList = {["BlotHand"] = true, ["BlotHand_L"] = true, ["BlotHand_R"] = true}
        local LethalList = {["DandyMonster"] = true, ["DyleMonster"] = true}
        local AllMonsters = {}
        for k in pairs(CommonList) do AllMonsters[k] = true end
        for k in pairs(UncommonList) do AllMonsters[k] = true end
        for k in pairs(RareList) do AllMonsters[k] = true end
        for k in pairs(BlotHandsList) do AllMonsters[k] = true end
        for k in pairs(ColorChangingList) do AllMonsters[k] = true end
        for k in pairs(LethalList) do AllMonsters[k] = true end

        local function setupMonster(model)
            if not model or not model:IsA("Model") or model:FindFirstChild("ESP_Container") then return end
            local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
            if not head then return end
            local container = Instance.new("Folder")
            container.Name = "ESP_Container"
            container.Parent = model
            local highlight = Instance.new("Highlight")
            highlight.Adornee = model
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = container
            local billboard = Instance.new("BillboardGui", head)
            billboard.Name = "Nametag"
            billboard.Size = UDim2.new(0, 180, 0, 35)
            billboard.StudsOffset = Vector3.new(0, 4.2, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = not twistedDisableNametags
            local textLabel = Instance.new("TextLabel", billboard)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.FredokaOne
            textLabel.TextSize = 12
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            local rarityText = ""
            local baseTextColor = Color3.fromRGB(255, 0, 0)
            if CommonList[model.Name] then
                rarityText = " | Common"
                baseTextColor = Color3.fromRGB(180, 180, 180)
            elseif UncommonList[model.Name] then
                rarityText = " | Uncommon"
                baseTextColor = Color3.fromRGB(50, 255, 50)
            elseif RareList[model.Name] then
                rarityText = " | Rare"
                baseTextColor = Color3.fromRGB(100, 200, 255)
            end
            if LethalList[model.Name] then rarityText = " | Lethal" end
            table.insert(activeTwistedMonsters, billboard)
            task.spawn(function()
                local alpha = 0
                local colorIndex = 1
                while twistedEspEnabled and model and highlight and highlight.Parent and head do
                    local dt = task.wait(0.1)
                    alpha = alpha + (dt / 1.0)
                    if alpha >= 1 then alpha = 0 colorIndex = colorIndex % #Colors + 1 end
                    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local displayName = model.Name:gsub("Monster", "")
                        textLabel.Text = displayName .. rarityText
                        local c1 = Colors[colorIndex]
                        local c2 = Colors[colorIndex % #Colors + 1]
                        local targetColor = c1:Lerp(c2, alpha)
                        highlight.FillColor = targetColor
                        textLabel.TextColor3 = targetColor
                    end
                end
            end)
        end
        if twistedEspEnabled then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and AllMonsters[obj.Name] then task.wait(0.1) setupMonster(obj) end
            end
            if twistedConnection then twistedConnection:Disconnect() end
            twistedConnection = Workspace.DescendantAdded:Connect(function(obj)
                if twistedEspEnabled and obj:IsA("Model") and AllMonsters[obj.Name] then task.wait(0.1) setupMonster(obj) end
            end)
        else
            if twistedConnection then twistedConnection:Disconnect() twistedConnection = nil end
            for _, container in ipairs(activeTwistedMonsters) do if container and container.Parent then container:Destroy() end end
            activeTwistedMonsters = {}
            for _, obj in pairs(Workspace:GetDescendants()) do if obj.Name == "ESP_Container" then obj:Destroy() end end
        end
    end,
})

EspTab:Toggle({
    Title = "Disable Twisted ESP Nametags",
    Value = false,
    Callback = function(v)
        twistedDisableNametags = v
        for _, tag in ipairs(activeTwistedMonsters) do if tag and tag.Parent then tag.Enabled = not twistedDisableNametags end end
    end,
})

-- ==============================================================================
-- TELEPORT TAB
-- ==============================================================================
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "navigation" })

TeleportTab:Button({
    Title = "Teleport To Elevator",
    Callback = function() teleportTo("elevator", false) end,
})

TeleportTab:Button({
    Title = "Teleport To Machine",
    Callback = function()
        if not Character or not HumanoidRootPart then return end
        local generators = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local nameLower = obj.Name:lower()
            if nameLower == "generator" or nameLower:find("generator") or nameLower:find("machine") then
                local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or (obj:IsA("BasePart") and obj)
                if part then table.insert(generators, part) end
            end
        end
        if #generators > 0 then
            local randomGen = generators[math.random(1, #generators)]
            HumanoidRootPart.CFrame = randomGen.CFrame + Vector3.new(0, 3, 0)
        end
    end,
})

TeleportTab:Section({ Title = "Items Teleport" })

local itemsList = {"AirHorn", "SmokeBomb", "ResearchCapsule", "ProteinBar", "Jawbreaker", "EjectButton", "HealthKit", "Bandage", "Tape", "Pumpkin"}
local selectedItem = itemsList[1]

TeleportTab:Dropdown({
    Title = "Select Item",
    Values = itemsList,
    Value = 1,
    Callback = function(opt) selectedItem = opt end,
})

TeleportTab:Button({
    Title = "Teleport to Selected Item",
    Callback = function() teleportTo(selectedItem, true) end,
})

-- ==============================================================================
-- PLAYER TAB
-- ==============================================================================
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })

PlayerTab:Button({
    Title = "Anti Lag",
    Callback = function()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled = false end
            end
            local function optimizeObject(object)
                if object:IsA("ParticleEmitter") or object:IsA("Trail") then object.Enabled = false
                elseif object:IsA("Light") then object.Enabled = false
                elseif object:IsA("BasePart") then object.Material = Enum.Material.SmoothPlastic object.CastShadow = false end
            end
            for _, descendant in pairs(Workspace:GetDescendants()) do optimizeObject(descendant) end
            Workspace.DescendantAdded:Connect(function(descendant) task.wait() optimizeObject(descendant) end)
        end)
    end,
})

local noSlipperyEnabled = false
local brakeConnection = nil

PlayerTab:Toggle({
    Title = "No Slippery",
    Value = false,
    Callback = function(v)
        noSlipperyEnabled = v
        if noSlipperyEnabled then
            local physicalProperties = PhysicalProperties.new(15.0, 3.0, 0.0, 1.0, 1.0)
            if not brakeConnection then
                brakeConnection = RunService.RenderStepped:Connect(function(dt)
                    if not noSlipperyEnabled then return end
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
                        local root = char.HumanoidRootPart
                        local hum = char.Humanoid
                        if hum.Health > 0 and hum.MoveDirection.Magnitude == 0 then
                            local vel = root.AssemblyLinearVelocity
                            local hz = Vector3.new(vel.X, 0, vel.Z)
                            if hz.Magnitude > 0.5 then
                                local f = math.clamp(dt * 25, 0, 1)
                                root.AssemblyLinearVelocity = Vector3.new(vel.X * (1-f), vel.Y, vel.Z * (1-f))
                            end
                        end
                    end
                end)
            end
        else
            if brakeConnection then brakeConnection:Disconnect() brakeConnection = nil end
        end
    end,
})

-- ==============================================================================
-- MAP TAB
-- ==============================================================================
local MapTab = Window:Tab({ Title = "Map", Icon = "map" })

local fbConn = nil
MapTab:Toggle({
    Title = "Fullbright",
    Value = false,
    Callback = function(v)
        if v then
            local function setFB()
                Lighting.Brightness = 3
                Lighting.ClockTime = 14
                Lighting.FogEnd = 999999
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            end
            setFB()
            fbConn = RunService.RenderStepped:Connect(setFB)
        else
            if fbConn then fbConn:Disconnect() fbConn = nil end
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.FogEnd = 10000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end,
})

-- ==============================================================================
-- FUN TAB
-- ==============================================================================
local FunTab = Window:Tab({ Title = "Fun", Icon = "smile" })

local spinning = false
local spinSpeed = 25

FunTab:Toggle({
    Title = "Spin",
    Value = false,
    Callback = function(v)
        spinning = v
        if spinning then
            task.spawn(function()
                while spinning do
                    if HumanoidRootPart then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                    end
                    task.wait()
                end
            end)
        end
    end,
})

FunTab:Slider({
    Title = "Spin Speed",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = 25 },
    Callback = function(v) spinSpeed = v end,
})

local fovEnabled = false
local fovValue = 70

FunTab:Toggle({
    Title = "FOV Changer",
    Value = false,
    Callback = function(v)
        fovEnabled = v
        if fovEnabled then
            task.spawn(function()
                while fovEnabled and Camera do
                    Camera.FieldOfView = fovValue
                    task.wait()
                end
            end)
        else
            if Camera then Camera.FieldOfView = 70 end
        end
    end,
})

FunTab:Slider({
    Title = "FOV Value",
    Step = 1,
    Value = { Min = 10, Max = 120, Default = 70 },
    Callback = function(v)
        fovValue = v
        if fovEnabled and Camera then Camera.FieldOfView = fovValue end
    end,
})

FunTab:Button({
    Title = "Kill Yourself",
    Callback = function()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end)
    end,
})

WindUI:Notify({
    Title = "✅ Loaded!",
    Content = "Looey's Circus Gui — WindUI Edition",
    Duration = 3,
})
