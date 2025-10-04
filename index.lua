-- Modern GUI Menu System using Drawing API
-- Fixed mouse click accuracy issues

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local CONFIG = {
    WINDOW_WIDTH = 600,
    WINDOW_HEIGHT = 400,
    WINDOW_ROUNDING = 12,
    HEADER_HEIGHT = 45,
    LEFT_PANEL_WIDTH = 180,
    MINIMIZE_BUTTON_SIZE = 22,
    MENU_ITEM_HEIGHT = 38,
    MENU_ITEM_PADDING = 8,
    COLORS = {
        BACKGROUND = Color3.fromRGB(25, 25, 30),
        HEADER = Color3.fromRGB(30, 30, 38),
        LEFT_PANEL = Color3.fromRGB(20, 20, 25),
        RIGHT_PANEL = Color3.fromRGB(28, 28, 35),
        ACCENT = Color3.fromRGB(88, 101, 242),
        ACCENT_HOVER = Color3.fromRGB(108, 121, 255),
        TEXT = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(180, 180, 190),
        MENU_HOVER = Color3.fromRGB(35, 35, 42),
        MENU_SELECTED = Color3.fromRGB(88, 101, 242),
        BORDER = Color3.fromRGB(45, 45, 55)
    }
}

-- Get screen center
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local windowX = (screenSize.X - CONFIG.WINDOW_WIDTH) / 2
local windowY = (screenSize.Y - CONFIG.WINDOW_HEIGHT) / 2

-- Drawing cache
local drawings = {}
local menuData = {
    {name = "Combat", features = {"Auto Farm", "Kill Aura", "Auto Click", "Rapid Fire"}},
    {name = "Player", features = {"Speed Boost", "Jump Power", "Fly Mode", "No Clip"}},
    {name = "World", features = {"Fullbright", "ESP", "No Fog", "Time Control"}},
    {name = "Teleport", features = {"Waypoints", "Quick TP", "Spawn TP", "Player TP"}},
    {name = "Settings", features = {"Save Config", "Load Config", "Reset All", "About"}}
}

-- GUI State
local guiState = {
    visible = true,
    minimized = false,
    selectedMenu = 1,
    hoveredMenu = 0,
    hoveredFeature = 0,
    minimizedPos = Vector2.new(screenSize.X - 80, 80),
    isDragging = false,
    dragOffset = Vector2.new(0, 0)
}

-- Utility: Check if point is in rectangle (IMPROVED ACCURACY)
local function isPointInRect(px, py, rx, ry, rw, rh)
    -- Add 1 pixel tolerance for better click detection
    return px >= rx - 1 and px <= rx + rw + 1 and py >= ry - 1 and py <= ry + rh + 1
end

-- Utility: Check if point is in circle (IMPROVED ACCURACY)
local function isPointInCircle(px, py, cx, cy, radius)
    local dx = px - cx
    local dy = py - cy
    return (dx * dx + dy * dy) <= (radius * radius)
end

-- Create drawing helper
local function createDrawing(drawType, props)
    local draw = Drawing.new(drawType)
    for k, v in pairs(props) do
        draw[k] = v
    end
    table.insert(drawings, draw)
    return draw
end

-- Create rounded rectangle using multiple shapes
local function createRoundedRect(x, y, width, height, radius, color, filled, transparency)
    local parts = {}
    
    -- Main body (center rectangle)
    local body = createDrawing("Square", {
        Position = Vector2.new(x + radius, y),
        Size = Vector2.new(width - radius * 2, height),
        Color = color,
        Filled = filled,
        Transparency = transparency or 1,
        Visible = true,
        ZIndex = 1
    })
    table.insert(parts, body)
    
    -- Left rectangle
    local left = createDrawing("Square", {
        Position = Vector2.new(x, y + radius),
        Size = Vector2.new(radius, height - radius * 2),
        Color = color,
        Filled = filled,
        Transparency = transparency or 1,
        Visible = true,
        ZIndex = 1
    })
    table.insert(parts, left)
    
    -- Right rectangle
    local right = createDrawing("Square", {
        Position = Vector2.new(x + width - radius, y + radius),
        Size = Vector2.new(radius, height - radius * 2),
        Color = color,
        Filled = filled,
        Transparency = transparency or 1,
        Visible = true,
        ZIndex = 1
    })
    table.insert(parts, right)
    
    -- Corner circles
    local corners = {
        {x + radius, y + radius},
        {x + width - radius, y + radius},
        {x + radius, y + height - radius},
        {x + width - radius, y + height - radius}
    }
    
    for _, pos in ipairs(corners) do
        local circle = createDrawing("Circle", {
            Position = Vector2.new(pos[1], pos[2]),
            Radius = radius,
            Color = color,
            Filled = filled,
            Transparency = transparency or 1,
            Visible = true,
            NumSides = 32,
            ZIndex = 1
        })
        table.insert(parts, circle)
    end
    
    return parts
end

-- GUI Components
local mainWindow = {}
local headerElements = {}
local leftPanelElements = {}
local rightPanelElements = {}
local minimizedButton = {}

-- Create main window
function createMainWindow()
    -- Background shadow
    mainWindow.shadow = createDrawing("Square", {
        Position = Vector2.new(windowX + 4, windowY + 4),
        Size = Vector2.new(CONFIG.WINDOW_WIDTH, CONFIG.WINDOW_HEIGHT),
        Color = Color3.fromRGB(0, 0, 0),
        Filled = true,
        Transparency = 0.4,
        Visible = true,
        ZIndex = 0
    })
    
    -- Main background
    mainWindow.bg = createRoundedRect(windowX, windowY, CONFIG.WINDOW_WIDTH, CONFIG.WINDOW_HEIGHT, 
        CONFIG.WINDOW_ROUNDING, CONFIG.COLORS.BACKGROUND, true, 1)
    
    -- Header
    mainWindow.header = createRoundedRect(windowX, windowY, CONFIG.WINDOW_WIDTH, CONFIG.HEADER_HEIGHT, 
        CONFIG.WINDOW_ROUNDING, CONFIG.COLORS.HEADER, true, 1)
    
    -- Header cover bottom (sharp bottom edge)
    local headerCover = createDrawing("Square", {
        Position = Vector2.new(windowX, windowY + CONFIG.HEADER_HEIGHT - 10),
        Size = Vector2.new(CONFIG.WINDOW_WIDTH, 10),
        Color = CONFIG.COLORS.HEADER,
        Filled = true,
        Transparency = 1,
        Visible = true,
        ZIndex = 1
    })
    table.insert(mainWindow.header, headerCover)
    
    -- Title text
    mainWindow.title = createDrawing("Text", {
        Text = "Arkan Scripts",
        Font = Drawing.Fonts.Plex,
        Size = 20,
        Position = Vector2.new(windowX + 20, windowY + 13),
        Color = CONFIG.COLORS.TEXT,
        Transparency = 1,
        Visible = true,
        ZIndex = 10
    })
    
    -- Minimize button background
    local minBtnX = windowX + CONFIG.WINDOW_WIDTH - CONFIG.MINIMIZE_BUTTON_SIZE - 15
    local minBtnY = windowY + (CONFIG.HEADER_HEIGHT - CONFIG.MINIMIZE_BUTTON_SIZE) / 2
    
    mainWindow.minimizeBtn = createDrawing("Circle", {
        Position = Vector2.new(minBtnX + CONFIG.MINIMIZE_BUTTON_SIZE / 2, minBtnY + CONFIG.MINIMIZE_BUTTON_SIZE / 2),
        Radius = CONFIG.MINIMIZE_BUTTON_SIZE / 2,
        Color = CONFIG.COLORS.ACCENT,
        Filled = true,
        Transparency = 1,
        Visible = true,
        NumSides = 32,
        ZIndex = 10
    })
    
    mainWindow.minimizeBtnBounds = {
        x = minBtnX,
        y = minBtnY,
        w = CONFIG.MINIMIZE_BUTTON_SIZE,
        h = CONFIG.MINIMIZE_BUTTON_SIZE
    }
    
    -- Minimize icon (line)
    mainWindow.minimizeIcon = createDrawing("Line", {
        From = Vector2.new(minBtnX + 6, minBtnY + CONFIG.MINIMIZE_BUTTON_SIZE / 2),
        To = Vector2.new(minBtnX + CONFIG.MINIMIZE_BUTTON_SIZE - 6, minBtnY + CONFIG.MINIMIZE_BUTTON_SIZE / 2),
        Color = CONFIG.COLORS.TEXT,
        Thickness = 2,
        Transparency = 1,
        Visible = true,
        ZIndex = 11
    })
    
    -- Left panel
    mainWindow.leftPanel = createDrawing("Square", {
        Position = Vector2.new(windowX, windowY + CONFIG.HEADER_HEIGHT),
        Size = Vector2.new(CONFIG.LEFT_PANEL_WIDTH, CONFIG.WINDOW_HEIGHT - CONFIG.HEADER_HEIGHT),
        Color = CONFIG.COLORS.LEFT_PANEL,
        Filled = true,
        Transparency = 1,
        Visible = true,
        ZIndex = 1
    })
    
    -- Right panel
    mainWindow.rightPanel = createDrawing("Square", {
        Position = Vector2.new(windowX + CONFIG.LEFT_PANEL_WIDTH, windowY + CONFIG.HEADER_HEIGHT),
        Size = Vector2.new(CONFIG.WINDOW_WIDTH - CONFIG.LEFT_PANEL_WIDTH, CONFIG.WINDOW_HEIGHT - CONFIG.HEADER_HEIGHT),
        Color = CONFIG.COLORS.RIGHT_PANEL,
        Filled = true,
        Transparency = 1,
        Visible = true,
        ZIndex = 1
    })
    
    -- Divider line
    mainWindow.divider = createDrawing("Line", {
        From = Vector2.new(windowX + CONFIG.LEFT_PANEL_WIDTH, windowY + CONFIG.HEADER_HEIGHT),
        To = Vector2.new(windowX + CONFIG.LEFT_PANEL_WIDTH, windowY + CONFIG.WINDOW_HEIGHT),
        Color = CONFIG.COLORS.BORDER,
        Thickness = 1,
        Transparency = 0.5,
        Visible = true,
        ZIndex = 2
    })
end

-- Create menu items
function createMenuItems()
    for i, menu in ipairs(menuData) do
        local yPos = windowY + CONFIG.HEADER_HEIGHT + (i - 1) * CONFIG.MENU_ITEM_HEIGHT + CONFIG.MENU_ITEM_PADDING
        
        -- Menu background (hover/selected)
        local menuBg = createDrawing("Square", {
            Position = Vector2.new(windowX + 8, yPos),
            Size = Vector2.new(CONFIG.LEFT_PANEL_WIDTH - 16, CONFIG.MENU_ITEM_HEIGHT - CONFIG.MENU_ITEM_PADDING),
            Color = i == guiState.selectedMenu and CONFIG.COLORS.MENU_SELECTED or CONFIG.COLORS.LEFT_PANEL,
            Filled = true,
            Transparency = 1,
            Visible = true,
            ZIndex = 2
        })
        
        -- Menu text
        local menuText = createDrawing("Text", {
            Text = menu.name,
            Font = Drawing.Fonts.Plex,
            Size = 16,
            Position = Vector2.new(windowX + 20, yPos + 8),
            Color = CONFIG.COLORS.TEXT,
            Transparency = 1,
            Visible = true,
            ZIndex = 10
        })
        
        table.insert(leftPanelElements, {
            bg = menuBg,
            text = menuText,
            bounds = {
                x = windowX + 8,
                y = yPos,
                w = CONFIG.LEFT_PANEL_WIDTH - 16,
                h = CONFIG.MENU_ITEM_HEIGHT - CONFIG.MENU_ITEM_PADDING
            },
            index = i
        })
    end
end

-- Create feature items
function createFeatureItems()
    -- Clear old features
    for _, elem in ipairs(rightPanelElements) do
        if elem.bg then elem.bg:Destroy() end
        if elem.text then elem.text:Destroy() end
    end
    rightPanelElements = {}
    
    local selectedMenu = menuData[guiState.selectedMenu]
    if not selectedMenu then return end
    
    local rightPanelX = windowX + CONFIG.LEFT_PANEL_WIDTH + 15
    local startY = windowY + CONFIG.HEADER_HEIGHT + 15
    
    for i, feature in ipairs(selectedMenu.features) do
        local yPos = startY + (i - 1) * 35
        
        -- Feature background
        local featureBg = createDrawing("Square", {
            Position = Vector2.new(rightPanelX, yPos),
            Size = Vector2.new(CONFIG.WINDOW_WIDTH - CONFIG.LEFT_PANEL_WIDTH - 30, 28),
            Color = CONFIG.COLORS.HEADER,
            Filled = true,
            Transparency = 1,
            Visible = true,
            ZIndex = 2
        })
        
        -- Feature text
        local featureText = createDrawing("Text", {
            Text = feature,
            Font = Drawing.Fonts.Plex,
            Size = 15,
            Position = Vector2.new(rightPanelX + 10, yPos + 7),
            Color = CONFIG.COLORS.TEXT_SECONDARY,
            Transparency = 1,
            Visible = true,
            ZIndex = 10
        })
        
        table.insert(rightPanelElements, {
            bg = featureBg,
            text = featureText,
            bounds = {
                x = rightPanelX,
                y = yPos,
                w = CONFIG.WINDOW_WIDTH - CONFIG.LEFT_PANEL_WIDTH - 30,
                h = 28
            },
            index = i
        })
    end
end

-- Create minimized button
function createMinimizedButton()
    -- Circle background
    minimizedButton.bg = createDrawing("Circle", {
        Position = guiState.minimizedPos,
        Radius = 30,
        Color = CONFIG.COLORS.ACCENT,
        Filled = true,
        Transparency = 1,
        Visible = false,
        NumSides = 32,
        ZIndex = 100
    })
    
    -- "A" text
    minimizedButton.text = createDrawing("Text", {
        Text = "A",
        Font = Drawing.Fonts.Plex,
        Size = 28,
        Position = Vector2.new(guiState.minimizedPos.X - 10, guiState.minimizedPos.Y - 14),
        Color = CONFIG.COLORS.TEXT,
        Transparency = 1,
        Visible = false,
        Center = false,
        ZIndex = 101
    })
    
    minimizedButton.bounds = {
        x = guiState.minimizedPos.X,
        y = guiState.minimizedPos.Y,
        radius = 30
    }
end

-- Toggle minimize
function toggleMinimize()
    guiState.minimized = not guiState.minimized
    
    -- Hide/show main window
    for _, draw in pairs(mainWindow) do
        if type(draw) == "table" then
            for _, d in ipairs(draw) do
                d.Visible = not guiState.minimized
            end
        elseif draw.Visible ~= nil then
            draw.Visible = not guiState.minimized
        end
    end
    
    for _, elem in ipairs(leftPanelElements) do
        elem.bg.Visible = not guiState.minimized
        elem.text.Visible = not guiState.minimized
    end
    
    for _, elem in ipairs(rightPanelElements) do
        elem.bg.Visible = not guiState.minimized
        elem.text.Visible = not guiState.minimized
    end
    
    -- Show/hide minimized button
    minimizedButton.bg.Visible = guiState.minimized
    minimizedButton.text.Visible = guiState.minimized
end

-- Handle mouse input (IMPROVED ACCURACY)
function handleMouseInput(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        
        -- Check minimized button click
        if guiState.minimized then
            if isPointInCircle(mousePos.X, mousePos.Y, guiState.minimizedPos.X, guiState.minimizedPos.Y, 30) then
                toggleMinimize()
                guiState.isDragging = true
                guiState.dragOffset = Vector2.new(
                    guiState.minimizedPos.X - mousePos.X,
                    guiState.minimizedPos.Y - mousePos.Y
                )
                return
            end
        end
        
        if not guiState.minimized then
            -- Check minimize button
            local bounds = mainWindow.minimizeBtnBounds
            if isPointInRect(mousePos.X, mousePos.Y, bounds.x, bounds.y, bounds.w, bounds.h) then
                toggleMinimize()
                return
            end
            
            -- Check menu items
            for _, elem in ipairs(leftPanelElements) do
                if isPointInRect(mousePos.X, mousePos.Y, elem.bounds.x, elem.bounds.y, elem.bounds.w, elem.bounds.h) then
                    guiState.selectedMenu = elem.index
                    
                    -- Update menu backgrounds
                    for _, m in ipairs(leftPanelElements) do
                        m.bg.Color = m.index == guiState.selectedMenu and CONFIG.COLORS.MENU_SELECTED or CONFIG.COLORS.LEFT_PANEL
                    end
                    
                    createFeatureItems()
                    return
                end
            end
            
            -- Check feature items
            for _, elem in ipairs(rightPanelElements) do
                if isPointInRect(mousePos.X, mousePos.Y, elem.bounds.x, elem.bounds.y, elem.bounds.w, elem.bounds.h) then
                    print("Feature clicked:", menuData[guiState.selectedMenu].features[elem.index])
                    return
                end
            end
        end
    end
end

-- Handle mouse movement
function handleMouseMove()
    local mousePos = UserInputService:GetMouseLocation()
    
    -- Drag minimized button
    if guiState.isDragging and guiState.minimized then
        guiState.minimizedPos = Vector2.new(
            mousePos.X + guiState.dragOffset.X,
            mousePos.Y + guiState.dragOffset.Y
        )
        
        minimizedButton.bg.Position = guiState.minimizedPos
        minimizedButton.text.Position = Vector2.new(guiState.minimizedPos.X - 10, guiState.minimizedPos.Y - 14)
        return
    end
    
    if guiState.minimized then return end
    
    -- Hover effects for menu items
    local hoveredMenu = 0
    for _, elem in ipairs(leftPanelElements) do
        if isPointInRect(mousePos.X, mousePos.Y, elem.bounds.x, elem.bounds.y, elem.bounds.w, elem.bounds.h) then
            hoveredMenu = elem.index
            if elem.index ~= guiState.selectedMenu then
                elem.bg.Color = CONFIG.COLORS.MENU_HOVER
            end
        else
            if elem.index ~= guiState.selectedMenu then
                elem.bg.Color = CONFIG.COLORS.LEFT_PANEL
            end
        end
    end
    guiState.hoveredMenu = hoveredMenu
    
    -- Hover effects for minimize button
    local bounds = mainWindow.minimizeBtnBounds
    if isPointInRect(mousePos.X, mousePos.Y, bounds.x, bounds.y, bounds.w, bounds.h) then
        mainWindow.minimizeBtn.Color = CONFIG.COLORS.ACCENT_HOVER
    else
        mainWindow.minimizeBtn.Color = CONFIG.COLORS.ACCENT
    end
    
    -- Hover effects for features
    for _, elem in ipairs(rightPanelElements) do
        if isPointInRect(mousePos.X, mousePos.Y, elem.bounds.x, elem.bounds.y, elem.bounds.w, elem.bounds.h) then
            elem.bg.Color = CONFIG.COLORS.MENU_HOVER
            elem.text.Color = CONFIG.COLORS.TEXT
        else
            elem.bg.Color = CONFIG.COLORS.HEADER
            elem.text.Color = CONFIG.COLORS.TEXT_SECONDARY
        end
    end
end

-- Initialize GUI
createMainWindow()
createMenuItems()
createFeatureItems()
createMinimizedButton()

-- Input connections
UserInputService.InputBegan:Connect(handleMouseInput)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        guiState.isDragging = false
    end
end)

RunService.RenderStepped:Connect(handleMouseMove)

print("Modern GUI Menu System loaded!")
print("Click minimize button to minimize/restore")
print("Minimized button is draggable")
