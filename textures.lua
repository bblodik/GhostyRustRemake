local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")

local originalMaterialOverride = MaterialService.Use2022Materials
local originalGlobalShadows = Lighting.GlobalShadows

game:GetService("RunService").RenderStepped:Connect(function()
    if not _G.GhostyConfig or not game:GetService("CoreGui"):FindFirstChild("GhostyMenu") then return end

    if _G.GhostyConfig.NoTextures then
        -- Экстремальный режим удаления текстур без изменения объектов
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        
        -- Сдвигаем настройки видимости текстур через глобальный рендер
        pcall(function()
            sethiddenproperty(workspace, "StreamingTargetRadius", 64)
            sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
        end)
    else
        -- Возвращаем всё к исходным игровым настройкам
        Lighting.GlobalShadows = originalGlobalShadows
    end
end)
