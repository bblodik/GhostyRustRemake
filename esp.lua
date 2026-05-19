local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
    
    local Health = Drawing.new("Line")
    Health.Visible = false
    Health.Thickness = 2
    Health.Color = Color3.fromRGB(0, 255, 0)

    local function Updater()
        local Connection
        Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not _G.GhostyConfig or not game:GetService("CoreGui"):FindFirstChild("GhostyMenu") then
                Box:Destroy() Fill:Destroy() Line:Destroy() Name:Destroy() Health:Destroy()
                Connection:Disconnect()
                return
            end
            
            local char = player.Character
            if _G.GhostyConfig.EspEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    -- Рассчитываем динамический размер бокса от расстояния
                    local scale = 1 / (screenPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                    local w, h = 3 * scale, 4.5 * scale
                    local x, y = screenPos.X - w / 2, screenPos.Y - h / 2
                    
                    -- 2D Boxes & Fill
                    if _G.GhostyConfig.EspBoxes2D then
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
                    else Box.Visible = false Fill.Visible = false end
                    
                    -- Snap Lines
                    if _G.GhostyConfig.EspLines then
                        Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Line.To = Vector2.new(screenPos.X, screenPos.Y + (h/2))
                        Line.Color = _G.GhostyConfig.BoxColor
                        Line.Visible = true
                    else Line.Visible = false end
                    
                    -- Names & Distance
                    if _G.GhostyConfig.EspNames then
                        local distText = _G.GhostyConfig.EspDistance and " ["..math.round(screenPos.Z).."m]" or ""
                        Name.Text = player.Name .. distText
                        Name.Position = Vector2.new(screenPos.X, y - 16)
                        Name.Color = Color3.fromRGB(255, 255, 255)
                        Name.Visible = true
                    else Name.Visible = false end
                    
                    -- Health Bar
                    if _G.GhostyConfig.EspHealth then
                        local healthPercent = char.Humanoid.Health / char.Humanoid.MaxHealth
                        Health.From = Vector2.new(x - 5, y + h)
                        Health.To = Vector2.new(x - 5, y + h - (h * healthPercent))
                        Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        Health.Visible = true
                    else Health.Visible = false end
                    
                else
                    Box.Visible = false Fill.Visible = false Line.Visible = false Name.Visible = false Health.Visible = false
                end
            else
                Box.Visible = false Fill.Visible = false Line.Visible = false Name.Visible = false Health.Visible = false
            end
        end)
    end
    task.spawn(Updater)
end

for _, p in ipairs(Players:GetPlayers()) do CreateEsp(p) end
Players.PlayerAdded:Connect(CreateEsp)
