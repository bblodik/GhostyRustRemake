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
        folder.Parent = char

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
