--[[
    Universal Remote Spy + Executor
    Работает на большинстве игр (если нет античита на :GetRemoteEvent())
    Открытие GUI: Кнопка в левом верхнем углу или клавиша "Ins" (Insert)
    Кнопку можно перетаскивать мышкой
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local userInputService = game:GetService("UserInputService")

-- Создаём ScreenGui в CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteSpyTool"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Главная кнопка открытия (теперь её можно перетаскивать)
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.Image = "rbxassetid://6023426968" -- шестерёнка
toggleBtn.Parent = gui

-- Добавляем обводку для кнопки (чтобы было видно границы)
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Thickness = 1
btnStroke.Transparency = 0.8
btnStroke.Parent = toggleBtn

-- Переменные для перетаскивания кнопки
local btnDragging = false
local btnDragStart = nil
local btnStartPos = nil

-- Обработка перетаскивания кнопки
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = toggleBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                btnDragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if btnDragging then
            local delta = input.Position - btnDragStart
            local newX = btnStartPos.X.Offset + delta.X
            local newY = btnStartPos.Y.Offset + delta.Y
            
            -- Ограничиваем позицию, чтобы кнопка не выходила за пределы экрана
            newX = math.clamp(newX, 0, userInputService.AbsoluteSize.X - toggleBtn.AbsoluteSize.X)
            newY = math.clamp(newY, 0, userInputService.AbsoluteSize.Y - toggleBtn.AbsoluteSize.Y)
            
            toggleBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

-- Основное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "Remote Spy & Executor"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = mainFrame

-- Поисковая строка
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -10, 0, 25)
searchBox.Position = UDim2.new(0, 5, 0, 35)
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderText = "Поиск ремоутов..."
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = mainFrame

-- Список ремоутов (ScrollingFrame)
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -10, 1, -100)
listFrame.Position = UDim2.new(0, 5, 0, 65)
listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
listFrame.BorderSizePixel = 0
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.ScrollBarThickness = 8
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = listFrame

-- Панель вызова
local execFrame = Instance.new("Frame")
execFrame.Size = UDim2.new(1, -10, 0, 80)
execFrame.Position = UDim2.new(0, 5, 1, -90)
execFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
execFrame.Visible = false
execFrame.Parent = mainFrame

local remoteNameLabel = Instance.new("TextLabel")
remoteNameLabel.Size = UDim2.new(1, 0, 0, 20)
remoteNameLabel.Text = "Выбран: none"
remoteNameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
remoteNameLabel.BackgroundTransparency = 1
remoteNameLabel.Parent = execFrame

local argBox = Instance.new("TextBox")
argBox.Size = UDim2.new(1, -70, 0, 30)
argBox.Position = UDim2.new(0, 0, 0, 25)
argBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
argBox.TextColor3 = Color3.fromRGB(255, 255, 255)
argBox.PlaceholderText = "Аргументы через запятую (например: 1, 'text', true, CFrame.new(0,0,0))"
argBox.TextXAlignment = Enum.TextXAlignment.Left
argBox.ClearTextOnFocus = true
argBox.Parent = execFrame

local fireBtn = Instance.new("TextButton")
fireBtn.Size = UDim2.new(0, 60, 0, 30)
fireBtn.Position = UDim2.new(1, -65, 0, 25)
fireBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
fireBtn.Text = "Fire"
fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fireBtn.Parent = execFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 60)
statusLabel.Text = "Статус: готов"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.TextSize = 11
statusLabel.Parent = execFrame

-- Данные
local remotes = {} -- {name, object, type, path}
local selectedRemote = nil

-- Функция сканирования всех ремоутов
local function scanRemotes()
    for i, v in pairs(remotes) do
        if v.button then v.button:Destroy() end
    end
    remotes = {}
    
    local function findRecursive(container, path)
        for _, obj in pairs(container:GetChildren()) do
            local objPath = path .. "/" .. obj.Name
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, {
                    name = obj.Name,
                    object = obj,
                    type = obj.ClassName,
                    path = objPath
                })
            end
            findRecursive(obj, objPath)
        end
    end
    
    findRecursive(game, "game")
    findRecursive(player, "player")
    
    -- Сортировка по имени
    table.sort(remotes, function(a,b) return a.name < b.name end)
    
    return #remotes
end

-- Обновление списка с поиском
local function updateList(searchText)
    -- Очищаем список
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local searchLower = searchText and searchText:lower() or ""
    local shown = 0
    
    for _, remote in pairs(remotes) do
        if searchLower == "" or remote.name:lower():find(searchLower) or remote.path:lower():find(searchLower) then
            shown = shown + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            btn.Text = remote.name .. " [" .. remote.type .. "]"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.BackgroundTransparency = 0.2
            
            -- Тултип с путём
            local tooltip = Instance.new("TextLabel")
            tooltip.Size = UDim2.new(0, 300, 0, 20)
            tooltip.Position = UDim2.new(0, 10, 0, -20)
            tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            tooltip.Text = remote.path
            tooltip.TextSize = 10
            tooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
            tooltip.Visible = false
            tooltip.Parent = btn
            
            btn.MouseEnter:Connect(function()
                tooltip.Visible = true
            end)
            btn.MouseLeave:Connect(function()
                tooltip.Visible = false
            end)
            
            btn.MouseButton1Click:Connect(function()
                selectedRemote = remote
                remoteNameLabel.Text = "Выбран: " .. remote.name .. " (" .. remote.type .. ")"
                execFrame.Visible = true
                statusLabel.Text = "Статус: выбран ремоут"
                argBox.Text = ""
            end)
            
            btn.Parent = listFrame
            remote.button = btn
        end
    end
    
    if shown == 0 then
        local noRes = Instance.new("TextLabel")
        noRes.Size = UDim2.new(1, -10, 0, 30)
        noRes.BackgroundTransparency = 1
        noRes.Text = "Ничего не найдено"
        noRes.TextColor3 = Color3.fromRGB(150, 150, 150)
        noRes.Parent = listFrame
    end
end

-- Вызов ремоута
local function fireRemote()
    if not selectedRemote then
        statusLabel.Text = "Статус: Ошибка - ремоут не выбран"
        return
    end
    
    local argsStr = argBox.Text
    local args = {}
    
    -- Парсим аргументы (упрощённо, для строк и чисел)
    if argsStr ~= "" then
        -- Очень упрощённый парсинг, для полноценного лучше loadstring, но это опасно
        -- Используем безопасный вариант: разделяем по запятой
        for token in string.gmatch(argsStr, "([^,]+)") do
            local arg = token:match("^%s*(.-)%s*$")
            -- Пробуем преобразовать в число
            local num = tonumber(arg)
            if num then
                table.insert(args, num)
            elseif arg == "true" then
                table.insert(args, true)
            elseif arg == "false" then
                table.insert(args, false)
            elseif arg:match("^'.*'$") or arg:match('^".*"$') then
                table.insert(args, arg:sub(2, -2))
            else
                table.insert(args, arg)
            end
        end
    end
    
    local success, err = pcall(function()
        if selectedRemote.object:IsA("RemoteEvent") then
            selectedRemote.object:FireServer(unpack(args))
            statusLabel.Text = "Статус: FireServer вызван с " .. #args .. " арг."
        elseif selectedRemote.object:IsA("RemoteFunction") then
            local result = selectedRemote.object:InvokeServer(unpack(args))
            statusLabel.Text = "Статус: InvokeServer -> " .. tostring(result)
        end
    end)
    
    if not success then
        statusLabel.Text = "Статус: Ошибка - " .. tostring(err)
    end
end

-- UI события
toggleBtn.MouseButton1Click:Connect(function()
    -- Проверяем, что это не перетаскивание (клик без движения)
    if not btnDragging then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            -- Пересканируем при открытии
            local count = scanRemotes()
            statusLabel.Text = "Статус: найдено " .. count .. " ремоутов"
            updateList("")
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateList(searchBox.Text)
end)

fireBtn.MouseButton1Click:Connect(fireRemote)

-- Хоткей Insert
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            local count = scanRemotes()
            statusLabel.Text = "Статус: найдено " .. count .. " ремоутов"
            updateList("")
        end
    end
end)

-- Перетаскивание окна
local dragging = false
local dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Remote Spy загружен. Нажми Ins или кнопку шестерёнки.")
print("Кнопку можно перетаскивать зажав ЛКМ и двигая мышкой.")
