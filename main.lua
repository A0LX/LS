----------------------------------------------------------------
--            Alt Control: No Manual Alt IDs, No Instances
----------------------------------------------------------------
-- 1) If LocalPlayer == HostUser => do nothing (we're the host).
-- 2) Otherwise, we are an alt:
--    - Sort all non-host players by UserId ascending
--    - LocalPlayer's position in that sorted list = alt index
--    - Then do .drop, .setup, .aura, .cdrop, etc.
-- 3) Removed admin/vault & crash commands, set 15k drops.
-- 4) Use only getgenv().HostUser, .Prefix, .AdMessage.
----------------------------------------------------------------

-- == Settings from getgenv() ==
local prefix    = getgenv().Prefix   or "."
local HostUser  = getgenv().HostUser or "HostNameHere"
local AdMessage = getgenv().AdMessage or "Default ad message"

local Players   = game:GetService("Players")
local RS        = game:GetService("RunService")
local RStorage  = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------------
-- 1) If we are Host or script re-executed, do nothing
----------------------------------------------------------------
if LocalPlayer.Name == HostUser or getgenv().Executed then
    return
end
getgenv().Executed = true  -- Mark so we don't run twice

----------------------------------------------------------------
-- 2) We are an alt. Assign "PointInTable" by sorting players
----------------------------------------------------------------
-- We gather all players except the host
local nonHostPlayers = {}
for _,plr in ipairs(Players:GetPlayers()) do
    if plr.Name ~= HostUser then
        table.insert(nonHostPlayers, plr)
    end
end

-- Sort them by UserId ascending
table.sort(nonHostPlayers, function(a, b)
    return a.UserId < b.UserId
end)

-- Find local player's position
local altIndex
for i,plr in ipairs(nonHostPlayers) do
    if plr == LocalPlayer then
        altIndex = i
        break
    end
end

-- If we didn't find ourselves, something’s off. Stop.
if not altIndex then
    return
end

-- This alt is altIndex (1-based)
getgenv().PointInTable = altIndex
print("Alt #"..altIndex.." => "..LocalPlayer.Name)

----------------------------------------------------------------
-- 3) Optional: reduce volume, disable 3D, set low fps
----------------------------------------------------------------
UserSettings().GameSettings.MasterVolume = 0
RS:Set3dRenderingEnabled(false)
setfpscap(5)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Optional: small UI to know script ran
local mainGui = Instance.new("ScreenGui")
local frame   = Instance.new("Frame")
local label   = Instance.new("TextLabel")

mainGui.IgnoreGuiInset = true
mainGui.Name           = "AltGUI"
mainGui.Parent         = game.CoreGui

frame.Parent          = mainGui
frame.BackgroundColor3= Color3.fromRGB(0,0,0)
frame.AnchorPoint     = Vector2.new(0.5,0.5)
frame.Position        = UDim2.new(0.5,0, 0.5,0)
frame.Size            = UDim2.new(1,0, 1,0)

label.Parent          = frame
label.AnchorPoint     = Vector2.new(0.5,0.5)
label.BackgroundTransparency = 1
label.Position        = UDim2.new(0.5,0, 0.42,0)
label.Size            = UDim2.new(0,300,0,30)
label.Font            = Enum.Font.Gotham
label.Text            = "Welcome Alt #"..altIndex..": "..LocalPlayer.Name
label.TextColor3      = Color3.fromRGB(255,255,255)
label.TextSize        = 19

-- Optional: anti-cheat bypass
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MsorkyScripts/OpenSourceAntiCheat/main/AntiCheatBypass.txt"))()
end)

----------------------------------------------------------------
-- 4) The usual drop & commands logic
----------------------------------------------------------------
local Crashed       = false -- leftover from older code
local CmdSettings   = {}
local DropFolder    = workspace:FindFirstChild("Ignored") 
                     and workspace.Ignored:FindFirstChild("Drop")
local CurrAnim

local function Drop(toggle)
    if toggle and not CmdSettings.Dropping then
        CmdSettings.Dropping   = true
        CmdSettings.CustomDrop = nil
        CmdSettings.Aura       = nil
        while CmdSettings.Dropping do
            RStorage.MainEvent:FireServer("DropMoney", "15000")  -- 15k
            task.wait(2.5)
        end
    else
        CmdSettings.Dropping   = nil
        CmdSettings.CustomDrop = nil
    end
end

local function AirLock(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if state and not CmdSettings.AirLock then
        CmdSettings.AirLock = true
        char.HumanoidRootPart.CFrame *= CFrame.new(0,10,0)
        local bp = Instance.new("BodyPosition", char.HumanoidRootPart)
        bp.Name = "AirLockBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Position = char.HumanoidRootPart.Position
    elseif not state and CmdSettings.AirLock then
        CmdSettings.AirLock = nil
        local bp = char.HumanoidRootPart:FindFirstChild("AirLockBP")
        if bp then bp:Destroy() end
    end
end

local function GetPlayerFromString(str, ignoreLocal)
    for _,p in ipairs(Players:GetPlayers()) do
        if not ignoreLocal and p==LocalPlayer then continue end
        local s = str:lower()
        if p.Name:lower():sub(1,#s) == s or p.DisplayName:lower():sub(1,#s) == s then
            return p
        end
    end
    return nil
end

local function BringPlr(target, pos)
    if getgenv().PointInTable ~= 1 then return end  -- only alt #1
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")) then return end

    local root = char.HumanoidRootPart
    local tchar = target and target.Character
    if not (tchar and tchar:FindFirstChild("HumanoidRootPart")) then return end

    local cKO   = char.BodyEffects["K.O"]
    local cGrab = char.BodyEffects.Grabbed
    local tKO   = tchar.BodyEffects["K.O"]
    if cKO.Value or cGrab.Value or tKO.Value then return end

    CmdSettings.Aura = nil
    CmdSettings.IsLocking = true
    char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    root.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0,0,1)

    repeat
        task.wait()
        root.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0,0,1)
        if not char:FindFirstChild("Combat") and LocalPlayer.Backpack:FindFirstChild("Combat") then
            char.Humanoid:EquipTool(LocalPlayer.Backpack.Combat)
        end
        if char:FindFirstChild("Combat") then
            char.Combat:Activate()
        end
    until not target or not tchar
          or cKO.Value or cGrab.Value
          or tKO.Value

    if tchar:FindFirstChild("LowerTorso") then
        root.CFrame = tchar.LowerTorso.CFrame * CFrame.new(0,3,0)
    end
    task.wait(1.5)

    if pos and typeof(pos)=="CFrame" then
        root.CFrame = pos
    end
    CmdSettings.IsLocking = nil
    task.wait(1.5)
    RStorage.MainEvent:FireServer("Grabbing", false)
end

-- "bank", "klub", "train" only
local BringLocations = {
    bank  = CFrame.new(-396.988922, 21.7570763, -293.929779,
                       -0.102468058, -1.9584887e-09, -0.994736314,
                        7.23731564e-09, 1, -2.71436984e-09,
                        0.994736314, -7.47735651e-09, -0.102468058),
    klub  = CFrame.new(-264.434479, 0.0355005264, -430.854736,
                       -0.999828756, 9.58909574e-09, -0.0185054261,
                        9.92017934e-09, 1, -1.77993904e-08,
                        0.0185054261, -1.79799198e-08, -0.999828756),
    train = CFrame.new(591.396118, 34.5070686, -146.159561,
                        0.0698467195, -4.91725913e-08, -0.997557759,
                        5.03374231e-08, 1, -4.57684664e-08,
                        0.997557759, -4.70177071e-08, 0.0698467195),
}

local SetupsTable = {
    Bank = {
        Origin      = CFrame.new(-386.826202, 21.2503242, -325.340912,
                                 0.998742342, 0, -0.0501373149,
                                 0, 1, 0,
                                 0.0501373149, 0, 0.998742342)
                      * CFrame.new(0,0,-3),
        ZMultiplier = 3,
        XMultiplier = 8,
        PerRow      = 10,
        Rows        = 4,
    },
    Klub = {
        Origin      = CFrame.new(-237.016571, -4.87585974, -411.940063,
                                 0.994918466, -1.5840282e-08, -0.100683607,
                                 6.8329018e-09, 1, -8.9807088e-08,
                                 0.100683607, 8.86627731e-08, 0.994918466),
        ZMultiplier = 6,
        XMultiplier = -12,
        PerRow      = 10,
        Rows        = 4,
    },
    Train = {
        Origin      = CFrame.new(606.527588, 34.5070801, -159.083542,
                                 0.0376962014, -7.60452892e-08, 0.999289274,
                                 6.54496404e-08, 1, 7.36304173e-08,
                                 -0.999289274, 6.26275352e-08, 0.0376962014),
        ZMultiplier = 5,
        XMultiplier = -7,
        PerRow      = 10,
        Rows        = 4,
    }
}

local function Setup(LocationKey)
    CmdSettings.Aura = nil
    local info = SetupsTable[LocationKey]
    if not info then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local altNum = getgenv().PointInTable
    local i
    if altNum <= 10 then
        i = 1
    elseif altNum <= 20 then
        i = 2
    elseif altNum <= 30 then
        i = 3
    elseif altNum <= 40 then
        i = 4
    end

    local X,Z = 0,0
    if i==1 then
        if altNum <= info.PerRow then
            Z = (altNum-1)*info.ZMultiplier
        end
    else
        local index = i*info.PerRow
        if index >= altNum then
            X = (i-1)*info.XMultiplier
            Z = (i*info.PerRow - altNum)*info.ZMultiplier
        end
    end

    root.CFrame = info.Origin * CFrame.new(X,0,Z)
end

local AbbreviationOptions = {k=1000, m=1000000}
local function GetNumberFromText(str)
    str = str:lower()
    if str:find("k") then
        local v = str:gsub("k","")
        return tonumber(v) and tonumber(v)*AbbreviationOptions.k
    elseif str:find("m") then
        local v = str:gsub("m","")
        return tonumber(v) and tonumber(v)*AbbreviationOptions.m
    end
    return tonumber(str)
end

----------------------------------------------------------------
-- 5) Listen for Host Chat Commands
----------------------------------------------------------------
local function StartCommandListener()
    local conn = RStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
        -- Must come from HostUser
        if data.FromSpeaker ~= HostUser then
            return
        end

        local msg      = data.Message
        local lowerMsg = msg:lower()
        local args     = lowerMsg:split(" ")

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            return
        end
        if char.Humanoid.Health <= 0 then
            return
        end

        --------------------------------------
        -- Parse prefix commands
        --------------------------------------
        if args[1] == prefix.."drop" then
            Drop(true)

        elseif args[1] == prefix.."stopdrop" then
            Drop(false)

        elseif args[1] == prefix.."ad" and args[2] == "on" then
            if CmdSettings.AdOn then return end
            local newStr = msg:gsub(prefix.."ad on","")
            if #newStr:gsub("%s+","")<1 then
                newStr = AdMessage
            end
            CmdSettings.AdOn = true
            coroutine.wrap(function()
                while CmdSettings.AdOn do
                    RStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(newStr,"All")
                    task.wait(1.5)
                end
            end)()

        elseif lowerMsg == prefix.."ad off" then
            CmdSettings.AdOn = nil

        elseif lowerMsg == prefix.."loopdel" then
            if DropFolder then
                DropFolder:Destroy()
                DropFolder = nil
            end

        -- .circle host
        elseif lowerMsg == prefix.."circle host" then
            local hostPlr = Players:FindFirstChild(HostUser)
            if hostPlr and hostPlr.Character and hostPlr.Character:FindFirstChild("HumanoidRootPart") then
                local cfr = hostPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
                local altN = getgenv().PointInTable
                local angle = 0
                local ZAxis = 2
                if altN <= 10 then
                    angle = 10 - altN
                    ZAxis = 2
                elseif altN <= 20 then
                    angle = 20 - altN
                    ZAxis = -1
                elseif altN <= 30 then
                    angle = 30 - altN
                    ZAxis = -4
                elseif altN <= 40 then
                    angle = 40 - altN
                    ZAxis = -8
                end
                angle = angle * 36

                local r = char:FindFirstChild("HumanoidRootPart")
                if r then
                    local size = 3
                    r.CFrame = cfr*CFrame.fromEulerAnglesXYZ(0,math.rad(angle),0)*CFrame.new(0,-size,-10)
                    r.CFrame = r.CFrame*CFrame.new(0,0,2)
                    r.CFrame = r.CFrame*CFrame.Angles(0,math.rad(180),0)
                end
            end

        elseif args[1] == prefix.."reset" then
            if char then
                local FLC = char:FindFirstChild("FULLY_LOADED_CHAR")
                if FLC then
                    FLC.Parent = RStorage
                    FLC:Destroy()
                end
                char:Destroy()
            end

        elseif args[1] == prefix.."airlock" then
            AirLock(true)

        elseif args[1] == prefix.."stopairlock" then
            AirLock(false)

        elseif lowerMsg == prefix.."bring" then
            -- Bring alt to host
            local hostPlr = Players:FindFirstChild(HostUser)
            if hostPlr and hostPlr.Character and hostPlr.Character:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = hostPlr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-1)
            end

        elseif args[1] == prefix.."bring" and #args >= 3 then
            local hostPlr = Players:FindFirstChild(HostUser)
            if args[2]=="host" and BringLocations[args[3]] then
                if hostPlr then
                    BringPlr(hostPlr, BringLocations[args[3]])
                end
            else
                local found = GetPlayerFromString(args[2])
                if found then
                    if BringLocations[args[3]] then
                        BringPlr(found, BringLocations[args[3]])
                    elseif args[3]=="host" then
                        BringPlr(found,nil)
                    end
                end
            end

        elseif lowerMsg == prefix.."setup bank" then
            Setup("Bank")
        elseif lowerMsg == prefix.."setup klub" then
            Setup("Klub")
        elseif lowerMsg == prefix.."setup train" then
            Setup("Train")

        elseif lowerMsg == prefix.."wallet on" then
            if LocalPlayer.Backpack:FindFirstChild("Wallet") then
                char.Humanoid:EquipTool(LocalPlayer.Backpack.Wallet)
            end
        elseif lowerMsg == prefix.."wallet off" then
            if char:FindFirstChild("Wallet") then
                char.Humanoid:UnequipTools()
            end

        elseif lowerMsg == prefix.."dolphin" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="rbxassetid://5918726674"
            CurrAnim=char.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."monkey" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="rbxassetid://3333499508"
            CurrAnim=char.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."floss" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="rbxassetid://5917459365"
            CurrAnim=char.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."shuffle" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="rbxassetid://4349242221"
            CurrAnim=char.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."stopdance" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end

        elseif lowerMsg == prefix.."maskon" then
            local maskItem = workspace.Ignored.Shop:FindFirstChild("[Surgeon Mask] - $25")
            if maskItem then
                local r = char.HumanoidRootPart
                local tries=0
                repeat
                    task.wait(0.1)
                    tries+=1
                    r.CFrame = maskItem.Head.CFrame*CFrame.new(math.random(-1,1),0,math.random(-1,1))
                    fireclickdetector(maskItem.ClickDetector)
                until tries>=50 or char:FindFirstChild("Mask") 
                      or LocalPlayer.Backpack:FindFirstChild("Mask")

                task.wait(0.5)
                if LocalPlayer.Backpack:FindFirstChild("Mask") then
                    char.Humanoid:EquipTool(LocalPlayer.Backpack.Mask)
                    char.Mask:Activate()
                elseif char:FindFirstChild("Mask") then
                    char.Mask:Activate()
                end
            end

        elseif lowerMsg == prefix.."maskoff" then
            if LocalPlayer.Backpack:FindFirstChild("Mask") then
                char.Humanoid:EquipTool(LocalPlayer.Backpack.Mask)
                char.Mask:Activate()
            elseif char:FindFirstChild("Mask") then
                char.Mask:Activate()
            end

        elseif args[1] == prefix.."aura" and args[2] then
            local p = GetPlayerFromString(args[2],true)
            if p == LocalPlayer and not CmdSettings.Aura then
                CmdSettings.Aura=true
                CmdSettings.Dropping=nil
                CmdSettings.CustomDrop=nil
                coroutine.wrap(function()
                    while CmdSettings.Aura do
                        if DropFolder then
                            for _,v in ipairs(DropFolder:GetChildren()) do
                                if v:IsA("BasePart") and v.Name=="MoneyDrop" then
                                    local dist=(v.Position - char.HumanoidRootPart.Position).Magnitude
                                    if dist<=12 then
                                        fireclickdetector(v.ClickDetector)
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                        task.wait()
                    end
                end)()
            end

        elseif args[1] == prefix.."stopaura" then
            CmdSettings.Aura=nil

        elseif args[1] == prefix.."cdrop" and args[2] and not CmdSettings.CustomDrop then
            local amt = GetNumberFromText(args[2])
            if amt and DropFolder then
                CmdSettings.Aura=nil
                CmdSettings.Dropping=nil

                local OldMoney=0
                for _,moneyObj in ipairs(DropFolder:GetChildren()) do
                    if moneyObj.Name=="MoneyDrop" and moneyObj:FindFirstChild("BillboardGui") then
                        local txt = moneyObj.BillboardGui.TextLabel.Text
                        local n = tonumber(txt:gsub("%D",""))
                        if n then OldMoney+=n end
                    end
                end

                RStorage.MainEvent:FireServer("DropMoney",15000)
                CmdSettings.CustomDrop=true
                coroutine.wrap(function()
                    repeat
                        task.wait(2.5)
                        RStorage.MainEvent:FireServer("DropMoney",15000)
                        local total=0
                        if DropFolder then
                            for _,moneyObj in ipairs(DropFolder:GetChildren()) do
                                if moneyObj.Name=="MoneyDrop" and moneyObj:FindFirstChild("BillboardGui") then
                                    local txt = moneyObj.BillboardGui.TextLabel.Text
                                    local n = tonumber(txt:gsub("%D",""))
                                    if n then total+=n end
                                end
                            end
                        end
                    until not DropFolder
                          or total>=(OldMoney+amt)
                          or not CmdSettings.CustomDrop

                    if CmdSettings.CustomDrop then
                        CmdSettings.CustomDrop=nil
                        RStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Custom Drop has finished.","All")
                    end
                end)()
            end
        end
    end)

    -- keep track so we can clean up if needed
    CmdSettings.CommandConnection = conn
end

StartCommandListener()
