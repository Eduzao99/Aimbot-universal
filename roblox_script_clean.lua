-- Roblox Universal Script - Aimbot & ESP
-- Criado para uso local

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações Globais
local Config = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        WallCheck = true,
        FOV = 100,
        Smoothness = 2,
        TargetPart = "Head",
        Key = Enum.KeyCode.E,
        MouseButton = false,
        VisibleCheck = true
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowBox = true,
        ShowTracers = false,
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        HealthColor = Color3.fromRGB(0, 255, 0),
        TracerColor = Color3.fromRGB(255, 0, 0),
        MaxDistance = 500
    },
    Misc = {
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        NoClip = false,
        Fly = false,
        FlySpeed = 16,
        ClickTeleport = false
    }
}

-- Variáveis de Estado
local ESPObjects = {}
local Connections = {}
local Flying = false
local NoClipping = false

-- Funções Utilitárias
local function GetClosestPlayerToCursor()
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
                    
                    local raycast = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, raycastParams)
                    
                    if raycast and raycast.Instance:IsDescendantOf(character) then
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

local function AimAtPlayer(player)
    if not player or not player.Character then return end
    
    local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart)
    if not targetPart then return end
    
    local targetPosition = targetPart.Position
    local cameraPosition = Camera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    
    local targetCFrame = CFrame.lookAt(cameraPosition, targetPosition)
    
    if Config.Aimbot.Smoothness > 0 then
        local tweenInfo = TweenInfo.new(1 / Config.Aimbot.Smoothness, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    else
        Camera.CFrame = targetCFrame
    end
end

-- Sistema ESP
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = game.CoreGui
    
    -- Box ESP
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Config.ESP.BoxColor
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    
    -- Name ESP
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = Config.ESP.NameColor
    nameLabel.Size = 18
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.new(0, 0, 0)
    nameLabel.Font = 2
    nameLabel.Text = player.Name
    
    -- Distance ESP
    local distanceLabel = Drawing.new("Text")
    distanceLabel.Visible = false
    distanceLabel.Color = Config.ESP.NameColor
    distanceLabel.Size = 16
    distanceLabel.Center = true
    distanceLabel.Outline = true
    distanceLabel.OutlineColor = Color3.new(0, 0, 0)
    distanceLabel.Font = 2
    
    -- Health ESP
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Config.ESP.HealthColor
    healthBar.Thickness = 1
    healthBar.Transparency = 1
    healthBar.Filled = true
    
    -- Tracer ESP
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Config.ESP.TracerColor
    tracer.Thickness = 2
    tracer.Transparency = 1
    
    ESPObjects[player] = {
        Box = box,
        Name = nameLabel,
        Distance = distanceLabel,
        Health = healthBar,
        Tracer = tracer,
        Folder = espFolder
    }
end

local function UpdateESP()
    for player, espData in pairs(ESPObjects) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            espData.Box.Visible = false
            espData.Name.Visible = false
            espData.Distance.Visible = false
            espData.Health.Visible = false
            espData.Tracer.Visible = false
            continue
        end
        
        if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
            espData.Box.Visible = false
            espData.Name.Visible = false
            espData.Distance.Visible = false
            espData.Health.Visible = false
            espData.Tracer.Visible = false
            continue
        end
        
        local character = player.Character
        local humanoidRootPart = character.HumanoidRootPart
        local humanoid = character:FindFirstChild("Humanoid")
        
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
        
        if distance > Config.ESP.MaxDistance then
            espData.Box.Visible = false
            espData.Name.Visible = false
            espData.Distance.Visible = false
            espData.Health.Visible = false
            espData.Tracer.Visible = false
            continue
        end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen and Config.ESP.Enabled then
            local headPos = Camera:WorldToViewportPoint(character.Head.Position)
            local legPos = Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
            
            local boxHeight = math.abs(headPos.Y - legPos.Y)
            local boxWidth = boxHeight * 0.5
            
            -- Update Box
            if Config.ESP.ShowBox then
                espData.Box.Size = Vector2.new(boxWidth, boxHeight)
                espData.Box.Position = Vector2.new(screenPoint.X - boxWidth/2, screenPoint.Y - boxHeight/2)
                espData.Box.Visible = true
            else
                espData.Box.Visible = false
            end
            
            -- Update Name
            if Config.ESP.ShowNames then
                espData.Name.Position = Vector2.new(screenPoint.X, headPos.Y - 25)
                espData.Name.Visible = true
            else
                espData.Name.Visible = false
            end
            
            -- Update Distance
            if Config.ESP.ShowDistance then
                espData.Distance.Text = math.floor(distance) .. "m"
                espData.Distance.Position = Vector2.new(screenPoint.X, legPos.Y + 5)
                espData.Distance.Visible = true
            else
                espData.Distance.Visible = false
            end
            
            -- Update Health
            if Config.ESP.ShowHealth and humanoid then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                espData.Health.Size = Vector2.new(3, boxHeight * healthPercent)
                espData.Health.Position = Vector2.new(screenPoint.X - boxWidth/2 - 8, screenPoint.Y - boxHeight/2 + (boxHeight * (1 - healthPercent)))
                espData.Health.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                espData.Health.Visible = true
            else
                espData.Health.Visible = false
            end
            
            -- Update Tracer
            if Config.ESP.ShowTracers then
                espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                espData.Tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
                espData.Tracer.Visible = true
            else
                espData.Tracer.Visible = false
            end
        else
            espData.Box.Visible = false
            espData.Name.Visible = false
            espData.Distance.Visible = false
            espData.Health.Visible = false
            espData.Tracer.Visible = false
        end
    end
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        ESPObjects[player].Name:Remove()
        ESPObjects[player].Distance:Remove()
        ESPObjects[player].Health:Remove()
        ESPObjects[player].Tracer:Remove()
        ESPObjects[player].Folder:Destroy()
        ESPObjects[player] = nil
    end
end

-- Funcionalidades Extras
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
    
    if Flying then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        
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
                    moveVector = moveVector + Vector3.new(0, -1, 0)
                end
                
                bodyVelocity.Velocity = moveVector * Config.Misc.FlySpeed
            end
        end)
    else
        if Connections.FlyConnection then
            Connections.FlyConnection:Disconnect()
            Connections.FlyConnection = nil
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bodyVelocity then
                bodyVelocity:Destroy()
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

-- Criação da GUI
local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UniversalScript"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false
    
    -- Frame Principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    -- Corner Radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = mainFrame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "Universal Script v1.0"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    
    -- ScrollingFrame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = mainFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    
    local function CreateSection(name, yPos)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = name .. "Section"
        sectionFrame.Parent = scrollFrame
        sectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sectionFrame.Position = UDim2.new(0, 0, 0, yPos)
        sectionFrame.Size = UDim2.new(1, -10, 0, 200)
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 8)
        sectionCorner.Parent = sectionFrame
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "SectionTitle"
        sectionTitle.Parent = sectionFrame
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Position = UDim2.new(0, 10, 0, 5)
        sectionTitle.Size = UDim2.new(1, -20, 0, 25)
        sectionTitle.Font = Enum.Font.GothamSemibold
        sectionTitle.Text = name
        sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        sectionTitle.TextSize = 16
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        return sectionFrame
    end
    
    local function CreateToggle(parent, text, yPos, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = text .. "Toggle"
        toggleFrame.Parent = parent
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Position = UDim2.new(0, 10, 0, yPos)
        toggleFrame.Size = UDim2.new(1, -20, 0, 25)
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Parent = toggleFrame
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel.Size = UDim2.new(1, -60, 1, 0)
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        toggleLabel.TextSize = 14
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Button"
        toggleButton.Parent = toggleFrame
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggleButton.Position = UDim2.new(1, -50, 0, 2)
        toggleButton.Size = UDim2.new(0, 45, 0, 20)
        toggleButton.Font = Enum.Font.Gotham
        toggleButton.Text = "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggleButton.TextSize = 12
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = toggleButton
        
        local isToggled = false
        
        toggleButton.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            if isToggled then
                toggleButton.Text = "ON"
                toggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
                toggleButton.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            else
                toggleButton.Text = "OFF"
                toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
                toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
            callback(isToggled)
        end)
        
        return toggleButton
    end
    
    local function CreateSlider(parent, text, yPos, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = text .. "Slider"
        sliderFrame.Parent = parent
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Position = UDim2.new(0, 10, 0, yPos)
        sliderFrame.Size = UDim2.new(1, -20, 0, 40)
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Parent = sliderFrame
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.Size = UDim2.new(1, 0, 0, 20)
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.Text = text .. ": " .. default
        sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        sliderLabel.TextSize = 14
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local sliderBG = Instance.new("Frame")
        sliderBG.Name = "Background"
        sliderBG.Parent = sliderFrame
        sliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderBG.Position = UDim2.new(0, 0, 0, 22)
        sliderBG.Size = UDim2.new(1, 0, 0, 15)
        
        local sliderBGCorner = Instance.new("UICorner")
        sliderBGCorner.CornerRadius = UDim.new(0, 8)
        sliderBGCorner.Parent = sliderBG
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.Parent = sliderBG
        sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        sliderFill.Position = UDim2.new(0, 0, 0, 0)
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(0, 8)
        sliderFillCorner.Parent = sliderFill
        
        local dragging = false
        
        sliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderBG.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = Players.LocalPlayer:GetMouse()
                local relative = math.clamp((mouse.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * relative)
                
                sliderFill.Size = UDim2.new(relative, 0, 1, 0)
                sliderLabel.Text = text .. ": " .. value
                callback(value)
            end
        end)
    end
    
    -- Seção Aimbot
    local aimbotSection = CreateSection("Aimbot", 10)
    
    CreateToggle(aimbotSection, "Aimbot Enabled", 35, function(state)
        Config.Aimbot.Enabled = state
    end)
    
    CreateToggle(aimbotSection, "Team Check", 65, function(state)
        Config.Aimbot.TeamCheck = state
    end)
    
    CreateToggle(aimbotSection, "Wall Check", 95, function(state)
        Config.Aimbot.WallCheck = state
    end)
    
    CreateSlider(aimbotSection, "FOV", 125, 50, 500, Config.Aimbot.FOV, function(value)
        Config.Aimbot.FOV = value
    end)
    
    CreateSlider(aimbotSection, "Smoothness", 170, 1, 10, Config.Aimbot.Smoothness, function(value)
        Config.Aimbot.Smoothness = value
    end)
    
    -- Seção ESP
    local espSection = CreateSection("ESP", 230)
    
    CreateToggle(espSection, "ESP Enabled", 35, function(state)
        Config.ESP.Enabled = state
    end)
    
    CreateToggle(espSection, "Show Names", 65, function(state)
        Config.ESP.ShowNames = state
    end)
    
    CreateToggle(espSection, "Show Distance", 95, function(state)
        Config.ESP.ShowDistance = state
    end)
    
    CreateToggle(espSection, "Show Health", 125, function(state)
        Config.ESP.ShowHealth = state
    end)
    
    CreateToggle(espSection, "Show Box", 155, function(state)
        Config.ESP.ShowBox = state
    end)
    
    -- Seção Misc
    local miscSection = CreateSection("Misc", 450)
    
    CreateSlider(miscSection, "WalkSpeed", 35, 16, 100, Config.Misc.WalkSpeed, function(value)
        Config.Misc.WalkSpeed = value
        SetWalkSpeed(value)
    end)
    
    CreateSlider(miscSection, "JumpPower", 80, 50, 200, Config.Misc.JumpPower, function(value)
        Config.Misc.JumpPower = value
        SetJumpPower(value)
    end)
    
    CreateToggle(miscSection, "Fly", 125, function(state)
        Config.Misc.Fly = state
        if state then
            ToggleFly()
        else
            if Flying then
                ToggleFly()
            end
        end
    end)
    
    CreateToggle(miscSection, "NoClip", 155, function(state)
        Config.Misc.NoClip = state
        if state then
            ToggleNoClip()
        else
            if NoClipping then
                ToggleNoClip()
            end
        end
    end)
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.Position = UDim2.new(1, -30, 0, 5)
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

-- Inicialização
local function Initialize()
    -- Criar ESP para jogadores existentes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Conectar eventos
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    
    -- Loop principal do Aimbot
    Connections.AimbotConnection = RunService.Heartbeat:Connect(function()
        if Config.Aimbot.Enabled then
            local isKeyPressed = UserInputService:IsKeyDown(Config.Aimbot.Key)
            local isMousePressed = Config.Aimbot.MouseButton and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            
            if isKeyPressed or isMousePressed then
                local target = GetClosestPlayerToCursor()
                if target then
                    AimAtPlayer(target)
                end
            end
        end
    end)
    
    -- Loop do ESP
    Connections.ESPConnection = RunService.Heartbeat:Connect(function()
        UpdateESP()
    end)
    
    -- Criar GUI
    CreateGUI()
    
    print("Universal Script carregado com sucesso!")
    print("Tecla do Aimbot: E")
    print("GUI criada - arraste para mover")
end

-- Cleanup function
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

-- Executar quando o jogador sair
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        Cleanup()
    end
end)

-- Inicializar o script
Initialize()