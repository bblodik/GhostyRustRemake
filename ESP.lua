local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ESP_Cache = {}

local function CreatePlayerEsp(player)
    if player == LocalPlayer then return end

    local function applyVisuals(char)
        if ESP_Cache[player] then
            pcall(function() ESP_Cache[player].Folder:Destroy() end)
            ESP_Cache[player] = nil
        end
        
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not root or not humanoid then return end

        local folder = Instance.new("Folder")
        folder.Name = "GhostyEspTag"
        folder.Parent = char

        -- Текстовый блок (Ники и Дистанция)
        local bGui = Instance.new("BillboardGui", folder)
        bGui.AlwaysOnTop = true
        bGui.Size = UDim2.new(0, 200, 0, 50)
        bGui.ExtentsOffset = Vector3.new(0, 3, 0)
        bGui.Adornee = root
        
        local nameLabel = Instance.new("TextLabel", bGui)
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Visible = false

        local distLabel = Instance.new("TextLabel", bGui)
        distLabel.Size = UDim2.new(1, 0, 0, 20)
        distLabel.Position = UDim2.new(0, 0, 0, 20)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(45, 140, 255)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.GothamMedium
        distLabel.Visible = false

        -- 3D Бокс
        local box3D = Instance.new("BoxHandleAdornment", folder)
        box3D.Size = Vector3.new(4, 5.5, 4)
        box3D.AlwaysOnTop = true
        box3D.ZIndex = 5
        box3D.Adornee = root
        box3D.Visible = false

        -- 2D Бокс
        local bGui2D = Instance.new("BillboardGui", folder)
        bGui2D.AlwaysOnTop = true
        bGui2D.Size = UDim2.new(0, 4.5, 0, 6)
        bGui2D.Adornee = root
        bGui2D.Enabled = false
        
        local frame2D = Instance.new("Frame", bGui2D)
        frame2D.Size = UDim2.new(1, 0, 1, 0)
        frame2D.BackgroundTransparency = 1
        
        local stroke2D = Instance.new("UIStroke", frame2D)
        stroke2D.Thickness = 1.5
        stroke2D.Color = Color3.fromRGB(255, 255, 255)

        -- Полоска здоровья
        local healthFrame = Instance.new("Frame", frame2D)
        healthFrame.Size = UDim2.new(0, 3, 1, 0)
        healthFrame.Position = UDim2.new(0, -8, 0, 0)
        healthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFrame.BorderSizePixel = 0
        healthFrame.Visible = false

        -- Сохраняем ссылки в кэш для единого цикла обработки
        ESP_Cache[player] = {
            Folder = folder,
            Root = root,
            Humanoid = humanoid,
            NameLabel = nameLabel,
            DistLabel = distLabel,
            Box3D = box3D,
            BGui2D = bGui2D,
            Frame2D = frame2D,
            Stroke2D = stroke2D,
            HealthFrame = healthFrame
        }
    end

    if player.Character then applyVisuals(player.Character) end
    player.CharacterAdded:Connect(applyVisuals)
end

-- Удаление из кэша при выходе игрока
local function RemovePlayerEsp(player)
    ESP_Cache[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do CreatePlayerEsp(p) end
Players.PlayerAdded:Connect(CreatePlayerEsp)
Players.PlayerRemoving:Connect(RemovePlayerEsp)

-- ГЛОБАЛЬНЫЙ ЕДИНЫЙ ЦИКЛ ОБРАБОТКИ (Убирает лаги)
local LastBoxColor, LastFillColor, LastFillTrans, LastFillEnabled = nil, nil, nil, nil

RunService.RenderStepped:Connect(function()
    local config = _G.GhostyConfig
    if not config then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- Быстрый чек изменений графики (чтобы не перезаписывать свойства каждый кадр)
    local colorChanged = (LastBoxColor ~= config.BoxColor) or (LastFillColor ~= config.FillColor) or (LastFillTrans ~= config.FillTransparency) or (LastFillEnabled ~= config.FillEnabled)
    if colorChanged then
        LastBoxColor = config.BoxColor
        LastFillColor = config.FillColor
        LastFillTrans = config.FillTransparency
        LastFillEnabled = config.FillEnabled
    end

    local espEnabled = config.EspEnabled
    local showNames = config.EspNames
    local showDist = config.EspDistance
    local show3D = config.EspBoxes3D
    local show2D = config.EspBoxes2D
    local showHealth = config.EspHealth
    local fillEnabled = config.FillEnabled

    for player, data in pairs(ESP_Cache) do
        -- Проверяем существование персонажа в игре
        if not data.Folder or not data.Folder.Parent then
            ESP_Cache[player] = nil
            continue
        end

        local humanoid = data.Humanoid
        if espEnabled and humanoid and humanoid.Health > 0 then
            -- 1. Никнеймы
            data.NameLabel.Visible = showNames

            -- 2. Дистанция (считаем только если включена)
            if showDist and myRoot and data.Root then
                local dist = math.round((data.Root.Position - myRoot.Position).Magnitude)
                data.DistLabel.Text = dist .. "m"
                data.DistLabel.Visible = true
                data.DistLabel.Position = showNames and UDim2.new(0,0,0,20) or UDim2.new(0,0,0,0)
            else
                data.DistLabel.Visible = false
            end

            -- 3. 3D Боксы
            if show3D then
                data.Box3D.Visible = true
                if colorChanged then
                    data.Box3D.Color3 = config.BoxColor
                    data.Box3D.Transparency = fillEnabled and config.FillTransparency or 1
                end
            else
                data.Box3D.Visible = false
            end

            -- 4. 2D Боксы
            if show2D and not show3D then
                data.BGui2D.Enabled = true
                if colorChanged then
                    data.Stroke2D.Color = config.BoxColor
                    if fillEnabled then
                        data.Frame2D.BackgroundTransparency = config.FillTransparency
                        data.Frame2D.BackgroundColor3 = config.FillColor
                    else
                        data.Frame2D.BackgroundTransparency = 1
                    end
                end
            else
                data.BGui2D.Enabled = false
            end

            -- 5. Полоска здоровья
            if showHealth and show2D and not show3D then
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                data.HealthFrame.Size = UDim2.new(0, 3, hpPercent, 0)
                data.HealthFrame.Position = UDim2.new(0, -8, 1 - hpPercent, 0)
                data.HealthFrame.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                data.HealthFrame.Visible = true
            else
                data.HealthFrame.Visible = false
            end
        else
            -- Если ESP выключен или игрок мёртв — скрываем всё разом
            data.NameLabel.Visible = false
            data.DistLabel.Visible = false
            data.Box3D.Visible = false
            data.BGui2D.Enabled = false
            data.HealthFrame.Visible = false
        end
    end
end)
