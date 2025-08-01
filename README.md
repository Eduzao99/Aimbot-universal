-- Script Local para ExperiÃªncia Hacker Completa
-- Coloque este script em StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Estados dos hacks
local hackingEnabled = false
local aimBotEnabled = false
local espEnabled = false
local wallHackEnabled = false
local speedHackEnabled = false
local flyHackEnabled = false
local godModeEnabled = false
local infiniteJumpEnabled = false
local noClipEnabled = false
local xRayEnabled = false

-- ConfiguraÃ§Ãµes
local AIMBOT_FOV = 200
local AIMBOT_SMOOTHNESS = 0.15
local ESP_COLOR = Color3.fromRGB(0, 255, 0)
local SPEED_MULTIPLIER = 3
local FLY_SPEED = 50
local originalWalkSpeed = 16
local originalJumpPower = 50

-- Armazenamento
local espObjects = {}
local originalTransparencies = {}
local bodyVelocity = nil
local bodyPosition = nil
local aimTarget = nil
local connections = {}

-- Criar GUI Principal com Visual Hacker
local function createHackerGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HackerControlPanel"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    -- Frame principal com efeito matrix
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 600)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    mainFrame.Parent = screenGui
    
    -- Efeito de sombra
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.BackgroundTransparency = 0.5
    shadow.Parent = mainFrame
    
    -- Header com animaÃ§Ã£o
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "âš¡ HACKER TERMINAL v2.0 âš¡"
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.Parent = header
    
    -- Status indicator
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 15, 0, 15)
    statusDot.Position = UDim2.new(0, 10, 0, 17)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = header
    
    -- Fazer o status piscar
    local function animateStatus()
        while true do
            TweenService:Create(statusDot, TweenInfo.new(0.5), {BackgroundTransparency = 0.8}):Play()
            wait(0.5)
            TweenService:Create(statusDot, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
            wait(0.5)
        end
    end
    spawn(animateStatus)
    
    -- Scroll frame para botÃµes
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 0, 400)
    scrollFrame.Position = UDim2.new(0, 0, 0, 60)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
    scrollFrame.Parent = mainFrame
    
    -- FunÃ§Ã£o para criar botÃµes
    local function createHackButton(name, text, position, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0.45, 0, 0, 40)
        button.Position = position
        button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        button.BorderColor3 = Color3.fromRGB(0, 150, 0)
        button.BorderSizePixel = 1
        button.Text = text
        button.TextColor3 = Color3.fromRGB(0, 255, 0)
        button.TextScaled = true
        button.Font = Enum.Font.Code
        button.Parent = scrollFrame
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 50, 0)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            }):Play()
        end)
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    -- Console terminal
    local console = Instance.new("Frame")
    console.Size = UDim2.new(1, 0, 0, 130)
    console.Position = UDim2.new(0, 0, 0, 470)
    console.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    console.BorderColor3 = Color3.fromRGB(0, 255, 0)
    console.BorderSizePixel = 1
    console.Parent = mainFrame
    
    local consoleLabel = Instance.new("TextLabel")
    consoleLabel.Size = UDim2.new(1, 0, 0, 20)
    consoleLabel.BackgroundTransparency = 1
    consoleLabel.Text = ">>> SYSTEM CONSOLE <<<"
    consoleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    consoleLabel.TextScaled = true
    consoleLabel.Font = Enum.Font.Code
    consoleLabel.Parent = console
    
    local consoleText = Instance.new("TextLabel")
    consoleText.Name = "ConsoleOutput"
    consoleText.Size = UDim2.new(1, -10, 1, -25)
    consoleText.Position = UDim2.new(0, 5, 0, 25)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = "[SYSTEM] Hacker Terminal Initialized...\n[SYSTEM] All systems ready for deployment\n[WARNING] Use responsibly in game context"
    consoleText.TextColor3 = Color3.fromRGB(0, 255, 0)
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextWrapped = true
    consoleText.Font = Enum.Font.Code
    consoleText.TextSize = 11
    consoleText.Parent = console
    
    return screenGui, scrollFrame, consoleText, statusDot
end

-- FunÃ§Ã£o para log no console
local function logToConsole(consoleText, message, messageType)
    local prefix = "[INFO]"
    local color = Color3.fromRGB(0, 255, 0)
    
    if messageType == "error" then
        prefix = "[ERROR]"
        color = Color3.fromRGB(255, 0, 0)
    elseif messageType == "warning" then
        prefix = "[WARNING]"
        color = Color3.fromRGB(255, 255, 0)
    elseif messageType == "success" then
        prefix = "[SUCCESS]"
        color = Color3.fromRGB(0, 255, 100)
    end
    
    local currentText = consoleText.Text
    local lines = currentText:split("\n")
    
    if #lines >= 8 then
        table.remove(lines, 1)
    end
    
    table.insert(lines, prefix .. " " .. message)
    consoleText.Text = table.concat(lines, "\n")
end

-- FunÃ§Ã£o AimBot avanÃ§ado
local function setupAimBot()
    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (targetPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance and distance <= AIMBOT_FOV then
                    shortestDistance = distance
                    closestPlayer = targetPlayer
                end
            end
        end
        
        return closestPlayer
    end
    
    connections["aimbot"] = RunService.Heartbeat:Connect(function()
        if aimBotEnabled then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPosition = target.Character.Head.Position
                local currentCamera = workspace.CurrentCamera
                
                local currentCFrame = currentCamera.CFrame
                local targetCFrame = CFrame.lookAt(currentCamera.CFrame.Position, targetPosition)
                
                -- Smooth aiming
                local newCFrame = currentCFrame:Lerp(targetCFrame, AIMBOT_SMOOTHNESS)
                currentCamera.CFrame = newCFrame
                
                aimTarget = target
            end
        end
    end)
end

-- FunÃ§Ã£o ESP avanÃ§ado
local function setupESP()
    local function createESPForPlayer(targetPlayer)
        if not targetPlayer.Character or espObjects[targetPlayer.Name] then return end
        
        local character = targetPlayer.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Billboard GUI
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_" .. targetPlayer.Name
        billboardGui.Adornee = humanoidRootPart
        billboardGui.Size = UDim2.new(0, 200, 0, 150)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.Parent = humanoidRootPart
        
        -- Box ESP
        local espBox = Instance.new("Frame")
        espBox.Size = UDim2.new(1, 0, 1, 0)
        espBox.BackgroundTransparency = 0.8
        espBox.BackgroundColor3 = ESP_COLOR
        espBox.BorderSizePixel = 2
        espBox.BorderColor3 = ESP_COLOR
        espBox.Parent = billboardGui
        
        -- Player name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 25)
        nameLabel.Position = UDim2.new(0, 0, -0.2, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "ðŸ‘¤ " .. targetPlayer.Name
        nameLabel.TextColor3 = ESP_COLOR
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.Code
        nameLabel.Parent = billboardGui
        
        -- Health bar
        local healthFrame = Instance.new("Frame")
        healthFrame.Size = UDim2.new(1, 0, 0, 8)
        healthFrame.Position = UDim2.new(0, 0, 1.1, 0)
        healthFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        healthFrame.BorderSizePixel = 1
        healthFrame.BorderColor3 = Color3.new(0, 0, 0)
        healthFrame.Parent = billboardGui
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthFrame
        
        -- Distance label
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 1.3, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "ðŸ“ 0m"
        distanceLabel.TextColor3 = ESP_COLOR
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.TextScaled = true
        distanceLabel.Font = Enum.Font.Code
        distanceLabel.Parent = billboardGui
        
        -- Atualizar informaÃ§Ãµes
        local updateConnection = RunService.Heartbeat:Connect(function()
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = targetPlayer.Character.Humanoid
                local distance = (targetPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                
                healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                distanceLabel.Text = "ðŸ“ " .. math.floor(distance) .. "m"
            end
        end)
        
        espObjects[targetPlayer.Name] = {
            gui = billboardGui,
            connection = updateConnection
        }
    end
    
    local function updateESP()
        if espEnabled then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    createESPForPlayer(targetPlayer)
                end
            end
        else
            for playerName, espData in pairs(espObjects) do
                if espData.gui then
                    espData.gui:Destroy()
                end
                if espData.connection then
                    espData.connection:Disconnect()
                end
            end
            espObjects = {}
        end
    end
    
    connections["esp"] = Players.PlayerAdded:Connect(function(newPlayer)
        if espEnabled then
            newPlayer.CharacterAdded:Connect(function()
                wait(1)
                createESPForPlayer(newPlayer)
            end)
        end
    end)
    
    updateESP()
end

-- FunÃ§Ã£o WallHack (X-Ray)
local function toggleWallHack()
    if wallHackEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Wall" or obj.Parent.Name:lower():find("wall") then
                if originalTransparencies[obj] then
                    obj.Transparency = originalTransparencies[obj]
                end
            end
        end
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Wall" or obj.Parent.Name:lower():find("wall") then
                originalTransparencies[obj] = obj.Transparency
                obj.Transparency = 0.8
            end
        end
    end
end

-- FunÃ§Ã£o Speed Hack
local function toggleSpeedHack()
    if speedHackEnabled then
        humanoid.WalkSpeed = originalWalkSpeed * SPEED_MULTIPLIER
    else
        humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- FunÃ§Ã£o Fly Hack
local function toggleFlyHack()
    if flyHackEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = character.HumanoidRootPart
        
        bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyPosition.Position = character.HumanoidRootPart.Position
        bodyPosition.Parent = character.HumanoidRootPart
        
        connections["fly"] = UserInputService.InputBegan:Connect(function(input)
            if flyHackEnabled then
                local moveVector = Vector3.new(0, 0, 0)
                
                if input.KeyCode == Enum.KeyCode.W then
                    moveVector = moveVector + Camera.CFrame.LookVector * FLY_SPEED
                elseif input.KeyCode == Enum.KeyCode.S then
                    moveVector = moveVector - Camera.CFrame.LookVector * FLY_SPEED
                elseif input.KeyCode == Enum.KeyCode.A then
                    moveVector = moveVector - Camera.CFrame.RightVector * FLY_SPEED
                elseif input.KeyCode == Enum.KeyCode.D then
                    moveVector = moveVector + Camera.CFrame.RightVector * FLY_SPEED
                elseif input.KeyCode == Enum.KeyCode.Space then
                    moveVector = moveVector + Vector3.new(0, FLY_SPEED, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftShift then
                    moveVector = moveVector - Vector3.new(0, FLY_SPEED, 0)
                end
                
                if bodyVelocity then
                    bodyVelocity.Velocity = moveVector
                end
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyPosition then bodyPosition:Destroy() end
        if connections["fly"] then connections["fly"]:Disconnect() end
    end
end

-- FunÃ§Ã£o God Mode
local function toggleGodMode()
    if godModeEnabled then
        connections["godmode"] = humanoid.HealthChanged:Connect(function()
            if godModeEnabled then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    else
        if connections["godmode"] then
            connections["godmode"]:Disconnect()
        end
    end
end

-- FunÃ§Ã£o NoClip
local function toggleNoClip()
    connections["noclip"] = RunService.Stepped:Connect(function()
        if noClipEnabled then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end

-- Criar GUI e configurar botÃµes
local screenGui, scrollFrame, consoleText, statusDot = createHackerGUI()

-- BotÃ£o Master
local masterToggle = createHackButton("MasterToggle", "ðŸ”´ HACKING MODE: OFF", 
    UDim2.new(0.025, 0, 0, 10), function()
        hackingEnabled = not hackingEnabled
        if hackingEnabled then
            masterToggle.Text = "ðŸŸ¢ HACKING MODE: ON"
            masterToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            logToConsole(consoleText, "Hacking mode activated", "success")
        else
            masterToggle.Text = "ðŸ”´ HACKING MODE: OFF"
            masterToggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            logToConsole(consoleText, "Hacking mode deactivated", "warning")
            
            -- Desativar todos os hacks
            aimBotEnabled = false
            espEnabled = false
            wallHackEnabled = false
            speedHackEnabled = false
            flyHackEnabled = false
            godModeEnabled = false
            noClipEnabled = false
        end
    end)

-- BotÃµes dos hacks
local aimBotToggle = createHackButton("AimBotToggle", "ðŸŽ¯ AIMBOT: OFF", 
    UDim2.new(0.025, 0, 0, 70), function()
        if not hackingEnabled then return end
        aimBotEnabled = not aimBotEnabled
        aimBotToggle.Text = aimBotEnabled and "ðŸŽ¯ AIMBOT: ON" or "ðŸŽ¯ AIMBOT: OFF"
        aimBotToggle.BackgroundColor3 = aimBotEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(20, 20, 20)
        logToConsole(consoleText, "AimBot " .. (aimBotEnabled and "activated" or "deactivated"))
        if aimBotEnabled then setupAimBot() end
    end)

local espToggle = createHackButton("ESPToggle", "ðŸ‘ï¸ ESP: OFF", 
    UDim2.new(0.525, 0, 0, 70), function()
        if not hackingEnabled then return end
        espEnabled = not espEnabled
        espToggle.Text = espEnabled and "ðŸ‘ï¸ ESP: ON" or "ðŸ‘ï¸ ESP: OFF"
        espToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(20, 20, 20)
        logToConsole(consoleText, "ESP " .. (espEnabled and "activated" or "deactivated"))
        setupESP()
    end)

        logToConsole(consoleText, "NoClip " .. (noClipEnabled and "activated" or "deactivated"))
        toggleNoClip()
    end)

-- BotÃµes extras
local teleportToggle = createHackButton("TeleportToggle", "ðŸ“ TELEPORT TO CURSOR", 
    UDim2.new(0.025, 0, 0, 310), function()
        if not hackingEnabled then return end
        local mouse = player:GetMouse()
        if mouse.Hit and mouse.Hit.Position then
            character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
            logToConsole(consoleText, "Teleported to cursor position", "success")
        end
    end)

local fullbrightToggle = createHackButton("FullbrightToggle", "ðŸ’¡ FULLBRIGHT: OFF", 
    UDim2.new(0.525, 0, 0, 310), function()
        if not hackingEnabled then return end
        xRayEnabled = not xRayEnabled
        if xRayEnabled then
            Lighting.Brightness = 10
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            fullbrightToggle.Text = "ðŸ’¡ FULLBRIGHT: ON"
            fullbrightToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            logToConsole(consoleText, "Fullbright activated")
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            fullbrightToggle.Text = "ðŸ’¡ FULLBRIGHT: OFF"
            fullbrightToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            logToConsole(consoleText, "Fullbright deactivated")
        end
    end)
    
