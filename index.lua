-- Modern GUI Menu System using Drawing API
-- Arkan Scripts v1.0

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local CONFIG = {
    WINDOW_WIDTH = 600,
    WINDOW_HEIGHT = 400,
    WINDOW_POS = Vector2.new(400, 200),
    HEADER_HEIGHT = 45,
    LEFT_PANEL_WIDTH = 180,
    CORNER_RADIUS = 12,
    
    -- Colors
    BG_COLOR = Color3.fromRGB(25, 25, 30),
    HEADER_COLOR = Color3.fromRGB(35, 35, 42),
    PANEL_COLOR = Color3.fromRGB(30, 30, 36),
    ACCENT_COLOR = Color3.fromRGB(88, 101, 242),
    TEXT_COLOR = Color3.fromRGB(240, 240, 245),
    TEXT_SECONDARY = Color3.fromRGB(160, 160, 170),
    HOVER_COLOR = Color3.fromRGB(45, 45, 54),
    SELECTED_COLOR = Color3.fromRGB(88, 101, 242),
    
    -- Transparency
    BG_TRANSPARENCY = 0.15,
    PANEL_TRANSPARENCY = 0.2,
}

-- Menu Data
local MENUS = {
    {name = "Combat", features = {"Auto Farm", "Kill Aura", "Auto Attack", "Damage Boost", "Critical Hits"}},
    {name = "Player", features = {"Speed Boost", "Jump Power", "Infinite Jump", "No Fall Damage", "Fly Mode"}},
    {name = "World", features = {"ESP Players", "ESP Chests", "Fullbright", "No Fog", "Time Control"}},
    {name = "Teleport", features = {"Waypoint System", "Player TP", "Location Save", "Quick TP", "Auto TP"}},
    {name = "Settings", features = {"UI Scale", "Transparency", "Keybinds", "Save Config", "Reset Settings"}},
}

-- GUI State
local GUI = {
    isMinimized = false,
    selectedMenu = 1,
    hoveredMenu = nil,
    hoveredFeature = nil,
    isDragging = false,
    dragOffset = Vector2.new(0, 0),
    windowPos = CONFIG.WINDOW_POS,
    drawings = {},
    mousePos = Vector2.new(0, 0),
}

-- Utility Functions
local function createDrawing(type, props)
    local drawing = Drawing.new(type)
    for k, v in pairs(props) do
        drawing[k] = v
    end
    table.insert(GUI.drawings, drawing)
    return drawing
end

local function clearAllDrawings()
    for _, drawing in ipairs(GUI.drawings) do
        if drawing and drawing.Visible ~= nil then
            drawing:Destroy()
        end
    end
    GUI.drawings = {}
end

local function isPointInRect(point, pos, size)
    return point.X >= pos.X and point.X <= pos.X + size.X and
           point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

-- Draw Rounded Rectangle using multiple shapes
local function drawRoundedRect(pos, size, color, transparency, filled, radius)
    radius = radius or CONFIG.CORNER_RADIUS
    
    -- Main rectangles (body)
    local mainRect = createDrawing("Square", {
        Position = Vector2.new(pos.X + radius, pos.Y),
        Size = Vector2.new(size.X - radius * 2, size.Y),
        Color = color,
        Transparency = transparency,
        Filled = filled,
        Visible = true,
        ZIndex = 1
    })
    
    local leftRect = createDrawing("Square", {
        Position = Vector2.new(pos.X, pos.Y + radius),
        Size = Vector2.new(radius, size.Y - radius * 2),
        Color = color,
        Transparency = transparency,
        Filled = filled,
        Visible = true,
        ZIndex = 1
    })
    
    local rightRect = createDrawing("Square", {
        Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius),
        Size = Vector2.new(radius, size.Y - radius * 2),
        Color = color,
        Transparency = transparency,
        Filled = filled,
        Visible = true,
        ZIndex = 1
    })
    
    -- Corner circles
    local corners = {
        {pos.X + radius, pos.Y + radius}, -- Top-left
        {pos.X + size.X - radius, pos.Y + radius}, -- Top-right
        {pos.X + radius, pos.Y + size.Y - radius}, -- Bottom-left
        {pos.X + size.X - radius, pos.Y + size.Y - radius}, -- Bottom-right
    }
    
    for _, corner in ipairs(corners) do
        createDrawing("Circle", {
            Position = Vector2.new(corner[1], corner[2]),
            Radius = radius,
            Color = color,
            Transparency = transparency,
            Filled = filled,
            NumSides = 32,
            Visible = true,
            ZIndex = 1
        })
    end
end

-- Draw Full GUI
local function drawGUI()
    clearAllDrawings()
    
    if GUI.isMinimized then
        -- Draw minimized circle button
        local miniCircle = createDrawing("Circle", {
            Position = GUI.windowPos,
            Radius = 30,
            Color = CONFIG.ACCENT_COLOR,
            Transparency = 0.1,
            Filled = true,
            NumSides = 64,
            Visible = true,
            ZIndex = 100
        })
        
        local miniCircleOutline = createDrawing("Circle", {
            Position = GUI.windowPos,
            Radius = 30,
            Color = CONFIG.ACCENT_COLOR,
            Transparency = 0.05,
            Filled = false,
            Thickness = 2,
            NumSides = 64,
            Visible = true,
            ZIndex = 101
        })
        
        local miniText = createDrawing("Text", {
            Text = "A",
            Size = 28,
            Font = Drawing.Fonts.Plex,
            Color = CONFIG.TEXT_COLOR,
            Transparency = 0.05,
            Position = Vector2.new(GUI.windowPos.X - 9, GUI.windowPos.Y - 14),
            Center = false,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Visible = true,
            ZIndex = 102
        })
        return
    end
    
    -- Main window background with shadow
    drawRoundedRect(
        Vector2.new(GUI.windowPos.X + 3, GUI.windowPos.Y + 3),
        Vector2.new(CONFIG.WINDOW_WIDTH, CONFIG.WINDOW_HEIGHT),
        Color3.fromRGB(0, 0, 0),
        0.6,
        true,
        CONFIG.CORNER_RADIUS
    )
    
    drawRoundedRect(
        GUI.windowPos,
        Vector2.new(CONFIG.WINDOW_WIDTH, CONFIG.WINDOW_HEIGHT),
        CONFIG.BG_COLOR,
        CONFIG.BG_TRANSPARENCY,
        true,
        CONFIG.CORNER_RADIUS
    )
    
    -- Header
    drawRoundedRect(
        GUI.windowPos,
        Vector2.new(CONFIG.WINDOW_WIDTH, CONFIG.HEADER_HEIGHT),
        CONFIG.HEADER_COLOR,
        CONFIG.PANEL_TRANSPARENCY,
        true,
        CONFIG.CORNER_RADIUS
    )
    
    -- Header separator
    createDrawing("Square", {
        Position = Vector2.new(GUI.windowPos.X + CONFIG.CORNER_RADIUS, GUI.windowPos.Y + CONFIG.HEADER_HEIGHT - 1),
        Size = Vector2.new(CONFIG.WINDOW_WIDTH - CONFIG.CORNER_RADIUS * 2, 1),
        Color = CONFIG.ACCENT_COLOR,
        Transparency = 0.3,
        Filled = true,
        Visible = true,
        ZIndex = 2
    })
    
    -- Title text
    createDrawing("Text", {
        Text = "Arkan Scripts",
        Size = 20,
        Font = Drawing.Fonts.Plex,
        Color = CONFIG.TEXT_COLOR,
        Transparency = 0.05,
        Position = Vector2.new(GUI.windowPos.X + 20, GUI.windowPos.Y + 13),
        Center = false,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Visible = true,
        ZIndex = 3
    })
    
    -- Minimize button (clickable area expanded)
    local minBtnX = GUI.windowPos.X + CONFIG.WINDOW_WIDTH - 35
    local minBtnY = GUI.windowPos.Y + 15
    
    createDrawing("Circle", {
        Position = Vector2.new(minBtnX + 7, minBtnY + 7),
        Radius = 7,
        Color = CONFIG.ACCENT_COLOR,
        Transparency = 0.2,
        Filled = true,
        NumSides = 32,
        Visible = true,
        ZIndex = 3
    })
    
    createDrawing("Text", {
        Text = "_",
        Size = 20,
        Font = Drawing.Fonts.Plex,
        Color = CONFIG.TEXT_COLOR,
        Transparency = 0.1,
        Position = Vector2.new(minBtnX + 3, minBtnY - 3),
        Center = false,
        Outline = false,
        Visible = true,
        ZIndex = 4
    })
    
    -- Left Panel
    local leftPanelPos = Vector2.new(GUI.windowPos.X + 12, GUI.windowPos.Y + CONFIG.HEADER_HEIGHT + 12)
    drawRoundedRect(
        leftPanelPos,
        Vector2.new(CONFIG.LEFT_PANEL_WIDTH, CONFIG.WINDOW_HEIGHT - CONFIG.HEADER_HEIGHT - 24),
        CONFIG.PANEL_COLOR,
        CONFIG.PANEL_TRANSPARENCY,
        true,
        8
    )
    
    -- Menu Items
    for i, menu in ipairs(MENUS) do
        local itemY = leftPanelPos.Y + (i - 1) * 50 + 10
        local isSelected = (i == GUI.selectedMenu)
        local isHovered = (i == GUI.hoveredMenu)
        
        local itemColor = isSelected and CONFIG.SELECTED_COLOR or (isHovered and CONFIG.HOVER_COLOR or CONFIG.PANEL_COLOR)
        local itemTransparency = isSelected and 0.15 or (isHovered and 0.25 or 0.35)
        
        -- Menu item background
        drawRoundedRect(
            Vector2.new(leftPanelPos.X + 8, itemY),
            Vector2.new(CONFIG.LEFT_PANEL_WIDTH - 16, 40),
            itemColor,
            itemTransparency,
            true,
            6
        )
        
        -- Selection indicator
        if isSelected then
            createDrawing("Square", {
                Position = Vector2.new(leftPanelPos.X + 8, itemY + 10),
                Size = Vector2.new(3, 20),
                Color = CONFIG.ACCENT_COLOR,
                Transparency = 0.05,
                Filled = true,
                Visible = true,
                ZIndex = 3
            })
        end
        
        -- Menu item text
        createDrawing("Text", {
            Text = menu.name,
            Size = 16,
            Font = Drawing.Fonts.Plex,
            Color = isSelected and CONFIG.TEXT_COLOR or CONFIG.TEXT_SECONDARY,
            Transparency = 0.05,
            Position = Vector2.new(leftPanelPos.X + 24, itemY + 12),
            Center = false,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Visible = true,
            ZIndex = 4
        })
    end
    
    -- Right Panel
    local rightPanelPos = Vector2.new(GUI.windowPos.X + CONFIG.LEFT_PANEL_WIDTH + 24, GUI.windowPos.Y + CONFIG.HEADER_HEIGHT + 12)
    local rightPanelWidth = CONFIG.WINDOW_WIDTH - CONFIG.LEFT_PANEL_WIDTH - 36
    drawRoundedRect(
        rightPanelPos,
        Vector2.new(rightPanelWidth, CONFIG.WINDOW_HEIGHT - CONFIG.HEADER_HEIGHT - 24),
        CONFIG.PANEL_COLOR,
        CONFIG.PANEL_TRANSPARENCY,
        true,
        8
    )
    
    -- Right Panel Content
    local selectedMenuData = MENUS[GUI.selectedMenu]
    
    createDrawing("Text", {
        Text = selectedMenuData.name .. " Features",
        Size = 18,
        Font = Drawing.Fonts.Plex,
        Color = CONFIG.TEXT_COLOR,
        Transparency = 0.05,
        Position = Vector2.new(rightPanelPos.X + 16, rightPanelPos.Y + 16),
        Center = false,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Visible = true,
        ZIndex = 4
    })
    
    -- Features list
    for i, feature in ipairs(selectedMenuData.features) do
        local featureY = rightPanelPos.Y + 50 + (i - 1) * 45
        local isHovered = (i == GUI.hoveredFeature)
        
        -- Feature background
        drawRoundedRect(
            Vector2.new(rightPanelPos.X + 12, featureY),
            Vector2.new(rightPanelWidth - 24, 35),
            isHovered and CONFIG.HOVER_COLOR or CONFIG.PANEL_COLOR,
            isHovered and 0.2 or 0.3,
            true,
            6
        )
        
        -- Feature text
        createDrawing("Text", {
            Text = feature,
            Size = 15,
            Font = Drawing.Fonts.Plex,
            Color = CONFIG.TEXT_SECONDARY,
            Transparency = 0.05,
            Position = Vector2.new(rightPanelPos.X + 24, featureY + 10),
            Center = false,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Visible = true,
            ZIndex = 4
        })
        
        -- Toggle indicator (visual only)
        createDrawing("Circle", {
            Position = Vector2.new(rightPanelPos.X + rightPanelWidth - 32, featureY + 17),
            Radius = 6,
            Color = CONFIG.ACCENT_COLOR,
            Transparency = 0.4,
            Filled = true,
            NumSides = 32,
            Visible = true,
            ZIndex = 4
        })
    end
end

-- Input Handling with improved accuracy
local function handleInput()
    -- Update mouse position
    GUI.mousePos = UserInputService:GetMouseLocation()
    
    if GUI.isMinimized then
        -- Check minimized button click (expanded hitbox)
        local dist = (GUI.mousePos - GUI.windowPos).Magnitude
        if dist <= 35 then -- Increased from 30 to 35 for better click detection
            GUI.isMinimized = false
            GUI.windowPos = Vector2.new(GUI.windowPos.X - 300, GUI.windowPos.Y - 200) -- Restore to center
            drawGUI()
        end
        return
    end
    
    -- Check minimize button (expanded hitbox)
    local minBtnPos = Vector2.new(GUI.windowPos.X + CONFIG.WINDOW_WIDTH - 35, GUI.windowPos.Y + 15)
    if isPointInRect(GUI.mousePos, minBtnPos, Vector2.new(28, 28)) then
        GUI.isMinimized = true
        GUI.windowPos = Vector2.new(GUI.mousePos.X, GUI.mousePos.Y) -- Minimize at mouse position
        drawGUI()
        return
    end
    
    -- Check menu items with expanded hitbox
    local leftPanelPos = Vector2.new(GUI.windowPos.X + 12, GUI.windowPos.Y + CONFIG.HEADER_HEIGHT + 12)
    GUI.hoveredMenu = nil
    for i = 1, #MENUS do
        local itemY = leftPanelPos.Y + (i - 1) * 50 + 10
        -- Expanded hitbox by 4 pixels on each side
        if isPointInRect(GUI.mousePos, Vector2.new(leftPanelPos.X + 4, itemY - 2), Vector2.new(CONFIG.LEFT_PANEL_WIDTH - 8, 44)) then
            GUI.hoveredMenu = i
            break
        end
    end
    
    -- Check features with expanded hitbox
    local rightPanelPos = Vector2.new(GUI.windowPos.X + CONFIG.LEFT_PANEL_WIDTH + 24, GUI.windowPos.Y + CONFIG.HEADER_HEIGHT + 12)
    local rightPanelWidth = CONFIG.WINDOW_WIDTH - CONFIG.LEFT_PANEL_WIDTH - 36
    GUI.hoveredFeature = nil
    for i = 1, #MENUS[GUI.selectedMenu].features do
        local featureY = rightPanelPos.Y + 50 + (i - 1) * 45
        -- Expanded hitbox
        if isPointInRect(GUI.mousePos, Vector2.new(rightPanelPos.X + 8, featureY - 2), Vector2.new(rightPanelWidth - 16, 39)) then
            GUI.hoveredFeature = i
            break
        end
    end
    
    drawGUI()
end

-- Mouse Click Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not GUI.isMinimized then
            -- Check header for dragging (expanded area)
            if isPointInRect(GUI.mousePos, GUI.windowPos, Vector2.new(CONFIG.WINDOW_WIDTH - 50, CONFIG.HEADER_HEIGHT)) then
                GUI.isDragging = true
                GUI.dragOffset = GUI.mousePos - GUI.windowPos
            end
            
            -- Check menu selection
            if GUI.hoveredMenu then
                GUI.selectedMenu = GUI.hoveredMenu
                drawGUI()
            end
            
            -- Check feature click
            if GUI.hoveredFeature then
                local selectedMenuData = MENUS[GUI.selectedMenu]
                print("Clicked:", selectedMenuData.features[GUI.hoveredFeature])
            end
        else
            handleInput() -- Handle minimize button click
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        GUI.isDragging = false
    end
end)

-- Update Loop
RunService.RenderStepped:Connect(function()
    if GUI.isDragging then
        GUI.windowPos = UserInputService:GetMouseLocation() - GUI.dragOffset
        drawGUI()
    else
        handleInput()
    end
end)

-- Initialize
drawGUI()
print("Arkan Scripts GUI Loaded - Press minimize button or click menu items!")
