-- Script Local para Roblox: Aimbot com UI Persistente
-- Coloque em StarterPlayerScripts para não sumir no respawn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cria ou recupera a GUI de forma segura
local function getOrCreateGui()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("AimbotGUI")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "AimbotGUI"
        gui.ResetOnSpawn = false -- ESSENCIAL: Não sumir ao morrer!
        gui.Parent = LocalPlayer.PlayerGui
    end
    return gui
end

local aimbotActive = false
local targetPlayer = nil
local playerList = {}
local playerIndex = 1

local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            table.insert(playerList, player)
        end
    end
    if #playerList == 0 then
        targetPlayer = nil
        playerIndex = 1
    else
        if playerIndex > #playerList then playerIndex = 1 end
        targetPlayer = playerList[playerIndex]
    end
end

local function nextPlayer()
    if #playerList == 0 then targetPlayer = nil; return end
    playerIndex = playerIndex + 1
    if playerIndex > #playerList then playerIndex = 1 end
    targetPlayer = playerList[playerIndex]
end

local function updateSwitchButtonText(switchButton)
    if targetPlayer then
        switchButton.Text = "Alvo: " .. targetPlayer.Name
    else
        switchButton.Text = "Nenhum alvo"
    end
end

local function aimbot()
    if not (aimbotActive and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head")) then return end
    local cam = workspace.CurrentCamera
    local headPos = targetPlayer.Character.Head.Position
    local camPos = cam.CFrame.Position
    local newCFrame = CFrame.new(camPos, headPos)
    cam.CFrame = cam.CFrame:Lerp(newCFrame, 0.2)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Criação da UI (uma vez só!)
local ScreenGui = getOrCreateGui()

local toggleButton = ScreenGui:FindFirstChild("ToggleButton") or Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(1, -130, 0, 10)
toggleButton.AnchorPoint = Vector2.new(0,0)
toggleButton.Text = "Aimbot: OFF"
toggleButton.Parent = ScreenGui
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true

local switchButton = ScreenGui:FindFirstChild("SwitchButton") or Instance.new("TextButton")
switchButton.Name = "SwitchButton"
switchButton.Size = UDim2.new(0, 120, 0, 40)
switchButton.Position = UDim2.new(1, -130, 0, 60)
switchButton.AnchorPoint = Vector2.new(0,0)
switchButton.Parent = ScreenGui
switchButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
switchButton.TextColor3 = Color3.new(1,1,1)
switchButton.BorderSizePixel = 0
switchButton.AutoButtonColor = true

updatePlayerList()
updateSwitchButtonText(switchButton)

toggleButton.MouseButton1Click:Connect(function()
    aimbotActive = not aimbotActive
    toggleButton.Text = aimbotActive and "Aimbot: ON" or "Aimbot: OFF"
end)

switchButton.MouseButton1Click:Connect(function()
    nextPlayer()
    updateSwitchButtonText(switchButton)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        aimbotActive = not aimbotActive
        toggleButton.Text = aimbotActive and "Aimbot: ON" or "Aimbot: OFF"
    elseif input.KeyCode == Enum.KeyCode.G then
        nextPlayer()
        updateSwitchButtonText(switchButton)
    end
end)

RunService.RenderStepped:Connect(aimbot)

while true do
    updatePlayerList()
    wait(2)
end
