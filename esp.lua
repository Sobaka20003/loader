local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local localplr = plrs.LocalPlayer
local cache = {}

for _,p in pairs(plrs:GetPlayers()) do if p~=localplr then
    cache[p] = {Drawing.new("Square"), Drawing.new("Text")}
    cache[p][1].Thickness = 2 cache[p][1].Filled = false
    cache[p][2].Size = 14 cache[p][2].Center = true
end end

plrs.PlayerAdded:Connect(function(p)
    cache[p] = {Drawing.new("Square"), Drawing.new("Text")}
    cache[p][1].Thickness = 2 cache[p][1].Filled = false
    cache[p][2].Size = 14 cache[p][2].Center = true
end)

plrs.PlayerRemoving:Connect(function(p)
    if cache[p] then for _,d in pairs(cache[p]) do d:Remove() end cache[p]=nil end
end)

run.RenderStepped:Connect(function()
    for p,d in pairs(cache) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local pos,vis = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if vis then
                local scale = 2000/pos.Z
                local size = Vector2.new(scale*2, scale*3)
                local pos2d = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                d[1].Visible = true d[1].Size = size d[1].Position = pos2d
                d[2].Visible = true d[2].Text = p.Name d[2].Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 20)
                d[1].Color = p.Team==localplr.Team and Color3.new(0,1,0) or Color3.new(1,0,0)
                d[2].Color = p.Team==localplr.Team and Color3.new(0,1,0) or Color3.new(1,0,0)
            else for _,obj in pairs(d) do obj.Visible = false end end
        else for _,obj in pairs(d) do obj.Visible = false end end
    end
end)
