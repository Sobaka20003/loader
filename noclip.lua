-- noclip.lua - NoClip с обходом серверного детекта
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Enabled = false
local NoclipConnection = nil
local OriginalVelocities = {}

-- Метод обхода детекта: смещение позиции на микро-расстояние
local function safeNoClip()
    if not Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Сохраняем оригинальные значения для восстановления
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if not OriginalVelocities[part] then
                OriginalVelocities[part] = {
                    CanCollide = part.CanCollide,
                    Velocity = part.VectorVelocity,
                    AssemblyLinearVelocity = part.AssemblyLinearVelocity
                }
            end
            
            -- Мягкое отключение коллизий (не сразу)
            part.CanCollide = false
            
            -- Добавляем микро-толчки для обхода простых детектов
            if RunService:IsClient() then
                -- На клиенте: незаметное смещение
                local microMove = Vector3.new(
                    math.random(-0.01, 0.01),
                    math.random(-0.01, 0.01),
                    math.random(-0.01, 0.01)
                )
                part.Velocity = part.Velocity + microMove
            end
        end
    end
    
    -- Метод 2: Временное изменение состояния Humanoid
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait(0.05)
        humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
    
    -- Метод 3: Периодическое "подпрыгивание" для сброса детекта
    if math.random(1, 100) < 10 then -- 10% chance
        rootPart.Velocity = rootPart.Velocity + Vector3.new(0, 0.1, 0)
    end
end

-- Основная функция NoClip
local function noclipLoop()
    while Enabled do
        safeNoClip()
        RunService.Heartbeat:Wait()
    end
end

local function enable()
    if Enabled then return end
    Enabled = true
    
    -- Подключаем соединение
    NoclipConnection = RunService.Heartbeat:Connect(safeNoClip)
    
    -- Также запускаем в отдельном потоке для надежности
    coroutine.wrap(noclipLoop)()
    
    print("NoClip включен (защита от детекта активна)")
end

local function disable()
    if not Enabled then return end
    Enabled = false
    
    -- Отключаем соединение
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    -- Восстанавливаем оригинальные значения
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and OriginalVelocities[part] then
                part.CanCollide = OriginalVelocities[part].CanCollide
                part.Velocity = OriginalVelocities[part].Velocity
                part.AssemblyLinearVelocity = OriginalVelocities[part].AssemblyLinearVelocity
            end
        end
    end
    
    -- Очищаем таблицу
    OriginalVelocities = {}
    
    print("NoClip выключен")
end

-- Модуль для управления из main.lua
local module = {}

function module.Toggle(state)
    if state == nil then
        state = not Enabled
    end
    
    if state then
        enable()
    else
        disable()
    end
    
    return Enabled
end

function module.SetEnabled(state)
    if state then
        enable()
    else
        disable()
    end
    
    return state
end

function module.Enable()
    enable()
end

function module.Disable()
    disable()
end

-- Экстренное отключение при смерти/респавне
LocalPlayer.CharacterAdded:Connect(function()
    if Enabled then
        task.wait(0.5)  -- Ждем загрузку персонажа
        enable()  -- Включаем заново
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    OriginalVelocities = {}
end)

return module
