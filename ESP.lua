local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local function CreatePlayerEsp(player)
    if player == LocalPlayer then return end

    local function applyVisuals(char)
        if char:FindFirstChild("GhostyEspTag") then char.GhostyEspTag:Destroy() end
        
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not root or not humanoid then return end

        -- Папка-контейнер внутри персонажа, чтобы легко чистить
        local folder = Instance.new("Folder")
        folder.Name = "GhostyEspTag"
        folder.Parent = charlocal Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function create3DLine()
    local l = Drawing.new("Line")
    l.Thickness = 1
    l.Visible = false
    return l
end

local function CreateEsp(player)
    if player == LocalPlayer then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = 1
    Box.Filled = false
    
    local Fill = Drawing.new("Square")
    Fill.Visible = false
    Fill.Thickness = 0
    Fill.Filled = true
    
    local Line = Drawing.new("Line")
    Line.Visible = false
    Line.Thickness = 1
    
    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Size = 13
    Name.Center = true
    Name.Outline = true
    
    local DistText = Drawing.new("Text")
    DistText.Visible = false
    DistText.Size = 11
    DistText.Center = true
    DistText.Outline = true

    local Health = Drawing.new("Line")
    Health.Visible = false
    Health.Thickness = 2
    
    local lines3D = {}
    for i = 1, 12 do table.insert(lines3D, create3DLine()) end

    local function update3DBox(hrp, size, color)
        local c = hrp.Position
        local ext = size / 2
        
        local vertices = {
            Camera:WorldToViewportPoint(c + Vector3.new(-ext.X,  ext.Y, -ext.Z)),
            Camera:WorldToViewportPoint(c + Vector3.new( ext.X,  ext.Y, -ext.Z)),
            Camera:WorldToViewportPoint(c + Vector3.new( ext.X, -ext.Y, -ext.Z)),
            Camera:WorldToViewportPoint(c + Vector3.new(-ext.X, -ext.Y, -ext.Z))
        }
        local vertices2 = {
            Camera:WorldToViewportPoint(c + Vector3.new(-ext.X,  ext.Y,  ext.Z)),
            Camera:WorldToViewportPoint(c + Vector3.new( ext.X,  ext.Y,  ext.Z)),
            Camera:WorldToViewportPoint(c + Vector3.new( ext.X, -ext.Y,  ext.Z)),
            Camera:WorldToViewportPoint(c + Vector3.new(-ext.X, -ext.Y,  ext.Z))
        }
        for i, v in ipairs(vertices2) do vertices[i+4] = v end

        local indices = {
            {1,2}, {2,3}, {3,4}, {4,1},
            {5,6}, {6,7}, {7,8}, {8,5},
            {1,5}, {2,6}, {3,7}, {4,8}
        }

        for i, edge in ipairs(indices) do
            local p1 = vertices[edge[1]]
            local p2 = vertices[edge[2]]
            local l = lines3D[i]
            
            if p1 and p2 and p1.Z > 0 and p2.Z > 0 then
                l.From = Vector2.new(p1.X, p1.Y)
                l.To = Vector2.new(p2.X, p2.Y)
                l.Color = color
                l.Visible = true
            else
                l.Visible = false
            end
        end
    end

    local function hide3D()
        for _, l in ipairs(lines3D) do l.Visible = false end
    end

    local Connection
    Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.GhostyConfig or not game:GetService("CoreGui"):FindFirstChild("GhostyMenu") then
            Box:Destroy() Fill:Destroy() Line:Destroy() Name:Destroy() DistText:Destroy() Health:Destroy()
            for _, l in ipairs(lines3D) do l:Destroy() end
            Connection:Disconnect()
            return
        end
        
        local char = player.Character
        if _G.GhostyConfig.EspEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local scale = 1 / (screenPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                local w, h = 3 * scale, 4.5 * scale
                local x, y = screenPos.X - w / 2, screenPos.Y - h / 2
                
                if _G.GhostyConfig.EspBoxes3D then
                    hide3D()
                    update3DBox(hrp, Vector3.new(4, 6, 4), _G.GhostyConfig.BoxColor)
                    Box.Visible = false
                    Fill.Visible = false
                elseif _G.GhostyConfig.EspBoxes2D then
                    hide3D()
                    Box.Size = Vector2.new(w, h)
                    Box.Position = Vector2.new(x, y)
                    Box.Color = _G.GhostyConfig.BoxColor
                    Box.Transparency = 1 - _G.GhostyConfig.BoxTransparency
                    Box.Visible = true
                    
                    if _G.GhostyConfig.FillEnabled then
                        Fill.Size = Vector2.new(w - 2, h - 2)
                        Fill.Position = Vector2.new(x + 1, y + 1)
                        Fill.Color = _G.GhostyConfig.FillColor
                        Fill.Transparency = 1 - _G.GhostyConfig.FillTransparency
                        Fill.Visible = true
                    else Fill.Visible = false end
                else
                    hide3D() Box.Visible = false Fill.Visible = false
                end
                
                if _G.GhostyConfig.EspLines then
                    Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Line.To = Vector2.new(screenPos.X, screenPos.Y + (h/2))
                    Line.Color = _G.GhostyConfig.BoxColor
                    Line.Visible = true
                else Line.Visible = false end
                
                if _G.GhostyConfig.EspNames then
                    Name.Text = player.Name
                    Name.Position = Vector2.new(screenPos.X, y - 16)
                    Name.Color = Color3.fromRGB(255, 255, 255)
                    Name.Visible = true
                else Name.Visible = false end
                
                if _G.GhostyConfig.EspDistance then
                    DistText.Text = math.round(screenPos.Z) .. "m"
                    DistText.Position = _G.GhostyConfig.EspNames and Vector2.new(screenPos.X, y + h + 4) or Vector2.new(screenPos.X, y - 14)
                    DistText.Color = Color3.fromRGB(45, 140, 255)
                    DistText.Visible = true
                else DistText.Visible = false end
                
                if _G.GhostyConfig.EspHealth then
                    local healthPercent = char.Humanoid.Health / char.Humanoid.MaxHealth
                    Health.From = Vector2.new(x - 5, y + h)
                    Health.To = Vector2.new(x - 5, y + h - (h * healthPercent))
                    Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    Health.Visible = true
                else Health.Visible = false end
                
            else
                Box.Visible = false Fill.Visible = false Line.Visible = false Name.Visible = false DistText.Visible = false Health.Visible = false hide3D()
            end
        else
            Box.Visible = false Fill.Visible = false Line.Visible = false Name.Visible = false DistText.Visible = false Health.Visible = false hide3D()
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do CreateEsp(p) end
Players.PlayerAdded:Connect(CreateEsp)

        -- Текстовый блок (Ники и Дистанция)
        local bGui = Instance.new("BillboardGui", folder)
        bGui.AlwaysOnTop = true
        bGui.Size = UDim2.new(0, 200, 0, 50)
        bGui.ExtentsOffset = Vector3.new(0, 3, 0)
        
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

        -- 3D Бокс (Adornment)
        local box3D = Instance.new("BoxHandleAdornment", folder)
        box3D.Size = Vector3.new(4, 5.5, 4)
        box3D.AlwaysOnTop = true
        box3D.ZIndex = 5
        box3D.Transparency = 0.5
        box3D.Visible = false

        -- 2D Бокс на основе интерфейса (Прямоугольник)
        local bGui2D = Instance.new("BillboardGui", folder)
        bGui2D.AlwaysOnTop = true
        bGui2D.Size = UDim2.new(0, 4.5, 0, 6)
        
        local stroke2D = Instance.new("UIStroke", Instance.new("Frame", bGui2D))
        stroke2D.Parent.Size = UDim2.new(1, 0, 1, 0)
        stroke2D.Parent.BackgroundTransparency = 1
        stroke2D.Color = Color3.fromRGB(255, 255, 255)
        stroke2D.Thickness = 1.5
        bGui2D.Enabled = false

        -- Полоска здоровья (Health Bar)
        local healthFrame = Instance.new("Frame", bGui2D.Frame)
        healthFrame.Size = UDim2.new(0, 3, 1, 0)
        healthFrame.Position = UDim2.new(0, -8, 0, 0)
        healthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFrame.BorderSizePixel = 0
        healthFrame.Visible = false

        -- Цикл постоянного обновления
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not folder or not folder.Parent or not _G.GhostyConfig then
                connection:Disconnect()
                return
            end

            local active = _G.GhostyConfig.EspEnabled and humanoid.Health > 0
            if active then
                bGui.Adornee = root
                bGui2D.Adornee = root
                box3D.Adornee = root

                -- Чекбокс никнеймов
                nameLabel.Visible = _G.GhostyConfig.EspNames
                
                -- Чекбокс Дистанции (Работает отдельно)
                if _G.GhostyConfig.EspDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.round((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    distLabel.Text = dist .. "m"
                    distLabel.Visible = true
                    -- Если ник скрыт, поднимаем дистанцию выше
                    distLabel.Position = _G.GhostyConfig.EspNames and UDim2.new(0,0,0,20) or UDim2.new(0,0,0,0)
                else
                    distLabel.Visible = false
                end

                -- Чекбокс 3D Боксов
                if _G.GhostyConfig.EspBoxes3D then
                    box3D.Visible = true
                    box3D.Color3 = _G.GhostyConfig.BoxColor
                    if _G.GhostyConfig.FillEnabled then
                        box3D.Transparency = _G.GhostyConfig.FillTransparency
                    else
                        box3D.Transparency = 1 -- Оставляем невидимым если заливка выключена
                    end
                else
                    box3D.Visible = false
                end

                -- Чекбокс 2D Боксов
                if _G.GhostyConfig.EspBoxes2D and not _G.GhostyConfig.EspBoxes3D then
                    bGui2D.Enabled = true
                    stroke2D.Color = _G.GhostyConfig.BoxColor
                    if _G.GhostyConfig.FillEnabled then
                        stroke2D.Parent.BackgroundTransparency = _G.GhostyConfig.FillTransparency
                        stroke2D.Parent.BackgroundColor3 = _G.GhostyConfig.FillColor
                    else
                        stroke2D.Parent.BackgroundTransparency = 1
                    end
                else
                    bGui2D.Enabled = false
                end

                -- Чекбокс здоровья
                if _G.GhostyConfig.EspHealth and _G.GhostyConfig.EspBoxes2D then
                    local hpPercent = humanoid.Health / humanoid.MaxHealth
                    healthFrame.Size = UDim2.new(0, 3, hpPercent, 0)
                    healthFrame.Position = UDim2.new(0, -8, 1 - hpPercent, 0)
                    healthFrame.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                    healthFrame.Visible = true
                else
                    healthFrame.Visible = false
                end
            else
                nameLabel.Visible = false
                distLabel.Visible = false
                box3D.Visible = false
                bGui2D.Enabled = false
            end
        end)
    end

    if player.Character then applyVisuals(player.Character) end
    player.CharacterAdded:Connect(applyVisuals)
end

for _, p in ipairs(Players:GetPlayers()) do CreatePlayerEsp(p) end
Players.PlayerAdded:Connect(CreatePlayerEsp)
