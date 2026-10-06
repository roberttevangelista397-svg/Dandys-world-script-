-- =============================================
-- 🌱 Sprout's Femboy Cafe - Wind UI
-- =============================================

-- Carregar Wind UI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Serviços
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Dados originais
local baseBrightness = Lighting.Brightness
local baseClockTime = Lighting.ClockTime
local baseShadows = Lighting.GlobalShadows
local baseAmbient = Lighting.Ambient

local NoclipConnection = nil
local VisualsEnabled = false
local walkspeedEnabled = false
local currentWalkSpeed = 16
local speedConnection = nil
local spinSpeed = 0
local spinning = false
local spinConnection = nil
getgenv().scinstant = false

-- Lista de Monstros
local MonsterNames = {
	"YattaMonster","BoxtenMonster","ShellyMonster","DandyMonster","DyleMonster","PoppyMonster",
	"SquirmMonster","TishaMonster","ShrimpoMonster","ScrapsMonster","GoobMonster","VeeMonster",
	"SproutMonster","CosmoMonster","AstroMonster","PebbleMonster","BlotMonster","LooeyMonster",
	"ToodlesMonster","FlutterMonster","GlistenMonster","FinnMonster","ConnieMonster",
	"RazzleAndDazzleMonster","RodgerMonster","TeaganMonster","BrushaMonster","BrightneyMonster",
	"EggsonMonster","RudieMonster","RibeccaMonster","GigiMonster","GingerMonster","FlyteMonster",
	"SoulvesterMonster","CoalMonster","CocoaMonster","BassieMonster","BobetteMonster","GourdyMonster"
}
local MonsterSet = {}
for _,v in pairs(MonsterNames) do MonsterSet[v] = true end

-- Skillcheck Hook
local function SetupSkillcheck()
	local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("SkillcheckUpdate")
	if not event then return end
	
	local ogcb = getcallbackvalue(event, "OnClientInvoke")
	if ogcb then
		local hook
		hook = hookfunction(ogcb, function(...)
			if getgenv().scinstant then
				task.spawn(function()
					local sg = StarterGui:FindFirstChild("ScreenGui")
					if sg then
						pcall(function() sg.Correct:Play() end)
						pcall(function() sg.GoldAreaHit:Play() end)
					end
					local msg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
						and LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("Menu")
						and LocalPlayer.PlayerGui.ScreenGui.Menu:FindFirstChild("SkillCheckMessage")
					if msg then
						msg.UIGradient.Enabled = false
						msg.Text = "Great Job!"
						msg.UIGradientWin.Enabled = true
						msg.Visible = true
						task.wait(1.5)
						local tween = TweenService:Create(msg, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {TextTransparency = 1})
						tween:Play()
						tween.Completed:Wait()
						msg.Visible = false
						msg.TextTransparency = 0
					end
				end)
				return "supercomplete"
			end
			return hook(...)
		end)
	end
end
SetupSkillcheck()

-- ESP Funções
local function AddESP(model)
	if model:FindFirstChild("MonsterESP") then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "MonsterESP"
	highlight.FillColor = Color3.fromRGB(255,0,0)
	highlight.OutlineColor = Color3.fromRGB(255,255,255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = VisualsEnabled
	highlight.Parent = model
end

local function ScanMonsters()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and MonsterSet[v.Name] then AddESP(v) end
	end
end

workspace.DescendantAdded:Connect(function(v)
	if VisualsEnabled and v:IsA("Model") and MonsterSet[v.Name] then
		task.wait(0.2)
		AddESP(v)
	end
end)

-- Spin Funções
local function startSpin()
	if spinning then return end
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	spinning = true
	spinConnection = RunService.Heartbeat:Connect(function()
		if root and root.Parent then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
		end
	end)
end

local function stopSpin()
	if spinConnection then spinConnection:Disconnect() spinConnection = nil end
	spinning = false
end

-- =============================================
-- 🖥️ JANELA WIND UI
-- =============================================

local Window = WindUI:CreateWindow({
	Title = "🌱 Sprout's Cafe",
	Icon = "sprout",
	Theme = "Dark",
	Size = UDim2.new(0, 330, 0, 400),
	Author = "Sprout",
})

-- Abas
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local FunTab = Window:Tab({ Title = "Fun", Icon = "sparkles" })

-- ========== MAIN TAB ==========
MainTab:Toggle({
	Title = "🌙 Fullbright",
	Default = false,
	Callback = function(Value)
		if Value then
			Lighting.Brightness = 4
			Lighting.ClockTime = 14
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		else
			Lighting.Brightness = baseBrightness
			Lighting.ClockTime = baseClockTime
			Lighting.GlobalShadows = baseShadows
			Lighting.Ambient = baseAmbient
		end
	end,
})

MainTab:Toggle({
	Title = "🚧 Noclip",
	Default = false,
	Callback = function(Value)
		if Value then
			local function applyNoclip()
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				for _,p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
			applyNoclip()
			if not NoclipConnection then
				NoclipConnection = RunService.Stepped:Connect(function()
					local char = LocalPlayer.Character
					if char then
						for _,p in ipairs(char:GetDescendants()) do
							if p:IsA("BasePart") then p.CanCollide = false end
						end
					end
				end)
			end
		else
			if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
			local char = LocalPlayer.Character
			if char then
				for _,p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = true end
				end
			end
		end
	end,
})

MainTab:Button({
	Title = "🎙️ Streamer Mode",
	Callback = function()
		pcall(function()
			local nameTag = workspace:FindFirstChild("Players") 
				and workspace.Players:FindFirstChild(LocalPlayer.Name)
				and workspace.Players[LocalPlayer.Name]:FindFirstChild("HumanoidRootPart")
				and workspace.Players[LocalPlayer.Name].HumanoidRootPart:FindFirstChild("NameTag")
				and workspace.Players[LocalPlayer.Name].HumanoidRootPart.NameTag:FindFirstChild("Frame")
			if nameTag then
				nameTag.UserName.Text = "Sprout"
				nameTag.DisplayName.Text = "Sprout"
			end
		end)
		WindUI:Notify({ Title = "Streamer Mode", Content = "Nome alterado para Sprout!", Duration = 3 })
	end,
})

MainTab:Toggle({
	Title = "✅ Instant Skillcheck",
	Default = false,
	Callback = function(Value)
		getgenv().scinstant = Value
	end,
})

-- ========== VISUALS TAB ==========
VisualsTab:Toggle({
	Title = "👁️ Monster ESP",
	Default = false,
	Callback = function(Value)
		VisualsEnabled = Value
		ScanMonsters()
		for _,v in pairs(workspace:GetDescendants()) do
			if v:FindFirstChild("MonsterESP") then
				v.MonsterESP.Enabled = Value
			end
		end
	end,
})

-- ========== PLAYER TAB ==========
PlayerTab:Slider({
	Title = "🏃 WalkSpeed",
	Min = 16,
	Max = 250,
	Default = 16,
	Callback = function(Value)
		currentWalkSpeed = Value
		if walkspeedEnabled then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = Value
			end
		end
	end,
})

PlayerTab:Toggle({
	Title = "⚡ Enable Speed",
	Default = false,
	Callback = function(Value)
		walkspeedEnabled = Value
		if Value then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = currentWalkSpeed
			end
			if not speedConnection then
				speedConnection = RunService.Heartbeat:Connect(function()
					local char = LocalPlayer.Character
					if char and char:FindFirstChild("Humanoid") then
						char.Humanoid.WalkSpeed = currentWalkSpeed
					end
				end)
			end
		else
			if speedConnection then speedConnection:Disconnect() speedConnection = nil end
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = 16
			end
		end
	end,
})

-- ========== FUN TAB ==========
FunTab:Slider({
	Title = "🌀 Spin",
	Min = 0,
	Max = 200,
	Default = 0,
	Callback = function(Value)
		spinSpeed = Value
		if Value > 0 then startSpin() else stopSpin() end
	end,
})

print("✅ Wind UI Carregada!")
