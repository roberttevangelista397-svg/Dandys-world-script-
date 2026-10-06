-- =============================================
-- 🌱 Sprout's Femboy Cafe - Void UI
-- =============================================

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
						sg:FindFirstChild("Correct"):Play()
						sg:FindFirstChild("GoldAreaHit"):Play()
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
-- 🖥️ INTERFACE VOID UI
-- =============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
if gethui then ScreenGui.Parent = gethui() end

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIShadow = Instance.new("UICorner")
UIShadow.CornerRadius = UDim.new(0, 10)
UIShadow.Parent = MainFrame

-- Barra Superior
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 35)
Topbar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 10)
TopbarCorner.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Text = "🌱 Void UI"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(220, 220, 240)
Title.TextSize = 14
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
CloseBtn.TextSize = 16
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = Topbar

-- Navegação de Abas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TabContainer.Parent = MainFrame

local TabList = {"Main", "Visuals", "Player", "Fun"}
local TabButtons = {}
local ActiveTab = "Main"

local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Name = "Content"
ContentContainer.Size = UDim2.new(1, 0, 1, -70)
ContentContainer.Position = UDim2.new(0, 0, 0, 70)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ScrollBarThickness = 3
ContentContainer.ScrollBarColor3 = Color3.fromRGB(70, 70, 90)
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 800)
ContentContainer.Parent = MainFrame

local function CreateTabButton(name, index)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextColor3 = Color3.fromRGB(160, 160, 180)
	btn.TextSize = 11
	btn.Size = UDim2.new(1/#TabList, -2, 0, 30)
	btn.Position = UDim2.new((index-1)/#TabList, 1, 0, 2)
	btn.BackgroundTransparency = 1
	btn.Parent = TabContainer
	
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0.6, 0, 0, 2)
	indicator.Position = UDim2.new(0.2, 0, 1, -2)
	indicator.BackgroundColor3 = Color3.fromRGB(110, 140, 255)
	indicator.Parent = btn
	
	btn.MouseButton1Click:Connect(function()
		ActiveTab = name
		for _,b in pairs(TabButtons) do
			b.TextColor3 = Color3.fromRGB(160, 160, 180)
			b.Indicator.BackgroundTransparency = 1
		end
		btn.TextColor3 = Color3.fromRGB(220, 220, 240)
		indicator.BackgroundTransparency = 0
		ContentContainer:ClearAllChildren()
		LoadTabContent(name)
	end)
	
	btn.Indicator = indicator
	TabButtons[name] = btn
	return btn
end

for i, name in pairs(TabList) do CreateTabButton(name, i) end
TabButtons["Main"].TextColor3 = Color3.fromRGB(220, 220, 240)
TabButtons["Main"].Indicator.BackgroundTransparency = 0

-- Elementos da UI
local function CreateToggle(parent, name, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 32)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Text = name
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.TextSize = 12
	label.Size = UDim2.new(1, -40, 1, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 36, 0, 20)
	toggle.Position = UDim2.new(1, -38, 0.5, -10)
	toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	toggle.Text = ""
	toggle.Parent = frame
	local tcorner = Instance.new("UICorner")
	tcorner.CornerRadius = UDim.new(1, 0)
	tcorner.Parent = toggle
	
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 16, 0, 16)
	dot.Position = UDim2.new(0, 2, 0.5, -8)
	dot.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
	dot.Parent = dot
	local dcorner = Instance.new("UICorner")
	dcorner.CornerRadius = UDim.new(1, 0)
	dot.Parent = toggle
	
	local enabled = false
	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		callback(enabled)
		TweenService:Create(dot, TweenInfo.new(0.15), {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
		TweenService:Create(toggle, TweenInfo.new(0.15), {BackgroundColor3 = enabled and Color3.fromRGB(90, 120, 220) or Color3.fromRGB(60, 60, 80)}):Play()
		dot.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
	end)
	
	return frame
end

local function CreateButton(parent, name, callback)
	local btn = Instance.new("TextButton")
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextColor3 = Color3.fromRGB(200, 200, 220)
	btn.TextSize = 12
	btn.Size = UDim2.new(1, -20, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	btn.AutoLocalize = false
	btn.Parent = parent
	local btncorner = Instance.new("UICorner")
	btncorner.CornerRadius = UDim.new(0, 6)
	btncorner.Parent = btn
	
	btn.MouseButton1Click:Connect(callback)
	
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(65, 65, 90) end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70) end)
	
	return btn
end

local function CreateSlider(parent, name, min, max, default, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 0, 50)
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Text = name .. ": " .. default
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.TextSize = 12
	label.Size = UDim2.new(1, 0, 0, 18)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	
	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, 0, 0, 6)
	barBg.Position = UDim2.new(0, 0, 0, 32)
	barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	barBg.Parent = container
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = barBg
	
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(90, 120, 220)
	barFill.Parent = barBg
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = barFill
	
	local value = default
	local function update(input)
		local percent = math.clamp((input.AbsolutePosition.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
		value = math.floor(min + percent * (max - min))
		label.Text = name .. ": " .. value
		barFill.Size = UDim2.new(percent, 0, 1, 0)
		callback(value)
	end
	
	barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local conn
			conn = game:GetService("UserInputService").InputChanged:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseMovement then
					update(i)
				end
			end)
			local upConn
			upConn = game:GetService("UserInputService").InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					conn:Disconnect()
					upConn:Disconnect()
				end
			end)
		end
	end)
	
	return container
end

local function AddSpacer(parent)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(1, 0, 0, 12)
	s.BackgroundTransparency = 1
	s.Parent = parent
	return s
end

-- Carregar Conteúdo das Abas
function LoadTabContent(tabName)
	local content = ContentContainer
	
	if tabName == "Main" then
		CreateToggle(content, "🌙 Fullbright", function(val)
			if val then
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
		end)
		AddSpacer(content)
		
		CreateToggle(content, "🚧 Noclip", function(val)
			if val then
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
		end)
		AddSpacer(content)
		
		CreateButton(content, "🎙️ Streamer Mode", function()
			local succ, err = pcall(function()
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
		end)
		AddSpacer(content)
		
		CreateToggle(content, "✅ Instant Skillcheck", function(val)
			getgenv().scinstant = val
		end)
		
	elseif tabName == "Visuals" then
		CreateToggle(content, "👁️ Monster ESP", function(val)
			VisualsEnabled = val
			ScanMonsters()
			for _,v in pairs(workspace:GetDescendants()) do
				if v:FindFirstChild("MonsterESP") then
					v.MonsterESP.Enabled = val
				end
			end
		end)
		
	elseif tabName == "Player" then
		CreateSlider(content, "🏃 WalkSpeed", 16, 250, 16, function(val)
			currentWalkSpeed = val
			if walkspeedEnabled then
				local char = LocalPlayer.Character
				if char and char:FindFirstChild("Humanoid") then
					char.Humanoid.WalkSpeed = val
				end
			end
		end)
		AddSpacer(content)
		
		CreateToggle(content, "⚡ Enable Speed", function(val)
			walkspeedEnabled = val
			if val then
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
		end)
		
	elseif tabName == "Fun" then
		CreateSlider(content, "🌀 Spin", 0, 200, 0, function(val)
			spinSpeed = val
			if val > 0 then startSpin() else stopSpin() end
		end)
	end
end

-- Clicar no X para esconder/mostrar
local UIHidden = false
CloseBtn.MouseButton1Click:Connect(function()
	UIHidden = not UIHidden
	MainFrame.Visible = not UIHidden
end)

-- Carregar aba inicial
LoadTabContent("Main")

-- Mover Janela
local dragging, dragStart, startPos
Topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("✅ Void UI Carregada!")
