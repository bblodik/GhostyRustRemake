-- ============================================================
--  GhostyRustRemake | main.lua
--  Insert = показать/скрыть меню
--  F10    = полностью выгрузить чит
-- ============================================================

local Players        = game:GetService("Players")
local CoreGui        = game:GetService("CoreGui")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local HttpService    = game:GetService("HttpService")

-- ─── очистка старой копии ────────────────────────────────────
if CoreGui:FindFirstChild("GhostyMenu") then CoreGui.GhostyMenu:Destroy() end
if Lighting:FindFirstChild("GhostyBlur") then Lighting.GhostyBlur:Destroy() end

-- ─── CONFIG  (единственный источник правды) ──────────────────
_G.GhostyConfig = {
    -- ESP
    EspEnabled          = false,
    EspBoxes2D          = false,
    EspBoxes3D          = false,
    FillEnabled         = false,
    FillTransparency    = 0.6,
    EspLines            = false,
    EspNames            = false,
    EspHealth           = false,
    HealthPosition      = "Left",   -- "Left" | "Right"
    EspDistance         = false,
    BoxColor            = Color3.fromRGB(255, 255, 255),
    FillColor           = Color3.fromRGB(45, 140, 255),
    -- Chams
    ChamsEnabled            = false,
    ChamsFillColor          = Color3.fromRGB(45, 140, 255),
    ChamsOutlineColor       = Color3.fromRGB(255, 255, 255),
    ChamsFillTransparency   = 0.5,
    ChamsOutlineTransparency = 0,
    ChamsVisibleOnly        = false,
    -- World
    NoTextures = false,
}

-- ─── KEYBINDS ────────────────────────────────────────────────
_G.GhostyBinds = {}         -- configKey → KeyCode.Name
local KeybindTriggers = {}  -- configKey → function

-- ─── CONFIG I/O (pcall-safe) ─────────────────────────────────
local CONFIG_KEY = "GhostyConfig_v1"

local function SaveConfig()
    pcall(function()
        local data = {}
        for k, v in pairs(_G.GhostyConfig) do
            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                data[k] = v
            elseif typeof(v) == "Color3" then
                data[k] = {r = v.R, g = v.G, b = v.B}
            end
        end
        data["__binds"] = _G.GhostyBinds
        writefile(CONFIG_KEY .. ".json", HttpService:JSONEncode(data))
    end)
end

local function LoadConfig()
    pcall(function()
        if not isfile(CONFIG_KEY .. ".json") then return end
        local raw = readfile(CONFIG_KEY .. ".json")
        local data = HttpService:JSONDecode(raw)
        for k, v in pairs(data) do
            if k == "__binds" then
                _G.GhostyBinds = v
            elseif type(v) == "table" and v.r then
                _G.GhostyConfig[k] = Color3.new(v.r, v.g, v.b)
            elseif _G.GhostyConfig[k] ~= nil then
                _G.GhostyConfig[k] = v
            end
        end
    end)
end

LoadConfig()

-- ─── GUI ROOT ────────────────────────────────────────────────
local GhostyMenu = Instance.new("ScreenGui")
GhostyMenu.Name = "GhostyMenu"
GhostyMenu.ResetOnSpawn = false
GhostyMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GhostyMenu.Parent = CoreGui

local Blur = Instance.new("BlurEffect")
Blur.Name = "GhostyBlur"
Blur.Size = 14
Blur.Enabled = false   -- включается только когда меню видно
Blur.Parent = Lighting

-- ─── MAIN FRAME ──────────────────────────────────────────────
local MainFrame = Instance.new("Frame", GhostyMenu)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 800, 0, 540)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -270)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true

local mainCorner = Instance.new("UICorner", MainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(35, 35, 45)
mainStroke.Thickness = 1

-- ─── LEFT SIDEBAR ────────────────────────────────────────────
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 185, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
Sidebar.BorderSizePixel = 0

-- скруглить только левую сторону
local sbCorner = Instance.new("UICorner", Sidebar)
sbCorner.CornerRadius = UDim.new(0, 10)
-- прикрыть правые скругления
local sbFix = Instance.new("Frame", Sidebar)
sbFix.Size = UDim2.new(0, 12, 1, 0)
sbFix.Position = UDim2.new(1, -12, 0, 0)
sbFix.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
sbFix.BorderSizePixel = 0

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.BackgroundTransparency = 1
Logo.Text = "GHOSTY"
Logo.TextColor3 = Color3.fromRGB(45, 140, 255)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold

local VersionLabel = Instance.new("TextLabel", Sidebar)
VersionLabel.Size = UDim2.new(1, 0, 0, 18)
VersionLabel.Position = UDim2.new(0, 0, 0, 42)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v2.0 | Roblox"
VersionLabel.TextColor3 = Color3.fromRGB(70, 70, 80)
VersionLabel.TextSize = 11
VersionLabel.Font = Enum.Font.Gotham

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Position = UDim2.new(0, 12, 0, 78)
TabContainer.Size = UDim2.new(1, -24, 1, -110)
TabContainer.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.Padding = UDim.new(0, 5)

-- ─── CONTENT AREA ────────────────────────────────────────────
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 200, 0, 15)
Content.Size = UDim2.new(1, -215, 1, -30)
Content.BackgroundTransparency = 1

-- ─── PAGES ───────────────────────────────────────────────────
local Pages = {}
local TABS = {"AIMBOT", "ESP", "CHAMS", "WORLD", "CONFIG"}

for _, tab in ipairs(TABS) do
    local Page = Instance.new("ScrollingFrame", Content)
    Page.Name = tab
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(45, 140, 255)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.BorderSizePixel = 0

    local lay = Instance.new("UIListLayout", Page)
    lay.Padding = UDim.new(0, 12)

    Pages[tab] = Page
end

-- ─── UI HELPERS ──────────────────────────────────────────────
local function Section(parent, title)
    local Sec = Instance.new("Frame", parent)
    Sec.Size = UDim2.new(1, -8, 0, 36)
    Sec.AutomaticSize = Enum.AutomaticSize.Y
    Sec.BackgroundColor3 = Color3.fromRGB(19, 19, 24)
    Sec.BorderSizePixel = 0
    Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 7)
    local st = Instance.new("UIStroke", Sec)
    st.Color = Color3.fromRGB(30, 30, 38)

    local Hdr = Instance.new("TextLabel", Sec)
    Hdr.Size = UDim2.new(1, -16, 0, 28)
    Hdr.Position = UDim2.new(0, 16, 0, 4)
    Hdr.BackgroundTransparency = 1
    Hdr.Text = title:upper()
    Hdr.TextColor3 = Color3.fromRGB(45, 140, 255)
    Hdr.TextSize = 11
    Hdr.Font = Enum.Font.GothamBold
    Hdr.TextXAlignment = Enum.TextXAlignment.Left

    local sep = Instance.new("Frame", Sec)
    sep.Size = UDim2.new(1, -32, 0, 1)
    sep.Position = UDim2.new(0, 16, 0, 32)
    sep.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    sep.BorderSizePixel = 0

    local Body = Instance.new("Frame", Sec)
    Body.Position = UDim2.new(0, 16, 0, 38)
    Body.Size = UDim2.new(1, -32, 0, 4)
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.BackgroundTransparency = 1
    local bLay = Instance.new("UIListLayout", Body)
    bLay.Padding = UDim.new(0, 6)

    local Pad = Instance.new("UIPadding", Sec)
    Pad.PaddingBottom = UDim.new(0, 10)

    return Body
end

-- Toggle
local function Toggle(parent, label, cfgKey, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 30)
    Row.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(1, -56, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.AutoButtonColor = false

    -- чекбокс
    local Box = Instance.new("Frame", Btn)
    Box.Size = UDim2.new(0, 16, 0, 16)
    Box.Position = UDim2.new(0, 0, 0.5, -8)
    Box.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    local bStroke = Instance.new("UIStroke", Box)
    bStroke.Color = Color3.fromRGB(50, 50, 60)

    local Tick = Instance.new("TextLabel", Box)
    Tick.Size = UDim2.new(1, 0, 1, 0)
    Tick.BackgroundTransparency = 1
    Tick.Text = "✓"
    Tick.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tick.TextSize = 12
    Tick.Font = Enum.Font.GothamBold
    Tick.Visible = false

    local Lbl = Instance.new("TextLabel", Btn)
    Lbl.Position = UDim2.new(0, 26, 0, 0)
    Lbl.Size = UDim2.new(1, -30, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(165, 165, 170)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- keybind
    local BindBtn = Instance.new("TextButton", Row)
    BindBtn.Size = UDim2.new(0, 48, 0, 20)
    BindBtn.Position = UDim2.new(1, -48, 0.5, -10)
    BindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    BindBtn.Text = _G.GhostyBinds[cfgKey] and ("[" .. _G.GhostyBinds[cfgKey] .. "]") or "[---]"
    BindBtn.TextColor3 = Color3.fromRGB(100, 100, 110)
    BindBtn.TextSize = 11
    BindBtn.Font = Enum.Font.Gotham
    BindBtn.AutoButtonColor = false
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)

    local function refresh()
        local on = _G.GhostyConfig[cfgKey]
        TweenService:Create(Box, TweenInfo.new(0.1), {
            BackgroundColor3 = on and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(28, 28, 36)
        }):Play()
        bStroke.Color = on and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(50, 50, 60)
        Tick.Visible = on
        Lbl.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(165, 165, 170)
    end

    local function trigger()
        _G.GhostyConfig[cfgKey] = not _G.GhostyConfig[cfgKey]
        refresh()
        if callback then callback(_G.GhostyConfig[cfgKey]) end
    end

    refresh()  -- apply saved state on load
    Btn.MouseButton1Click:Connect(trigger)
    KeybindTriggers[cfgKey] = trigger

    local listening = false
    BindBtn.MouseButton1Click:Connect(function()
        listening = true
        BindBtn.Text = "[?]"
        BindBtn.TextColor3 = Color3.fromRGB(45, 140, 255)
    end)

    UserInputService.InputBegan:Connect(function(inp, proc)
        if not listening then return end
        if proc then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        if inp.KeyCode == Enum.KeyCode.Escape or inp.KeyCode == Enum.KeyCode.Delete then
            _G.GhostyBinds[cfgKey] = nil
            BindBtn.Text = "[---]"
            BindBtn.TextColor3 = Color3.fromRGB(100, 100, 110)
        else
            _G.GhostyBinds[cfgKey] = inp.KeyCode.Name
            BindBtn.Text = "[" .. inp.KeyCode.Name .. "]"
            BindBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
    end)

    return Row
end

-- Slider
local function Slider(parent, label, min, max, cfgKey, decimals)
    local default = _G.GhostyConfig[cfgKey] or min
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 46)
    Row.BackgroundTransparency = 1

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -50, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(165, 165, 170)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local ValLbl = Instance.new("TextLabel", Row)
    ValLbl.Size = UDim2.new(0, 45, 0, 20)
    ValLbl.Position = UDim2.new(1, -45, 0, 0)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text = tostring(default)
    ValLbl.TextColor3 = Color3.fromRGB(45, 140, 255)
    ValLbl.TextSize = 12
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("TextButton", Row)
    Track.Position = UDim2.new(0, 0, 0, 26)
    Track.Size = UDim2.new(1, 0, 0, 8)
    Track.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Track.Text = ""
    Track.AutoButtonColor = false
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 4)

    local Fill = Instance.new("Frame", Track)
    Fill.BackgroundColor3 = Color3.fromRGB(45, 140, 255)
    Fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

    local Handle = Instance.new("Frame", Track)
    Handle.Size = UDim2.new(0, 12, 0, 12)
    Handle.AnchorPoint = Vector2.new(0.5, 0.5)
    Handle.Position = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 0.5, 0)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.BorderSizePixel = 0
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)

    local function update(inputPos)
        local pct = math.clamp((inputPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * pct
        val = decimals and (math.round(val * 100) / 100) or math.round(val)
        _G.GhostyConfig[cfgKey] = val
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Handle.Position = UDim2.new(pct, 0, 0.5, 0)
        ValLbl.Text = tostring(val)
    end

    local sliding = false
    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true; update(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            update(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)

    return Row
end

-- Selector (цикличный выбор)
local function Selector(parent, label, cfgKey, options)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1, 0, 0, 30)
    Row.BackgroundTransparency = 1

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -110, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(165, 165, 170)
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextXAlignment = Enum.TextXAlignment.Left

    local BtnL = Instance.new("TextButton", Row)
    BtnL.Size = UDim2.new(0, 22, 0, 22)
    BtnL.Position = UDim2.new(1, -108, 0.5, -11)
    BtnL.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    BtnL.Text = "<"
    BtnL.TextColor3 = Color3.fromRGB(45, 140, 255)
    BtnL.TextSize = 13
    BtnL.Font = Enum.Font.GothamBold
    BtnL.AutoButtonColor = false
    Instance.new("UICorner", BtnL).CornerRadius = UDim.new(0, 4)

    local ValLbl = Instance.new("TextLabel", Row)
    ValLbl.Size = UDim2.new(0, 60, 0, 22)
    ValLbl.Position = UDim2.new(1, -82, 0.5, -11)
    ValLbl.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    ValLbl.Text = tostring(_G.GhostyConfig[cfgKey] or options[1])
    ValLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValLbl.TextSize = 12
    ValLbl.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ValLbl).CornerRadius = UDim.new(0, 4)

    local BtnR = Instance.new("TextButton", Row)
    BtnR.Size = UDim2.new(0, 22, 0, 22)
    BtnR.Position = UDim2.new(1, -18, 0.5, -11)
    BtnR.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    BtnR.Text = ">"
    BtnR.TextColor3 = Color3.fromRGB(45, 140, 255)
    BtnR.TextSize = 13
    BtnR.Font = Enum.Font.GothamBold
    BtnR.AutoButtonColor = false
    Instance.new("UICorner", BtnR).CornerRadius = UDim.new(0, 4)

    local idx = 1
    for i, v in ipairs(options) do
        if v == _G.GhostyConfig[cfgKey] then idx = i break end
    end

    local function move(d)
        idx = ((idx - 1 + d) % #options) + 1
        _G.GhostyConfig[cfgKey] = options[idx]
        ValLbl.Text = options[idx]
    end

    BtnL.MouseButton1Click:Connect(function() move(-1) end)
    BtnR.MouseButton1Click:Connect(function() move(1) end)

    return Row
end

-- Label (разделитель / подсказка)
local function Label(parent, text, color)
    local Lbl = Instance.new("TextLabel", parent)
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = color or Color3.fromRGB(90, 90, 100)
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    return Lbl
end

-- Button
local function Button(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 140, 255)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 160, 255)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 140, 255)}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return Btn
end

-- ─── ВКЛАДКА: ESP ────────────────────────────────────────────
do
    local espSec = Section(Pages["ESP"], "Player ESP")

    -- sub-контейнер с настройками, появляется после включения ESP
    local espSub = Instance.new("Frame", espSec)
    espSub.Size = UDim2.new(1, 0, 0, 0)
    espSub.AutomaticSize = Enum.AutomaticSize.Y
    espSub.BackgroundTransparency = 1
    espSub.Visible = _G.GhostyConfig.EspEnabled
    local espSubLay = Instance.new("UIListLayout", espSub)
    espSubLay.Padding = UDim.new(0, 6)

    Toggle(espSec, "Enable ESP", "EspEnabled", function(v)
        espSub.Visible = v
    end)

    Toggle(espSub, "2D Boxes",              "EspBoxes2D")
    Toggle(espSub, "3D Boxes",              "EspBoxes3D")
    Toggle(espSub, "Box Fill",              "FillEnabled")
    Slider(espSub,  "Fill Transparency",     0, 1, "FillTransparency", true)
    Toggle(espSub, "Snap Lines",            "EspLines")
    Toggle(espSub, "Names",                 "EspNames")
    Toggle(espSub, "Health Bar",            "EspHealth")
    Selector(espSub, "Health Side",         "HealthPosition", {"Left", "Right"})
    Toggle(espSub, "Distance",              "EspDistance")
end

-- ─── ВКЛАДКА: CHAMS ──────────────────────────────────────────
do
    local chamsSec = Section(Pages["CHAMS"], "Chams")

    local chamsSub = Instance.new("Frame", chamsSec)
    chamsSub.Size = UDim2.new(1, 0, 0, 0)
    chamsSub.AutomaticSize = Enum.AutomaticSize.Y
    chamsSub.BackgroundTransparency = 1
    chamsSub.Visible = _G.GhostyConfig.ChamsEnabled
    local chamsSubLay = Instance.new("UIListLayout", chamsSub)
    chamsSubLay.Padding = UDim.new(0, 6)

    Toggle(chamsSec, "Enable Chams", "ChamsEnabled", function(v)
        chamsSub.Visible = v
    end)

    Toggle(chamsSub, "Visible Only",         "ChamsVisibleOnly")
    Slider(chamsSub, "Fill Transparency",    0, 1, "ChamsFillTransparency", true)
    Slider(chamsSub, "Outline Transparency", 0, 1, "ChamsOutlineTransparency", true)
end

-- ─── ВКЛАДКА: WORLD ──────────────────────────────────────────
do
    local worldSec = Section(Pages["WORLD"], "World")
    Toggle(worldSec, "No Textures", "NoTextures")
end

-- ─── ВКЛАДКА: AIMBOT ─────────────────────────────────────────
do
    local aimSec = Section(Pages["AIMBOT"], "Aimbot")
    Label(aimSec, "-- Coming soon --")
end

-- ─── ВКЛАДКА: CONFIG ─────────────────────────────────────────
do
    local cfgSec = Section(Pages["CONFIG"], "Config")
    Label(cfgSec, "Сохраняет в файл (writefile/readfile)")

    Button(cfgSec, "💾  Save Config", function()
        SaveConfig()
    end)

    Button(cfgSec, "📂  Load Config", function()
        LoadConfig()
        -- обновить все визуальные состояния через полный реинит не нужен,
        -- т.к. конфиг читается в RenderStepped напрямую
    end)

    Label(cfgSec, "")
    Label(cfgSec, "Insert — показать / скрыть")
    Label(cfgSec, "F10    — выгрузить")
end

-- ─── ТАБЫ (КНОПКИ) ───────────────────────────────────────────
local activeTab = "ESP"
local tabBtns = {}

local tabIcons = {
    AIMBOT = "🎯", ESP = "👁", CHAMS = "💎", WORLD = "🌍", CONFIG = "⚙️"
}

local function SwitchTab(name)
    activeTab = name
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        local on = (n == name)
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = on and Color3.fromRGB(22, 22, 30) or Color3.fromRGB(10, 10, 13),
            TextColor3 = on and Color3.fromRGB(45, 140, 255) or Color3.fromRGB(120, 120, 130)
        }):Play()
    end
end

for id, name in ipairs(TABS) do
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    Btn.BorderSizePixel = 0
    Btn.Text = (tabIcons[name] or "") .. "  " .. name
    Btn.TextColor3 = Color3.fromRGB(120, 120, 130)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = id
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local btnPad = Instance.new("UIPadding", Btn)
    btnPad.PaddingLeft = UDim.new(0, 12)

    tabBtns[name] = Btn
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

SwitchTab("ESP")

-- ─── DRAG ────────────────────────────────────────────────────
local dragging, dragStart, frameStart = false, nil, nil

MainFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        frameStart = MainFrame.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        MainFrame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + d.X,
            frameStart.Y.Scale, frameStart.Y.Offset + d.Y
        )
    end
end)

-- ─── HOTKEYS & BINDS ─────────────────────────────────────────
local conn
conn = UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if inp.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        Blur.Enabled = MainFrame.Visible

    elseif inp.KeyCode == Enum.KeyCode.F10 then
        -- полная выгрузка
        SaveConfig()
        conn:Disconnect()
        GhostyMenu:Destroy()
        Blur:Destroy()

    else
        -- пользовательские бинды
        for cfgKey, keyName in pairs(_G.GhostyBinds) do
            if inp.KeyCode.Name == keyName and KeybindTriggers[cfgKey] then
                KeybindTriggers[cfgKey]()
            end
        end
    end
end)

-- ─── ЗАГРУЗКА ESP (после полной инициализации конфига) ───────
task.delay(0.05, function()   -- крошечная задержка: конфиг точно готов
    pcall(function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/bblodik/GhostyRustRemake/refs/heads/main/ESP.lua"
        ))()
    end)
    -- pcall(function() loadstring(game:HttpGet("...chams.lua"))() end)
    -- pcall(function() loadstring(game:HttpGet("...textures.lua"))() end)
end)
