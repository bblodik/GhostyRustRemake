-- ============================================================
--  GhostyRustRemake | ESP.lua
--  Зависит от _G.GhostyConfig, который задаётся в main.lua
-- ============================================================

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Camera      = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local ESP_Cache   = {}   -- [Player] = { ... }

-- ─── вспомогательная функция ─────────────────────────────────
local function AddStroke(obj, thickness, color)
    local s = Instance.new("UIStroke", obj)
    s.Thickness = thickness or 1.5
    s.Color = color or Color3.fromRGB(0, 0, 0)
    s.JoinMode = Enum.LineJoinMode.Round
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    return s
end

-- ─── создать GUI для одного игрока ───────────────────────────
local function BuildEsp(player, char)
    -- убрать старое
    if ESP_Cache[player] then
        pcall(function() ESP_Cache[player].Folder:Destroy() end)
        ESP_Cache[player] = nil
    end

    local root     = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid",         5)
    if not root or not humanoid then return end

    local folder = Instance.new("Folder")
    folder.Name = "GhostyESP"
    folder.Parent = char

    -- ── 1. Ник ────────────────────────────────────────────────
    local bName = Instance.new("BillboardGui", folder)
    bName.AlwaysOnTop = true
    bName.Size = UDim2.new(0, 200, 0, 24)
    bName.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
    bName.Adornee = root
    bName.Enabled = false

    local nameLabel = Instance.new("TextLabel", bName)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    AddStroke(nameLabel, 1.5)

    -- ── 2. Дистанция ─────────────────────────────────────────
    local bDist = Instance.new("BillboardGui", folder)
    bDist.AlwaysOnTop = true
    bDist.Size = UDim2.new(0, 200, 0, 22)
    bDist.StudsOffsetWorldSpace = Vector3.new(0, -3.8, 0)
    bDist.Adornee = root
    bDist.Enabled = false

    local distLabel = Instance.new("TextLabel", bDist)
    distLabel.Size = UDim2.new(1, 0, 1, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(45, 200, 255)
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.GothamBold
    AddStroke(distLabel, 1.2)

    -- ── 3. 3D SelectionBox (каркас) ───────────────────────────
    local box3D = Instance.new("SelectionBox", folder)
    box3D.Adornee = root
    box3D.LineThickness = 0.05
    box3D.AlwaysOnTop = true
    box3D.Color3 = Color3.fromRGB(255, 255, 255)
    box3D.SurfaceTransparency = 1        -- заливка выключена по умолчанию
    box3D.SurfaceColor3 = Color3.fromRGB(45, 140, 255)
    box3D.Visible = false

    -- ── 4. 2D Бокс (Drawing-like через ScreenGui) ─────────────
    --    Рисуем 4 линии через Frame'ы в SurfaceGui, прикреплённом к BillboardGui
    --    Но простой и стабильный способ для Roblox — BillboardGui + UIStroke на Frame
    local bBox2D = Instance.new("BillboardGui", folder)
    bBox2D.AlwaysOnTop = true
    bBox2D.Size = UDim2.new(0, 48, 0, 68)   -- пиксели экрана (визуальный размер бокса)
    bBox2D.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
    bBox2D.Adornee = root
    bBox2D.Enabled = false

    local boxFrame = Instance.new("Frame", bBox2D)
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1

    local boxStroke = Instance.new("UIStroke", boxFrame)
    boxStroke.Thickness = 1.6
    boxStroke.Color = Color3.fromRGB(255, 255, 255)

    local boxFill = Instance.new("Frame", boxFrame)
    boxFill.Size = UDim2.new(1, 0, 1, 0)
    boxFill.BackgroundTransparency = 0.6
    boxFill.BackgroundColor3 = Color3.fromRGB(45, 140, 255)
    boxFill.BorderSizePixel = 0
    boxFill.Visible = false

    -- ── 5. Полоска HP (внутри того же BillboardGui) ───────────
    -- Фон
    local hpBg = Instance.new("Frame", bBox2D)
    hpBg.Size = UDim2.new(0, 5, 1, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hpBg.BorderSizePixel = 0
    hpBg.BackgroundTransparency = 0.3
    hpBg.Visible = false
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

    -- Заполнение
    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.AnchorPoint = Vector2.new(0, 1)
    hpFill.Position = UDim2.new(0, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpFill.BorderSizePixel = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

    -- ── 6. Snap-линия (Drawing API — единственный надёжный способ) ──
    local snapLine = Drawing.new("Line")
    snapLine.Visible = false
    snapLine.Thickness = 1.5
    snapLine.Color = Color3.fromRGB(255, 255, 255)
    snapLine.Transparency = 1

    ESP_Cache[player] = {
        Folder    = folder,
        Root      = root,
        Humanoid  = humanoid,
        -- nick
        bName     = bName,
        nameLabel = nameLabel,
        -- dist
        bDist     = bDist,
        distLabel = distLabel,
        -- 3d
        box3D     = box3D,
        -- 2d
        bBox2D    = bBox2D,
        boxStroke = boxStroke,
        boxFill   = boxFill,
        -- hp
        hpBg      = hpBg,
        hpFill    = hpFill,
        -- line
        snapLine  = snapLine,
    }
end

-- ─── очистить ESP игрока ─────────────────────────────────────
local function RemoveEsp(player)
    local d = ESP_Cache[player]
    if d then
        pcall(function() d.Folder:Destroy() end)
        pcall(function() d.snapLine:Remove() end)
        ESP_Cache[player] = nil
    end
end

-- ─── регистрация игроков ─────────────────────────────────────
local function RegisterPlayer(player)
    if player == LocalPlayer then return end

    if player.Character then
        task.spawn(BuildEsp, player, player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        task.spawn(BuildEsp, player, char)
    end)
    player.CharacterRemoving:Connect(function()
        RemoveEsp(player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do RegisterPlayer(p) end
Players.PlayerAdded:Connect(RegisterPlayer)
Players.PlayerRemoving:Connect(RemoveEsp)

-- ─── ГЛАВНЫЙ ЦИКЛ ────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local cfg = _G.GhostyConfig
    if not cfg then return end          -- конфиг ещё не готов

    local espOn   = cfg.EspEnabled
    local myChar  = LocalPlayer.Character
    local myRoot  = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for player, d in pairs(ESP_Cache) do

        -- проверка валидности данных
        if not d.Folder or not d.Folder.Parent then
            RemoveEsp(player)
            continue
        end

        local alive = d.Humanoid
            and d.Humanoid.Health > 0
            and d.Root
            and d.Root.Parent

        if not espOn or not alive then
            -- всё скрыть
            d.bName.Enabled   = false
            d.bDist.Enabled   = false
            d.box3D.Visible   = false
            d.bBox2D.Enabled  = false
            d.hpBg.Visible    = false
            d.snapLine.Visible = false
            continue
        end

        -- ── цвета / стили ─────────────────────────────────
        local bColor = cfg.BoxColor or Color3.fromRGB(255, 255, 255)
        local fColor = cfg.FillColor or Color3.fromRGB(45, 140, 255)

        -- ── ник ───────────────────────────────────────────
        d.bName.Enabled = cfg.EspNames == true

        -- ── дистанция ─────────────────────────────────────
        if cfg.EspDistance and myRoot then
            local dist = math.round((d.Root.Position - myRoot.Position).Magnitude)
            d.distLabel.Text = dist .. "m"
            d.bDist.Enabled = true
        else
            d.bDist.Enabled = false
        end

        -- ── 3D Box ────────────────────────────────────────
        if cfg.EspBoxes3D then
            d.box3D.Color3 = bColor
            if cfg.FillEnabled then
                d.box3D.SurfaceColor3       = fColor
                d.box3D.SurfaceTransparency = cfg.FillTransparency or 0.6
            else
                d.box3D.SurfaceTransparency = 1
            end
            d.box3D.Visible = true
        else
            d.box3D.Visible = false
        end

        -- ── 2D Box ────────────────────────────────────────
        --   Показываем только если 3D выключен (или оба если хочешь)
        if cfg.EspBoxes2D and not cfg.EspBoxes3D then
            d.boxStroke.Color = bColor
            d.boxFill.Visible = cfg.FillEnabled == true
            if cfg.FillEnabled then
                d.boxFill.BackgroundColor3      = fColor
                d.boxFill.BackgroundTransparency = cfg.FillTransparency or 0.6
            end
            d.bBox2D.Enabled = true
        else
            d.bBox2D.Enabled = false
        end

        -- ── HP bar ────────────────────────────────────────
        if cfg.EspHealth and cfg.EspBoxes2D and not cfg.EspBoxes3D then
            local pct = math.clamp(d.Humanoid.Health / d.Humanoid.MaxHealth, 0, 1)
            -- позиция слева или справа от 2D бокса
            local isRight = cfg.HealthPosition == "Right"
            d.hpBg.AnchorPoint = isRight and Vector2.new(0, 0) or Vector2.new(1, 0)
            d.hpBg.Position    = isRight
                and UDim2.new(1,  4, 0, 0)
                or  UDim2.new(0, -4, 0, 0)

            d.hpFill.Size = UDim2.new(1, 0, pct, 0)
            -- цвет: зелёный → красный
            d.hpFill.BackgroundColor3 = Color3.fromRGB(
                math.round(255 * (1 - pct)),
                math.round(255 * pct),
                0
            )
            d.hpBg.Visible = true
        else
            d.hpBg.Visible = false
        end

        -- ── Snap Lines (Drawing API) ───────────────────────
        if cfg.EspLines then
            local screenSize = Camera.ViewportSize
            local rootPos, onScreen = Camera:WorldToViewportPoint(d.Root.Position)

            if onScreen then
                d.snapLine.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                d.snapLine.To   = Vector2.new(rootPos.X, rootPos.Y)
                d.snapLine.Color = bColor
                d.snapLine.Transparency = 1
                d.snapLine.Visible = true
            else
                d.snapLine.Visible = false
            end
        else
            d.snapLine.Visible = false
        end
    end
end)
