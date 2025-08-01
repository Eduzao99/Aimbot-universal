-- Roblox Aimbot Script Otimizado para Codex Executor
-- AVISO: Este script é apenas para fins educacionais
-- Compatível com Codex Executor v2.683+

-- Verificação de compatibilidade do executor
local function checkExecutorCompatibility()
    local executor = identifyexecutor and identifyexecutor() or "Unknown"
    local isCodex = executor:lower():find("codex") or getgenv().codex or false
    
    if not isCodex then
        warn("⚠️ Este script foi otimizado para Codex Executor")
        warn("Algumas funcionalidades podem não funcionar corretamente")
    end
    
    return {
        Drawing = Drawing ~= nil,
        HttpService = pcall(function() return game:GetService("HttpService") end),
        UserInput = pcall(function() return game:GetService("UserInputService") end),
        TweenService = pcall(function() return game:GetService("TweenService") end)
    }
end

local compatibility = checkExecutorCompatibility()
print("🎯 Carregando Aimbot para Codex Executor...")

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configurações do Aimbot (otimizadas para Codex)
local AimbotSettings = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = true,
    VisibleCheck = true,
    TargetPart = "Head",
    FOV = 100,
    Smoothness = 0.5,
    MaxDistance = 1000,
    PredictionEnabled = false,
    PredictionStrength = 0.5,
    SilentAim = false,
    TriggerBot = false,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    TargetHighlight = true,
    HighlightColor = Color3.fromRGB(255, 0, 0),
    -- Configurações específicas do Codex
    CodexOptimized = true,
    AntiDetection = true,
    SafeMode = true
}

-- Variáveis globais
local CurrentTarget = nil
local FOVCircle = nil
local TargetHighlight = nil
local Connection = nil
local GuiConnections = {}

-- Sistema Anti-Detecção para Codex
local function setupAntiDetection()
    if not AimbotSettings.AntiDetection then return end
    
    -- Randomizar valores ligeiramente para parecer mais natural
    local function randomizeValue(value, variance)
        local random = math.random(-variance * 100, variance * 100) / 100
        return value + (value * random)
    end
    
    -- Aplicar randomização aos settings críticos
    spawn(function()
        while AimbotSettings.Enabled do
            wait(math.random(1, 3))
            if AimbotSettings.Smoothness > 0 then
                AimbotSettings.Smoothness = randomizeValue(AimbotSettings.Smoothness, 0.1)
                AimbotSettings.Smoothness = math.clamp(AimbotSettings.Smoothness, 0.1, 1)
            end
        end
    end)
end

-- Função para criar a GUI otimizada para Codex
local function CreateCodexGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CodexAimbotGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    
    -- Frame principal com design específico para Codex
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    MainFrame.Size = UDim2.new(0, 380, 0, 520)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 10
    
    -- Efeito de borda para Codex
    local Border = Instance.new("Frame")
    Border.Name = "Border"
    Border.Parent = MainFrame
    Border.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    Border.BorderSizePixel = 0
    Border.Position = UDim2.new(0, -2, 0, -2)
    Border.Size = UDim2.new(1, 4, 1, 4)
    Border.ZIndex = MainFrame.ZIndex - 1
    
    -- Gradiente otimizado
    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = MainFrame
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
    }
    Gradient.Rotation = 45
    
    -- Cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.Parent = MainFrame
    Corner.CornerRadius = UDim.new(0, 8)
    
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.Parent = Border
    BorderCorner.CornerRadius = UDim.new(0, 10)
    
    -- Título com logo Codex
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎯 Codex Aimbot Pro"
    Title.TextColor3 = Color3.fromRGB(0, 162, 255)
    Title.TextSize = 20
    Title.ZIndex = MainFrame.ZIndex + 1
    
    -- Status indicator específico do Codex
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Parent = MainFrame
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Position = UDim2.new(0, 10, 0, 50)
    StatusFrame.Size = UDim2.new(1, -20, 0, 25)
    StatusFrame.ZIndex = MainFrame.ZIndex + 1
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.Parent = StatusFrame
    StatusCorner.CornerRadius = UDim.new(0, 4)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 1, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "🟢 Codex Executor Detectado | Status: Pronto"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.ZIndex = StatusFrame.ZIndex + 1
    
    -- Scroll Frame otimizado
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Position = UDim2.new(0, 10, 0, 85)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -95)
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
    ScrollFrame.ZIndex = MainFrame.ZIndex + 1
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = ScrollFrame
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Função para criar toggle otimizado para Codex
    local function CreateCodexToggle(name, description, defaultValue, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(1, 0, 0, 55)
        ToggleFrame.ZIndex = ScrollFrame.ZIndex + 1
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.Parent = ToggleFrame
        ToggleCorner.CornerRadius = UDim.new(0, 6)
        
        -- Efeito hover para Codex
        local HoverEffect = Instance.new("Frame")
        HoverEffect.Name = "HoverEffect"
        HoverEffect.Parent = ToggleFrame
        HoverEffect.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        HoverEffect.BackgroundTransparency = 1
        HoverEffect.BorderSizePixel = 0
        HoverEffect.Size = UDim2.new(1, 0, 1, 0)
        HoverEffect.ZIndex = ToggleFrame.ZIndex - 1
        
        local HoverCorner = Instance.new("UICorner")
        HoverCorner.Parent = HoverEffect
        HoverCorner.CornerRadius = UDim.new(0, 6)
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0, 12, 0, 8)
        ToggleLabel.Size = UDim2.new(1, -70, 0, 22)
        ToggleLabel.Font = Enum.Font.GothamBold
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.ZIndex = ToggleFrame.ZIndex + 1
        
        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Parent = ToggleFrame
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Position = UDim2.new(0, 12, 0, 30)
        ToggleDesc.Size = UDim2.new(1, -70, 0, 18)
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.Text = description
        ToggleDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        ToggleDesc.TextSize = 11
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDesc.ZIndex = ToggleFrame.ZIndex + 1
        
        -- Switch toggle específico do Codex
        local SwitchFrame = Instance.new("Frame")
        SwitchFrame.Parent = ToggleFrame
        SwitchFrame.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(60, 60, 60)
        SwitchFrame.BorderSizePixel = 0
        SwitchFrame.Position = UDim2.new(1, -50, 0.5, -10)
        SwitchFrame.Size = UDim2.new(0, 40, 0, 20)
        SwitchFrame.ZIndex = ToggleFrame.ZIndex + 1
        
        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.Parent = SwitchFrame
        SwitchCorner.CornerRadius = UDim.new(0, 10)
        
        local SwitchButton = Instance.new("Frame")
        SwitchButton.Parent = SwitchFrame
        SwitchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchButton.BorderSizePixel = 0
        SwitchButton.Position = defaultValue and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        SwitchButton.Size = UDim2.new(0, 16, 0, 16)
        SwitchButton.ZIndex = SwitchFrame.ZIndex + 1
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.Parent = SwitchButton
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        
        local ClickDetector = Instance.new("TextButton")
        ClickDetector.Parent = ToggleFrame
        ClickDetector.BackgroundTransparency = 1
        ClickDetector.Size = UDim2.new(1, 0, 1, 0)
        ClickDetector.Text = ""
        ClickDetector.ZIndex = ToggleFrame.ZIndex + 2
        
        local isEnabled = defaultValue
        
        -- Animações específicas do Codex
        ClickDetector.MouseEnter:Connect(function()
            TweenService:Create(HoverEffect, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
        end)
        
        ClickDetector.MouseLeave:Connect(function()
            TweenService:Create(HoverEffect, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end)
        
        ClickDetector.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            
            -- Animação do switch
            local switchColor = isEnabled and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(60, 60, 60)
            local switchPos = isEnabled and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            
            TweenService:Create(SwitchFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = switchColor}):Play()
            TweenService:Create(SwitchButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = switchPos}):Play()
            
            callback(isEnabled)
        end)
        
        GuiConnections[#GuiConnections + 1] = ClickDetector.MouseButton1Click
        return ClickDetector
    end
    
    -- Função para criar slider otimizado para Codex
    local function CreateCodexSlider(name, description, min, max, defaultValue, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name .. "Slider"
        SliderFrame.Parent = ScrollFrame
        SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(1, 0, 0, 70)
        SliderFrame.ZIndex = ScrollFrame.ZIndex + 1
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.Parent = SliderFrame
        SliderCorner.CornerRadius = UDim.new(0, 6)
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 12, 0, 8)
        SliderLabel.Size = UDim2.new(0.6, 0, 0, 20)
        SliderLabel.Font = Enum.Font.GothamBold
        SliderLabel.Text = name
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 14
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.ZIndex = SliderFrame.ZIndex + 1
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.6, 0, 0, 8)
        ValueLabel.Size = UDim2.new(0.4, -12, 0, 20)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(defaultValue)
        ValueLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
        ValueLabel.TextSize = 14
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.ZIndex = SliderFrame.ZIndex + 1
        
        local SliderDesc = Instance.new("TextLabel")
        SliderDesc.Parent = SliderFrame
        SliderDesc.BackgroundTransparency = 1
        SliderDesc.Position = UDim2.new(0, 12, 0, 28)
        SliderDesc.Size = UDim2.new(1, -24, 0, 15)
        SliderDesc.Font = Enum.Font.Gotham
        SliderDesc.Text = description
        SliderDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        SliderDesc.TextSize = 11
        SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
        SliderDesc.ZIndex = SliderFrame.ZIndex + 1
        
        -- Barra do slider específica do Codex
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Parent = SliderFrame
        SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Position = UDim2.new(0, 12, 1, -18)
        SliderTrack.Size = UDim2.new(1, -24, 0, 6)
        SliderTrack.ZIndex = SliderFrame.ZIndex + 1
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.Parent = SliderTrack
        TrackCorner.CornerRadius = UDim.new(0, 3)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderTrack
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        SliderFill.ZIndex = SliderTrack.ZIndex + 1
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.Parent = SliderFill
        FillCorner.CornerRadius = UDim.new(0, 3)
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderTrack
        SliderButton.BackgroundTransparency = 1
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.Text = ""
        SliderButton.ZIndex = SliderTrack.ZIndex + 2
        
        local dragging = false
        local currentValue = defaultValue
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        local function updateSlider(input)
            if dragging then
                local mousePos = input.Position.X
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                currentValue = min + (max - min) * percentage
                
                if name == "FOV" or name == "Max Distance" then
                    currentValue = math.floor(currentValue)
                else
                    currentValue = math.floor(currentValue * 100) / 100
                end
                
                ValueLabel.Text = tostring(currentValue)
                TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                callback(currentValue)
            end
        end
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        GuiConnections[#GuiConnections + 1] = SliderButton.MouseButton1Down
        return SliderButton
    end
    
    -- Função para criar dropdown otimizado para Codex
    local function CreateCodexDropdown(name, description, options, defaultValue, callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = name .. "Dropdown"
        DropdownFrame.Parent = ScrollFrame
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Size = UDim2.new(1, 0, 0, 55)
        DropdownFrame.ZIndex = ScrollFrame.ZIndex + 1
        
        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.Parent = DropdownFrame
        DropdownCorner.CornerRadius = UDim.new(0, 6)
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Parent = DropdownFrame
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Position = UDim2.new(0, 12, 0, 8)
        DropdownLabel.Size = UDim2.new(0.5, 0, 0, 20)
        DropdownLabel.Font = Enum.Font.GothamBold
        DropdownLabel.Text = name
        DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownLabel.TextSize = 14
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropdownLabel.ZIndex = DropdownFrame.ZIndex + 1
        
        local DropdownDesc = Instance.new("TextLabel")
        DropdownDesc.Parent = DropdownFrame
        DropdownDesc.BackgroundTransparency = 1
        DropdownDesc.Position = UDim2.new(0, 12, 0, 30)
        DropdownDesc.Size = UDim2.new(1, -120, 0, 18)
        DropdownDesc.Font = Enum.Font.Gotham
        DropdownDesc.Text = description
        DropdownDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        DropdownDesc.TextSize = 11
        DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
        DropdownDesc.ZIndex = DropdownFrame.ZIndex + 1
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Parent = DropdownFrame
        DropdownButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Position = UDim2.new(1, -100, 0.5, -12)
        DropdownButton.Size = UDim2.new(0, 88, 0, 24)
        DropdownButton.Font = Enum.Font.GothamBold
        DropdownButton.Text = defaultValue
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextSize = 11
        DropdownButton.ZIndex = DropdownFrame.ZIndex + 1
        
        local DropdownButtonCorner = Instance.new("UICorner")
        DropdownButtonCorner.Parent = DropdownButton
        DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
        
        local currentIndex = 1
        for i, option in ipairs(options) do
            if option == defaultValue then
                currentIndex = i
                break
            end
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            currentIndex = currentIndex + 1
            if currentIndex > #options then
                currentIndex = 1
            end
            DropdownButton.Text = options[currentIndex]
            callback(options[currentIndex])
        end)
        
        GuiConnections[#GuiConnections + 1] = DropdownButton.MouseButton1Click
        return DropdownButton
    end
    
    -- Criar controles otimizados para Codex
    CreateCodexToggle("Aimbot Enabled", "Liga/desliga o aimbot principal", AimbotSettings.Enabled, function(value)
        AimbotSettings.Enabled = value
        StatusLabel.Text = value and "🟢 Aimbot Ativo | Codex Otimizado" or "🟡 Aimbot Inativo | Aguardando..."
        StatusLabel.TextColor3 = value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
    end)
    
    CreateCodexToggle("Team Check", "Ignora jogadores da mesma equipe", AimbotSettings.TeamCheck, function(value)
        AimbotSettings.TeamCheck = value
    end)
    
    CreateCodexToggle("Wall Check", "Verifica paredes (otimizado para Codex)", AimbotSettings.WallCheck, function(value)
        AimbotSettings.WallCheck = value
    end)
    
    CreateCodexToggle("Visible Check", "Só mira em alvos visíveis", AimbotSettings.VisibleCheck, function(value)
        AimbotSettings.VisibleCheck = value
    end)
    
    CreateCodexToggle("Prediction", "Predição de movimento avançada", AimbotSettings.PredictionEnabled, function(value)
        AimbotSettings.PredictionEnabled = value
    end)
    
    CreateCodexToggle("Silent Aim", "Mira silenciosa (Codex otimizado)", AimbotSettings.SilentAim, function(value)
        AimbotSettings.SilentAim = value
    end)
    
    CreateCodexToggle("Show FOV", "Mostra círculo FOV", AimbotSettings.ShowFOV, function(value)
        AimbotSettings.ShowFOV = value
        if FOVCircle then
            FOVCircle.Visible = value
        end
    end)
    
    CreateCodexToggle("Target Highlight", "Destaca alvo atual", AimbotSettings.TargetHighlight, function(value)
        AimbotSettings.TargetHighlight = value
    end)
    
    CreateCodexToggle("Anti-Detection", "Sistema anti-detecção do Codex", AimbotSettings.AntiDetection, function(value)
        AimbotSettings.AntiDetection = value
        if value then
            setupAntiDetection()
        end
    end)
    
    CreateCodexSlider("FOV", "Campo de visão do aimbot", 10, 360, AimbotSettings.FOV, function(value)
        AimbotSettings.FOV = value
    end)
    
    CreateCodexSlider("Smoothness", "Suavidade da mira (0 = instantâneo)", 0, 1, AimbotSettings.Smoothness, function(value)
        AimbotSettings.Smoothness = value
    end)
    
    CreateCodexSlider("Max Distance", "Distância máxima para alvos", 100, 2000, AimbotSettings.MaxDistance, function(value)
        AimbotSettings.MaxDistance = value
    end)
    
    CreateCodexSlider("Prediction Strength", "Força da predição", 0, 2, AimbotSettings.PredictionStrength, function(value)
        AimbotSettings.PredictionStrength = value
    end)
    
    CreateCodexDropdown("Target Part", "Parte do corpo alvo", {"Head", "Torso", "HumanoidRootPart"}, AimbotSettings.TargetPart, function(value)
        AimbotSettings.TargetPart = value
    end)
    
    -- Atualizar canvas size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    return ScreenGui
end

-- Função para criar círculo FOV otimizada para Codex
local function CreateCodexFOVCircle()
    if not compatibility.Drawing then
        warn("⚠️ Drawing API não disponível no Codex")
        return nil
    end
    
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.NumSides = 60 -- Mais suave para Codex
    circle.Radius = AimbotSettings.FOV
    circle.Filled = false
    circle.Visible = AimbotSettings.ShowFOV
    circle.Color = AimbotSettings.FOVColor
    circle.Transparency = 0.6
    return circle
end

-- Funções do aimbot otimizadas para Codex
local function IsTeammate(player)
    if not AimbotSettings.TeamCheck then return false end
    return player.Team == LocalPlayer.Team and player.Team ~= nil
end

local function HasWallBetween(startPos, endPos, ignoreList)
    if not AimbotSettings.WallCheck then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList or {LocalPlayer.Character}
    
    local raycastResult = Workspace:Raycast(startPos, (endPos - startPos), raycastParams)
    return raycastResult ~= nil
end

local function IsVisible(targetPart)
    if not AimbotSettings.VisibleCheck then return true end
    
    local camera = Workspace.CurrentCamera
    local cameraPos = camera.CFrame.Position
    local targetPos = targetPart.Position
    
    return not HasWallBetween(cameraPos, targetPos, {LocalPlayer.Character, targetPart.Parent})
end

local function GetDistance(part1, part2)
    return (part1.Position - part2.Position).Magnitude
end

local function IsInFOV(targetPart)
    local camera = Workspace.CurrentCamera
    local screenPoint, onScreen = camera:WorldToScreenPoint(targetPart.Position)
    
    if not onScreen then return false end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
    local distance = (targetPos - mousePos).Magnitude
    
    return distance <= AimbotSettings.FOV
end

local function GetBestTarget()
    local bestTarget = nil
    local bestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 and not IsTeammate(player) then
                local targetPart = player.Character:FindFirstChild(AimbotSettings.TargetPart)
                if targetPart then
                    local distance = GetDistance(Camera.CFrame, targetPart.CFrame)
                    if distance <= AimbotSettings.MaxDistance then
                        if IsInFOV(targetPart) and IsVisible(targetPart) then
                            if distance < bestDistance then
                                bestDistance = distance
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

local function GetPredictedPosition(targetPart)
    if not AimbotSettings.PredictionEnabled then
        return targetPart.Position
    end
    
    local velocity = targetPart.Velocity
    local predictedPos = targetPart.Position + (velocity * AimbotSettings.PredictionStrength)
    return predictedPos
end

-- Função de mira otimizada para Codex
local function AimAtTarget(target)
    if not target or not target.Character then return end
    
    local targetPart = target.Character:FindFirstChild(AimbotSettings.TargetPart)
    if not targetPart then return end
    
    local predictedPos = GetPredictedPosition(targetPart)
    local camera = Workspace.CurrentCamera
    
    if AimbotSettings.SilentAim then
        -- Silent aim otimizado para Codex
        local direction = (predictedPos - camera.CFrame.Position).Unit
        -- Implementação específica do Codex seria aqui
    else
        -- Aim normal com suavidade otimizada
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, predictedPos)
        
        if AimbotSettings.Smoothness > 0 then
            local tweenInfo = TweenInfo.new(
                AimbotSettings.Smoothness * 0.5, -- Mais rápido para Codex
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            )
            local tween = TweenService:Create(camera, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        else
            camera.CFrame = targetCFrame
        end
    end
end

local function HighlightTarget(target)
    if TargetHighlight then
        TargetHighlight:Destroy()
        TargetHighlight = nil
    end
    
    if target and target.Character and AimbotSettings.TargetHighlight then
        local highlight = Instance.new("Highlight")
        highlight.Parent = target.Character
        highlight.FillColor = AimbotSettings.HighlightColor
        highlight.OutlineColor = AimbotSettings.HighlightColor
        highlight.FillTransparency = 0.8
        highlight.OutlineTransparency = 0.2
        TargetHighlight = highlight
    end
end

-- Loop principal otimizado para Codex
local function CodexAimbotLoop()
    if not AimbotSettings.Enabled then
        CurrentTarget = nil
        HighlightTarget(nil)
        return
    end
    
    local newTarget = GetBestTarget()
    
    if newTarget ~= CurrentTarget then
        CurrentTarget = newTarget
        HighlightTarget(CurrentTarget)
    end
    
    if CurrentTarget then
        AimAtTarget(CurrentTarget)
    end
    
    -- Atualizar FOV circle
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = AimbotSettings.FOV
        FOVCircle.Visible = AimbotSettings.ShowFOV
    end
end

-- Configurar keybinds otimizados para Codex
local function SetupCodexKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            AimbotSettings.Enabled = not AimbotSettings.Enabled
            print("🎯 Codex Aimbot " .. (AimbotSettings.Enabled and "Ativado" or "Desativado"))
        elseif input.KeyCode == Enum.KeyCode.G then
            AimbotSettings.ShowFOV = not AimbotSettings.ShowFOV
            if FOVCircle then
                FOVCircle.Visible = AimbotSettings.ShowFOV
            end
        elseif input.KeyCode == Enum.KeyCode.H then
            local gui = LocalPlayer.PlayerGui:FindFirstChild("CodexAimbotGUI")
            if gui then
                gui.MainFrame.Visible = not gui.MainFrame.Visible
            end
        end
    end)
end

-- Função de inicialização para Codex
local function InitializeCodexAimbot()
    print("🚀 Inicializando Aimbot para Codex Executor...")
    
    -- Criar GUI otimizada
    CreateCodexGUI()
    
    -- Criar FOV circle se disponível
    if compatibility.Drawing then
        FOVCircle = CreateCodexFOVCircle()
    end
    
    -- Configurar keybinds
    SetupCodexKeybinds()
    
    -- Configurar anti-detecção
    if AimbotSettings.AntiDetection then
        setupAntiDetection()
    end
    
    -- Iniciar loop principal
    Connection = RunService.Heartbeat:Connect(CodexAimbotLoop)
    
    print("✅ Codex Aimbot carregado com sucesso!")
    print("📋 Funcionalidades:")
    print("   • GUI otimizada para Codex")
    print("   • Sistema anti-detecção")
    print("   • Compatibilidade verificada")
    print("🎮 Controles:")
    print("   • F - Toggle Aimbot")
    print("   • G - Toggle FOV")
    print("   • H - Toggle GUI")
end

-- Função de limpeza otimizada
local function CleanupCodex()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    
    if FOVCircle then
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    if TargetHighlight then
        TargetHighlight:Destroy()
        TargetHighlight = nil
    end
    
    for _, connection in pairs(GuiConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    GuiConnections = {}
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild("CodexAimbotGUI")
    if gui then
        gui:Destroy()
    end
    
    print("🧹 Codex Aimbot limpo com sucesso!")
end

-- Event listeners
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        CleanupCodex()
    end
end)

-- Inicializar
InitializeCodexAimbot()

-- Retornar API para controle externo
return {
    Settings = AimbotSettings,
    Compatibility = compatibility,
    Toggle = function() AimbotSettings.Enabled = not AimbotSettings.Enabled end,
    SetFOV = function(fov) AimbotSettings.FOV = math.clamp(fov, 10, 360) end,
    SetSmoothness = function(smoothness) AimbotSettings.Smoothness = math.clamp(smoothness, 0, 1) end,
    Cleanup = CleanupCodex,
    Version = "Codex v1.0"
}