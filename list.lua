-- list.lua (список игроков с расстоянием и направлением)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "PlayerListUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 360)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(40, 40, 50)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "ИГРОКИ [0]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 16
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -12, 1, -50)
PlayerList.Position = UDim2.new(0, 6, 0, 46)
PlayerList.BackgroundTransparency = 1
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Parent = PlayerList

local playerFrames = {}
local function formatDistance(distance)
    if distance >= 1000 then
        return string.format("%.1fk", distance / 1000)
    else
        return string.format("%.0f", distance)
    end
end

local function calculateDirection(localRoot, targetRoot)
    if not localRoot or not targetRoot then return 0 end
    
    local lookVector = Camera.CFrame.LookVector
    local toTarget = (targetRoot.Position - localRoot.Position).Unit
    
    local dotX = lookVector:Dot(toTarget)
    local crossY = lookVector:Cross(toTarget).Y
    
    local angle = math.atan2(crossY, dotX)
    return math.deg(angle)
end

local function createPlayerFrame(player)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local teamColor = Instance.new("Frame")
    teamColor.Size = UDim2.new(0, 4, 1, -8)
    teamColor.Position = UDim2.new(0, 4, 0, 4)
    teamColor.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    teamColor.Parent = frame
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = teamColor
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.55, -10, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = frame
    
    local distanceContainer = Instance.new("Frame")
    distanceContainer.Size = UDim2.new(0.45, 0, 1, 0)
    distanceContainer.Position = UDim2.new(0.55, 0, 0, 0)
    distanceContainer.BackgroundTransparency = 1
    distanceContainer.Parent = frame
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0, 2)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "---"
    distanceLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Right
    distanceLabel.Name = "Distance"
    distanceLabel.Parent = distanceContainer
    
    local arrowContainer = Instance.new("Frame")
    arrowContainer.Size = UDim2.new(0.4, 0, 1, 0)
    arrowContainer.Position = UDim2.new(0.6, 0, 0, 0)
    arrowContainer.BackgroundTransparency = 1
    arrowContainer.Parent = distanceContainer
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.Size = UDim2.new(1, 0, 1, 0)
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Text = "⬆"
    arrowLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    arrowLabel.Font = Enum.Font.GothamSemibold
    arrowLabel.TextSize = 14
    arrowLabel.Name = "Arrow"
    arrowLabel.Parent = arrowContainer
    
    playerFrames[player] = {
        Frame = frame,
        TeamColor = teamColor,
        DistanceLabel = distanceLabel,
        ArrowLabel = arrowLabel
    }
    
    frame.Parent = PlayerList
    return frame
end

local function updateTeamColor(player, data)
    if player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            data.TeamColor.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            data.TeamColor.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        end
    else
        data.TeamColor.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

local function updatePlayerFrame(player, data)
    if not player or not player.Character then
        data.DistanceLabel.Text = "---"
        data.ArrowLabel.Text = "⬆"
        data.ArrowLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart or not localRoot then
        data.DistanceLabel.Text = "N/A"
        data.ArrowLabel.Text = "⬆"
        data.ArrowLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end
    
    local distance = (humanoidRootPart.Position - localRoot.Position).Magnitude
    data.DistanceLabel.Text = formatDistance(distance) .. " studs"
    
    local direction = calculateDirection(localRoot, humanoidRootPart)
    
    local arrowMap = {
        {0, 45, "⬆"},      -- Север
        {45, 135, "➡"},    -- Восток
        {135, 225, "⬇"},   -- Юг
        {225, 315, "⬅"},   -- Запад
        {315, 360, "⬆"}    -- Север
    }
    
    local absDir = math.abs(direction)
    if absDir > 180 then
        absDir = 360 - absDir
    end
    
    local arrowText = "⬆"
    for _, range in ipairs(arrowMap) do
        if direction >= range[1] and direction < range[2] then
            arrowText = range[3]
            break
        end
    end
    
    data.ArrowLabel.Text = arrowText
    
    local distanceColor
    if distance < 50 then
        distanceColor = Color3.fromRGB(255, 100, 100)
        data.ArrowLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
    elseif distance < 150 then
        distanceColor = Color3.fromRGB(255, 200, 100)
        data.ArrowLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    else
        distanceColor = Color3.fromRGB(100, 200, 255)
        data.ArrowLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
    end
    
    data.DistanceLabel.TextColor3 = distanceColor
end

local function updateList()
    local count = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not playerFrames[player] then
                createPlayerFrame(player)
            end
            
            local data = playerFrames[player]
            if data then
                updateTeamColor(player, data)
                updatePlayerFrame(player, data)
                count = count + 1
            end
        end
    end
    
    Title.Text = string.format("ИГРОКИ [%d]", count)
    
    for player, data in pairs(playerFrames) do
        if not Players:FindFirstChild(player.Name) then
            data.Frame:Destroy()
            playerFrames[player] = nil
        end
    end
end

local function initialize()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerFrame(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            task.wait(0.5)
            createPlayerFrame(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if playerFrames[player] then
            playerFrames[player].Frame:Destroy()
            playerFrames[player] = nil
        end
    end)
    
    local debounce = false
    RunService.RenderStepped:Connect(function()
        if debounce then return end
        debounce = true
        
        updateList()
        
        debounce = false
    end)
end

initialize()
