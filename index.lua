-- Arkan Scripts Management Menu using Drawing API
-- Compatible with Delta Executor / Unified Naming Standard

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Screen center calculation
local screenSize = camera.ViewportSize
local centerX, centerY = screenSize.X / 2, screenSize.Y / 2

-- GUI Config
local isMinimized = false
local selectedMenu = nil
local guiWidth, guiHeight = 400, 300
local minCircleRadius = 20
local menuWidth = 120  -- Left menu width
local panelWidth = guiWidth - menuWidth - 10  -- Right panel width
local itemHeight = 30
local rounding = 8
local bgColor = Color3.fromRGB(30, 30, 35)
local accentColor = Color3.fromRGB(0, 120, 255)
local textColor = Color3.fromRGB(255, 255, 255)
local font = Drawing.Fonts.Plex

-- Drawing Objects Cache
local drawings = {}

-- Function to create a new Drawing object
local function newDrawing(type)
    local obj = Drawing.new(type)
    table.insert(drawings, obj)
    return obj
end

-- Function to destroy all drawings
local function destroyAll()
    for _, obj in ipairs(drawings) do
        if obj.Destroy then obj:Destroy() end
    end
    drawings = {}
end

-- Function to update position of all objects (for centering/minimize)
local function updatePositions()
    local posX = isMinimized and (centerX - minCircleRadius) or (centerX - guiWidth / 2)
    local posY = isMinimized and (centerY - minCircleRadius) or (centerY - guiHeight / 2)
    
    -- Title
    drawings.title.Position = Vector2.new(posX + guiWidth / 2, posY + 10)
    
    -- Left menu bg
    drawings.leftBg.Position = Vector2.new(posX, posY + 40)
    
    -- Menu items
    for i, item in ipairs(drawings.menuItems) do
        item.Position = Vector2.new(posX + 5, posY + 45 + (i-1) * itemHeight)
    end
    
    -- Right panel bg
    drawings.rightBg.Position = Vector2.new(posX + menuWidth + 5, posY + 40)
    
    -- Features (dynamic)
    local startY = posY + 45
    for i, feat in ipairs(drawings.features or {}) do
        feat.Position = Vector2.new(posX + menuWidth + 10, startY + (i-1) * itemHeight)
    end
    
    -- Minimize button
    drawings.minBtn.Position = Vector2.new(posX + guiWidth - 30, posY + 5)
    
    -- Minimize circle and text (hidden if not minimized)
    if drawings.minCircle then
        drawings.minCircle.Position = Vector2.new(centerX - minCircleRadius, centerY - minCircleRadius)
        drawings.minText.Position = Vector2.new(centerX - 8, centerY - 12)  -- Approx center for "A"
        drawings.minCircle.Visible = isMinimized
        drawings.minText.Visible = isMinimized
    end
    
    -- Hide/show main elements when minimized
    local visibility = not isMinimized
    drawings.title.Visible = visibility
    drawings.leftBg.Visible = visibility
    for _, item in ipairs(drawings.menuItems) do item.Visible = visibility end
    drawings.rightBg.Visible = visibility
    for _, feat in ipairs(drawings.features or {}) do feat.Visible = visibility end
    drawings.minBtn.Visible = visibility
end

-- Create GUI Elements
local function createGUI()
    -- Main BG (invisible, just for reference)
    -- Title
    local title = newDrawing("Text")
    title.Text = "Arkan Scripts"
    title.Font = font
    title.Size = 24
    title.Color = accentColor
    title.Center = true
    title.Outline = true
    title.OutlineColor = Color3.fromRGB(0, 0, 0)
    title.Position = Vector2.new(centerX, centerY - guiHeight / 2 + 10)
    drawings.title = title
    
    -- Left Menu BG
    local leftBg = newDrawing("Square")
    leftBg.Size = Vector2.new(menuWidth, guiHeight - 40)
    leftBg.Position = Vector2.new(centerX - guiWidth / 2, centerY - guiHeight / 2 + 40)
    leftBg.Color = bgColor
    leftBg.Filled = true
    leftBg.Thickness = 1
    leftBg.Rounding = rounding
    leftBg.Transparency = 0.2
    drawings.leftBg = leftBg
    
    -- Menu Items (buttons as Text, clickable)
    local menuNames = {"Player", "Combat", "Misc"}
    drawings.menuItems = {}
    for i, name in ipairs(menuNames) do
        local item = newDrawing("Text")
        item.Text = name
        item.Font = font
        item.Size = 18
        item.Color = textColor
        item.Center = true
        item.Outline = true
        item.OutlineColor = Color3.fromRGB(0, 0, 0)
        item.Position = Vector2.new(centerX - guiWidth / 2 + menuWidth / 2, centerY - guiHeight / 2 + 45 + (i-1) * itemHeight)
        table.insert(drawings.menuItems, item)
    end
    
    -- Right Panel BG
    local rightBg = newDrawing("Square")
    rightBg.Size = Vector2.new(panelWidth, guiHeight - 40)
    rightBg.Position = Vector2.new(centerX - guiWidth / 2 + menuWidth + 5, centerY - guiHeight / 2 + 40)
    rightBg.Color = bgColor
    rightBg.Filled = true
    rightBg.Thickness = 1
    rightBg.Rounding = rounding
    rightBg.Transparency = 0.2
    drawings.rightBg = rightBg
    
    -- Features (initially empty, will populate on menu click)
    drawings.features = {}
    
    -- Minimize Button (small square)
    local minBtn = newDrawing("Square")
    minBtn.Size = Vector2.new(20, 20)
    minBtn.Position = Vector2.new(centerX + guiWidth / 2 - 25, centerY - guiHeight / 2 + 5)
    minBtn.Color = accentColor
    minBtn.Filled = true
    minBtn.Rounding = 4
    minBtn.Transparency = 0.5
    drawings.minBtn = minBtn
    
    -- Minimize Circle (hidden initially)
    local minCircle = newDrawing("Circle")
    minCircle.Radius = minCircleRadius
    minCircle.NumSides = 32
    minCircle.Position = Vector2.new(centerX, centerY)
    minCircle.Color = accentColor
    minCircle.Filled = true
    minCircle.Thickness = 2
    minCircle.Transparency = 0.3
    minCircle.Visible = false
    drawings.minCircle = minCircle
    
    -- "A" Text in Circle
    local minText = newDrawing("Text")
    minText.Text = "A"
    minText.Font = font
    minText.Size = 24
    minText.Color = textColor
    minText.Center = true
    minText.Outline = true
    minText.OutlineColor = Color3.fromRGB(0, 0, 0)
    minText.Position = Vector2.new(centerX, centerY)
    minText.Visible = false
    drawings.minText = minText
    
    updatePositions()
    
    -- Set all visible
    for _, obj in ipairs(drawings) do
        if obj ~= drawings.minCircle and obj ~= drawings.minText then
            obj.Visible = true
        end
    end
end

-- Menu Data (contoh features per menu)
local menuFeatures = {
    Player = {"Speed Hack", "Jump Power", "Infinite Health"},
    Combat = {"Aimbot", "ESP", "Kill Aura"},
    Misc = {"Fly", "Noclip", "Teleport"}
}

-- Function to update right panel features
local function updateFeatures(menuName)
    -- Clear old features
    for _, feat in ipairs(drawings.features) do
        feat:Destroy()
    end
    drawings.features = {}
    
    if not menuName then
        -- Empty panel
        local emptyText = newDrawing("Text")
        emptyText.Text = "Select a menu..."
        emptyText.Font = font
        emptyText.Size = 18
        emptyText.Color = Color3.fromRGB(150, 150, 150)
        emptyText.Center = true
        emptyText.Position = Vector2.new(centerX, centerY)
        table.insert(drawings.features, emptyText)
    else
        local features = menuFeatures[menuName] or {}
        for i, featName in ipairs(features) do
            local feat = newDrawing("Text")
            feat.Text = featName .. " [OFF]"  -- Contoh toggle state
            feat.Font = font
            feat.Size = 16
            feat.Color = textColor
            feat.Position = Vector2.new(centerX - guiWidth / 2 + menuWidth + 10, centerY - guiHeight / 2 + 45 + (i-1) * itemHeight)
            table.insert(drawings.features, feat)
        end
    end
    
    updatePositions()
end

-- Click Detection
local connections = {}
local lastClickPos = nil

-- Track mouse click
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        lastClickPos = Vector2.new(mouse.X, mouse.Y)
    end
end))

-- Check clicks on objects (simplified hit detection)
table.insert(connections, RunService.Heartbeat:Connect(function()
    if not lastClickPos then return end
    
    local clickX, clickY = lastClickPos.X, lastClickPos.Y
    
    -- Check minimize button
    local minBtn = drawings.minBtn
    if not isMinimized and clickX >= minBtn.Position.X and clickX <= minBtn.Position.X + minBtn.Size.X and
       clickY >= minBtn.Position.Y and clickY <= minBtn.Position.Y + minBtn.Size.Y then
        isMinimized = not isMinimized
        updatePositions()
        lastClickPos = nil
        return
    end
    
    -- Check minimize circle
    local minCircle = drawings.minCircle
    if isMinimized and clickX >= minCircle.Position.X and clickX <= minCircle.Position.X + minCircle.Radius * 2 and
       clickY >= minCircle.Position.Y and clickY <= minCircle.Position.Y + minCircle.Radius * 2 then
        isMinimized = not isMinimized
        updatePositions()
        lastClickPos = nil
        return
    end
    
    -- Check menu items
    if not isMinimized then
        for i, item in ipairs(drawings.menuItems) do
            local itemRect = {X = item.Position.X - 50, Y = item.Position.Y - 10, W = 100, H = itemHeight}  -- Approx bounds
            if clickX >= itemRect.X and clickX <= itemRect.X + itemRect.W and
               clickY >= itemRect.Y and clickY <= itemRect.Y + itemRect.H then
                selectedMenu = menuFeatures[i] and i  -- Index to name
                updateFeatures(menuFeatures[selectedMenu] and menuFeatures[selectedMenu][1] or nil)  -- Dummy, adjust
                -- Highlight: Tween color
                local tween = TweenService:Create(item, TweenInfo.new(0.2), {Color = accentColor})
                tween:Play()
                tween.Completed:Connect(function() item.Color = textColor end)
                lastClickPos = nil
                return
            end
        end
    end
    
    lastClickPos = nil
end))

-- Menu click handler (use selectedMenu for actual logic)
updateFeatures()  -- Initial empty

-- Init
createGUI()

-- Cleanup on player leaving (optional)
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        destroyAll()
        for _, conn in ipairs(connections) do conn:Disconnect() end
    end
end)

print("Arkan Scripts loaded! Minimize with the button top-right.")
