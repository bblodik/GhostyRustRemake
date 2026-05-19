local Players = game:GetService("Players")
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
