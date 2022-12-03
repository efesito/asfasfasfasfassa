local ILikeBigBootyLatinas = {}
local MainLoop = nil
local Camera = workspace.CurrentCamera
local Viewport = Camera.ViewportSize
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Head = Character.Head
local Mouse = LocalPlayer:GetMouse()
local FOV = nil
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local MousePosition = function()
    return Vector2.new(Mouse.X,Mouse.Y)
end
local NotObstructing = function(destination, ignore) -- Rewrote by Stefanuk12
    local Origin = workspace.CurrentCamera.CFrame.p
    local CheckRay = Ray.new(Origin, destination- Origin)
    local Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
    return Hit == nil
end
local ClosestPlayer = function(friendlyfire)
    local MousePos = MousePosition()
    local Radius = FOV.Radius
    local Closest = math.huge
    local Target = nil
    local function HandleTeam(player)
        local Team = LocalPlayer.Team
        local Result = true
        if player.Team == Team and friendlyfire then
            Result = true
        elseif player.Team == Team and friendlyfire == false then
            Result = false
        else
            Result = true
        end
        return Result
    end
    for k,v in pairs(Players:GetPlayers()) do
        pcall(function()
            if HandleTeam(v) then
                if v.Character:FindFirstChild("Head") and v ~= LocalPlayer then
                    local Point,OnScreen = Camera:WorldToScreenPoint(v.Character.Head.Position)
                    local Char = game.Players.LocalPlayer.Character
                    if OnScreen and NotObstructing(v.Character.Head.Position,{Char,v.Character}) then
                        local Distance = (Vector2.new(Point.X,Point.Y) - MousePosition()).magnitude
                        if Distance < math.min(Radius,Closest) then
                            Closest = Distance
                            Target = v
                        end
                    end
                end
            end
        end)
    end
    return Target
end
local RefreshInternals = function()
    Camera = workspace.CurrentCamera
    LocalPlayer = Players.LocalPlayer
    Character = LocalPlayer.Character
    Head = Character.Head
end
 
ILikeBigBootyLatinas.Disable = function()
    if MainLoop then
        MainLoop:Disconnect()
        MainLoop = nil
    end
    if FOV then
        FOV:Remove()
    end
    RefreshInternals()
end
 
ILikeBigBootyLatinas.Enable = function(showfov,fovconfig,key,friendlyfire)
    assert(typeof(showfov)=="boolean","ILikeBigBootyLatinas.Enable | Expected Boolean as argument #1")
    assert(typeof(fovconfig)=="table","ILikeBigBootyLatinas.Enable | Expected Table as argument #2")
    assert(fovconfig["Size"],"ILikeBigBootyLatinas.Enable | Expected Size in argument #2")
    assert(fovconfig["Sides"],"ILikeBigBootyLatinas.Enable | Expected Sides in argument #2")
    assert(fovconfig["Color"],"ILikeBigBootyLatinas.Enable | Expected Color in argument #2")
    assert(type(fovconfig["Size"])=="number","ILikeBigBootyLatinas.Enable | Expected Size in argument #2")
    assert(type(fovconfig["Sides"])=="number","ILikeBigBootyLatinas.Enable | Expected Sides in argument #2")
    assert(typeof(fovconfig["Color"])=="Color3","ILikeBigBootyLatinas.Enable | Expected Color in argument #2")
    assert(type(key)=="string","ILikeBigBootyLatinas.Enable | Expected String as argument #3")
    assert(type(friendlyfire)=="boolean","ILikeBigBootyLatinas.Enable | Expected Boolean as argument #4")
    local Size = fovconfig["Size"]
    local Sides = fovconfig["Sides"]
    local Color = fovconfig["Color"]
    if showfov then
        FOV = Drawing.new("Circle")
        local FOV = FOV
        FOV.NumSides = Sides
        FOV.Position = MousePosition()
        FOV.Radius = Size
        FOV.Thickness = 2
        FOV.Radius = Size
        FOV.Color = Color
        FOV.Visible = true
    end
    MainLoop = RunService.RenderStepped:Connect(function()
        if FOV then
            FOV.Position = MousePosition()
        end
        if InputService:IsKeyDown(Enum.KeyCode[key]) then
            local ClosestPlayer = ClosestPlayer(friendlyfire)
            if ClosestPlayer then
                Camera.CFrame = CFrame.new(Camera.CFrame.p,ClosestPlayer.Character.Head.CFrame.p)
            end
            RefreshInternals()
        end
    end)
end
 
return ILikeBigBootyLatinas
