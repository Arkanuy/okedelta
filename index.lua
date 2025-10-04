-- Arkan Scripts GUI Manager dengan Drawing API
-- Unified Naming Convention (UNC) Compatible

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Konfigurasi
local screenSize = workspace.CurrentCamera.ViewportSize
local guiWidth = 600
local guiHeight = 400
local guiX = (screenSize.X - guiWidth) / 2
local guiY = (screenSize.Y - guiHeight) / 2
local cornerRadius = 12

-- State Management
local isMinimized = false
local selectedMenu = 1
local drawings = {}

-- Menu Data
local menuItems = {
    {name = "Main", features = {"Auto Farm", "Auto Click", "Speed Boost"}},
    {name = "Combat", features = {"Kill Aura", "Auto Aim", "No Recoil"}},
    {name = "Player", features = {"Fly", "Noclip", "Infinite Jump"}},
    {name = "Visual", features = {"ESP", "Tracers", "Chams"}},
    {name = "Misc", features = {"Anti AFK", "Chat Spy", "Teleport"}}
}

-- Fungsi Helper untuk membuat kotak rounded
local function createRoundedRect(x, y, w, h, color, filled, transparency)
    local rect = Drawing.new("Square")
    rect.Position = Vector2.new(x, y)
    rect.Size = Vector2.new(w, h)
    rect.Color = color
    rect.Filled = filled
    rect.Transparency = transparency or 1
    rect.Visible = true
    rect.ZIndex = 1
    return rect
end

-- Fungsi untuk membuat text
local function createText(text, x, y, size, color)
    local textObj = Drawing.new("Text")
    textObj.Text = text
    textObj.Position = Vector2.new(x, y)
    textObj.Size = size
    textObj.Color = color
    textObj.Font = Drawing.Fonts.Plex
    textObj.Visible = true
    textObj.ZIndex = 2
    return textObj
end

-- Fungsi untuk membuat circle
local function createCircle(x, y, radius, color, filled)
    local circle = Drawing.new("Circle")
    circle.Position = Vector2.new(x, y)
    circle.Radius = radius
    circle.Color = color
    circle.Filled = filled
    circle.NumSides = 32
    circle.Transparency = 1
    circle.Visible = true
    circle.ZIndex = 1
    return circle
end

-- Fungsi untuk clear semua drawings
local function clearDrawings()
    for _, drawing in pairs(drawings) do
        drawing:Destroy()
    end
    drawings = {}
end

-- Fungsi untuk draw GUI yang diminimize
local function drawMinimized()
    clearDrawings()
    
    local centerX = screenSize.X / 2
    local centerY = screenSize.Y / 2
    
    -- Background circle
    local bgCircle = createCircle(centerX, centerY, 35, Color3.fromRGB(30, 30, 35), true)
    table.insert(drawings, bgCircle)
    
    -- Border circle
    local borderCircle = createCircle(centerX, centerY, 35, Color3.fromRGB(100, 100, 255), false)
    borderCircle.Thickness = 2
    table.insert(drawings, borderCircle)
    
    -- Text "A"
    local aText = createText("A", centerX - 12, centerY - 18, 36, Color3.fromRGB(100, 100, 255))
    aText.Center = false
    table.insert(drawings, aText)
end

-- Fungsi untuk draw GUI yang expanded
local function drawExpanded()
    clearDrawings()
    
    -- Main Background
    local mainBg = createRoundedRect(guiX, guiY, guiWidth, guiHeight, Color3.fromRGB(25, 25, 30), true, 0.95)
    table.insert(drawings, mainBg)
    
    -- Border
    local border = createRoundedRect(guiX, guiY, guiWidth, guiHeight, Color3.fromRGB(100, 100, 255), false, 1)
    border.Thickness = 2
    table.insert(drawings, border)
    
    -- Header Background
    local headerBg = createRoundedRect(guiX, guiY, guiWidth, 50, Color3.fromRGB(35, 35, 40), true, 1)
    table.insert(drawings, headerBg)
    
    -- Header Line
    local headerLine = Drawing.new("Line")
    headerLine.From = Vector2.new(guiX, guiY + 50)
    headerLine.To = Vector2.new(guiX + guiWidth, guiY + 50)
    headerLine.Color = Color3.fromRGB(100, 100, 255)
    headerLine.Thickness = 2
    headerLine.Visible = true
    headerLine.ZIndex = 2
    table.insert(drawings, headerLine)
    
    -- Title Text
    local titleText = createText("Arkan Scripts", guiX + 20, guiY + 12, 24, Color3.fromRGB(100, 100, 255))
    table.insert(drawings, titleText)
    
    -- Minimize Button Background
    local minBtnBg = createCircle(guiX + guiWidth - 30, guiY + 25, 12, Color3.fromRGB(255, 100, 100), true)
    table.insert(drawings, minBtnBg)
    
    -- Minimize Button Text
    local minBtnText = createText("-", guiX + guiWidth - 37, guiY + 8, 24, Color3.fromRGB(255, 255, 255))
    table.insert(drawings, minBtnText)
    
    -- Left Menu Background
    local leftMenuBg = createRoundedRect(guiX + 10, guiY + 60, 150, guiHeight - 70, Color3.fromRGB(30, 30, 35), true, 1)
    table.insert(drawings, leftMenuBg)
    
    -- Menu Items
    for i, menu in ipairs(menuItems) do
        local menuY = guiY + 60 + (i - 1) * 50
        local isSelected = (i == selectedMenu)
        
        -- Menu Item Background
        if isSelected then
            local selectBg = createRoundedRect(guiX + 15, menuY + 5, 140, 40, Color3.fromRGB(100, 100, 255), true, 0.3)
            table.insert(drawings, selectBg)
        end
        
        -- Menu Item Text
        local menuText = createText(menu.name, guiX + 30, menuY + 15, 18, isSelected and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(200, 200, 200))
        table.insert(drawings, menuText)
    end
    
    -- Right Content Background
    local rightBg = createRoundedRect(guiX + 170, guiY + 60, guiWidth - 180, guiHeight - 70, Color3.fromRGB(30, 30, 35), true, 1)
    table.insert(drawings, rightBg)
    
    -- Content Title
    local contentTitle = createText(menuItems[selectedMenu].name .. " Features", guiX + 185, guiY + 70, 20, Color3.fromRGB(255, 255, 255))
    table.insert(drawings, contentTitle)
    
    -- Content Line
    local contentLine = Drawing.new("Line")
    contentLine.From = Vector2.new(guiX + 185, guiY + 95)
    contentLine.To = Vector2.new(guiX + guiWidth - 25, guiY + 95)
    contentLine.Color = Color3.fromRGB(60, 60, 65)
    contentLine.Thickness = 1
    contentLine.Visible = true
    contentLine.ZIndex = 2
    table.insert(drawings, contentLine)
    
    -- Features List
    local features = menuItems[selectedMenu].features
    for i, feature in ipairs(features) do
        local featureY = guiY + 105 + (i - 1) * 35
        
        -- Feature Checkbox (Circle)
        local checkboxCircle = createCircle(guiX + 195, featureY + 10, 6, Color3.fromRGB(100, 100, 255), false)
        checkboxCircle.Thickness = 2
        table.insert(drawings, checkboxCircle)
        
        -- Feature Text
        local featureText = createText(feature, guiX + 215, featureY, 16, Color3.fromRGB(220, 220, 220))
        table.insert(drawings, featureText)
    end
end

-- Fungsi untuk check click pada minimize button
local function isClickOnMinimize(x, y)
    if isMinimized then
        local centerX = screenSize.X / 2
        local centerY = screenSize.Y / 2
        local dx = x - centerX
        local dy = y - centerY
        return (dx * dx + dy * dy) <= (35 * 35)
    else
        local btnX = guiX + guiWidth - 30
        local btnY = guiY + 25
        local dx = x - btnX
        local dy = y - btnY
        return (dx * dx + dy * dy) <= (12 * 12)
    end
end

-- Fungsi untuk check click pada menu items
local function checkMenuClick(x, y)
    if isMinimized then return end
    
    for i = 1, #menuItems do
        local menuY = guiY + 60 + (i - 1) * 50
        if x >= guiX + 15 and x <= guiX + 155 and y >= menuY + 5 and y <= menuY + 45 then
            selectedMenu = i
            drawExpanded()
            return
        end
    end
end

-- Initial Draw
drawExpanded()

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        
        -- Check minimize button
        if isClickOnMinimize(mousePos.X, mousePos.Y) then
            isMinimized = not isMinimized
            if isMinimized then
                drawMinimized()
            else
                drawExpanded()
            end
        else
            -- Check menu clicks
            checkMenuClick(mousePos.X, mousePos.Y)
        end
    end
end)

-- Cleanup function (opsional)
local function cleanup()
    clearDrawings()
end

print("Arkan Scripts GUI loaded successfully!")
print("Click the minimize button to toggle GUI")
print("Click menu items to switch categories")
