-- Roblox Aimbot Script com GUI Avançada
-- AVISO: Este script é apenas para fins educacionais

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

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
    MaxDistance = 1000,
    PredictionEnabled = false,
    PredictionStrength = 0.5,
    SilentAim = false,
    TriggerBot = false,
    AutoShoot = false,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    TargetHighlight = true,
    HighlightColor = Color3.fromRGB(255, 0, 0)
}

-- Variáveis globais
local CurrentTarget = nil
local FOVCircle = nil
local TargetHighlight = nil
local Connection = nil

-- Função para criar a GUI
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AimbotGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 350, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Adicionar gradiente ao frame principal
    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = MainFrame
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    }
    Gradient.Rotation = 45
    
    -- Adicionar cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.Parent = MainFrame
    Corner.CornerRadius = UDim.new(0, 10)
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎯 Advanced Aimbot"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    
    -- Scroll Frame para as opções
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollFrame.ScrollBarThickness = 5
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = ScrollFrame
    Layout.Padding = UDim.new(0, 5)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Função para criar toggle
    local function CreateToggle(name, description, defaultValue, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Parent = ScrollFrame
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.Parent = ToggleFrame
        ToggleCorner.CornerRadius = UDim.new(0, 5)
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0, 10, 0, 5)
        ToggleLabel.Size = UDim2.new(1, -60, 0, 20)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Parent = ToggleFrame
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Position = UDim2.new(0, 10, 0, 25)
        ToggleDesc.Size = UDim2.new(1, -60, 0, 20)
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.Text = description
        ToggleDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        ToggleDesc.TextSize = 10
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 30, 0, 20)
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Text = defaultValue and "ON" or "OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 10
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.Parent = ToggleButton
        ButtonCorner.CornerRadius = UDim.new(0, 3)
        
        local isEnabled = defaultValue
        ToggleButton.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            ToggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            ToggleButton.Text = isEnabled and "ON" or "OFF"
            callback(isEnabled)
        end)
        
        return ToggleButton
    end
    
    -- Função para criar slider
    local function CreateSlider(name, description, min, max, defaultValue, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name .. "Slider"
        SliderFrame.Parent = ScrollFrame
        SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SliderFrame.Size = UDim2.new(1, 0, 0, 60)
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.Parent = SliderFrame
        SliderCorner.CornerRadius = UDim.new(0, 5)
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = name
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 14
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
        ValueLabel.Font = Enum.Font.Gotham
        ValueLabel.Text = tostring(defaultValue)
        ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local SliderDesc = Instance.new("TextLabel")
        SliderDesc.Parent = SliderFrame
        SliderDesc.BackgroundTransparency = 1
        SliderDesc.Position = UDim2.new(0, 10, 0, 25)
        SliderDesc.Size = UDim2.new(1, -20, 0, 15)
        SliderDesc.Font = Enum.Font.Gotham
        SliderDesc.Text = description
        SliderDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        SliderDesc.TextSize = 10
        SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderBar.Position = UDim2.new(0, 10, 1, -15)
        SliderBar.Size = UDim2.new(1, -20, 0, 5)
        
        local SliderBarCorner = Instance.new("UICorner")
        SliderBarCorner.Parent = SliderBar
        SliderBarCorner.CornerRadius = UDim.new(0, 2)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.Parent = SliderFill
        SliderFillCorner.CornerRadius = UDim.new(0, 2)
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderBar
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
                local mousePos = input.Position.X
                local sliderPos = SliderBar.AbsolutePosition.X
                local sliderSize = SliderBar.AbsoluteSize.X
                local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                currentValue = min + (max - min) * percentage
                
                if name == "FOV" or name == "Max Distance" then
                    currentValue = math.floor(currentValue)
                else
                    currentValue = math.floor(currentValue * 100) / 100
                end
                
                ValueLabel.Text = tostring(currentValue)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                callback(currentValue)
            end
        end)
        
        return SliderButton
    end
    
    -- Função para criar dropdown
    local function CreateDropdown(name, description, options, defaultValue, callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = name .. "Dropdown"
        DropdownFrame.Parent = ScrollFrame
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        DropdownFrame.Size = UDim2.new(1, 0, 0, 50)
        
        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.Parent = DropdownFrame
        DropdownCorner.CornerRadius = UDim.new(0, 5)
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Parent = DropdownFrame
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Position = UDim2.new(0, 10, 0, 5)
        DropdownLabel.Size = UDim2.new(0.5, 0, 0, 20)
        DropdownLabel.Font = Enum.Font.Gotham
        DropdownLabel.Text = name
        DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownLabel.TextSize = 14
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local DropdownDesc = Instance.new("TextLabel")
        DropdownDesc.Parent = DropdownFrame
        DropdownDesc.BackgroundTransparency = 1
        DropdownDesc.Position = UDim2.new(0, 10, 0, 25)
        DropdownDesc.Size = UDim2.new(1, -120, 0, 20)
        DropdownDesc.Font = Enum.Font.Gotham
        DropdownDesc.Text = description
        DropdownDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
        DropdownDesc.TextSize = 10
        DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Parent = DropdownFrame
        DropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        DropdownButton.Position = UDim2.new(1, -100, 0.5, -10)
        DropdownButton.Size = UDim2.new(0, 90, 0, 20)
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.Text = defaultValue
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextSize = 10
        
        local DropdownButtonCorner = Instance.new("UICorner")
        DropdownButtonCorner.Parent = DropdownButton
        DropdownButtonCorner.CornerRadius = UDim.new(0, 3)
        
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
        
        return DropdownButton
    end
    
    -- Criar controles da GUI
    CreateToggle("Aimbot Enabled", "Liga/desliga o aimbot principal", AimbotSettings.Enabled, function(value)
        AimbotSettings.Enabled = value
    end)
    
    CreateToggle("Team Check", "Ignora jogadores da mesma equipe", AimbotSettings.TeamCheck, function(value)
        AimbotSettings.TeamCheck = value
    end)
    
    CreateToggle("Wall Check", "Verifica se há paredes entre você e o alvo", AimbotSettings.WallCheck, function(value)
        AimbotSettings.WallCheck = value
    end)
    
    CreateToggle("Visible Check", "Só mira em alvos visíveis", AimbotSettings.VisibleCheck, function(value)
        AimbotSettings.VisibleCheck = value
    end)
    
    CreateToggle("Prediction", "Prediz movimento do alvo", AimbotSettings.PredictionEnabled, function(value)
        AimbotSettings.PredictionEnabled = value
    end)
    
    CreateToggle("Silent Aim", "Mira sem mover a câmera visualmente", AimbotSettings.SilentAim, function(value)
        AimbotSettings.SilentAim = value
    end)
    
    CreateToggle("Trigger Bot", "Atira automaticamente quando mira no alvo", AimbotSettings.TriggerBot, function(value)
        AimbotSettings.TriggerBot = value
    end)
    
    CreateToggle("Show FOV", "Mostra círculo do campo de visão", AimbotSettings.ShowFOV, function(value)
        AimbotSettings.ShowFOV = value
        if FOVCircle then
            FOVCircle.Visible = value
        end
    end)
    
    CreateToggle("Target Highlight", "Destaca o alvo atual", AimbotSettings.TargetHighlight, function(value)
        AimbotSettings.TargetHighlight = value
    end)
    
    CreateSlider("FOV", "Campo de visão do aimbot (em graus)", 10, 360, AimbotSettings.FOV, function(value)
        AimbotSettings.FOV = value
    end)
    
    CreateSlider("Smoothness", "Suavidade da mira (0 = instantâneo, 1 = muito suave)", 0, 1, AimbotSettings.Smoothness, function(value)
        AimbotSettings.Smoothness = value
    end)
    
    CreateSlider("Max Distance", "Distância máxima para detectar alvos", 100, 2000, AimbotSettings.MaxDistance, function(value)
        AimbotSettings.MaxDistance = value
    end)
    
    CreateSlider("Prediction Strength", "Força da predição de movimento", 0, 2, AimbotSettings.PredictionStrength, function(value)
        AimbotSettings.PredictionStrength = value
    end)
    
    CreateDropdown("Target Part", "Parte do corpo para mirar", {"Head", "Torso", "HumanoidRootPart"}, AimbotSettings.TargetPart, function(value)
        AimbotSettings.TargetPart = value
    end)
    
    -- Atualizar tamanho do scroll frame
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end)
    
    return ScreenGui
end

-- Função para criar círculo FOV
local function CreateFOVCircle()
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.NumSides = 50
    circle.Radius = AimbotSettings.FOV
    circle.Filled = false
    circle.Visible = AimbotSettings.ShowFOV
    circle.Color = AimbotSettings.FOVColor
    circle.Transparency = 0.5
    return circle
end

-- Função para verificar se o jogador está na mesma equipe
local function IsTeammate(player)
    if not AimbotSettings.TeamCheck then
        return false
    end
    return player.Team == LocalPlayer.Team and player.Team ~= nil
end

-- Função para verificar se há parede entre dois pontos
local function HasWallBetween(startPos, endPos, ignoreList)
    if not AimbotSettings.WallCheck then
        return false
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList or {}
    
    local raycastResult = Workspace:Raycast(startPos, (endPos - startPos).Unit * (endPos - startPos).Magnitude, raycastParams)
    return raycastResult ~= nil
end

-- Função para verificar se o alvo está visível
local function IsVisible(targetPart)
    if not AimbotSettings.VisibleCheck then
        return true
    end
    
    local camera = Workspace.CurrentCamera
    local cameraPos = camera.CFrame.Position
    local targetPos = targetPart.Position
    
    return not HasWallBetween(cameraPos, targetPos, {LocalPlayer.Character, targetPart.Parent})
end

-- Função para calcular distância
local function GetDistance(part1, part2)
    return (part1.Position - part2.Position).Magnitude
end

-- Função para verificar se está dentro do FOV
local function IsInFOV(targetPart)
    local camera = Workspace.CurrentCamera
    local screenPoint, onScreen = camera:WorldToScreenPoint(targetPart.Position)
    
    if not onScreen then
        return false
    end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
    local distance = (targetPos - mousePos).Magnitude
    
    return distance <= AimbotSettings.FOV
end

-- Função para encontrar o melhor alvo
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

-- Função para calcular predição
local function GetPredictedPosition(targetPart)
    if not AimbotSettings.PredictionEnabled then
        return targetPart.Position
    end
    
    local velocity = targetPart.Velocity
    local predictedPos = targetPart.Position + (velocity * AimbotSettings.PredictionStrength)
    return predictedPos
end

-- Função para mirar no alvo
local function AimAtTarget(target)
    if not target or not target.Character then
        return
    end
    
    local targetPart = target.Character:FindFirstChild(AimbotSettings.TargetPart)
    if not targetPart then
        return
    end
    
    local predictedPos = GetPredictedPosition(targetPart)
    local camera = Workspace.CurrentCamera
    
    if AimbotSettings.SilentAim then
        -- Silent aim - não move a câmera visualmente
        local direction = (predictedPos - camera.CFrame.Position).Unit
        -- Aqui você aplicaria o silent aim dependendo do jogo específico
    else
        -- Aim normal - move a câmera
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, predictedPos)
        
        if AimbotSettings.Smoothness > 0 then
            -- Aim suave
            local tweenInfo = TweenInfo.new(AimbotSettings.Smoothness, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local tween = TweenService:Create(camera, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        else
            -- Aim instantâneo
            camera.CFrame = targetCFrame
        end
    end
end

-- Função para destacar alvo
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
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        TargetHighlight = highlight
    end
end

-- Função principal do aimbot
local function AimbotLoop()
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
        
        -- Trigger bot
        if AimbotSettings.TriggerBot then
            -- Aqui você implementaria o sistema de tiro automático
            -- Isso depende do jogo específico
        end
    end
    
    -- Atualizar círculo FOV
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = AimbotSettings.FOV
        FOVCircle.Visible = AimbotSettings.ShowFOV
    end
end

-- Função para toggle do aimbot com tecla
local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            AimbotSettings.Enabled = not AimbotSettings.Enabled
            print("Aimbot " .. (AimbotSettings.Enabled and "Ativado" or "Desativado"))
        elseif input.KeyCode == Enum.KeyCode.G then
            AimbotSettings.ShowFOV = not AimbotSettings.ShowFOV
            if FOVCircle then
                FOVCircle.Visible = AimbotSettings.ShowFOV
            end
        elseif input.KeyCode == Enum.KeyCode.H then
            local gui = LocalPlayer.PlayerGui:FindFirstChild("AimbotGUI")
            if gui then
                gui.MainFrame.Visible = not gui.MainFrame.Visible
            end
        end
    end)
end

-- Função de inicialização
local function Initialize()
    -- Criar GUI
    CreateGUI()
    
    -- Criar círculo FOV
    if Drawing then
        FOVCircle = CreateFOVCircle()
    end
    
    -- Configurar keybinds
    SetupKeybinds()
    
    -- Iniciar loop do aimbot
    Connection = RunService.Heartbeat:Connect(AimbotLoop)
    
    print("🎯 Aimbot carregado com sucesso!")
    print("Teclas:")
    print("F - Toggle Aimbot")
    print("G - Toggle FOV Circle")
    print("H - Toggle GUI")
end

-- Função de limpeza
local function Cleanup()
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
    
    local gui = LocalPlayer.PlayerGui:FindFirstChild("AimbotGUI")
    if gui then
        gui:Destroy()
    end
end

-- Detectar quando o jogador sai do jogo
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        Cleanup()
    end
end)

-- Inicializar o script
Initialize()

-- Retornar tabela com funções úteis para controle externo
return {
    Settings = AimbotSettings,
    Toggle = function() AimbotSettings.Enabled = not AimbotSettings.Enabled end,
    SetFOV = function(fov) AimbotSettings.FOV = fov end,
    SetSmoothness = function(smoothness) AimbotSettings.Smoothness = smoothness end,
    Cleanup = Cleanup
}