local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function ApplyChams(player)
    if player == LocalPlayer then return end
    
    local function characterAdded(char)
        local highlight = Instance.new("Highlight")
        highlight.Name = "GhostyChams"
        highlight.Parent = char
        
        local Connection
        Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not _G.GhostyConfig or not game:GetService("CoreGui"):FindFirstChild("GhostyMenu") then
                highlight:Destroy()
                Connection:Disconnect()
                return
            end
            
            if _G.GhostyConfig.ChamsEnabled then
                highlight.Enabled = true
                highlight.FillColor = _G.GhostyConfig.ChamsFillColor
                highlight.FillTransparency = _G.GhostyConfig.ChamsFillTransparency
                highlight.OutlineColor = _G.GhostyConfig.ChamsOutlineColor
                highlight.DepthMode = _G.GhostyConfig.ChamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.Always
            else
                highlight.Enabled = false
            end
        end)
    end
    
    if player.Character then characterAdded(player.Character) end
    player.CharacterAdded:Connect(characterAdded)
end

for _, p in ipairs(Players:GetPlayers()) do ApplyChams(p) end
Players.PlayerAdded:Connect(ApplyChams)
