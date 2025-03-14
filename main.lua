if game.Players.LocalPlayer.UserId == getgenv().controller then
    game.Players.LocalPlayer:Kick("Controller cannot run this script here.")
end

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
end)

getgenv().adverting = false
getgenv().isDropping = false

local speed = 50
local c
local h
local bv
local bav
local cam
local flying = false
local p = game.Players.LocalPlayer
local buttons = {W=false, S=false, A=false, D=false, Moving=false}

local function startFly()
    if not p.Character or not p.Character.Head or flying then return end
    c = p.Character
    h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    h.PlatformStand = true
    cam = workspace:WaitForChild("Camera")
    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(10000,10000,10000)
    bv.P = 1000
    bav.AngularVelocity = Vector3.new(0,0,0)
    bav.MaxTorque = Vector3.new(10000,10000,10000)
    bav.P = 1000
    bv.Parent = c.Head
    bav.Parent = c.Head
    flying = true
    h.Died:Connect(function()
        flying = false
    end)
end

local function endFly()
    if not p.Character or not flying then return end
    h.PlatformStand = false
    if bv then bv:Destroy() end
    if bav then bav:Destroy() end
    flying = false
end

game:GetService("UserInputService").InputBegan:Connect(function(input, GPE)
    if GPE then return end
    for key in pairs(buttons) do
        if key ~= "Moving" and input.KeyCode == Enum.KeyCode[key] then
            buttons[key] = true
            buttons.Moving = true
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, GPE)
    if GPE then return end
    local stillMoving = false
    for key in pairs(buttons) do
        if key ~= "Moving" then
            if input.KeyCode == Enum.KeyCode[key] then
                buttons[key] = false
            end
            if buttons[key] then
                stillMoving = true
            end
        end
    end
    buttons.Moving = stillMoving
end)

local function setVec(vec)
    return vec * (speed / vec.Magnitude)
end

game:GetService("RunService").Heartbeat:Connect(function(step)
    if flying and c and c.PrimaryPart then
        local cf = cam.CFrame
        local ax, ay, az = cf:ToEulerAnglesXYZ()
        local pPos = c.PrimaryPart.Position
        c:SetPrimaryPartCFrame(CFrame.new(pPos) * CFrame.Angles(ax, ay, az))
        if buttons.Moving then
            local t = Vector3.new()
            if buttons.W then t = t + setVec(cf.LookVector) end
            if buttons.S then t = t - setVec(cf.LookVector) end
            if buttons.A then t = t - setVec(cf.RightVector) end
            if buttons.D then t = t + setVec(cf.RightVector) end
            c:TranslateBy(t * step)
        end
    end
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
    game.StarterGui:SetCore("SendNotification", {
        Title = "LR Alt Control",
        Text = player.Name.." joined the game!",
        Duration = 5
    })
end)

local Players = game:GetService("Players")
local function getPlayerByUserId(userId)
    for _, player in pairs(Players:GetPlayers()) do
        if player.UserId == userId then
            return player
        end
    end
end

local function PlayerAdded(Player)
    local function Chatted(Message)
        local finalMsg = Message:lower()
        local plrLocal = game.Players.LocalPlayer
        local humanoid = plrLocal.Character and plrLocal.Character:FindFirstChildOfClass("Humanoid")
        if Player.UserId == getgenv().controller then
            if finalMsg == getgenv().prefix.."fly" or finalMsg == getgenv().prefix.."fly "..plrLocal.Name:lower() then
                startFly()
            end
            if finalMsg == getgenv().prefix.."unfly" or finalMsg == getgenv().prefix.."unfly "..plrLocal.Name:lower() then
                endFly()
            end
            if finalMsg == getgenv().prefix.."setup bank" then
                plrLocal.Character.Head.Anchored = false
                for i, userId in pairs(getgenv().alts) do
                    if userId == plrLocal.UserId then
                        if i == "Alt1" or i == 1 then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-389, 21, -338)
                        elseif i == "Alt2" or i == 2 then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -338)
                        elseif i == "Alt3" or i == 3 then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-380, 21, -337)
                        elseif i == "Alt4" or i == 4 then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -338)
                        elseif i == "Alt5" or i == 5 then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 21, -338)
                        elseif i == "Alt6" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-366, 21, -338)
                        elseif i == "Alt7" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -338)
                        elseif i == "Alt8" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -333)
                        elseif i == "Alt9" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-365, 21, -334)
                        elseif i == "Alt10" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 21, -334)
                        elseif i == "Alt11" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-375, 21, -334)
                        elseif i == "Alt12" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-381, 21, -334)
                        elseif i == "Alt13" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-386, 21, -334)
                        elseif i == "Alt14" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -334)
                        elseif i == "Alt15" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -331)
                        elseif i == "Alt16" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-386, 21, -331)
                        elseif i == "Alt17" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-382, 21, -331)
                        elseif i == "Alt18" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -331)
                        elseif i == "Alt19" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-371, 21, -331)
                        elseif i == "Alt20" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-366, 21, -331)
                        elseif i == "Alt21" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -331)
                        elseif i == "Alt22" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -327)
                        elseif i == "Alt23" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-365, 21, -327)
                        elseif i == "Alt24" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-371, 21, -326)
                        elseif i == "Alt25" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -327)
                        elseif i == "Alt26" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-381, 21, -326)
                        elseif i == "Alt27" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -327)
                        elseif i == "Alt28" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -323)
                        elseif i == "Alt29" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -326)
                        elseif i == "Alt30" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -323)
                        elseif i == "Alt31" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -323)
                        elseif i == "Alt32" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-381, 21, -323)
                        elseif i == "Alt33" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-375, 21, -324)
                        elseif i == "Alt34" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 21, -323)
                        elseif i == "Alt35" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-365, 21, -324)
                        elseif i == "Alt36" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-360, 21, -324)
                        elseif i == "Alt37" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-359, 21, -318)
                        elseif i == "Alt38" then
                            plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(-364, 21, -319)
                        end
                    end
                end
            end
            if finalMsg == getgenv().prefix.."drop" or finalMsg == getgenv().prefix.."drop "..plrLocal.Name:lower() then
                if getgenv().isDropping == false then
                    getgenv().isDropping = true
                    local startMsg = {[1]="Started Dropping 15000!",[2]="All"}
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(startMsg))
                    while getgenv().isDropping do
                        if plrLocal.DataFolder.Currency.Value < 15000 then
                            local stopMsg = {[1]="Ran out of money, Stopped Dropping.",[2]="All"}
                            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(stopMsg))
                            getgenv().isDropping = false
                            break
                        end
                        local args = {[1]="DropMoney",[2]="15000"}
                        game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(args))
                        wait(15)
                    end
                else
                    getgenv().isDropping = false
                    local endMsg = {[1]="Stopped Dropping!",[2]="All"}
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(endMsg))
                end
            end
            if finalMsg == getgenv().prefix.."ad" or finalMsg == getgenv().prefix.."ad "..plrLocal.Name:lower() then
                if not getgenv().adverting then
                    getgenv().adverting = true
                    while getgenv().adverting do
                        local adArgs = {[1]=getgenv().adMessage,[2]="All"}
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(adArgs))
                        wait(getgenv().adMessageCooldown)
                    end
                else
                    getgenv().adverting = false
                end
            end
            if finalMsg == getgenv().prefix.."vibe" or finalMsg == getgenv().prefix.."vibe "..plrLocal.Name:lower() then
                game:GetService("Players"):Chat("/e dance2")
            end
            if finalMsg == getgenv().prefix.."wallet" or finalMsg == getgenv().prefix.."wallet "..plrLocal.Name:lower() then
                for _,tool in pairs(plrLocal.Backpack:GetChildren()) do
                    if tool.Name == "Wallet" then
                        tool.Parent = plrLocal.Character
                    else
                        if humanoid then
                            humanoid:UnequipTools()
                        end
                    end
                end
            end
            if finalMsg == getgenv().prefix.."spot" or finalMsg == getgenv().prefix.."spot "..plrLocal.Name:lower() then
                local controllerPlayer = getPlayerByUserId(getgenv().controller)
                if controllerPlayer and controllerPlayer.Character and controllerPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local cf = controllerPlayer.Character.HumanoidRootPart.CFrame
                    getgenv().poss = (cf * CFrame.new(0,0,-3)).Position
                else
                    return
                end
                plrLocal.Character.Head.Anchored = false
                plrLocal.Character.HumanoidRootPart.CFrame = CFrame.new(getgenv().poss)
                wait(0.5)
                plrLocal.Character.Head.Anchored = true
            end
            if finalMsg == getgenv().prefix.."money?" or finalMsg == getgenv().prefix.."money? "..plrLocal.Name:lower() then
                local cashMsg = {[1]="I have "..plrLocal.PlayerGui.MainScreenGui.MoneyText.Text,[2]="All"}
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(cashMsg))
            end
            if finalMsg == getgenv().prefix.."airlock" or finalMsg == getgenv().prefix.."airlock "..plrLocal.Name:lower() then
                plrLocal.Character.Head.Anchored = false
                if humanoid then
                    humanoid.Jump = true
                end
                wait(0.3)
                plrLocal.Character.Head.Anchored = true
            end
            if finalMsg == getgenv().prefix.."kill" or finalMsg == getgenv().prefix.."kill "..plrLocal.Name:lower() then
                if humanoid then
                    humanoid.Health = 0
                end
            end
            if finalMsg == getgenv().prefix.."kick" or finalMsg == getgenv().prefix.."kick "..plrLocal.Name:lower() then
                plrLocal:Kick("You've been kicked by the LR Controller.")
            end
            if finalMsg == getgenv().prefix.."bringalts" or finalMsg == getgenv().prefix.."bring "..plrLocal.Name:lower() then
                local targetHum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                local localHum = plrLocal.Character and plrLocal.Character:FindFirstChildOfClass("Humanoid")
                if targetHum and localHum then
                    local lastPos = targetHum.RootPart.CFrame
                    plrLocal.Character.Head.Anchored = false
                    localHum.RootPart.CFrame = lastPos + lastPos.LookVector*3
                    localHum.RootPart.CFrame = CFrame.new(localHum.RootPart.CFrame.Position, Vector3.new(lastPos.Position.X, localHum.RootPart.CFrame.Position.Y, lastPos.Position.Z))
                end
            end
            if finalMsg == getgenv().prefix.."freeze" or finalMsg == getgenv().prefix.."freeze "..plrLocal.Name:lower() then
                plrLocal.Character.Head.Anchored = true
            end
            if finalMsg == getgenv().prefix.."unfreeze" or finalMsg == getgenv().prefix.."unfreeze "..plrLocal.Name:lower() then
                plrLocal.Character.Head.Anchored = false
            end
        end
    end
    Player.Chatted:Connect(Chatted)
end

for _, player in ipairs(Players:GetPlayers()) do
    coroutine.wrap(function()
        PlayerAdded(player)
    end)()
end
Players.PlayerAdded:Connect(PlayerAdded)

if getgenv().alts then
    for _, altID in pairs(getgenv().alts) do
        if altID == game.Players.LocalPlayer.UserId then
            local speaker = game.Players.LocalPlayer
            local Clip = false
            local function NoclipLoop()
                if Clip == false and speaker.Character then
                    for _, child in pairs(speaker.Character:GetDescendants()) do
                        if child:IsA("BasePart") then
                            child.CanCollide = false
                        end
                    end
                end
            end
            game:GetService('RunService').Stepped:Connect(NoclipLoop)
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.WaterReflectance = 0
            workspace.Terrain.WaterTransparency = 0
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Explosion") then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                end
            end
            for _, eff in pairs(game:GetService("Lighting"):GetDescendants()) do
                if eff:IsA("BlurEffect") or eff:IsA("SunRaysEffect") or eff:IsA("ColorCorrectionEffect") or eff:IsA("BloomEffect") or eff:IsA("DepthOfFieldEffect") then
                    eff.Enabled = false
                end
            end
            game:GetService("RunService"):Set3dRenderingEnabled(false)
            local sGui = Instance.new("ScreenGui")
            sGui.Name = "LRAltControl_Overlay"
            sGui.IgnoreGuiInset = true
            sGui.Parent = game.CoreGui
            local mainFrame = Instance.new("Frame")
            mainFrame.Size = UDim2.new(1,0,1,36)
            mainFrame.BackgroundColor3 = Color3.fromRGB(31,31,31)
            mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
            mainFrame.Position = UDim2.new(0.5,0,0.5,0)
            mainFrame.Parent = sGui
            local title = Instance.new("TextLabel")
            title.AnchorPoint = Vector2.new(0.5,0)
            title.Position = UDim2.new(0.5,0,0.02,0)
            title.Size = UDim2.new(0,400,0,40)
            title.BackgroundTransparency = 1
            title.Text = "LR Alt Control"
            title.TextColor3 = Color3.new(1,1,1)
            title.Font = Enum.Font.Code
            title.TextScaled = true
            title.Parent = mainFrame
            local info1 = Instance.new("TextLabel")
            info1.AnchorPoint = Vector2.new(0,0)
            info1.Position = UDim2.new(0.16,0,0.30,0)
            info1.Size = UDim2.new(0,1000,0,40)
            info1.BackgroundTransparency = 1
            info1.Text = "Name: "..game.Players.LocalPlayer.Name
            info1.TextColor3 = Color3.new(1,1,1)
            info1.Font = Enum.Font.Code
            info1.TextSize = 38
            info1.TextXAlignment = Enum.TextXAlignment.Left
            info1.Parent = mainFrame
            local info2 = Instance.new("TextLabel")
            info2.AnchorPoint = Vector2.new(0,0)
            info2.Position = UDim2.new(0.16,0,0.37,0)
            info2.Size = UDim2.new(0,1000,0,40)
            info2.BackgroundTransparency = 1
            info2.TextColor3 = Color3.new(1,1,1)
            info2.Font = Enum.Font.Code
            info2.TextSize = 38
            info2.TextXAlignment = Enum.TextXAlignment.Left
            info2.Parent = mainFrame
            task.spawn(function()
                while true do
                    task.wait(1)
                    if game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                    and game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainScreenGui")
                    and game.Players.LocalPlayer.PlayerGui.MainScreenGui:FindFirstChild("MoneyText") then
                        info2.Text = "Money: "..game.Players.LocalPlayer.PlayerGui.MainScreenGui.MoneyText.Text
                    else
                        info2.Text = "Money: ???"
                    end
                end
            end)
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
            StarterGui:SetCore("TopbarEnabled", false)
            game:GetService("UserInputService").ModalEnabled = true
            local RunService = game:GetService("RunService")
            local maxFps = getgenv().altFPS or 10
            coroutine.wrap(function()
                while true do
                    local t0 = tick()
                    RunService.Heartbeat:Wait()
                    while (tick() - t0) < (1/maxFps) do
                        task.wait()
                    end
                end
            end)()
        end
    end
end

print("LR Alt Control loaded successfully!")
