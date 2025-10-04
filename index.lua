-- Arkan Scripts GUI Menu Manager
-- Menggunakan Drawing API untuk Delta Exploit
-- Center screen dengan rounded corners

local drawings = {}
local menuData = {
    {name = "Player", features = {"Speed Boost", "Jump Power", "Fly Mode", "Noclip"}},
    {name = "Combat", features = {"Aimbot", "ESP", "Silent Aim", "Hitbox Expander"}},
    {name = "Visual", features = {"Fullbright", "No Fog", "Tracers", "Chams"}},
    {name = "Misc", features = {"Auto Farm", "Teleport", "Infinite Jump", "Anti AFK"}},
}

local selectedMenu = 1
local camera = workspace.CurrentCamera
local menuSize = Vector2.new(800, 600)
local isMinimized = false
local minimizedSize = 60 -- Diameter circle saat minimized

-- Fungsi untuk mendapatkan posisi center
local function getCenterPosition()
    local viewportSize = camera.ViewportSize
    return Vector2.new(
        (viewportSize.X - menuSize.X) / 2,
        (viewportSize.Y - menuSize.Y) / 2
    )
end

local menuPos = getCenterPosition()

-- Fungsi helper untuk membuat drawing
local function createDrawing(type, properties)
    local d = Drawing.new(type)
    for prop, val in pairs(properties) do
        d[prop] = val
    end
    table.insert(drawings, d)
    return d
end

-- Fungsi untuk membuat rounded rectangle dengan triangle
local function createRoundedRect(pos, size, color, filled, radius, transparency, zIndex)
    radius = radius or 10
    
    -- Main rectangle (center)
    local mainRect = createDrawing("Square", {
        Size = Vector2.new(size.X - radius * 2, size.Y),
        Position = Vector2.new(pos.X + radius, pos.Y),
        Color = color,
        Filled = filled,
        Transparency = transparency,
        Visible = true,
        ZIndex = zIndex
    })
    
    -- Top and bottom strips
    local topRect = createDrawing("Square", {
        Size = Vector2.new(size.X, size.Y - radius * 2),
        Position = Vector2.new(pos.X, pos.Y + radius),
        Color = color,
        Filled = filled,
        Transparency = transparency,
        Visible = true,
        ZIndex = zIndex
    })
    
    -- Corners (using circles for smooth rounded effect)
    local corners = {
        {x = pos.X + radius, y = pos.Y + radius}, -- Top-left
        {x = pos.X + size.X - radius, y = pos.Y + radius}, -- Top-right
        {x = pos.X + radius, y = pos.Y + size.Y - radius}, -- Bottom-left
        {x = pos.X + size.X - radius, y = pos.Y + size.Y - radius}, -- Bottom-right
    }
    
    for _, corner in ipairs(corners) do
        createDrawing("Circle", {
            Position = Vector2.new(corner.x, corner.y),
            Radius = radius,
            Color = color,
            Filled = filled,
            NumSides = 32,
            Transparency = transparency,
            Visible = true,
            ZIndex = zIndex
        })
    end
end

-- Fungsi untuk membersihkan semua drawing
local function clearAllDrawings()
    for _, d in ipairs(drawings) do
        d:Destroy()
    end
    drawings = {}
end

-- Fungsi untuk render GUI
local function renderGUI()
    clearAllDrawings()
    menuPos = getCenterPosition()
    
    -- Background utama dengan rounded corners
    createRoundedRect(menuPos, menuSize, Color3.fromRGB(25, 25, 35), true, 15, 0.95, 1)
    
    -- Border utama dengan rounded corners
    createRoundedRect(menuPos, menuSize, Color3.fromRGB(100, 100, 255), false, 15, 1, 2)
    
    -- Header background dengan rounded top corners
    local headerHeight = 50
    createRoundedRect(menuPos, Vector2.new(menuSize.X, headerHeight), Color3.fromRGB(35, 35, 50), true, 15, 1, 2)
    
    -- Cover bagian bawah header agar tidak rounded
    local headerCover = createDrawing("Square", {
        Size = Vector2.new(menuSize.X - 30, 15),
        Position = Vector2.new(menuPos.X + 15, menuPos.Y + headerHeight - 15),
        Color = Color3.fromRGB(35, 35, 50),
        Filled = true,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })
    
    -- Title text
    local titleText = createDrawing("Text", {
        Text = "Arkan Scripts",
        Font = Drawing.Fonts.Plex,
        Size = 24,
        Position = Vector2.new(menuPos.X + 30, menuPos.Y + 15),
        Color = Color3.fromRGB(100, 150, 255),
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })
    
    -- Divider horizontal setelah header
    local dividerHeader = createDrawing("Line", {
        From = Vector2.new(menuPos.X + 15, menuPos.Y + headerHeight),
        To = Vector2.new(menuPos.X + menuSize.X - 15, menuPos.Y + headerHeight),
        Color = Color3.fromRGB(100, 100, 255),
        Thickness = 2,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })
    
    -- Panel kiri (Menu List) - 30% lebar
    local leftPanelWidth = menuSize.X * 0.3
    local contentHeight = menuSize.Y - headerHeight
    
    -- Divider vertikal antara panel kiri dan kanan
    local dividerVertical = createDrawing("Line", {
        From = Vector2.new(menuPos.X + leftPanelWidth, menuPos.Y + headerHeight),
        To = Vector2.new(menuPos.X + leftPanelWidth, menuPos.Y + menuSize.Y - 15),
        Color = Color3.fromRGB(100, 100, 255),
        Thickness = 2,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })
    
    -- Render menu items di panel kiri
    local menuItemHeight = 50
    for i, menu in ipairs(menuData) do
        local yPos = menuPos.Y + headerHeight + (i - 1) * menuItemHeight
        
        -- Background menu item (highlight jika selected) dengan rounded
        if i == selectedMenu then
            createRoundedRect(
                Vector2.new(menuPos.X + 8, yPos + 5),
                Vector2.new(leftPanelWidth - 16, menuItemHeight - 10),
                Color3.fromRGB(60, 60, 120),
                true,
                8,
                0.8,
                3
            )
        end
        
        -- Menu text
        local menuText = createDrawing("Text", {
            Text = menu.name,
            Font = Drawing.Fonts.UI,
            Size = 18,
            Position = Vector2.new(menuPos.X + 25, yPos + 17),
            Color = i == selectedMenu and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
            Transparency = 1,
            Visible = true,
            ZIndex = 4
        })
        
        -- Divider antara menu items
        if i < #menuData then
            local menuDivider = createDrawing("Line", {
                From = Vector2.new(menuPos.X + 15, yPos + menuItemHeight),
                To = Vector2.new(menuPos.X + leftPanelWidth - 15, yPos + menuItemHeight),
                Color = Color3.fromRGB(50, 50, 60),
                Thickness = 1,
                Transparency = 0.5,
                Visible = true,
                ZIndex = 3
            })
        end
    end
    
    -- Panel kanan (Features) - 70% lebar
    local rightPanelX = menuPos.X + leftPanelWidth
    local rightPanelWidth = menuSize.X - leftPanelWidth
    
    -- Header panel kanan
    local rightHeaderText = createDrawing("Text", {
        Text = menuData[selectedMenu].name .. " Features",
        Font = Drawing.Fonts.Plex,
        Size = 20,
        Position = Vector2.new(rightPanelX + 25, menuPos.Y + headerHeight + 20),
        Color = Color3.fromRGB(200, 200, 255),
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })
    
    -- Render features
    local featureStartY = menuPos.Y + headerHeight + 60
    local featureSpacing = 45
    for i, feature in ipairs(menuData[selectedMenu].features) do
        local yPos = featureStartY + (i - 1) * featureSpacing
        
        -- Feature checkbox background dengan rounded corners
        createRoundedRect(
            Vector2.new(rightPanelX + 25, yPos),
            Vector2.new(20, 20),
            Color3.fromRGB(50, 50, 60),
            true,
            4,
            1,
            3
        )
        
        -- Feature checkbox border dengan rounded corners
        createRoundedRect(
            Vector2.new(rightPanelX + 25, yPos),
            Vector2.new(20, 20),
            Color3.fromRGB(100, 100, 150),
            false,
            4,
            1,
            4
        )
        
        -- Feature text
        local featureText = createDrawing("Text", {
            Text = feature,
            Font = Drawing.Fonts.UI,
            Size = 16,
            Position = Vector2.new(rightPanelX + 55, yPos + 2),
            Color = Color3.fromRGB(220, 220, 220),
            Transparency = 1,
            Visible = true,
            ZIndex = 3
        })
    end
    
    -- Info text di bawah
    local infoText = createDrawing("Text", {
        Text = "Klik menu di kiri untuk melihat fitur | Press DEL untuk close",
        Font = Drawing.Fonts.Monospace,
        Size = 12,
        Position = Vector2.new(menuPos.X + 25, menuPos.Y + menuSize.Y - 25),
        Color = Color3.fromRGB(150, 150, 150),
        Transparency = 0.7,
        Visible = true,
        ZIndex = 3
    })
end

-- Input handling
local function handleInput()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    
    mouse.Button1Down:Connect(function()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local leftPanelWidth = menuSize.X * 0.3
        local menuItemHeight = 50
        local headerHeight = 50
        
        -- Check jika klik di area menu kiri
        if mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + leftPanelWidth then
            if mousePos.Y >= menuPos.Y + headerHeight and mousePos.Y <= menuPos.Y + menuSize.Y then
                local clickedIndex = math.floor((mousePos.Y - (menuPos.Y + headerHeight)) / menuItemHeight) + 1
                if clickedIndex >= 1 and clickedIndex <= #menuData then
                    selectedMenu = clickedIndex
                    renderGUI()
                end
            end
        end
    end)
end

-- Update posisi saat viewport berubah
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    renderGUI()
end)

-- Inisialisasi GUI
renderGUI()
handleInput()

-- Fungsi untuk menutup GUI
local function closeGUI()
    clearAllDrawings()
end

-- Keyboard handler untuk close
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Delete then
        closeGUI()
    end
end)

print("Arkan Scripts GUI loaded! Press DELETE to close.")
