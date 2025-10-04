-- Arkan Scripts GUI dengan Drawing API
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Konfigurasi
local screenSize = workspace.CurrentCamera.ViewportSize
local guiWidth = 500
local guiHeight = 350
local guiX = (screenSize.X - guiWidth) / 2
local guiY = (screenSize.Y - guiHeight) / 2
local cornerRadius = 12
local menuWidth = 150

-- State
local isMinimized = false
local currentMenu = "Home"
local drawings = {}
local menuButtons = {}

-- Warna
local colors = {
    background = Color3.fromRGB(25, 25, 30),
    sidebar = Color3.fromRGB(20, 20, 25),
    accent = Color3.fromRGB(100, 100, 255),
    text = Color3.fromRGB(240, 240, 240),
    textDim = Color3.fromRGB(160, 160, 160),
    border = Color3.fromRGB(50, 50, 60),
}

-- Menu items
local menus = {
    {name = "Home", icon = "H"},
    {name = "Player", icon = "P"},
    {name = "Combat", icon = "C"},
    {name = "Visual", icon = "V"},
    {name = "Settings", icon = "S"},
}

-- Fungsi helper untuk membuat rounded rectangle
local function createRoundedRect(x, y, w, h, radius, color, filled, transparency)
    local rects = {}
    
    -- Main body
    local main = Drawing.new("Square")
    main.Position = Vector2.new(x + radius, y)
    main.Size = Vector2.new(w - radius * 2, h)
    main.Color = color
    main.Filled = filled
    main.Transparency = transparency or 1
    main.Visible = true
    table.insert(rects, main)
    
    -- Left side
    local left = Drawing.new("Square")
    left.Position = Vector2.new(x, y + radius)
    left.Size = Vector2.new(radius, h - radius * 2)
    left.Color = color
    left.Filled = filled
    left.Transparency = transparency or 1
    left.Visible = true
    table.insert(rects, left)
    
    -- Right side
    local right = Drawing.new("Square")
    right.Position = Vector2.new(x + w - radius, y + radius)
    right.Size = Vector2.new(radius, h - radius * 2)
    right.Color = color
    right.Filled = filled
    right.Transparency = transparency or 1
    right.Visible = true
    table.insert(rects, right)
    
    -- Corners (circles)
    local corners = {
        {x + radius, y + radius},
        {x + w - radius, y + radius},
        {x + radius, y + h - radius},
        {x + w - radius, y + h - radius},
    }
    
    for _, pos in ipairs(corners) do
        local circle = Drawing.new("Circle")
        circle.Position = Vector2.new(pos[1], pos[2])
        circle.Radius = radius
        circle.Color = color
        circle.Filled = filled
        circle.NumSides = 16
        circle.Transparency = transparency or 1
        circle.Visible = true
        table.insert(rects, circle)
    end
    
    return rects
end

-- Fungsi untuk membersihkan drawings
local function clearDrawings()
    for _, drawing in ipairs(drawings) do
        if type(drawing) == "table" then
            for _, d in ipairs(drawing) do
                d:Destroy()
            end
        else
            drawing:Destroy()
        end
    end
    drawings = {}
    menuButtons = {}
end

-- Fungsi untuk membuat GUI minimized
local function createMinimizedGUI()
    clearDrawings()
    
    local minSize = 60
    local minX = (screenSize.X - minSize) / 2
    local minY = (screenSize.Y - minSize) / 2
    
    -- Background circle
    local bg = Drawing.new("Circle")
    bg.Position = Vector2.new(minX + minSize/2, minY + minSize/2)
    bg.Radius = minSize / 2
    bg.Color = colors.background
    bg.Filled = true
    bg.NumSides = 32
    bg.Transparency = 0.95
    bg.Visible = true
    table.insert(drawings, bg)
    
    -- Border circle
    local border = Drawing.new("Circle")
    border.Position = Vector2.new(minX + minSize/2, minY + minSize/2)
    border.Radius = minSize / 2
    border.Color = colors.accent
    border.Filled = false
    border.NumSides = 32
    border.Thickness = 2
    border.Transparency = 0.8
    border.Visible = true
    table.insert(drawings, border)
    
    -- Text "A"
    local text = Drawing.new("Text")
    text.Text = "A"
    text.Size = 28
    text.Font = Drawing.Fonts.Plex
    text.Color = colors.accent
    text.Position = Vector2.new(minX + minSize/2 - 8, minY + minSize/2 - 14)
    text.Transparency = 1
    text.Visible = true
    table.insert(drawings, text)
    
    -- Hit area untuk click
    menuButtons.minimize = {
        x = minX, y = minY,
        w = minSize, h = minSize,
        action = function()
            isMinimized = false
            createMainGUI()
        end
    }
end

-- Fungsi untuk membuat GUI utama
function createMainGUI()
    clearDrawings()
    
    -- Background utama
    local mainBg = createRoundedRect(guiX, guiY, guiWidth, guiHeight, cornerRadius, colors.background, true, 0.95)
    for _, d in ipairs(mainBg) do table.insert(drawings, d) end
    
    -- Header
    local headerH = 45
    local header = createRoundedRect(guiX, guiY, guiWidth, headerH, cornerRadius, colors.accent, true, 0.3)
    for _, d in ipairs(header) do table.insert(drawings, d) end
    
    -- Title
    local title = Drawing.new("Text")
    title.Text = "Arkan Scripts"
    title.Size = 20
    title.Font = Drawing.Fonts.Plex
    title.Color = colors.text
    title.Position = Vector2.new(guiX + 20, guiY + 12)
    title.Transparency = 1
    title.Visible = true
    table.insert(drawings, title)
    
    -- Minimize button
    local minBtn = Drawing.new("Circle")
    minBtn.Position = Vector2.new(guiX + guiWidth - 30, guiY + headerH/2)
    minBtn.Radius = 8
    minBtn.Color = colors.accent
    minBtn.Filled = true
    minBtn.NumSides = 16
    minBtn.Transparency = 0.8
    minBtn.Visible = true
    table.insert(drawings, minBtn)
    
    menuButtons.minimize = {
        x = guiX + guiWidth - 40,
        y = guiY + 5,
        w = 30, h = 30,
        action = function()
            isMinimized = true
            createMinimizedGUI()
        end
    }
    
    -- Sidebar
    local sidebarX = guiX
    local sidebarY = guiY + headerH
    local sidebar = createRoundedRect(sidebarX, sidebarY, menuWidth, guiHeight - headerH, cornerRadius, colors.sidebar, true, 0.9)
    for _, d in ipairs(sidebar) do table.insert(drawings, d) end
    
    -- Menu items
    local menuY = sidebarY + 15
    for i, menu in ipairs(menus) do
        local itemH = 40
        local itemY = menuY + (i - 1) * (itemH + 8)
        
        -- Menu background (highlight if selected)
        if menu.name == currentMenu then
            local highlight = createRoundedRect(sidebarX + 8, itemY, menuWidth - 16, itemH, 6, colors.accent, true, 0.3)
            for _, d in ipairs(highlight) do table.insert(drawings, d) end
        end
        
        -- Menu icon
        local icon = Drawing.new("Text")
        icon.Text = menu.icon
        icon.Size = 18
        icon.Font = Drawing.Fonts.Plex
        icon.Color = menu.name == currentMenu and colors.accent or colors.textDim
        icon.Position = Vector2.new(sidebarX + 20, itemY + 10)
        icon.Transparency = 1
        icon.Visible = true
        table.insert(drawings, icon)
        
        -- Menu text
        local text = Drawing.new("Text")
        text.Text = menu.name
        text.Size = 16
        text.Font = Drawing.Fonts.UI
        text.Color = menu.name == currentMenu and colors.text or colors.textDim
        text.Position = Vector2.new(sidebarX + 45, itemY + 11)
        text.Transparency = 1
        text.Visible = true
        table.insert(drawings, text)
        
        -- Hit area
        menuButtons[menu.name] = {
            x = sidebarX + 8,
            y = itemY,
            w = menuWidth - 16,
            h = itemH,
            action = function()
                currentMenu = menu.name
                createMainGUI()
            end
        }
    end
    
    -- Content area
    local contentX = guiX + menuWidth + 20
    local contentY = sidebarY + 20
    local contentW = guiWidth - menuWidth - 40
    
    -- Content title
    local contentTitle = Drawing.new("Text")
    contentTitle.Text = currentMenu .. " Menu"
    contentTitle.Size = 18
    contentTitle.Font = Drawing.Fonts.Plex
    contentTitle.Color = colors.accent
    contentTitle.Position = Vector2.new(contentX, contentY)
    contentTitle.Transparency = 1
    contentTitle.Visible = true
    table.insert(drawings, contentTitle)
    
    -- Content description
    local desc = Drawing.new("Text")
    desc.Text = "Features for " .. currentMenu
    desc.Size = 14
    desc.Font = Drawing.Fonts.UI
    desc.Color = colors.textDim
    desc.Position = Vector2.new(contentX, contentY + 30)
    desc.Transparency = 1
    desc.Visible = true
    table.insert(drawings, desc)
    
    -- Sample features
    for i = 1, 4 do
        local featureY = contentY + 60 + (i - 1) * 35
        
        local checkbox = Drawing.new("Square")
        checkbox.Position = Vector2.new(contentX, featureY)
        checkbox.Size = Vector2.new(18, 18)
        checkbox.Color = colors.border
        checkbox.Filled = false
        checkbox.Thickness = 2
        checkbox.Transparency = 0.8
        checkbox.Visible = true
        table.insert(drawings, checkbox)
        
        local feature = Drawing.new("Text")
        feature.Text = "Feature " .. i
        feature.Size = 14
        feature.Font = Drawing.Fonts.UI
        feature.Color = colors.text
        feature.Position = Vector2.new(contentX + 28, featureY + 2)
        feature.Transparency = 1
        feature.Visible = true
        table.insert(drawings, feature)
    end
end

-- Fungsi untuk handle click
local function handleClick(x, y)
    for name, btn in pairs(menuButtons) do
        if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
            btn.action()
            break
        end
    end
end

-- Event listener
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        handleClick(mousePos.X, mousePos.Y - 36) -- Offset untuk topbar Roblox
    end
end)

-- Initialize
createMainGUI()

-- Cleanup saat script dihentikan
local function cleanup()
    clearDrawings()
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(cleanup)
