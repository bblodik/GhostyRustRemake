local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Переменная для контроля работы всех циклов чита
local _G_GhostyRunning = true

-- Чистка старых копий перед запуском
if CoreGui:FindFirstChild("GhostyMenu") then CoreGui.GhostyMenu:Destroy() end
if Lighting:FindFirstChild("GhostyBlur") then Lighting.GhostyBlur:Destroy() end

-- Создание основы интерфейса
local GhostyMenu = Instance.new("ScreenGui")
GhostyMenu.Name = "GhostyMenu"
GhostyMenu.Parent = CoreGui
GhostyMenu.ResetOnSpawn = false
GhostyMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Размытие заднего фона
local Blur = Instance.new("BlurEffect")
Blur.Name = "GhostyBlur"
Blur.Size = 14
Blur.Enabled = true
Blur.Parent = Lighting

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 740, 0, 460)
MainFrame.Position = UDim2.new(0.5, -370, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = GhostyMenu

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 42)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- =======================================================
-- САЙДБАР (ЛЕВАЯ ПАНЕЛЬ)
-- =======================================================
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 180, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 10)
LeftCorner.Parent = LeftPanel

local LeftHide = Instance.new("Frame")
LeftHide.Size = UDim2.new(0, 20, 1, 0)
LeftHide.Position = UDim2.new(1, -20, 0, 0)
LeftHide.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
LeftHide.BorderSizePixel = 0
LeftHide.Parent = LeftPanel

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.BackgroundTransparency = 1
Logo.Text = "GHOSTY"
Logo.TextColor3 = Color3.fromRGB(45, 140, 255)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold
Logo.Parent = LeftPanel

local TabContainer = Instance.new("Frame")
TabContainer.Position = UDim2.new(0, 15, 0, 75)
TabContainer.Size = UDim2.new(1, -30, 1, -90)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = LeftPanel

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 8) -- ИСПРАВЛЕНО: Свойство настроено корректно
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabContainer

-- =======================================================
-- СТРАНИЦЫ И НАСТРОЙКИ
-- =======================================================
local Content = Instance.new("Frame")
Content.Position = UDim2.new(0, 195, 0, 20)
Content.Size = UDim2.new(1, -215, 1, -40)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Pages = {}
local categories = {"AIM", "RENDER", "MISC", "CONFIG"}

-- Таблица состояний функций
local GhostySettings = {
    NetworkJammer = false,
    ChatSpamJam = false,
    VisualJammer = false,
    SilentAim = false,
    SmoothAim = false,
    BoxEsp = false,
    Chams = false
}

for _, catName in ipairs(categories) do
    local Page = Instance.new("ScrollingFrame")
    Page.Name = catName.."_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (catName == "AIM")
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(45, 140, 255)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Parent = Content
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 15) -- ИСПРАВЛЕНО
    PageLayout.Parent = Page
    
    Pages[catName] = Page
end

-- Функция создания красивой карточки (секции)
local function CreateSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, -5, 0, 40)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Section.Parent = parent
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(28, 28, 35)
    stroke.Parent = Section
    
    local SecTitle = Instance.new("TextLabel")
    SecTitle.Size = UDim2.new(1, -15, 0, 30)
    SecTitle.Position = UDim2.new(0, 15, 0, 5)
    SecTitle.BackgroundTransparency = 1
    SecTitle.Text = title:upper()
    SecTitle.TextColor3 = Color3.fromRGB(120, 120, 130)
    SecTitle.TextSize = 12
    SecTitle.Font = Enum.Font.GothamBold
    SecTitle.TextXAlignment = Enum.TextXAlignment.Left
    SecTitle.Parent = Section
    
    local Container = Instance.new("Frame")
    Container.Position = UDim2.new(0, 15, 0, 35)
    Container.Size = UDim2.new(1, -30, 0, 5)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BackgroundTransparency = 1
    Container.Parent = Section
    
    local ContainerLayout = Instance.new("UIListLayout")
    ContainerLayout.Padding = UDim.new(0, 8) -- ИСПРАВЛЕНО
    ContainerLayout.Parent = Container
    
    return Container
end

-- Функция создания Чекбокса (Toggle)
local function CreateToggle(parent, text, settingName, callback)
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Text = ""
    ToggleFrame.Parent = parent
    
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 18, 0, 18)
    Box.Position = UDim2.new(0, 0, 0.5, -9)
    Box.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    Box.BorderSizePixel = 0
    Box.Parent = ToggleFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 190, 195)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    local function updateVisual(state)
        if state then
            TweenService:Create(Box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 140, 255)}):Play()
            TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        else
            TweenService:Create(Box, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 35)}):Play()
            TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(190, 190, 195)}):Play()
        end
    end
    
    ToggleFrame.MouseButton1Click:Connect(function()
        GhostySettings[settingName] = not GhostySettings[settingName]
        updateVisual(GhostySettings[settingName])
        if callback then callback(GhostySettings[settingName]) end
    end)
    
    ToggleFrame.MouseEnter:Connect(function()
        TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    ToggleFrame.MouseLeave:Connect(function()
        if not GhostySettings[settingName] then
            TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(190, 190, 195)}):Play()
        end
    end)
end

-- =======================================================
-- НАПОЛНЕНИЕ ФУНКЦИЯМИ
-- =======================================================

-- MISC (Глушилки)
local JammerSection = CreateSection(Pages["MISC"], "Server & Network Jammers")

CreateToggle(JammerSection, "Network Jammer", "NetworkJammer", function(state)
    if state then print("Network Jammer запущен") end
end)

CreateToggle(JammerSection, "Chat Jammer (Спам-глушилка)", "ChatSpamJam", function(state)
    task.spawn(function()
        while _G_GhostyRunning and GhostySettings.ChatSpamJam do
            local ChatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if ChatEvents and ChatEvents:FindFirstChild("SayMessageRequest") then
                ChatEvents.SayMessageRequest:FireServer("▓▒░ GHOSTY JAMMER ░▒▓", "All")
            end
            task.wait(0.3)
        end
    end)
end)

CreateToggle(JammerSection, "Visual Lag Jammer", "VisualJammer")

-- AIM
local AimSection = CreateSection(Pages["AIM"], "Combat Settings")
CreateToggle(AimSection, "Silent Aimbot", "SilentAim")
CreateToggle(AimSection, "Smooth Lock", "SmoothAim")

-- RENDER
local RenderSection = CreateSection(Pages["RENDER"], "Visuals")
CreateToggle(RenderSection, "Boxes ESP", "BoxEsp")
CreateToggle(RenderSection, "Chams", "Chams")

-- CONFIG
local ConfigSection = CreateSection(Pages["CONFIG"], "Profiles")

-- =======================================================
-- ОТРИСОВКА И ПЕРЕКЛЮЧЕНИЕ КАТЕГОРИЙ
-- =======================================================
local activeTab = "AIM"
local tabButtons = {}

local function SwitchTab(target)
    activeTab = target
    for name, page in pairs(Pages) do 
        page.Visible = (name == target) 
    end
    
    for name, btn in pairs(tabButtons) do
        if name == target then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 30), TextColor3 = Color3.fromRGB(45, 140, 255)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(11, 11, 13), TextColor3 = Color3.fromRGB(130, 130, 135)}):Play()
        end
    end
end

-- Генерация кнопок категорий
for id, catName in ipairs(categories) do
    local Btn = Instance.new("TextButton")
    Btn.Name = catName.."_TabBtn"
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = (catName == "AIM") and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(11, 11, 13)
    Btn.BorderSizePixel = 0
    Btn.Text = "  " .. catName
    Btn.TextColor3 = (catName == "AIM") and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(130, 130, 135)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = id 
    Btn.Parent = TabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = Btn
    
    tabButtons[catName] = Btn
    
    Btn.MouseButton1Click:Connect(function() 
        SwitchTab(catName) 
    end)
end

-- =======================================================
-- ПЕРЕТАСКИВАНИЕ МЫШКОЙ (Drag)
-- =======================================================
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseBehavior and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- =======================================================
-- ХОТКЕИ: ВЫГРУЗ (F10) И ОТКРЫТИЕ (INSERT)
-- =======================================================
local KeyConnection
KeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- INSERT: Скрытие / Показ меню и блюра
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        Blur.Enabled = MainFrame.Visible
    
    -- F10: Полная выгрузка софта
    elseif input.KeyCode == Enum.KeyCode.F10 then
        _G_GhostyRunning = false 
        
        if KeyConnection then 
            KeyConnection:Disconnect() 
        end
        
        GhostyMenu:Destroy()
        Blur:Destroy()
        
        print("[GHOSTY] Читы полностью выгружены из памяти.")
    end
end)
