-- Roblox Aimbot Script com GUI
-- Compatível com Codex Executor
-- Criado com funções avançadas de personalização

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações do Aimbot
local AimbotSettings = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = true,
    VisibleCheck = true,
    TargetPart = "Head",
    FOV = 100,
    Smoothness = 0.5,
    PredictionEnabled = false,
    PredictionStrength = 0.1,
    DistanceLimit = 1000,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    TargetHighlight = true,
    AutoShoot = false,
    SilentAim = false,
    TriggerBot = false,
    AimKey = Enum.KeyCode.E,
    ToggleKey = Enum.KeyCode.F
}

-- Variáveis do sistema
local CurrentTarget = nil
local FOVCircle = nil
local TargetHighlights = {}
local Connection = nil
local GUI = nil

-- Função para criar a GUI
local function CreateGUI()
    -- ScreenGui principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Adicionar cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎯 Aimbot Pro - Codex"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- ScrollingFrame para conteúdo
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    
    -- Layout para organizar elementos
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = ScrollFrame
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Função para criar seções
    local function CreateSection(name, order)
        local Section = Instance.new("Frame")
        Section.Name = name .. "Section"
        Section.Parent = ScrollFrame
        Section.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(1, 0, 0, 200)
        Section.LayoutOrder = order
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 8)
        SectionCorner.Parent = Section
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Size = UDim2.new(1, 0, 0, 30)
        SectionTitle.Font = Enum.Font.GothamSemibold
        SectionTitle.Text = name
        SectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        SectionTitle.TextSize = 14
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Position = UDim2.new(0, 10, 0, 5)
        
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.Parent = Section
        SectionLayout.Padding = UDim.new(0, 5)
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        return Section
    end
    
    -- Função para criar toggle
    local function CreateToggle(parent, text, defaultValue, callback, order)
        local Toggle = Instance.new("Frame")
        Toggle.Name = text .. "Toggle"
        Toggle.Parent = parent
        Toggle.BackgroundTransparency = 1
        Toggle.Size = UDim2.new(1, -20, 0, 35)
        Toggle.Position = UDim2.new(0, 10, 0, 0)
        Toggle.LayoutOrder = order
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = Toggle
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 12
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = Toggle
        ToggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.8, 0, 0.2, 0)
        ToggleButton.Size = UDim2.new(0, 50, 0, 20)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = defaultValue and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 10
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 5)
        ButtonCorner.Parent = ToggleButton
        
        local isEnabled = defaultValue
        ToggleButton.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            ToggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            ToggleButton.Text = isEnabled and "ON" or "OFF"
            callback(isEnabled)
        end)
        
        return Toggle
    end
    
    -- Função para criar slider
    local function CreateSlider(parent, text, min, max, defaultValue, callback, order)
        local Slider = Instance.new("Frame")
        Slider.Name = text .. "Slider"
        Slider.Parent = parent
        Slider.BackgroundTransparency = 1
        Slider.Size = UDim2.new(1, -20, 0, 50)
        Slider.Position = UDim2.new(0, 10, 0, 0)
        Slider.LayoutOrder = order
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = Slider
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = text .. ": " .. defaultValue
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 12
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = Slider
        SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(0, 0, 0, 25)
        SliderFrame.Size = UDim2.new(1, 0, 0, 20)
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 10)
        SliderCorner.Parent = SliderFrame
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderFrame
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 10)
        FillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderFrame
        SliderButton.BackgroundTransparency = 1
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.Text = ""
        
        local dragging = false
        local currentValue = defaultValue
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = Mouse
                local relativeX = math.clamp((mouse.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                currentValue = min + (max - min) * relativeX
                currentValue = math.floor(currentValue * 100) / 100
                
                SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                SliderLabel.Text = text .. ": " .. currentValue
                callback(currentValue)
            end
        end)
        
        return Slider
    end
    
    -- Função para criar dropdown
    local function CreateDropdown(parent, text, options, defaultOption, callback, order)
        local Dropdown = Instance.new("Frame")
        Dropdown.Name = text .. "Dropdown"
        Dropdown.Parent = parent
        Dropdown.BackgroundTransparency = 1
        Dropdown.Size = UDim2.new(1, -20, 0, 35)
        Dropdown.Position = UDim2.new(0, 10, 0, 0)
        Dropdown.LayoutOrder = order
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Parent = Dropdown
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
        DropdownLabel.Font = Enum.Font.Gotham
        DropdownLabel.Text = text .. ":"
        DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownLabel.TextSize = 12
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Parent = Dropdown
        DropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Position = UDim2.new(0.5, 0, 0.1, 0)
        DropdownButton.Size = UDim2.new(0.45, 0, 0.8, 0)
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.Text = defaultOption
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextSize = 11
        
        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 5)
        DropdownCorner.Parent = DropdownButton
        
        local currentOption = defaultOption
        local optionIndex = 1
        for i, option in ipairs(options) do
            if option == defaultOption then
                optionIndex = i
                break
            end
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            optionIndex = optionIndex + 1
            if optionIndex > #options then
                optionIndex = 1
            end
            currentOption = options[optionIndex]
            DropdownButton.Text = currentOption
            callback(currentOption)
        end)
        
        return Dropdown
    end
    
    -- Criar seções
    local MainSection = CreateSection("🎯 Principal", 1)
    local TargetSection = CreateSection("🔍 Alvo", 2)
    local VisualSection = CreateSection("👁️ Visual", 3)
    local AdvancedSection = CreateSection("⚙️ Avançado", 4)
    
    -- Elementos da seção principal
    CreateToggle(MainSection, "Aimbot Ativado", AimbotSettings.Enabled, function(value)
        AimbotSettings.Enabled = value
        if value then
            StartAimbot()
        else
            StopAimbot()
        end
    end, 1)
    
    CreateToggle(MainSection, "Verificar Time", AimbotSettings.TeamCheck, function(value)
        AimbotSettings.TeamCheck = value
    end, 2)
    
    CreateToggle(MainSection, "Verificar Parede", AimbotSettings.WallCheck, function(value)
        AimbotSettings.WallCheck = value
    end, 3)
    
    CreateToggle(MainSection, "Auto Atirar", AimbotSettings.AutoShoot, function(value)
        AimbotSettings.AutoShoot = value
    end, 4)
    
    CreateToggle(MainSection, "Silent Aim", AimbotSettings.SilentAim, function(value)
        AimbotSettings.SilentAim = value
    end, 5)
    
    -- Elementos da seção de alvo
    CreateSlider(TargetSection, "FOV", 10, 500, AimbotSettings.FOV, function(value)
        AimbotSettings.FOV = value
        UpdateFOVCircle()
    end, 1)
    
    CreateSlider(TargetSection, "Suavidade", 0.1, 2, AimbotSettings.Smoothness, function(value)
        AimbotSettings.Smoothness = value
    end, 2)
    
    CreateSlider(TargetSection, "Limite Distância", 100, 2000, AimbotSettings.DistanceLimit, function(value)
        AimbotSettings.DistanceLimit = value
    end, 3)
    
    CreateDropdown(TargetSection, "Parte do Corpo", {"Head", "Torso", "HumanoidRootPart"}, AimbotSettings.TargetPart, function(value)
        AimbotSettings.TargetPart = value
    end, 4)
    
    -- Elementos da seção visual
    CreateToggle(VisualSection, "Mostrar FOV", AimbotSettings.ShowFOV, function(value)
        AimbotSettings.ShowFOV = value
        UpdateFOVCircle()
    end, 1)
    
    CreateToggle(VisualSection, "Destacar Alvo", AimbotSettings.TargetHighlight, function(value)
        AimbotSettings.TargetHighlight = value
    end, 2)
    
    -- Elementos da seção avançada
    CreateToggle(AdvancedSection, "Predição", AimbotSettings.PredictionEnabled, function(value)
        AimbotSettings.PredictionEnabled = value
    end, 1)
    
    CreateSlider(AdvancedSection, "Força Predição", 0.05, 0.5, AimbotSettings.PredictionStrength, function(value)
        AimbotSettings.PredictionStrength = value
    end, 2)
    
    CreateToggle(AdvancedSection, "TriggerBot", AimbotSettings.TriggerBot, function(value)
        AimbotSettings.TriggerBot = value
    end, 3)
    
    -- Botão de fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Ajustar tamanho do ScrollFrame baseado no conteúdo
    local function UpdateScrollFrameSize()
        local totalHeight = 0
        for _, child in pairs(ScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                totalHeight = totalHeight + child.Size.Y.Offset + 10
            end
        end
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end
    
    ScrollFrame.ChildAdded:Connect(UpdateScrollFrameSize)
    UpdateScrollFrameSize()
    
    GUI = ScreenGui
    return ScreenGui
end

-- Função para criar círculo do FOV
local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = AimbotSettings.FOVColor
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 50
    FOVCircle.Radius = AimbotSettings.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = AimbotSettings.ShowFOV
    FOVCircle.Transparency = 0.7
end

-- Função para atualizar círculo do FOV
function UpdateFOVCircle()
    if FOVCircle then
        FOVCircle.Radius = AimbotSettings.FOV
        FOVCircle.Visible = AimbotSettings.ShowFOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

-- Função para verificar se o jogador está na mesma equipe
local function IsTeammate(player)
    if not AimbotSettings.TeamCheck then
        return false
    end
    return player.Team == LocalPlayer.Team and player.Team ~= nil
end

-- Função para verificar se há parede entre jogador e alvo
local function HasWallBetween(startPos, endPos, targetPlayer)
    if not AimbotSettings.WallCheck then
        return false
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPlayer.Character}
    
    local raycast = workspace:Raycast(startPos, (endPos - startPos), raycastParams)
    return raycast ~= nil
end

-- Função para obter a posição prevista do alvo
local function GetPredictedPosition(targetPart)
    if not AimbotSettings.PredictionEnabled or not targetPart.Parent:FindFirstChild("Humanoid") then
        return targetPart.Position
    end
    
    local humanoid = targetPart.Parent:FindFirstChild("Humanoid")
    local rootPart = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        local velocity = rootPart.Velocity
        local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
        local timeToTarget = distance / 1000 -- Assumindo velocidade de projétil
        
        return targetPart.Position + (velocity * timeToTarget * AimbotSettings.PredictionStrength)
    end
    
    return targetPart.Position
end

-- Função para encontrar o melhor alvo
local function GetBestTarget()
    local bestTarget = nil
    local shortestDistance = math.huge
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimbotSettings.TargetPart) then
            if not IsTeammate(player) then
                local targetPart = player.Character[AimbotSettings.TargetPart]
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local distance2D = (Vector2.new(screenPoint.X, screenPoint.Y) - centerScreen).Magnitude
                    local distance3D = (Camera.CFrame.Position - targetPart.Position).Magnitude
                    
                    if distance2D <= AimbotSettings.FOV and distance3D <= AimbotSettings.DistanceLimit then
                        if not HasWallBetween(Camera.CFrame.Position, targetPart.Position, player) then
                            if distance2D < shortestDistance then
                                shortestDistance = distance2D
                                bestTarget = player
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- Função para destacar alvo
local function HighlightTarget(target)
    -- Remover highlights anteriores
    for _, highlight in pairs(TargetHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    TargetHighlights = {}
    
    if AimbotSettings.TargetHighlight and target and target.Character then
        local highlight = Instance.new("Highlight")
        highlight.Parent = target.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        table.insert(TargetHighlights, highlight)
    end
end

-- Função principal do aimbot
local function AimbotLoop()
    if not AimbotSettings.Enabled then
        return
    end
    
    local target = GetBestTarget()
    CurrentTarget = target
    
    if target and target.Character and target.Character:FindFirstChild(AimbotSettings.TargetPart) then
        local targetPart = target.Character[AimbotSettings.TargetPart]
        local predictedPos = GetPredictedPosition(targetPart)
        
        HighlightTarget(target)
        
        if AimbotSettings.SilentAim then
            -- Silent aim implementation
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "FireServer" and string.find(tostring(self), "RemoteEvent") then
                    -- Modificar argumentos para silent aim
                    if args[1] and typeof(args[1]) == "Vector3" then
                        args[1] = predictedPos
                    end
                end
                
                return oldNamecall(self, unpack(args))
            end)
        else
            -- Aimbot normal
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, predictedPos)
            
            local smoothedCFrame = currentCFrame:Lerp(targetCFrame, AimbotSettings.Smoothness)
            Camera.CFrame = smoothedCFrame
        end
        
        -- Auto shoot
        if AimbotSettings.AutoShoot then
            mouse1press()
            wait(0.1)
            mouse1release()
        end
        
        -- TriggerBot
        if AimbotSettings.TriggerBot then
            local screenPoint, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
                local distance = (mousePos - targetPos).Magnitude
                
                if distance <= 50 then -- Distância do cursor para trigger
                    mouse1press()
                    wait(0.05)
                    mouse1release()
                end
            end
        end
    else
        HighlightTarget(nil)
    end
    
    UpdateFOVCircle()
end

-- Função para iniciar o aimbot
function StartAimbot()
    if Connection then
        Connection:Disconnect()
    end
    
    CreateFOVCircle()
    Connection = RunService.Heartbeat:Connect(AimbotLoop)
end

-- Função para parar o aimbot
function StopAimbot()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    -- Remover highlights
    for _, highlight in pairs(TargetHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    TargetHighlights = {}
    
    CurrentTarget = nil
end

-- Controles de teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == AimbotSettings.ToggleKey then
        AimbotSettings.Enabled = not AimbotSettings.Enabled
        if AimbotSettings.Enabled then
            StartAimbot()
        else
            StopAimbot()
        end
    elseif input.KeyCode == AimbotSettings.AimKey then
        if not AimbotSettings.Enabled then
            AimbotSettings.Enabled = true
            StartAimbot()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == AimbotSettings.AimKey then
        if AimbotSettings.Enabled then
            AimbotSettings.Enabled = false
            StopAimbot()
        end
    end
end)

-- Função para toggle da GUI
local function ToggleGUI()
    if GUI then
        GUI:Destroy()
        GUI = nil
    else
        CreateGUI()
    end
end

-- Comando para abrir/fechar GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        ToggleGUI()
    end
end)

-- Notificação de carregamento
local function ShowNotification(title, text, duration)
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    notification.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Parent = notification
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.Size = UDim2.new(0, 300, 0, 80)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = frame
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = frame
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -10, 0, 45)
    textLabel.Position = UDim2.new(0, 5, 0, 30)
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    
    -- Animação de entrada
    frame:TweenPosition(UDim2.new(1, -320, 0, 20), "Out", "Quad", 0.5, true)
    
    -- Remover após duração
    game:GetService("Debris"):AddItem(notification, duration or 5)
    
    -- Animação de saída
    wait(duration - 0.5 or 4.5)
    frame:TweenPosition(UDim2.new(1, 0, 0, 20), "In", "Quad", 0.5, true)
end

-- Inicialização
ShowNotification("🎯 Aimbot Pro", "Script carregado com sucesso!\nPressione INSERT para abrir a GUI", 5)

-- Criar GUI automaticamente
CreateGUI()

print("🎯 Aimbot Pro carregado com sucesso!")
print("📋 Controles:")
print("   INSERT - Abrir/Fechar GUI")
print("   F - Toggle Aimbot")
print("   E - Aimbot temporário")
print("✅ Script pronto para uso!")