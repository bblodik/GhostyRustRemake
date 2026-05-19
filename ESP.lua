local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ESP_Cache = {}

-- Функция для создания чёткой обводки текста
local function НавеситьЧеткийКонтур(label)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.8
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.JoinMode = Enum.LineJoinMode.Round
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = label
end

local function CreatePlayerEsp(player)
	if player == LocalPlayer then return end

	local function applyVisuals(char)
		if ESP_Cache[player] then
			pcall(function()
				-- Уничтожаем Drawing линии если есть
				if ESP_Cache[player].SnapLine then
					ESP_Cache[player].SnapLine:Remove()
				end
				ESP_Cache[player].Folder:Destroy()
			end)
			ESP_Cache[player] = nil
		end

		local root = char:WaitForChild("HumanoidRootPart", 5)
		local humanoid = char:WaitForChild("Humanoid", 5)
		if not root or not humanoid then return end

		local folder = Instance.new("Folder")
		folder.Name = "GhostyEspTag"
		folder.Parent = char

		-- 1. Ники (BillboardGui сверху головы)
		local bGuiName = Instance.new("BillboardGui", folder)
		bGuiName.AlwaysOnTop = true
		bGuiName.Size = UDim2.new(0, 200, 0, 25)
		bGuiName.ExtentsOffset = Vector3.new(0, 3, 0)
		bGuiName.Adornee = root

		local nameLabel = Instance.new("TextLabel", bGuiName)
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 13
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Visible = false
		НавеситьЧеткийКонтур(nameLabel)

		-- 2. Дистанция (BillboardGui снизу ног)
		local bGuiDist = Instance.new("BillboardGui", folder)
		bGuiDist.AlwaysOnTop = true
		bGuiDist.Size = UDim2.new(0, 200, 0, 25)
		bGuiDist.ExtentsOffset = Vector3.new(0, -3.5, 0)
		bGuiDist.Adornee = root

		local distLabel = Instance.new("TextLabel", bGuiDist)
		distLabel.Size = UDim2.new(1, 0, 1, 0)
		distLabel.BackgroundTransparency = 1
		distLabel.TextColor3 = Color3.fromRGB(45, 140, 255)
		distLabel.TextSize = 12
		distLabel.Font = Enum.Font.GothamBold
		distLabel.Visible = false
		НавеситьЧеткийКонтур(distLabel)

		-- 3. 3D Бокс с заливкой (BoxHandleAdornment)
		local box3DFill = Instance.new("BoxHandleAdornment", folder)
		box3DFill.Size = Vector3.new(4, 5.5, 4)
		box3DFill.AlwaysOnTop = true
		box3DFill.ZIndex = 4
		box3DFill.Adornee = root
		box3DFill.Visible = false

		-- 4. 3D Бокс каркас (SelectionBox)
		local box3DWire = Instance.new("SelectionBox", folder)
		box3DWire.Adornee = root
		box3DWire.LineThickness = 0.04
		box3DWire.AlwaysOnTop = true
		box3DWire.Visible = false

		-- 5. 2D Бокс (BillboardGui каркас)
		local bGui2D = Instance.new("BillboardGui", folder)
		bGui2D.AlwaysOnTop = true
		bGui2D.Size = UDim2.new(0, 4.3, 0, 5.8)
		bGui2D.Adornee = root
		bGui2D.Enabled = false

		local frame2D = Instance.new("Frame", bGui2D)
		frame2D.Size = UDim2.new(1, 0, 1, 0)
		frame2D.BackgroundTransparency = 1

		local stroke2D = Instance.new("UIStroke", frame2D)
		stroke2D.Thickness = 1.8
		stroke2D.Color = Color3.fromRGB(255, 255, 255)

		-- 6. Полоска здоровья (Health Bar) — ИСПРАВЛЕНО
		-- Подложка (фон HP бара)
		local healthBg = Instance.new("Frame", frame2D)
		healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		healthBg.BorderSizePixel = 0
		healthBg.ZIndex = 1
		healthBg.Visible = false

		-- Заливка HP (якорим снизу, растём вверх)
		local healthFrame = Instance.new("Frame", healthBg)
		healthFrame.AnchorPoint = Vector2.new(0, 1)
		healthFrame.Position = UDim2.new(0, 1, 1, 0)
		healthFrame.Size = UDim2.new(1, -2, 1, -2)
		healthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		healthFrame.BorderSizePixel = 0
		healthFrame.ZIndex = 2
		healthFrame.Visible = false

		-- 7. Снап-линии через Drawing — ИСПРАВЛЕНО (убран LineHandleAdornment)
		local snapLine = Drawing.new("Line")
		snapLine.Visible = false
		snapLine.Thickness = 1.5
		snapLine.Color = Color3.fromRGB(255, 255, 255)
		snapLine.Transparency = 1  -- Drawing: 1 = полностью видим

		ESP_Cache[player] = {
			Folder      = folder,
			Root        = root,
			Humanoid    = humanoid,
			NameLabel   = nameLabel,
			DistLabel   = distLabel,
			Box3DFill   = box3DFill,
			Box3DWire   = box3DWire,
			BGui2D      = bGui2D,
			Frame2D     = frame2D,
			Stroke2D    = stroke2D,
			HealthFrame = healthFrame,
			HealthBg    = healthBg,
			SnapLine    = snapLine
		}
	end

	if player.Character then applyVisuals(player.Character) end
	player.CharacterAdded:Connect(applyVisuals)
end

local function RemovePlayerEsp(player)
	if ESP_Cache[player] then
		pcall(function()
			if ESP_Cache[player].SnapLine then
				ESP_Cache[player].SnapLine:Remove()
			end
			ESP_Cache[player].Folder:Destroy()
		end)
		ESP_Cache[player] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do CreatePlayerEsp(p) end
Players.PlayerAdded:Connect(CreatePlayerEsp)
Players.PlayerRemoving:Connect(RemovePlayerEsp)

-- ГЛОБАЛЬНЫЙ ЕДИНЫЙ ЦИКЛ ОБРАБОТКИ
local LastBoxColor, LastFillColor, LastFillTrans, LastFillEnabled, LastHPPos = nil, nil, nil, nil, nil

RunService.RenderStepped:Connect(function()
	local config = _G.GhostyConfig
	if not config then return end

	local hpPosition = config.HealthPosition or "Left"

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera

	local colorChanged = (LastBoxColor ~= config.BoxColor)
		or (LastFillColor ~= config.FillColor)
		or (LastFillTrans ~= config.FillTransparency)
		or (LastFillEnabled ~= config.FillEnabled)
		or (LastHPPos ~= hpPosition)

	if colorChanged then
		LastBoxColor    = config.BoxColor
		LastFillColor   = config.FillColor
		LastFillTrans   = config.FillTransparency
		LastFillEnabled = config.FillEnabled
		LastHPPos       = hpPosition
	end

	local espEnabled  = config.EspEnabled
	local showNames   = config.EspNames
	local showDist    = config.EspDistance
	local show3D      = config.EspBoxes3D
	local show2D      = config.EspBoxes2D
	local showHealth  = config.EspHealth
	local fillEnabled = config.FillEnabled
	local showLines   = config.EspLines

	for player, data in pairs(ESP_Cache) do
		if not data.Folder or not data.Folder.Parent then
			-- Чистим Drawing перед удалением из кэша
			pcall(function()
				if data.SnapLine then data.SnapLine:Remove() end
			end)
			ESP_Cache[player] = nil
			continue
		end

		local humanoid = data.Humanoid

		if espEnabled and humanoid and humanoid.Health > 0 and data.Root then

			-- 1. Никнеймы
			data.NameLabel.Visible = showNames

			-- 2. Дистанция
			if showDist and myRoot then
				local dist = math.round((data.Root.Position - myRoot.Position).Magnitude)
				data.DistLabel.Text = dist .. "m"
				data.DistLabel.Visible = true
			else
				data.DistLabel.Visible = false
			end

			-- 3. 3D Боксы
			if show3D then
				if fillEnabled then
					data.Box3DWire.Visible = false
					data.Box3DFill.Visible = true
					if colorChanged then
						data.Box3DFill.Color3 = config.BoxColor
						data.Box3DFill.Transparency = config.FillTransparency
					end
				else
					data.Box3DFill.Visible = false
					data.Box3DWire.Visible = true
					if colorChanged then
						data.Box3DWire.Color3 = config.BoxColor
					end
				end
			else
				data.Box3DFill.Visible = false
				data.Box3DWire.Visible = false
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

			-- 5. Полоска здоровья — ИСПРАВЛЕНО
			if showHealth and show2D and not show3D then
				local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)

				-- Позиционируем фон HP бара (слева или справа от 2D бокса)
				if hpPosition == "Right" then
					data.HealthBg.Position = UDim2.new(1, 5, 0, -1)
				else -- Left
					data.HealthBg.Position = UDim2.new(0, -9, 0, -1)
				end
				data.HealthBg.Size = UDim2.new(0, 5, 1, 2)
				data.HealthBg.Visible = true

				-- Заливка растёт снизу вверх через AnchorPoint
				-- healthFrame является дочерним healthBg, растём внутри него
				data.HealthFrame.AnchorPoint = Vector2.new(0, 1)
				data.HealthFrame.Position    = UDim2.new(0, 1, 1, -1)
				data.HealthFrame.Size        = UDim2.new(1, -2, hpPercent, 0)
				data.HealthFrame.BackgroundColor3 = Color3.fromRGB(
					math.floor(255 * (1 - hpPercent)),
					math.floor(255 * hpPercent),
					0
				)
				data.HealthFrame.Visible = true
			else
				data.HealthFrame.Visible = false
				data.HealthBg.Visible    = false
			end

			-- 6. Снап-линии через Drawing — ИСПРАВЛЕНО
			if showLines and camera then
				local rootPos = data.Root.Position
				local screenPos, onScreen = camera:WorldToViewportPoint(rootPos)

				if onScreen then
					local viewportSize = camera.ViewportSize
					-- Линия от нижнего центра экрана до позиции игрока на экране
					data.SnapLine.From        = Vector2.new(viewportSize.X / 2, viewportSize.Y)
					data.SnapLine.To          = Vector2.new(screenPos.X, screenPos.Y)
					data.SnapLine.Color       = config.BoxColor
					data.SnapLine.Visible     = true
				else
					data.SnapLine.Visible = false
				end
			else
				data.SnapLine.Visible = false
			end

		else
			-- Выключаем всё
			data.NameLabel.Visible    = false
			data.DistLabel.Visible    = false
			data.Box3DFill.Visible    = false
			data.Box3DWire.Visible    = false
			data.BGui2D.Enabled       = false
			data.HealthFrame.Visible  = false
			data.HealthBg.Visible     = false
			data.SnapLine.Visible     = false
		end
	end
end)
