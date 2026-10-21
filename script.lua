local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("Yunium")
if existing then existing:Destroy() end

local C = {
    bg = Color3.fromRGB(15, 16, 19),
    top = Color3.fromRGB(18, 19, 23),
    panel = Color3.fromRGB(23, 24, 29),
    row = Color3.fromRGB(28, 29, 35),
    pink = Color3.fromRGB(255, 111, 177),
    pinkDim = Color3.fromRGB(91, 48, 69),
    text = Color3.fromRGB(236, 236, 241),
    muted = Color3.fromRGB(139, 141, 153),
    line = Color3.fromRGB(48, 49, 58),
}

local function create(className, properties, parent)
    local obj = Instance.new(className)
    for key, value in pairs(properties or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius)}, obj)
end

local function outline(obj, color, thickness, transparency)
    create("UIStroke", {
        Color = color or C.line,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, obj)
end

local gui = create("ScreenGui", {
    Name = "Yunium",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(560, 360),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, gui)
round(main, 12)
outline(main, C.line, 1, 0.12)

local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 49),
    BackgroundColor3 = C.top,
    BorderSizePixel = 0,
}, main)
round(header, 12)
create("Frame", {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = C.top,
    BorderSizePixel = 0,
}, header)

local brand = create("TextLabel", {
    Name = "Brand",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(17, 0),
    Size = UDim2.fromOffset(105, 49),
    Font = Enum.Font.GothamBold,
    Text = "Yunium",
    TextSize = 19,
    TextColor3 = C.pink,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local tabHolder = create("Frame", {
    Name = "Tabs",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(127, 9),
    Size = UDim2.fromOffset(235, 31),
}, header)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, tabHolder)

local page = create("ScrollingFrame", {
    Name = "Page",
    Position = UDim2.fromOffset(12, 60),
    Size = UDim2.new(1, -24, 1, -72),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.pink,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
create("UIPadding", {
    PaddingTop = UDim.new(0, 3),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 6),
}, page)
local pageLayout = create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, page)

local function clearPage()
    for _, child in ipairs(page:GetChildren()) do
        if child ~= pageLayout and child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function heading(text)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -3, 0, 19),
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, page)
end

local function toggleRow(label, defaultValue, callback)
    local row = create("Frame", {
        Size = UDim2.new(1, -3, 0, 31),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, page)

    local dot = create("TextButton", {
        Name = "Toggle",
        AutoButtonColor = false,
        Position = UDim2.fromOffset(5, 8),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = defaultValue and C.pink or C.row,
        Text = "",
        BorderSizePixel = 0,
    }, row)
    round(dot, 10)
    outline(dot, defaultValue and C.pink or C.muted, 1, 0.15)

    local labelObj = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.Gotham,
        Text = label,
        TextSize = 12,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local enabled = defaultValue == true
    local function paint()
        dot.BackgroundColor3 = enabled and C.pink or C.row
        labelObj.TextColor3 = enabled and C.text or C.muted
        local s = dot:FindFirstChildOfClass("UIStroke")
        if s then s.Color = enabled and C.pink or C.muted end
    end
    dot.Activated:Connect(function()
        enabled = not enabled
        paint()
        if callback then callback(enabled) end
    end)
    paint()
    return function() return enabled end
end

local function sliderRow(label, minValue, maxValue, initial, callback)
    local holder = create("Frame", {
        Size = UDim2.new(1, -3, 0, 47),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, page)

    local value = initial
    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(5, 0),
        Size = UDim2.new(1, -10, 0, 20),
        Font = Enum.Font.Gotham,
        Text = label .. "  " .. tostring(value),
        TextSize = 11,
        TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local bar = create("TextButton", {
        Name = "SliderTrack",
        AutoButtonColor = false,
        Position = UDim2.new(0, 5, 0, 28),
        Size = UDim2.new(1, -13, 0, 5),
        BackgroundColor3 = C.line,
        Text = "",
        BorderSizePixel = 0,
    }, holder)
    round(bar, 4)

    local fill = create("Frame", {
        Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0),
        BackgroundColor3 = C.pink,
        BorderSizePixel = 0,
    }, bar)
    round(fill, 4)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - minValue) / (maxValue - minValue), 0, 0.5, 0),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = C.pink,
        BorderSizePixel = 0,
    }, bar)
    round(knob, 10)

    local dragging = false
    local function update(x)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(minValue + (maxValue - minValue) * alpha + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        title.Text = label .. "  " .. tostring(value)
        if callback then callback(value) end
    end
    bar.Activated:Connect(function()
        update(UserInputService:GetMouseLocation().X)
    end)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Feature Logic Variables
local aimbotEnabled = false
local silentAimEnabled = false
local showFovEnabled = false
local fovRadius = 120
local fovRange = 250
local gFlyEnabled = false
local gFlyActive = false
local FLY_SPEED = 250

-- TP Walk & Hitbox Variables
local tpWalkSpeed = 16
local hitboxEnabled = false
local hitboxSize = 5
local TRANSPARENCY_VAL = 0.7

-- Skull Guitar Dash Configs
local skullGuitarDashEnabled = false
local DASH_SPEED = 200
local DASH_DURATION = 0.25
local isDashing = false

-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = C.pink
fovCircle.Filled = false
fovCircle.Transparency = 0.7

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = mousePos
    fovCircle.Radius = fovRadius
    fovCircle.Visible = showFovEnabled
end)

-- TP Walk Implementation
RunService.RenderStepped:Connect(function(dt)
    if tpWalkSpeed > 16 then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (tpWalkSpeed * dt))
        end
    end
end)

-- Hitbox Expander Logic
local function expandHitbox(character)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if rootPart then
        if hitboxEnabled then
            rootPart.Size = Vector3.new(2, 2, 1) + Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            rootPart.Transparency = TRANSPARENCY_VAL
            rootPart.CanCollide = false
        else
            rootPart.Size = Vector3.new(2, 2, 1)
            rootPart.Transparency = 1
            rootPart.CanCollide = true
        end
    end
end

local function updateAllHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            task.spawn(function()
                expandHitbox(p.Character)
            end)
        end
    end
    for _, enemy in ipairs(workspace:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(enemy) then
            task.spawn(function()
                expandHitbox(enemy)
            end)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if hitboxEnabled then
            task.wait(1)
            expandHitbox(char)
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    if hitboxEnabled then
        updateAllHitboxes()
    end
end)

-- Target Finder Utility
local function getBestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local shortestDist = fovRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local rootPart = p.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local worldDist = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    if dist < shortestDist and worldDist <= fovRange then
                        shortestDist = dist
                        closestTarget = rootPart
                    end
                end
            end
        end
    end

    for _, enemy in ipairs(workspace:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= player.Character then
            local hum = enemy.Humanoid
            if hum.Health > 0 and not Players:GetPlayerFromCharacter(enemy) then
                local rootPart = enemy.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local worldDist = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    if dist < shortestDist and worldDist <= fovRange then
                        shortestDist = dist
                        closestTarget = rootPart
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Aimbot (M2)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getBestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Silent Aim
RunService.RenderStepped:Connect(function()
    if silentAimEnabled then
        local target = getBestTarget()
        if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Skull Guitar Dash
UserInputService.InputBegan:Connect(function(input, processed)
    if not skullGuitarDashEnabled or isDashing then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
        local char = player.Character
        if not char then return end
        
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool.Name == "Skull Guitar" then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                isDashing = true
                task.spawn(function()
                    local startTime = tick()
                    while tick() - startTime < DASH_DURATION do
                        local dt = RunService.RenderStepped:Wait()
                        local lookDir = Camera.CFrame.LookVector
                        root.CFrame = root.CFrame + (Vector3.new(lookDir.X, 0, lookDir.Z).Unit * (DASH_SPEED * dt))
                    end
                    isDashing = false
                end)
            end
        end
    end
end)

-- G Fly Controls
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G and gFlyEnabled then
        gFlyActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        gFlyActive = false
    end
end)

RunService.Heartbeat:Connect(function()
    if gFlyEnabled and gFlyActive then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local vel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(vel.X, FLY_SPEED, vel.Z)
        end
    end
end)

local tabButtons = {}
local function showTab(name)
    for tabName, button in pairs(tabButtons) do
        local active = tabName == name
        button.TextColor3 = active and C.pink or C.muted
        button.BackgroundColor3 = active and C.pinkDim or C.top
    end
    clearPage()
    if name == "PVP" then
        heading("Aimbot")
        toggleRow("Aimbot (M2)", aimbotEnabled, function(state)
            aimbotEnabled = state
        end)
        heading("Silent Aim")
        toggleRow("Player Silent Aim", silentAimEnabled, function(state)
            silentAimEnabled = state
        end)
        toggleRow("Show fove circle", showFovEnabled, function(state)
            showFovEnabled = state
        end)
        sliderRow("Fov Radius", 0, 500, fovRadius, function(val)
            fovRadius = val
        end)
        sliderRow("Fov range", 0, 1000, fovRange, function(val)
            fovRange = val
        end)
        heading("Hitbox Expander")
        toggleRow("Expand Hitboxes", hitboxEnabled, function(state)
            hitboxEnabled = state
            if not state then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                        p.Character.HumanoidRootPart.Transparency = 1
                        p.Character.HumanoidRootPart.CanCollide = true
                    end
                end
            end
        end)
        sliderRow("Hitbox Size", 0, 10, hitboxSize, function(val)
            hitboxSize = val
        end)
        heading("Movement & Combos")
        sliderRow("TP WalkSpeed", 16, 1500, tpWalkSpeed, function(value)
            tpWalkSpeed = value
        end)
        toggleRow("G Fly  [G]", gFlyEnabled, function(state)
            gFlyEnabled = state
        end)
        toggleRow("Dash Skull Guitar", skullGuitarDashEnabled, function(state)
            skullGuitarDashEnabled = state
        end)
    elseif name == "MISC" then
        heading("Misc")
        toggleRow("Show UI status", true)
        toggleRow("Reduce animations", false)
    else
        heading("Config")
        toggleRow("Pink accent", true)
        create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -3, 0, 28),
            Font = Enum.Font.Gotham,
            Text = "Yunium • visual prototype",
            TextSize = 11,
            TextColor3 = C.muted,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, page)
    end
end

for i, name in ipairs({"PVP", "MISC", "CONFIG"}) do
    local button = create("TextButton", {
        Name = name .. "Tab",
        LayoutOrder = i,
        Size = UDim2.fromOffset(name == "CONFIG" and 72 or 61, 29),
        BackgroundColor3 = name == "PVP" and C.pinkDim or C.top,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = name == "PVP" and C.pink or C.muted,
    }, tabHolder)
    round(button, 5)
    tabButtons[name] = button
    button.Activated:Connect(function() showTab(name) end)
end

local dragging = false
local dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

showTab("PVP")

local guiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
    end
end)
