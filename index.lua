-- Arkan Scripts GUI Example using Drawing API

-- Assume input functions (adjust if Delta has different names)
local function getMousePos()
    -- If executor has getmousepos(), use it. Else, assume mouse object
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    return Vector2.new(mouse.X, mouse.Y)
end

local function isLeftClickPressed()
    -- Assume ismousebuttonpressed(0) for left click
    return ismousebuttonpressed(0)  -- 0 = left, adjust if needed
end

local function getScreenSize()
    -- Assume getscreensize() or use ViewportSize
    return workspace.CurrentCamera.ViewportSize  -- Or Vector2.new(1920, 1080)
end

-- GUI Config
local guiWidth = 400
local guiHeight = 300
local cornerRadius = 10
local bgColor = Color3.fromRGB(30, 30, 30)  -- Dark bg
local textColor = Color3.fromRGB(255, 255, 255)
local accentColor = Color3.fromRGB(0, 170, 255)
local screenSize = getScreenSize()
local guiPos = Vector2.new((screenSize.X - guiWidth) / 2, (screenSize.Y - guiHeight) / 2)  -- Centered

-- State variables
local isMinimized = false
local selectedMenu = 1  -- Default Menu1
local lastClickTime = 0  -- Debounce click
local drawings = {}  -- Store all Drawing objects for easy destroy/manage

-- Function to create rounded rect (bg)
local function createRoundedRect(pos, size, color, filled)
    local rect = {}
    
    -- Main body square
    local body = Drawing.new("Square")
    body.Position = pos + Vector2.new(cornerRadius, 0)
    body.Size = Vector2.new(size.X - 2 * cornerRadius, size.Y)
    body.Color = color
    body.Filled = filled
    body.Thickness = 1
    body.Visible = true
    body.Transparency = 1
    table.insert(rect, body)
    table.insert(drawings, body)
    
    -- Top and bottom bars
    local topBar = Drawing.new("Square")
    topBar.Position = pos + Vector2.new(0, cornerRadius)
    topBar.Size = Vector2.new(size.X, size.Y - 2 * cornerRadius)
    topBar.Color = color
    topBar.Filled = filled
    topBar.Visible = true
    topBar.Transparency = 1
    table.insert(rect, topBar)
    table.insert(drawings, topBar)
    
    -- 4 corner circles
    local corners = {
        {pos, "top-left"},
        {pos + Vector2.new(size.X - 2 * cornerRadius, 0), "top-right"},
        {pos + Vector2.new(0, size.Y - 2 * cornerRadius), "bottom-left"},
        {pos + Vector2.new(size.X - 2 * cornerRadius, size.Y - 2 * cornerRadius), "bottom-right"}
    }
    for _, c in ipairs(corners) do
        local circle = Drawing.new("Circle")
        circle.Position = c[1] + Vector2.new(cornerRadius, cornerRadius)
        circle.Radius = cornerRadius
        circle.NumSides = 32
        circle.Color = color
        circle.Filled = filled
        circle.Visible = true
        circle.Transparency = 1
        table.insert(rect, circle)
        table.insert(drawings, circle)
    end
    
    return rect
end

-- Function to create text
local function createText(text, pos, size, font, color, center)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Position = pos
    txt.Size = size
    txt.Font = font or Drawing.Fonts.UI
    txt.Color = color
    txt.Center = center or false
    txt.Outline = true
    txt.OutlineColor = Color3.fromRGB(0, 0, 0)
    txt.Visible = true
    txt.Transparency = 1
    table.insert(drawings, txt)
    return txt
end

-- Function to create button (as square + text)
local function createButton(text, pos, size, onClick)
    local btn = {}
    btn.bg = Drawing.new("Square")
    btn.bg.Position = pos
    btn.bg.Size = size
    btn.bg.Color = accentColor
    btn.bg.Filled = true
    btn.bg.Visible = true
    btn.bg.Transparency = 0.8
    table.insert(drawings, btn.bg)
    
    btn.txt = createText(text, pos + Vector2.new(size.X / 2, size.Y / 2 - 10), 20, Drawing.Fonts.UI, textColor, true)
    
    btn.checkClick = function(mousePos)
        if os.clock() - lastClickTime < 0.2 then return end  -- Debounce
        local inBounds = mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
                         mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y
        if inBounds and isLeftClickPressed() then
            lastClickTime = os.clock()
            onClick()
        end
    end
    
    return btn
end

-- Render GUI when not minimized
local function renderGUI()
    -- Clear existing drawings
    for _, d in ipairs(drawings) do
        d:Destroy()
    end
    drawings = {}
    
    -- BG rounded rect
    createRoundedRect(guiPos, Vector2.new(guiWidth, guiHeight), bgColor, true)
    
    -- Title
    createText("Arkan Scripts", guiPos + Vector2.new(guiWidth / 2, 10), 24, Drawing.Fonts.Plex, textColor, true)
    
    -- Minimize button (small square at top right)
    local minBtn = createButton("-", guiPos + Vector2.new(guiWidth - 30, 10), Vector2.new(20, 20), function()
        isMinimized = true
        renderMinimized()
    end)
    
    -- Left sidebar: Menu list (2 examples)
    local menuItems = {"Menu1", "Menu2"}
    local menuBtns = {}
    for i, menu in ipairs(menuItems) do
        local btnPos = guiPos + Vector2.new(10, 50 + (i-1)*40)
        menuBtns[i] = createButton(menu, btnPos, Vector2.new(120, 30), function()
            selectedMenu = i
            renderContent()  -- Refresh right content
        end)
    end
    
    -- Right content area
    local contentPos = guiPos + Vector2.new(140, 50)
    local function renderContent()
        -- Clear old content texts
        if contentTexts then
            for _, t in ipairs(contentTexts) do
                t:Destroy()
            end
        end
        contentTexts = {}
        
        -- Example features based on selected menu
        local features = selectedMenu == 1 and {"Feature A", "Feature B", "Feature C"} or {"Feature X", "Feature Y"}
        for i, feat in ipairs(features) do
            local txt = createText(feat, contentPos + Vector2.new(0, (i-1)*30), 18, Drawing.Fonts.System, textColor, false)
            table.insert(contentTexts, txt)
        end
    end
    renderContent()
    
    -- Separator line between left and right
    local sep = Drawing.new("Line")
    sep.From = guiPos + Vector2.new(140, 40)
    sep.To = guiPos + Vector2.new(140, guiHeight - 10)
    sep.Color = accentColor
    sep.Thickness = 2
    sep.Visible = true
    table.insert(drawings, sep)
end

-- Render minimized state (circle with 'A')
local function renderMinimized()
    -- Clear drawings
    for _, d in ipairs(drawings) do
        d:Destroy()
    end
    drawings = {}
    
    -- Circle
    local minCircle = Drawing.new("Circle")
    minCircle.Position = screenSize / 2
    minCircle.Radius = 30
    minCircle.NumSides = 64
    minCircle.Color = accentColor
    minCircle.Filled = true
    minCircle.Visible = true
    minCircle.Transparency = 0.9
    table.insert(drawings, minCircle)
    
    -- Text 'A'
    createText("A", screenSize / 2 - Vector2.new(10, 15), 30, Drawing.Fonts.Monospaced, textColor, false)
    
    -- Check click to restore
    minCheck = function(mousePos)
        local center = screenSize / 2
        local dist = (mousePos - center).Magnitude
        if dist <= 30 and isLeftClickPressed() and os.clock() - lastClickTime > 0.2 then
            lastClickTime = os.clock()
            isMinimized = false
            renderGUI()
        end
    end
end

-- Initial render
if not isMinimized then
    renderGUI()
end

-- Main loop for input (run in background)
task.spawn(function()
    while true do
        local mousePos = getMousePos()
        
        if isMinimized then
            minCheck(mousePos)
        else
            -- Check menu buttons
            for _, btn in ipairs(menuBtns) do
                btn.checkClick(mousePos)
            end
            -- Check minimize button
            minBtn.checkClick(mousePos)
        end
        
        task.wait(0.05)  -- Low CPU usage
    end
end)

-- Cleanup on script end (optional)
-- cleardrawcache()
