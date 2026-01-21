local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Window = Rayfield:CreateWindow({
   Name = "Core-X | 100 Waves Later", 
   LoadingTitle = "Core-X System Loading...", 
   LoadingSubtitle = "Developed by _M3lm_",
   ConfigurationSaving = { 
      Enabled = true,
      FolderName = "CoreXConfig", 
      FileName = "AutoSave",
      AutoLoad = true 
   },
   KeySystem = false, 
})

-- [[ إعدادات الواجهة الرسومية للإشعارات ]] --
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "DeathNotifyGui"
if gethui then NotifyGui.Parent = gethui() else NotifyGui.Parent = game.CoreGui end

local function CreateDeathNotify(PlayerName)
    local Frame = Instance.new("Frame")
    Frame.Name = "NotifyFrame"
    Frame.Parent = NotifyGui
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(1, 20, 0.8, 0)
    Frame.Size = UDim2.new(0, 250, 0, 60)
    
    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 6)
    
    local UIStroke = Instance.new("UIStroke", Frame)
    UIStroke.Color = Color3.fromRGB(60, 60, 60)
    UIStroke.Thickness = 1

    local Icon = Instance.new("ImageLabel", Frame)
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 10, 0.5, -15)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://6022668888"
    Icon.ImageColor3 = Color3.fromRGB(255, 50, 50)

    local Title = Instance.new("TextLabel", Frame)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 50, 0, 10)
    Title.Size = UDim2.new(1, -60, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = PlayerName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Status = Instance.new("TextLabel", Frame)
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 50, 0, 30)
    Status.Size = UDim2.new(1, -60, 0, 15)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Has Died"
    Status.TextColor3 = Color3.fromRGB(150, 150, 150)
    Status.TextSize = 12
    Status.TextXAlignment = Enum.TextXAlignment.Left

    local BarBg = Instance.new("Frame", Frame)
    BarBg.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    BarBg.BorderSizePixel = 0
    BarBg.Position = UDim2.new(0, 0, 1, -4)
    BarBg.Size = UDim2.new(1, 0, 0, 4)

    local Bar = Instance.new("Frame", BarBg)
    Bar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Bar.BorderSizePixel = 0
    Bar.Size = UDim2.new(1, 0, 1, 0)

    local OpenTween = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 0.8, 0)})
    OpenTween:Play()

    local BarTween = TweenService:Create(Bar, TweenInfo.new(3, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
    BarTween:Play()

    task.delay(3, function()
        local FadeTween = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        FadeTween:Play()
        task.wait(0.5)
        Frame:Destroy()
    end)
end

-- [[ وظائف المساعدة ]] --
local function ClearESP(Tag)
    for _, obj in pairs(game:GetDescendants()) do if obj.Name == Tag then obj:Destroy() end end
end

local function CreateSimpleLabel(Parent, Text, Color)
    local label = Instance.new("TextLabel", Parent)
    label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color; label.Font = Enum.Font.SourceSansBold; label.TextSize = 14; label.Text = Text; label.TextStrokeTransparency = 0.5
    return label
end

local function GetRoot(char) return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end

-- [[ 1. نظام الذاكرة ]] --
_G.CachedZombies = {} 
task.spawn(function()
    while true do
        local list = {}
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then table.insert(list, obj) end
        end
        _G.CachedZombies = list
        task.wait(3) 
    end
end)

local Icons = { Zombie = 4483345998, Friends = 6023426915, Player = 6022668888, Other = 6022668955, Settings = 6022668888 }

-- [[ 2. ترتيب التبويبات ]] --

-- تبويب اللاعب (Player)
local PlayerTab = Window:CreateTab("Player", Icons.Player)
_G.WallhackEnabled = false
PlayerTab:CreateToggle({Name = "Wallhack (Chams)", CurrentValue = false, Callback = function(Value) 
    _G.WallhackEnabled = Value 
    if not Value and Players.LocalPlayer.Character then
        for _, p in pairs(Players.LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end
end})

local FlyEnabled = false; local FlySpeed = 50; local UIS = game:GetService("UserInputService"); local LP = Players.LocalPlayer
PlayerTab:CreateToggle({
   Name = "Fly Mode (PC Only)", CurrentValue = false,
   Callback = function(Value)
       FlyEnabled = Value
       local char = LP.Character
       if not char then return end
       local hrp = GetRoot(char)
       if not hrp then return end
       if FlyEnabled then
           local bg = Instance.new("BodyGyro", hrp); bg.Name = "FlyGyro"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = hrp.CFrame
           local bv = Instance.new("BodyVelocity", hrp); bv.Name = "FlyVel"; bv.velocity = Vector3.new(0,0.1,0); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
           task.spawn(function()
               while FlyEnabled and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 do
                   if not hrp:FindFirstChild("FlyGyro") then break end
                   char.Humanoid.PlatformStand = true; local cam = workspace.CurrentCamera; local newVel = Vector3.new()
                   if UIS:IsKeyDown(Enum.KeyCode.W) then newVel = newVel + (cam.CFrame.LookVector * FlySpeed) end
                   if UIS:IsKeyDown(Enum.KeyCode.S) then newVel = newVel - (cam.CFrame.LookVector * FlySpeed) end
                   if UIS:IsKeyDown(Enum.KeyCode.A) then newVel = newVel - (cam.CFrame.RightVector * FlySpeed) end
                   if UIS:IsKeyDown(Enum.KeyCode.D) then newVel = newVel + (cam.CFrame.RightVector * FlySpeed) end
                   hrp.FlyVel.Velocity = newVel; hrp.FlyGyro.CFrame = cam.CFrame; task.wait()
               end
               if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end; if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end; char.Humanoid.PlatformStand = false
           end)
       else
           if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end; if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end; if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
       end
   end,
})

-- تبويب الزومبي (Zombie)
local ZombieTab = Window:CreateTab("Zombie", Icons.Zombie)
_G.HitboxEnabled = false
ZombieTab:CreateToggle({Name = "Enable Hitbox Expansion", CurrentValue = false, Callback = function(Value) 
    _G.HitboxEnabled = Value 
    if not Value then for _, obj in pairs(_G.CachedZombies) do if obj:FindFirstChild("Head") then obj.Head.Size = Vector3.new(1, 1, 1); obj.Head.Transparency = 0 end end end
end})

_G.HeadSize = 1
ZombieTab:CreateSlider({Name = "Hitbox Size", Range = {1, 5}, Increment = 0.5, CurrentValue = 1, Callback = function(Value) _G.HeadSize = Value end})
ZombieTab:CreateSection("ESP Settings")
ZombieTab:CreateToggle({Name = "Zombie Box ESP (2D)", CurrentValue = false, Callback = function(Value) _G.ZombieBox = Value if not Value then ClearESP("ZombieBoxGui") end end})
ZombieTab:CreateToggle({Name = "Zombie Name ESP", CurrentValue = false, Callback = function(Value) _G.ZombieName = Value if not Value then ClearESP("ZombieNameTag") end end})
ZombieTab:CreateToggle({Name = "Zombie Health ESP", CurrentValue = false, Callback = function(Value) _G.ZombieHealth = Value if not Value then ClearESP("ZombieHealthTag") end end})
ZombieTab:CreateToggle({Name = "Zombie Tracker (Tracer)", CurrentValue = false, Callback = function(Value) _G.ZombieTracker = Value if not Value then ClearESP("ZombieBeam") ClearESP("ZombieAtt") end end})

-- تبويب الأصدقاء (Friends)
local FriendsTab = Window:CreateTab("Friends", Icons.Friends)
_G.DeathNotify = false
FriendsTab:CreateToggle({Name = "Enable Death Notification", CurrentValue = false, Callback = function(Value) _G.DeathNotify = Value end})
FriendsTab:CreateSection("ESP")
FriendsTab:CreateToggle({Name = "Friends Box ESP (2D)", CurrentValue = false, Callback = function(Value) _G.FriendBox = Value if not Value then ClearESP("FriendBoxGui") end end})
FriendsTab:CreateToggle({Name = "Friends Name ESP", CurrentValue = false, Callback = function(Value) _G.FriendName = Value if not Value then ClearESP("FriendNameTag") end end})
FriendsTab:CreateToggle({Name = "Friends Health ESP", CurrentValue = false, Callback = function(Value) _G.FriendHealth = Value if not Value then ClearESP("FriendHealthTag") end end})
FriendsTab:CreateToggle({Name = "Friends Tracker (Tracer)", CurrentValue = false, Callback = function(Value) _G.FriendTracker = Value if not Value then ClearESP("FriendBeam") ClearESP("FriendAtt") end end})

-- تبويب آخر (Other)
local OtherTab = Window:CreateTab("Other", Icons.Other)
_G.BringToggle = false; _G.HoldingF = false
OtherTab:CreateToggle({Name = "Enable Hold (F) to Bring All Zombies", CurrentValue = false, Callback = function(Value) _G.BringToggle = Value end})

-- إضافة ميزة جلب الصناديق (Box Bringer) هنا
_G.BoxBring = false
OtherTab:CreateToggle({
   Name = "Auto Bring All Boxes",
   CurrentValue = false,
   Callback = function(Value)
       _G.BoxBring = Value
   end,
})

game:GetService("UserInputService").InputBegan:Connect(function(input, processed) if not processed and input.KeyCode == Enum.KeyCode.F then _G.HoldingF = true end end)
game:GetService("UserInputService").InputEnded:Connect(function(input) if input.KeyCode == Enum.KeyCode.F then _G.HoldingF = false end end)

-- تبويب الإعدادات (Settings)
local SettingTab = Window:CreateTab("Settings", Icons.Settings)
_G.FullBrightEnabled = false
SettingTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(Value) 
    _G.FullBrightEnabled = Value 
    if not Value then game:GetService("Lighting").Brightness = 1; game:GetService("Lighting").ClockTime = 12 end
end})

-- [[ الأنظمة الخلفية والحلقات ]] --

-- حلقة جلب الصناديق
task.spawn(function()
    while true do
        if _G.BoxBring then
            local hrp = LP.Character and GetRoot(LP.Character)
            if hrp then
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:find("box") or name:find("crate") or obj:FindFirstChild("TouchTransmitter") then
                            local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if target and not obj:IsDescendantOf(LP.Character) then
                                if obj:IsA("Model") then obj:PivotTo(hrp.CFrame) else obj.CFrame = hrp.CFrame end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- مراقبة الموت
local DeadState = {}
task.spawn(function()
    while true do
        if _G.DeathNotify then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health <= 0 and not DeadState[plr.Name] then DeadState[plr.Name] = true; CreateDeathNotify(plr.Name)
                    elseif hum.Health > 0 then DeadState[plr.Name] = false end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- حلقة السحب (Zombies)
task.spawn(function()
    while true do
        if _G.BringToggle and _G.HoldingF then
            local hrp = GetRoot(LP.Character)
            if hrp then
                local targetPos = hrp.CFrame * CFrame.new(0, 0, -16) 
                for _, zombie in pairs(_G.CachedZombies) do if zombie and GetRoot(zombie) then GetRoot(zombie).CFrame = targetPos end end
            end
        end
        task.wait(0.01)
    end
end)

-- الحلقة الرئيسية للتحديث (ESP, Hitbox, Tracker)
task.spawn(function()
    while true do
        local myChar = LP.Character
        local myHrp = myChar and GetRoot(myChar)
        local myAtt = nil
        if myHrp then myAtt = myHrp:FindFirstChild("MyTrackerAtt") or Instance.new("Attachment", myHrp); myAtt.Name = "MyTrackerAtt" end

        for _, obj in pairs(_G.CachedZombies) do
            if obj and GetRoot(obj) then
                local root = GetRoot(obj)
                if _G.HitboxEnabled and obj:FindFirstChild("Head") then
                    obj.Head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize); obj.Head.Transparency = 0.8; obj.Head.CanCollide = false
                end
                if _G.ZombieBox and not obj:FindFirstChild("ZombieBoxGui") then
                    local b = Instance.new("BillboardGui", obj); b.Name = "ZombieBoxGui"; b.Size = UDim2.new(4.5,0,6,0); b.AlwaysOnTop = true; local f = Instance.new("Frame", b); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(255, 0, 0); s.Thickness = 1.5
                end
                if _G.ZombieName and not obj:FindFirstChild("ZombieNameTag") then
                    local b = Instance.new("BillboardGui", obj); b.Name = "ZombieNameTag"; b.Size = UDim2.new(0,100,0,20); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0,3.5,0); CreateSimpleLabel(b, obj.Name, Color3.fromRGB(255, 50, 50))
                end
                if _G.ZombieHealth and obj:FindFirstChild("Humanoid") then
                    local tag = obj:FindFirstChild("ZombieHealthTag")
                    if not tag then local b = Instance.new("BillboardGui", obj); b.Name = "ZombieHealthTag"; b.Size = UDim2.new(0,100,0,20); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0,2.5,0); CreateSimpleLabel(b, math.floor(obj.Humanoid.Health).." HP", Color3.fromRGB(50, 255, 50))
                    else tag.TextLabel.Text = math.floor(obj.Humanoid.Health).." HP" end
                end
                if _G.ZombieTracker and myAtt and not root:FindFirstChild("ZombieBeam") then
                    local att = Instance.new("Attachment", root); att.Name = "ZombieAtt"; local beam = Instance.new("Beam", root); beam.Name = "ZombieBeam"; beam.Attachment0 = myAtt; beam.Attachment1 = att; beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)); beam.Width0 = 0.1; beam.Width1 = 0.1; beam.FaceCamera = true
                end
            end
        end

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and GetRoot(plr.Character) then
                local char = plr.Character; local root = GetRoot(char)
                if _G.FriendBox and not char:FindFirstChild("FriendBoxGui") then
                    local b = Instance.new("BillboardGui", char); b.Name = "FriendBoxGui"; b.Size = UDim2.new(4.5,0,6,0); b.AlwaysOnTop = true; local f = Instance.new("Frame", b); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(0, 255, 255); s.Thickness = 1.5
                end
                if _G.FriendName and not char:FindFirstChild("FriendNameTag") then
                    local b = Instance.new("BillboardGui", char); b.Name = "FriendNameTag"; b.Size = UDim2.new(0,100,0,20); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0,3.5,0); CreateSimpleLabel(b, plr.Name, Color3.fromRGB(0, 255, 255))
                end
                if _G.FriendHealth and char:FindFirstChild("Humanoid") then
                    local tag = char:FindFirstChild("FriendHealthTag")
                    if not tag then local b = Instance.new("BillboardGui", char); b.Name = "FriendHealthTag"; b.Size = UDim2.new(0,100,0,20); b.AlwaysOnTop = true; b.StudsOffset = Vector3.new(0,2.5,0); CreateSimpleLabel(b, math.floor(char.Humanoid.Health).." HP", Color3.fromRGB(0, 255, 100))
                    else tag.TextLabel.Text = math.floor(char.Humanoid.Health).." HP" end
                end
                if _G.FriendTracker and myAtt and not root:FindFirstChild("FriendBeam") then
                    local att = Instance.new("Attachment", root); att.Name = "FriendAtt"; local beam = Instance.new("Beam", root); beam.Name = "FriendBeam"; beam.Attachment0 = myAtt; beam.Attachment1 = att; beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)); beam.Width0 = 0.1; beam.Width1 = 0.1; beam.FaceCamera = true
                end
            end
        end

        if _G.FullBrightEnabled then game:GetService("Lighting").Brightness = 2; game:GetService("Lighting").ClockTime = 14 end
        if _G.WallhackEnabled and myChar then for _, p in pairs(myChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        task.wait(0.1)
    end
end)

Rayfield:Notify({
   Title = "System Ready",
   Content = "Core-X Loaded Successfully",
   Duration = 3,
   Image = 6022668888,
})
