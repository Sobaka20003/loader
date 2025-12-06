-- list.lua (список игроков с расстоянием)
local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local localplr = plrs.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "ИГРОКИ [0]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -10, 1, -40)
PlayerList.Position = UDim2.new(0, 5, 0, 35)
PlayerList.BackgroundTransparency = 1
PlayerList.ScrollBarThickness = 4
PlayerList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = PlayerList

local playerFrames = {}

local function createPlayerFrame(player)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 25)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.3
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0.4, 0, 1, 0)
    distLabel.Position = UDim2.new(0.6, 0, 0, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.Font = Enum.Font.SourceSans
    distLabel.TextSize = 12
    distLabel.TextXAlignment = Enum.TextXAlignment.Right
    distLabel.Parent = frame
    
    local teamColor = Instance.new("Frame")
    teamColor.Size = UDim2.new(0, 4, 1, 0)
    teamColor.BackgroundColor3 = player.Team == localplr.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    teamColor.Parent = frame
    
    playerFrames[player] = frame
    frame.Parent = PlayerList
end

local function updateList()
    local count = 0
    for _, player in pairs(plrs:GetPlayers()) do
        if player ~= localplr then
            if not playerFrames[player] then
                createPlayerFrame(player)
            end
            count = count + 1
            
            local frame = playerFrames[player]
            if frame then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and localplr.Character and localplr.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - localplr.Character.HumanoidRootPart.Position).Magnitude
                    local distText = string.format("%.0f studs", distance)
                    frame:FindFirstChild("TextLabel", true).Text = distText
                else
                    frame:FindFirstChild("TextLabel", true).Text = "N/A"
                end
            end
        end
    end
    Title.Text = "ИГРОКИ ["..count.."]"
    
    for player, frame in pairs(playerFrames) do
        if not plrs:FindFirstChild(player.Name) then
            frame:Destroy()
            playerFrames[player] = nil
        end
    end
end

for _, player in pairs(plrs:GetPlayers()) do
    if player ~= localplr then
        createPlayerFrame(player)
    end
end

plrs.PlayerAdded:Connect(function(player)
    if player ~= localplr then
        createPlayerFrame(player)
    end
end)

plrs.PlayerRemoving:Connect(function(player)
    if playerFrames[player] then
        playerFrames[player]:Destroy()
        playerFrames[player] = nil
    end
end)

run.RenderStepped:Connect(updateList)

PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)
