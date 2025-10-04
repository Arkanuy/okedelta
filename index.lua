-- Arkan Scripts GUI Menu Manager
-- Menggunakan Drawing API untuk Delta Exploit

local drawings = {}
local menuData = {
    {name = "Player", features = {"Speed Boost", "Jump Power", "Fly Mode", "Noclip"}},
    {name = "Combat", features = {"Aimbot", "ESP", "Silent Aim", "Hitbox Expander"}},
    {name = "Visual", features = {"Fullbright", "No Fog", "Tracers", "Chams"}},
    {name = "Misc", features = {"Auto Farm", "Teleport", "Infinite Jump", "Anti AFK"}},
}

local selectedMenu = 1
local screenSize = Vector2.new(1920, 1080) -- Sesuaikan dengan resolusi Anda
local menuPos = Vector2.new(screenSize.X / 2 - 400, screenSize.Y / 2 - 300)
local menuSize = Vector2.new(800, 600)

-- Fungsi helper untuk membuat drawing
local function createDrawing(type, properties)
    local d = Drawing.new(type)
    for prop, val in pairs(properties) do
        d[prop] = val
    end
    table.insert(drawings, d)
    return d
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
    
    -- Background utama
    local bgMain = createDrawing("Square", {
        Size = menuSize,
        Position = menuPos,
        Color = Color3.fromRGB(25, 25, 35),
        Filled = true,
        Transparency = 0.95,
        Visible = true,
        ZIndex = 1
    })
    
    -- Border utama
    local borderMain = createDrawing("Square", {
        Size = menuSize,
        Position = menuPos,
        Color = Color3.fromRGB(100, 100, 255),
        Filled = false,
        Thickness = 2,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })
    
    -- Header
    local headerBg = createDrawing("Square", {
        Size = Vector2.new(menuSize.X, 50),
        Position = menuPos,
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
        Position = Vector2.new(menuPos.X + 20, menuPos.Y + 15),
        Color = Color3.fromRGB(100, 150, 255),
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })
    
    -- Divider horizontal setelah header
    local dividerHeader = createDrawing("Line", {
        From = Vector2.new(menuPos.X, menuPos.Y + 50),
        To = Vector2.new(menuPos.X + menuSize.X, menuPos.Y + 50),
        Color = Color3.fromRGB(100, 100, 255),
        Thickness = 2,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })
    
    -- Panel kiri (Menu List) - 30% lebar
    local leftPanelWidth = menuSize.X * 0.3
    local leftPanelBg = createDrawing("Square", {
        Size = Vector2.new(leftPanelWidth, menuSize.Y - 50),
        Position = Vector2.new(menuPos.X, menuPos.Y + 50),
        Color = Color3.fromRGB(30, 30, 40),
        Filled = true,
        Transparency = 0.98,
        Visible = true,
        ZIndex = 2
    })
    
    -- Divider vertikal antara panel kiri dan kanan
    local dividerVertical = createDrawing("Line", {
        From = Vector2.new(menuPos.X + leftPanelWidth, menuPos.Y + 50),
        To = Vector2.new(menuPos.X + leftPanelWidth, menuPos.Y + menuSize.Y),
        Color = Color3.fromRGB(100, 100, 255),
        Thickness = 2,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })
    
    -- Render menu items di panel kiri
    local menuItemHeight = 50
    for i, menu in ipairs(menuData) do
        local yPos = menuPos.Y + 50 + (i - 1) * menuItemHeight
        
        -- Background menu item (highlight jika selected)
        if i == selectedMenu then
            local selectedBg = createDrawing("Square", {
                Size = Vector2.new(leftPanelWidth - 4, menuItemHeight - 2),
                Position = Vector2.new(menuPos.X + 2, yPos + 1),
                Color = Color3.fromRGB(60, 60, 120),
                Filled = true,
                Transparency = 0.8,
                Visible = true,
                ZIndex = 3
            })
        end
        
        -- Menu text
        local menuText = createDrawing("Text", {
            Text = menu.name,
            Font = Drawing.Fonts.UI,
            Size = 18,
            Position = Vector2.new(menuPos.X + 20, yPos + 17),
            Color = i == selectedMenu and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
            Transparency = 1,
            Visible = true,
            ZIndex = 4
        })
        
        -- Divider antara menu items
        if i < #menuData then
            local menuDivider = createDrawing("Line", {
                From = Vector2.new(menuPos.X + 10, yPos + menuItemHeight),
                To = Vector2.new(menuPos.X + leftPanelWidth - 10, yPos + menuItemHeight),
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
        Position = Vector2.new(rightPanelX + 20, menuPos.Y + 70),
        Color = Color3.fromRGB(200, 200, 255),
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })
    
    -- Render features
    local featureStartY = menuPos.Y + 110
    local featureSpacing = 40
    for i, feature in ipairs(menuData[selectedMenu].features) do
        local yPos = featureStartY + (i - 1) * featureSpacing
        
        -- Feature checkbox background
        local checkboxBg = createDrawing("Square", {
            Size = Vector2.new(20, 20),
            Position = Vector2.new(rightPanelX + 20, yPos),
            Color = Color3.fromRGB(50, 50, 60),
            Filled = true,
            Transparency = 1,
            Visible = true,
            ZIndex = 3
        })
        
        -- Feature checkbox border
        local checkboxBorder = createDrawing("Square", {
            Size = Vector2.new(20, 20),
            Position = Vector2.new(rightPanelX + 20, yPos),
            Color = Color3.fromRGB(100, 100, 150),
            Filled = false,
            Thickness = 1,
            Transparency = 1,
            Visible = true,
            ZIndex = 4
        })
        
        -- Feature text
        local featureText = createDrawing("Text", {
            Text = feature,
            Font = Drawing.Fonts.UI,
            Size = 16,
            Position = Vector2.new(rightPanelX + 50, yPos + 2),
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
        Position = Vector2.new(menuPos.X + 20, menuPos.Y + menuSize.Y - 25),
        Color = Color3.fromRGB(150, 150, 150),
        Transparency = 0.7,
        Visible = true,
        ZIndex = 3
    })
end

-- Input handling sederhana (contoh)
-- Dalam implementasi nyata, Anda perlu menambahkan mouse input handler
local function handleInput()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    
    mouse.Button1Down:Connect(function()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local leftPanelWidth = menuSize.X * 0.3
        local menuItemHeight = 50
        
        -- Check jika klik di area menu kiri
        if mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + leftPanelWidth then
            if mousePos.Y >= menuPos.Y + 50 and mousePos.Y <= menuPos.Y + menuSize.Y then
                local clickedIndex = math.floor((mousePos.Y - (menuPos.Y + 50)) / menuItemHeight) + 1
                if clickedIndex >= 1 and clickedIndex <= #menuData then
                    selectedMenu = clickedIndex
                    renderGUI()
                end
            end
        end
    end)
end

-- Inisialisasi GUI
renderGUI()
handleInput()

-- Fungsi untuk menutup GUI
local function closeGUI()
    clearAllDrawings()
end

-- Keyboard handler untuk close (contoh dengan UserInputService)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Delete then
        closeGUI()
    end
end)

print("Arkan Scripts GUI loaded! Press DELETE to close.")
