-- Raw 1x1 white PNG data for Image objects
local pixel = string.char(137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83, 222, 0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 248, 255, 255, 63, 0, 5, 254, 2, 254, 137, 28, 73, 10, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130)

-- Services
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize

-- GUI Configuration
local windowSize = Vector2.new(400, 300)
local windowPos = (screenSize - windowSize) / 2
local headerHeight = 40
local leftWidth = 150
local rounding = 10
local btnRounding = 5
local normalColor = Color3.fromRGB(50, 50, 50)
local hoverColor = Color3.fromRGB(70, 70, 70)
local selectedColor = Color3.fromRGB(0, 120, 200)
local textColor = Color3.new(1, 1, 1)
local bgColor = Color3.fromRGB(30, 30, 30)
local shadowColor = Color3.new(0, 0, 0)
local shadowOffset = Vector2.new(5, 5)
local shadowTransparency = 0.3

-- Menu Structure
local menus = {"Combat", "Player", "World", "Teleport", "Settings"}
local features = {
    Combat = {"Auto Farm", "Kill Aura", "ESP"},
    Player = {"Speed", "Jump Power", "God Mode"},
    World = {"No Clip", "Day/Night Cycle", "Infinite Resources"},
    Teleport = {"TP to Player", "TP to Location", "Safe TP"},
    Settings = {"Theme", "Keybinds", "Credits"}
}

-- State
local selected = 1
local minimized = false
local dragging = false
local dragStart = nil
local startPos = nil

-- Drawing Objects
local shadow = Drawing.new("Image")
shadow.Data = pixel
shadow.Size = windowSize + shadowOffset * 2
shadow.Position = windowPos + shadowOffset
shadow.Rounding = rounding
shadow.Color = shadowColor
shadow.Transparency = shadowTransparency
shadow.ZIndex = 0
shadow.Visible = true

local bg = Drawing.new("Image")
bg.Data = pixel
bg.Size = windowSize
bg.Position = windowPos
bg.Rounding = rounding
bg.Color = bgColor
bg.Transparency = 1
bg.ZIndex = 1
bg.Visible = true

local header = Drawing.new("Text")
header.Text = "Arkan Scripts"
header.Size = 24
header.Font = Drawing.Fonts.UI
header.Color = textColor
header.Center = true
header.ZIndex = 2
header.Visible = true
header.Position = windowPos + Vector2.new(windowSize.X / 2, 10)

local minBtn = Drawing.new("Circle")
minBtn.Radius = 10
minBtn.NumSides = 32
minBtn.Filled = true
minBtn.Color = Color3.fromRGB(200, 0, 0)
minBtn.Transparency = 1
minBtn.ZIndex = 2
minBtn.Visible = true
minBtn.Position = windowPos + Vector2.new(windowSize.X - 20, 20)

local separator = Drawing.new("Line")
separator.From = windowPos + Vector2.new(leftWidth, headerHeight)
separator.To = windowPos + Vector2.new(leftWidth, windowSize.Y - 10)
separator.Thickness = 1
separator.Color = Color3.fromRGB(100, 100, 100)
separator.Transparency = 1
separator.ZIndex = 2
separator.Visible = true

local menuBgs = {}
local menuTexts = {}
for i, name in ipairs(menus) do
    local btnPos = windowPos + Vector2.new(10, headerHeight + 10 + (i - 1) * 35)
    local btnBg = Drawing.new("Image")
    btnBg.Data = pixel
    btnBg.Size = Vector2.new(leftWidth - 20, 25)
    btnBg.Position = btnPos
    btnBg.Rounding = btnRounding
    btnBg.Color = normalColor
    btnBg.Transparency = 1
    btnBg.ZIndex = 1
    btnBg.Visible = true
    menuBgs[i] = btnBg

    local txt = Drawing.new("Text")
    txt.Text = name
    txt.Size = 18
    txt.Font = Drawing.Fonts.UI
    txt.Color = textColor
    txt.Center = true
    txt.ZIndex = 2
    txt.Visible = true
    txt.Position = btnPos + Vector2.new(btnBg.Size.X / 2, (btnBg.Size.Y - txt.TextBounds.Y) / 2)
    menuTexts[i] = txt
end

local featureTexts = {}

local minCircle = Drawing.new("Circle")
minCircle.Radius = 20
minCircle.NumSides = 32
minCircle.Filled = true
minCircle.Color = bgColor
minCircle.Transparency = 1
minCircle.ZIndex = 1
minCircle.Visible = false
minCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

local minText = Drawing.new("Text")
minText.Text = "A"
minText.Size = 20
minText.Font = Drawing.Fonts.UI
minText.Color = textColor
minText.Center = true
minText.ZIndex = 2
minText.Visible = false
minText.Position = minCircle.Position - Vector2.new(0, minText.TextBounds.Y / 2)

-- Functions
local function updatePositions()
    -- No need since window is not draggable, only minimized is
end

local function updateRightPanel()
    for _, t in ipairs(featureTexts) do
        t:Destroy()
    end
    featureTexts = {}
    local list = features[menus[selected]]
    for i, f in ipairs(list) do
        local txt = Drawing.new("Text")
        txt.Text = "- " .. f
        txt.Size = 16
        txt.Font = Drawing.Fonts.UI
        txt.Color = textColor
        txt.Position = windowPos + Vector2.new(leftWidth + 10, headerHeight + 10 + (i - 1) * 25)
        txt.ZIndex = 2
        txt.Visible = true
        table.insert(featureTexts, txt)
    end
end

local function toggleMinimize()
    minimized = not minimized
    if minimized then
        shadow.Visible = false
        bg.Visible = false
        header.Visible = false
        minBtn.Visible = false
        separator.Visible = false
        for _, bg in ipairs(menuBgs) do bg.Visible = false end
        for _, txt in ipairs(menuTexts) do txt.Visible = false end
        for _, txt in ipairs(featureTexts) do txt.Visible = false end
        minCircle.Visible = true
        minText.Visible = true
        minText.Position = minCircle.Position - Vector2.new(0, minText.TextBounds.Y / 2)
    else
        shadow.Visible = true
        bg.Visible = true
        header.Visible = true
        minBtn.Visible = true
        separator.Visible = true
        for _, bg in ipairs(menuBgs) do bg.Visible = true end
        for _, txt in ipairs(menuTexts) do txt.Visible = true end
        updateRightPanel()
        minCircle.Visible = false
        minText.Visible = false
    end
end

-- Initial Setup
updateRightPanel()

-- Input Handling
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        if not minimized then
            -- Minimize button
            if (mousePos - minBtn.Position).Magnitude <= minBtn.Radius + 2 then  -- +2 for accuracy buffer
                toggleMinimize()
                return
            end
            -- Menu buttons
            for i, btnBg in ipairs(menuBgs) do
                local topLeft = btnBg.Position
                local bottomRight = topLeft + btnBg.Size
                if mousePos.X >= topLeft.X - 2 and mousePos.X <= bottomRight.X + 2 and  -- Buffer for accuracy
                   mousePos.Y >= topLeft.Y - 2 and mousePos.Y <= bottomRight.Y + 2 then
                    selected = i
                    updateRightPanel()
                    return
                end
            end
        else
            -- Minimized circle
            if (mousePos - minCircle.Position).Magnitude <= minCircle.Radius + 2 then  -- Buffer
                dragging = true
                dragStart = mousePos
                startPos = minCircle.Position
            end
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local delta = mousePos - dragStart
        minCircle.Position = startPos + delta
        minText.Position = minCircle.Position - Vector2.new(0, minText.TextBounds.Y / 2)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if dragging then
            local mousePos = Vector2.new(mouse.X, mouse.Y)
            if (mousePos - dragStart).Magnitude < 5 then  -- Click threshold
                toggleMinimize()
            end
            dragging = false
        end
    end
end)

-- Hover and Selected Visuals
RS.RenderStepped:Connect(function()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    for i, btnBg in ipairs(menuBgs) do
        local isHover = false
        local topLeft = btnBg.Position
        local bottomRight = topLeft + btnBg.Size
        if mousePos.X >= topLeft.X and mousePos.X <= bottomRight.X and
           mousePos.Y >= topLeft.Y and mousePos.Y <= bottomRight.Y then
            isHover = true
        end
        if i == selected then
            btnBg.Color = selectedColor
        elseif isHover then
            btnBg.Color = hoverColor
        else
            btnBg.Color = normalColor
        end
    end
end)

-- Cleanup on script end (optional, but good practice)
-- cleardrawcache() can be called if needed
