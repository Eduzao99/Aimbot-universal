-- Roblox Universal Script - Versão Compatível
-- Funciona na maioria dos executores

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Configurações
local Config = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        FOV = 100,
        Smoothness = 2,
        TargetPart = "Head",
        Key = Enum.KeyCode.E
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowBox = true
    },
    Misc = {
        WalkSpeed = 16,
        JumpPower = 50,
        Fly = false,
        NoClip = false,
        FlySpeed = 16
    }
}

-- Variáveis
local ESPObjects = {}
local Connections = {}
local Flying = false
local NoClipping = false

-- Função para encontrar o jogador mais próximo
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart)
            if not targetPart then continue end
            
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
            
            if distance < Config.Aimbot.FOV and distance < shortestDistance then
                if Config.Aimbot.WallCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    
                    local raycast = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, raycastParams)
                    
                    if not raycast or raycast.Instance:IsDescendantOf(character) then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                else
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Função de Aimbot
local function AimAtTarget(target)
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
    if not targetPart then return end
    
    local targetPosition = targetPart.Position
    local cameraPosition = Camera.CFrame.Position
    
    local newCFrame = CFrame.lookAt(cameraPosition, targetPosition)
    
    if Config.Aimbot.Smoothness > 1 then
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = newCFrame})
        tween:Play()
    else
        Camera.CFrame = newCFrame
    end
end

-- Sistema ESP usando BillboardGui (mais compatível)
local function CreateESP(player)
    if ESPObjects[player] or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Criar BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Parent = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    -- Nome do jogador
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    
    -- Distância
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Parent = billboard
    distanceLabel.Size = UDim2.new(1, 0, 0.25, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    
    -- Saúde
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Parent = billboard
    healthLabel.Size = UDim2.new(1, 0, 0.25, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.75, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "100%"
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = 12
    
    -- Box (usando SelectionBox)
    local box = Instance.new("SelectionBox")
    box.Name = "ESPBox"
    box.Parent = humanoidRootPart
    box.Adornee = humanoidRootPart
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.LineThickness = 0.1
    box.Transparency = 0.3
    
    ESPObjects[player] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistanceLabel = distanceLabel,
        HealthLabel = healthLabel,
        Box = box
    }
end

-- Atualizar ESP
local function UpdateESP()
    for player, espData in pairs(ESPObjects) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if espData.Billboard then espData.Billboard.Enabled = false end
            if espData.Box then espData.Box.Visible = false end
            continue
        end
        
        if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
            if espData.Billboard then espData.Billboard.Enabled = false end
            if espData.Box then espData.Box.Visible = false end
            continue
        end
        
        if not Config.ESP.Enabled then
            if espData.Billboard then espData.Billboard.Enabled = false end
            if espData.Box then espData.Box.Visible = false end
            continue
        end
        
        local character = player.Character
        local humanoidRootPart = character.HumanoidRootPart
        local humanoid = character:FindFirstChild("Humanoid")
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            
            -- Atualizar visibilidade
            if espData.Billboard then
                espData.Billboard.Enabled = Config.ESP.Enabled
                
                if Config.ESP.ShowNames and espData.NameLabel then
                    espData.NameLabel.Visible = true
                else
                    espData.NameLabel.Visible = false
                end
                
                if Config.ESP.ShowDistance and espData.DistanceLabel then
                    espData.DistanceLabel.Visible = true
                    espData.DistanceLabel.Text = math.floor(distance) .. "m"
                else
                    espData.DistanceLabel.Visible = false
                end
                
                if Config.ESP.ShowHealth and espData.HealthLabel and humanoid then
                    espData.HealthLabel.Visible = true
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    espData.HealthLabel.Text = healthPercent .. "%"
                    
                    if healthPercent > 75 then
                        espData.HealthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 50 then
                        espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    elseif healthPercent > 25 then
                        espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                    else
                        espData.HealthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                else
                    espData.HealthLabel.Visible = false
                end
            end
            
            if espData.Box then
                espData.Box.Visible = Config.ESP.ShowBox and Config.ESP.Enabled
            end
        end
    end
end

-- Remover ESP
local function RemoveESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Billboard then
            ESPObjects[player].Billboard:Destroy()
        end
        if ESPObjects[player].Box then
            ESPObjects[player].Box:Destroy()
        end
        ESPObjects[player] = nil
    end
end

-- Funcionalidades extras
local function SetWalkSpeed(speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

local function SetJumpPower(power)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = power
    end
end

local function ToggleFly()
    Flying = not Flying
    
    if Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        bodyVelocity.Name = "FlyVelocity"
        
        Connections.FlyConnection = RunService.Heartbeat:Connect(function()
            if Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
                local camera = Camera
                local moveVector = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                local flyVelocity = humanoidRootPart:FindFirstChild("FlyVelocity")
                if flyVelocity then
                    flyVelocity.Velocity = moveVector * Config.Misc.FlySpeed
                end
            end
        end)
    else
        if Connections.FlyConnection then
            Connections.FlyConnection:Disconnect()
            Connections.FlyConnection = nil
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local flyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVelocity")
            if flyVelocity then
                flyVelocity:Destroy()
            end
        end
    end
end

local function ToggleNoClip()
    NoClipping = not NoClipping
    
    if NoClipping then
        Connections.NoClipConnection = RunService.Stepped:Connect(function()
            if NoClipping and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.NoClipConnection then
            Connections.NoClipConnection:Disconnect()
            Connections.NoClipConnection = nil
        end
    end
end

-- Criar GUI simplificada
local function CreateGUI()
    -- Remover GUI existente
    local existingGui = CoreGui:FindFirstChild("UniversalScript")
    if existingGui then
        existingGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalScript"
    screenGui.Parent = CoreGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 162, 255)
    mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = mainFrame
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "Universal Script v2.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    
    local yOffset = 40
    
    -- Função para criar botões
    local function CreateButton(text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Parent = mainFrame
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Position = UDim2.new(0, 10, 0, yOffset)
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Font = Enum.Font.Gotham
        button.Text = text .. ": OFF"
        button.TextColor3 = Color3.fromRGB(255, 100, 100)
        button.TextSize = 14
        
        local isToggled = false
        
        button.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            if isToggled then
                button.Text = text .. ": ON"
                button.TextColor3 = Color3.fromRGB(100, 255, 100)
                button.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            else
                button.Text = text .. ": OFF"
                button.TextColor3 = Color3.fromRGB(255, 100, 100)
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            callback(isToggled)
        end)
        
        yOffset = yOffset + 40
        return button
    end
    
    -- Botões do Aimbot
    CreateButton("Aimbot", function(state)
        Config.Aimbot.Enabled = state
        print("Aimbot:", state and "ON" or "OFF")
    end)
    
    CreateButton("Team Check", function(state)
        Config.Aimbot.TeamCheck = state
        print("Team Check:", state and "ON" or "OFF")
    end)
    
    CreateButton("Wall Check", function(state)
        Config.Aimbot.WallCheck = state
        print("Wall Check:", state and "ON" or "OFF")
    end)
    
    -- Botões do ESP
    CreateButton("ESP", function(state)
        Config.ESP.Enabled = state
        print("ESP:", state and "ON" or "OFF")
    end)
    
    CreateButton("ESP Names", function(state)
        Config.ESP.ShowNames = state
        print("ESP Names:", state and "ON" or "OFF")
    end)
    
    CreateButton("ESP Distance", function(state)
        Config.ESP.ShowDistance = state
        print("ESP Distance:", state and "ON" or "OFF")
    end)
    
    CreateButton("ESP Health", function(state)
        Config.ESP.ShowHealth = state
        print("ESP Health:", state and "ON" or "OFF")
    end)
    
    CreateButton("ESP Box", function(state)
        Config.ESP.ShowBox = state
        print("ESP Box:", state and "ON" or "OFF")
    end)
    
    -- Botões Misc
    CreateButton("Fly", function(state)
        Config.Misc.Fly = state
        ToggleFly()
        print("Fly:", state and "ON" or "OFF")
    end)
    
    CreateButton("NoClip", function(state)
        Config.Misc.NoClip = state
        ToggleNoClip()
        print("NoClip:", state and "ON" or "OFF")
    end)
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 12
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- Inicialização
local function Initialize()
    print("Carregando Universal Script...")
    
    -- Criar ESP para jogadores existentes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Eventos
    Players.PlayerAdded:Connect(function(player)
        wait(1) -- Aguardar o character carregar
        CreateESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    -- Loop do Aimbot
    Connections.AimbotConnection = RunService.Heartbeat:Connect(function()
        if Config.Aimbot.Enabled then
            local isKeyPressed = UserInputService:IsKeyDown(Config.Aimbot.Key)
            
            if isKeyPressed then
                local target = GetClosestPlayer()
                if target then
                    AimAtTarget(target)
                end
            end
        end
    end)
    
    -- Loop do ESP
    Connections.ESPConnection = RunService.Heartbeat:Connect(function()
        UpdateESP()
    end)
    
    -- Aplicar configurações iniciais
    SetWalkSpeed(Config.Misc.WalkSpeed)
    SetJumpPower(Config.Misc.JumpPower)
    
    -- Criar GUI
    CreateGUI()
    
    print("✅ Universal Script carregado!")
    print("🎯 Tecla do Aimbot: E")
    print("🎮 Use a GUI para configurar")
end

-- Cleanup
local function Cleanup()
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    for player, _ in pairs(ESPObjects) do
        RemoveESP(player)
    end
    
    if Flying then
        ToggleFly()
    end
    
    if NoClipping then
        ToggleNoClip()
    end
end

-- Evento de limpeza
Players.PlayerRemoving:Connect(function(player)
    if player
