-- Функция для включения/выключения (исправленная)
local function toggleFunction(funcName)
    local funcData = Functions[funcName]
    local funcFrame = FunctionFrames[funcName]
    
    if not funcData.Enabled then
        -- Включаем
        Status.Text = "Загрузка "..funcName.."..."
        
        local success, err = pcall(function()
            if loadScript(funcName, funcData.ScriptURL) then
                if funcData.Module then
                    -- Для NoClip используем специальную обработку
                    if funcName == "NoClip" then
                        funcData.Enabled = funcData.Module.Enable()
                    elseif funcData.Module.Toggle then
                        funcData.Module.Toggle(true)
                    elseif funcData.Module.SetEnabled then
                        funcData.Module.SetEnabled(true)
                    elseif funcData.Module.Enable then
                        funcData.Module.Enable()
                    end
                end
                funcData.Enabled = true
                funcFrame.ToggleBtn.Text = funcData.Name .. " [ON]"
                funcFrame.ToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
                Status.Text = funcName.." включен!"
            end
        end)
        
        if not success then
            Status.Text = "Ошибка: "..tostring(err)
            funcData.Enabled = false
        end
        
    else
        -- Выключаем
        local success, err = pcall(function()
            if funcData.Module then
                -- Для NoClip
                if funcName == "NoClip" then
                    funcData.Module.Disable()
                elseif funcData.Module.Toggle then
                    funcData.Module.Toggle(false)
                elseif funcData.Module.SetEnabled then
                    funcData.Module.SetEnabled(false)
                elseif funcData.Module.Disable then
                    funcData.Module.Disable()
                end
            end
            funcData.Enabled = false
            funcFrame.ToggleBtn.Text = funcData.Name .. " [OFF]"
            funcFrame.ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            Status.Text = funcData.Name .. " выключен"
        end)
        
        if not success then
            Status.Text = "Ошибка отключения: "..tostring(err)
        end
    end
end
