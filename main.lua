local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local _G_GhostyRunning = true

if CoreGui:FindFirstChild("GhostyMenu") then CoreGui.GhostyMenu:Destroy() end
if Lighting:FindFirstChild("GhostyBlur") then Lighting.GhostyBlur:Destroy() end

local GhostyMenu = Instance.new("ScreenGui")
GhostyMenu.Name = "GhostyMenu"
GhostyMenu.Parent = CoreGui
GhostyMenu.ResetOnSpawn = false
GhostyMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Blur = Instance.new("BlurEffect")
Blur.Name = "GhostyBlur"
Blur.Size = 14
Blur.Enabled = true
Blur.Parent = Lighting

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 760, 0, 500)
MainFrame.Position = UDim2.new(0.5, -380, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = GhostyMenu

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 35, 42)

-- Сайдбар
local LeftPanel = Instance.new("Frame", MainFrame)
LeftPanel.Size = UDim2.new(0, 180, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
LeftPanel.BorderSizePixel = 0
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)

local LeftHide = Instance.new("Frame", LeftPanel)
LeftHide.Size = UDim2.new(0, 20, 1, 0)
LeftHide.Position = UDim2.new(1, -20, 0, 0)
LeftHide.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
LeftHide.BorderSizePixel = 0

local Logo = Instance.new("TextLabel", LeftPanel)
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.BackgroundTransparency = 1
Logo.Text = "GHOSTY"
Logo.TextColor3 = Color3.fromRGB(45, 140, 255)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold

local TabContainer = Instance.new("Frame", LeftPanel)
TabContainer.Position = UDim2.new(0, 15, 0, 75)
TabContainer.Size = UDim2.new(1, -30, 1, -90)
TabContainer.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.Padding = UDim.new(0, 8)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Контентная зона
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 195, 0, 20)
Content.Size = UDim2.new(1, -215, 1, -40)
Content.BackgroundTransparency = 1

local Pages = {}
local categories = {"AIM", "RENDER", "MISC", "CONFIG"}

-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ
_G.GhostyConfig = {
    EspEnabled = false,
    EspBoxes2D = false,
    EspBoxes3D = false,
    EspLines = false,
    EspNames = false,
    EspHealth = false,
    EspDistance = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    FillColor = Color3.fromRGB(255, 255, 255),
    BoxTransparency = 0,
    FillTransparency = 0.5,
    FillEnabled = false,
    
    ChamsEnabled = false,
    ChamsFillColor = Color3.fromRGB(45, 140, 255),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsFillTransparency = 0.5,
    ChamsOutlineTransparency = 0,
    ChamsVisibleOnly = false
}

for _, catName in ipairs(categories) do
    local Page = Instance.new("ScrollingFrame", Content)
    Page.Name = catName.."_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (catName == "AIM")
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(45, 140, 255)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 15)
    Pages[catName] = Page
end

-- Функция создания подкатегории (Секции)
local function CreateSubCategory(parent, title)
    local Section = Instance.new("Frame", parent)
    Section.Size = UDim2.new(1, -5, 0, 40)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Section).Color = Color3.fromRGB(28, 28, 35)
    
    local SecTitle = Instance.new("TextLabel", Section)
    SecTitle.Size = UDim2.new(1, -15, 0, 30)
    SecTitle.Position = UDim2.new(0, 15, 0, 5)
    SecTitle.BackgroundTransparency = 1
    SecTitle.Text = title:upper()
    SecTitle.TextColor3 = Color3.fromRGB(45, 140, 255)
    SecTitle.TextSize = 11
    SecTitle.Font = Enum.Font.GothamBold
    SecTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local Container = Instance.new("Frame", Section)
    Container.Position = UDim2.new(0, 15, 0, 35)
    Container.Size = UDim2.new(1, -30, 0, 5)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BackgroundTransparency = 1
    Instance.new("UIListLayout", Container).Padding = UDim.new(0, 6)
    
    return Container
end

-- Элемент: Переключатель (Toggle)
local function CreateToggle(parent, text, configKey, callback)
    local ToggleFrame = Instance.new("TextButton", parent)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Text = ""
    
    local Box = Instance.new("Frame", ToggleFrame)
    Box.Size = UDim2.new(0, 16, 0, 16)
    Box.Position = UDim2.new(0, 0, 0.5, -8)
    Box.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Position = UDim2.new(0, 26, 0, 0)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(170, 170, 175)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleFrame.MouseButton1Click:Connect(function()
        _G.GhostyConfig[configKey] = not _G.GhostyConfig[configKey]
        local state = _G.GhostyConfig[configKey]
        TweenService:Create(Box, TweenInfo.new(0.12), {BackgroundColor3 = state and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(28, 28, 35)}):Play()
        TweenService:Create(Label, TweenInfo.new(0.12), {TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 175)}):Play()
        if callback then callback(state) end
    end)
end

-- Элемент: Ползунок (Slider)
local function CreateSlider(parent, text, min, max, default, configKey, decimals)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(170, 170, 175)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Track = Instance.new("TextButton", SliderFrame)
    Track.Position = UDim2.new(0, 0, 0, 24)
    Track.Size = UDim2.new(1, 0, 0, 6)
    Track.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    Track.Text = ""
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 3)
    
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(45, 140, 255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)
    
    local function update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pos
        if decimals then val = math.round(val * 10) / 10 else val = math.round(val) end
        _G.GhostyConfig[configKey] = val
        Label.Text = text .. ": " .. tostring(val)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
    end
    
    local sliding = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
end

-- =======================================================
-- НАПОЛНЕНИЕ ПОДКАТЕГОРИЙ (ПАНЕЛЬ РЕНДЕРА)
-- =======================================================
local EspSub = CreateSubCategory(Pages["RENDER"], "ESP Settings (Настройки отрисовки)")
CreateToggle(EspSub, "Master Switch (Включить ESP)", "EspEnabled")
CreateToggle(EspSub, "2D Boxes (Плоские боксы)", "EspBoxes2D")
CreateToggle(EspSub, "3D Boxes (Объемные боксы)", "EspBoxes3D")
CreateToggle(EspSub, "Fill Box (Заливка внутренностей)", "FillEnabled")
CreateToggle(EspSub, "Snap Lines (Линии до игроков)", "EspLines")
CreateToggle(EspSub, "Show Names (Никнеймы)", "EspNames")
CreateToggle(EspSub, "Health Bar (Здоровье)", "EspHealth")
CreateToggle(EspSub, "Distance (Дистанция)", "EspDistance")
CreateSlider(EspSub, "Box Transparency (Прозрачность рамок)", 0, 1, 0, "BoxTransparency", true)
CreateSlider(EspSub, "Fill Transparency (Прозрачность заливки)", 0, 1, 0.5, "FillTransparency", true)

local ChamsSub = CreateSubCategory(Pages["RENDER"], "Chams Settings (Подсветка моделей)")
CreateToggle(ChamsSub, "Enable Chams", "ChamsEnabled")
CreateToggle(ChamsSub, "Visible Only (Только за стеной)", "ChamsVisibleOnly")
CreateSlider(ChamsSub, "Chams Transparency", 0, 1, 0.5, "ChamsFillTransparency", true)

-- Категории переключение
local activeTab = "AIM"
local tabButtons = {}

local function SwitchTab(target)
    activeTab = target
    for name, page in pairs(Pages) do page.Visible = (name == target) end
    for name, btn in pairs(tabButtons) do
        local act = (name == target)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = act and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(11, 11, 13), TextColor3 = act and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(130, 130, 135)}):Play()
    end
end

for id, catName in ipairs(categories) do
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = (catName == "AIM") and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(11, 11, 13)
    Btn.BorderSizePixel = 0
    Btn.Text = "  " .. catName
    Btn.TextColor3 = (catName == "AIM") and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(130, 130, 135)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = id
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    
    tabButtons[catName] = Btn
    Btn.MouseButton1Click:Connect(function() SwitchTab(catName) end)
end

-- =======================================================
-- НОВОЕ ИСПРАВЛЕННОЕ ПЕРЕТАСКИВАНИЕ МЫШКОЙ (БЕЗ ОШИБОК)
-- =======================================================
local dragToggle = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Хоткеи
local KeyConnection
KeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        Blur.Enabled = MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F10 then
        _G_GhostyRunning = false
        if KeyConnection then KeyConnection:Disconnect() end
        GhostyMenu:Destroy()
        Blur:Destroy()
        print("[GHOSTY] Читы полностью выгружены.")
    end
end)

-- ПОДГРУЗКА ВНЕШНИХ МОДУЛЕЙ (С ОТСЛЕЖИВАНИЕМ ОШИБОК)
task.spawn(function()
    print("[GHOSTY] Начинаем загрузку модулей рендера...")
    
    local espSuccess, espError = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bblodik/GhostyRustRemake/main/ESP.lua"))()
    end)
    if espSuccess then
        print("[GHOSTY] Модуль ESP.lua успешно загружен!")
    else
        warn("[GHOSTY] Ошибка загрузки ESP.lua: ", espError)
    end

    local chamsSuccess, chamsError = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bblodik/GhostyRustRemake/main/chams.lua"))()
    end)
    if chamsSuccess then
        print("[GHOSTY] Модуль chams.lua успешно загружен!")
    else
        warn("[GHOSTY] Ошибка загрузки chams.lua: ", chamsError)
    end
end)
