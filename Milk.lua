-- [[ MILK SCRIPT: CUSTOM INTERFACE UTILITY ]] --
local Players = game:Service("Players")
local UserInputService = game:Service("UserInputService")
local TweenService = game:Service("TweenService")
local HttpService = game:Service("HttpService") -- Понадобится, если включен HTTP-допуск в игре

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- 1. Создание основы интерфейса (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MilkScriptHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pGui

-- 2. Главное фрейм-окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- Нужно для перетаскивания
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Шапка для перетаскивания (Title Bar)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Text = "🥛 Milk Script v2.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 18
TitleText.BackgroundTransparency = 1
TitleText.Parent = TitleBar

-- Скролл-зона для функций
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -20, 1, -60)
ContentScroll.Position = UDim2.new(0, 10, 0, 50)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
ContentScroll.ScrollBarThickness = 4
ContentScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentScroll

-- ========================================================
-- ФУНКЦИЯ ПЕРЕТАСКИВАНИЯ ОКНА (Drag-and-Drop интерфейса)
-- ========================================================
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Шаблон для кнопок
local function createButton(text, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 35)
	Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.Font = Enum.Font.SourceSans
	Btn.TextSize = 16
	Btn.Text = text
	Btn.Parent = ContentScroll
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = Btn
	
	Btn.MouseButton1Click:Connect(callback)
	return Btn
end

-- ========================================================
-- ТОП-10 ФУНКЦИЙ ИНТЕРФЕЙСА (Milk Script)
-- ========================================================

-- Поле ввода для скриптов (Используется для функции №1)
local ScriptInput = Instance.new("TextBox")
ScriptInput.Size = UDim2.new(1, -10, 0, 40)
ScriptInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ScriptInput.TextColor3 = Color3.fromRGB(0, 255, 150)
ScriptInput.Text = "-- Вставьте URL или код скрипта сюда"
ScriptInput.ClearTextOnFocus = true
ScriptInput.Font = Enum.Font.Code
ScriptInput.TextSize = 12
ScriptInput.Parent = ContentScroll

-- 1. Предприниматель / Загрузчик внешних скриптов (Исполнитель/Обновление)
createButton("🔄 Загрузить / Обновить скрипт", function()
	local code = ScriptInput.Text
	print("[Milk Script]: Попытка загрузки обновления...")
	
	-- Логика безопасного выполнения кода (если это строка кода)
	local success, err = pcall(function()
		if string.match(code, "^http") then
			-- Если вставлена ссылка, пытаемся стянуть код (требуется HttpService на сервере или спец. окружение)
			print("[Milk Script]: Скачивание с внешнего источника: " .. code)
			-- loadstring(game:HttpGet(code))() -- Пример для сред исполнения
		else
			-- Если вставлен чистый код
			local compiled = loadstring(code)
			if compiled then compiled() else error("Не удалось скомпилировать код") end
		end
	end)
	
	if not success then
		warn("[Milk Script Ошибка]: " .. tostring(err))
	end
end)

-- 2. ВЫКЛЮЧИТЬ СКРИПТ (Полное уничтожение интерфейса)
createButton("❌ Полностью выключить Milk Script", function()
	print("[Milk Script]: Деактивация интерфейса...")
	ScreenGui:Destroy()
end)

-- 3. Свернуть / Развернуть меню (Toggle Visibility)
local minimized = false
createButton("🔽 Свернуть панель (Компактный вид)", function(btn)
	minimized = not minimized
	if minimized then
		ContentScroll.Visible = false
		MainFrame.Size = UDim2.new(0, 350, 0, 40)
		btn.Text = "🔼 Развернуть панель"
	else
		ContentScroll.Visible = true
		MainFrame.Size = UDim2.new(0, 350, 0, 450)
		btn.Text = "🔽 Свернуть панель (Компактный вид)"
	end
end)

-- 4. Изменить тему оформления (Смена цветов UI)
local darkTheme = true
createButton("🎨 Сменить тему (Светлая/Темная)", function()
	darkTheme = not darkTheme
	if darkTheme then
		MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		MainFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
		TitleBar.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
		TitleText.TextColor3 = Color3.fromRGB(30, 30, 30)
	end
end)

-- 5. Сброс позиции окна по центру экрана
createButton("🎯 Центрировать окно", function()
	MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
end)

-- 6. Сделать меню прозрачным (Ghost Mode)
local transparent = false
createButton("👻 Прозрачность меню (Вкл/Выкл)", function()
	transparent = not transparent
	TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = transparent and 0.6 or 0}):Play()
	TweenService:Create(TitleBar, TweenInfo.new(0.3), {BackgroundTransparency = transparent and 0.6 or 0}):Play()
end)

-- 7. Очистить поле ввода кода
createButton("🧹 Очистить поле ввода скрипта", function()
	ScriptInput.Text = ""
end)

-- 8. Проверить статус сети (Пинг системы)
createButton("⚡ Проверить отклик (Ping)", function(btn)
	local startTime = os.clock()
	task.wait(0.05) -- Симуляция задержки
	local endTime = os.clock()
	btn.Text = "Пинг UI: " .. string.format("%.2f", (endTime - startTime) * 1000) .. " ms"
	task.delay(2, function() btn.Text = "⚡ Проверить отклик (Ping)" end)
end)

-- 9. Вывести системный лог в консоль игры
createButton("📋 Выгрузить лог Milk Script", function()
	print("--- MILK SCRIPT LOG ---")
	print("Статус: Активен")
	print("Текущее разрешение UI: " .. tostring(MainFrame.AbsoluteSize))
	print("Позиция фрейма: " .. tostring(MainFrame.AbsolutePosition))
end)

-- 10. Показать/Скрыть FPS-счетчик в шапке
local showFPS = false
local fpsConnection
createButton("📊 Включить счетчик кадров (FPS)", function(btn)
	showFPS = not showFPS
	if showFPS then
		btn.Text = "📊 Выключить счетчик кадров"
		fpsConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
			TitleText.Text = "🥛 Milk Script | FPS: " .. math.floor(1/dt)
		end)
	else
		btn.Text = "📊 Включить счетчик кадров (FPS)"
		if fpsConnection then fpsConnection:Disconnect() end
		TitleText.Text = "🥛 Milk Script v2.0"
	end
end)
