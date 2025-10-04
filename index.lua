-- Modern GUI Menu System for DeltaExploit
-- Arkan Scripts Professional Menu

local GUI = {}
GUI.__index = GUI

-- Configuration
local CONFIG = {
    -- Window Settings
    windowWidth = 600,
    windowHeight = 400,
    windowPosition = Vector2.new(200, 200),
    
    -- Colors
    colors = {
        background = Color3.fromRGB(25, 28, 35),
        header = Color3.fromRGB(32, 36, 44),
        sidebar = Color3.fromRGB(28, 31, 38),
        content = Color3.fromRGB(30, 33, 41),
        accent = Color3.fromRGB(88, 101, 242),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(160, 165, 175),
        hover = Color3.fromRGB(45, 50, 60),
        border = Color3.fromRGB(45, 50, 60),
        minimizedBg = Color3.fromRGB(88, 101, 242),
    },
    
    -- Sizes
    headerHeight = 40,
    sidebarWidth = 150,
    padding = 10,
    minimizedSize = 50,
    
    -- Animation
    animationSpeed = 0.15,
}

-- Helper Functions
local function isPointInRect(point, position, size)
    return point.X >= position.X and point.X <= position.X + size.X and
           point.Y >= position.Y and point.Y <= position.Y + size.Y
end

local function isPointInCircle(point, center, radius)
    local distance = ((point.X - center.X)^2 + (point.Y - center.Y)^2)^0.5
    return distance <= radius
end

local function createRoundedRect(position, size, color, transparency, filled)
    local drawings = {}
    local cornerRadius = 8
    
    -- Main rectangle (slightly smaller to account for corners)
    local mainRect = Drawing.new("Square")
    mainRect.Position = Vector2.new(position.X + cornerRadius, position.Y)
    mainRect.Size = Vector2.new(size.X - cornerRadius * 2, size.Y)
    mainRect.Color = color
    mainRect.Transparency = transparency
    mainRect.Filled = filled
    mainRect.Visible = true
    table.insert(drawings, mainRect)
    
    -- Top and bottom rectangles
    local topRect = Drawing.new("Square")
    topRect.Position = Vector2.new(position.X, position.Y + cornerRadius)
    topRect.Size = Vector2.new(size.X, size.Y - cornerRadius * 2)
    topRect.Color = color
    topRect.Transparency = transparency
    topRect.Filled = filled
    topRect.Visible = true
    table.insert(drawings, topRect)
    
    -- Corner circles
    local corners = {
        {position.X + cornerRadius, position.Y + cornerRadius},
        {position.X + size.X - cornerRadius, position.Y + cornerRadius},
        {position.X + cornerRadius, position.Y + size.Y - cornerRadius},
        {position.X + size.X - cornerRadius, position.Y + size.Y - cornerRadius}
    }
    
    for _, corner in ipairs(corners) do
        local circle = Drawing.new("Circle")
        circle.Position = Vector2.new(corner[1], corner[2])
        circle.Radius = cornerRadius
        circle.Color = color
        circle.Transparency = transparency
        circle.Filled = filled
        circle.NumSides = 12
        circle.Visible = true
        table.insert(drawings, circle)
    end
    
    return drawings
end

function GUI.new()
    local self = setmetatable({}, GUI)
    
    -- State
    self.visible = false
    self.minimized = false
    self.dragging = false
    self.dragOffset = Vector2.new(0, 0)
    self.position = CONFIG.windowPosition
    self.minimizedPosition = Vector2.new(CONFIG.windowPosition.X + CONFIG.windowWidth / 2 - CONFIG.minimizedSize / 2, 
                                         CONFIG.windowPosition.Y - 60)
    self.selectedMenu = 1
    self.hoveredMenuItem = nil
    
    -- Drawing objects
    self.drawings = {}
    
    -- Menu data
    self.menus = {
        {
            name = "Combat",
            features = {
                {name = "Auto Farm", enabled = false, description = "Automatically farms enemies"},
                {name = "Kill Aura", enabled = false, description = "Attacks nearby enemies"},
                {name = "Aimbot", enabled = false, description = "Auto-aim at targets"},
                {name = "ESP", enabled = false, description = "Show enemy positions"},
            }
        },
        {
            name = "Player",
            features = {
                {name = "Speed Hack", enabled = false, description = "Increase movement speed"},
                {name = "Jump Power", enabled = false, description = "Increase jump height"},
                {name = "Fly Mode", enabled = false, description = "Enable flight"},
                {name = "Noclip", enabled = false, description = "Walk through walls"},
            }
        },
        {
            name = "World",
            features = {
                {name = "Fullbright", enabled = false, description = "Remove darkness"},
                {name = "No Fog", enabled = false, description = "Disable fog effects"},
                {name = "Time Changer", enabled = false, description = "Change time of day"},
                {name = "Weather", enabled = false, description = "Control weather"},
            }
        },
        {
            name = "Teleport",
            features = {
                {name = "Save Position", enabled = false, description = "Save current position"},
                {name = "Load Position", enabled = false, description = "Teleport to saved position"},
                {name = "Teleport to Player", enabled = false, description = "TP to selected player"},
                {name = "Click TP", enabled = false, description = "Teleport where you click"},
            }
        },
        {
            name = "Settings",
            features = {
                {name = "UI Scale", enabled = false, description = "Adjust interface size"},
                {name = "Theme", enabled = false, description = "Change color theme"},
                {name = "Keybinds", enabled = false, description = "Configure hotkeys"},
                {name = "Auto Save", enabled = true, description = "Save settings automatically"},
            }
        }
    }
    
    -- Mouse handling
    self.mouseConnection = nil
    
    return self
end

function GUI:clearDrawings()
    for _, drawing in ipairs(self.drawings) do
        if drawing and drawing.Destroy then
            drawing:Destroy()
        end
    end
    self.drawings = {}
end

function GUI:drawMinimized()
    self:clearDrawings()
    
    -- Background circle
    local bgCircle = Drawing.new("Circle")
    bgCircle.Position = Vector2.new(
        self.minimizedPosition.X + CONFIG.minimizedSize / 2,
        self.minimizedPosition.Y + CONFIG.minimizedSize / 2
    )
    bgCircle.Radius = CONFIG.minimizedSize / 2
    bgCircle.Color = CONFIG.colors.minimizedBg
    bgCircle.Filled = true
    bgCircle.NumSides = 32
    bgCircle.Transparency = 0.9
    bgCircle.Visible = true
    table.insert(self.drawings, bgCircle)
    
    -- Border circle
    local borderCircle = Drawing.new("Circle")
    borderCircle.Position = bgCircle.Position
    borderCircle.Radius = CONFIG.minimizedSize / 2
    borderCircle.Color = CONFIG.colors.text
    borderCircle.Filled = false
    borderCircle.Thickness = 2
    borderCircle.NumSides = 32
    borderCircle.Transparency = 0.8
    borderCircle.Visible = true
    table.insert(self.drawings, borderCircle)
    
    -- "A" text
    local text = Drawing.new("Text")
    text.Text = "A"
    text.Font = Drawing.Fonts.System
    text.Size = 24
    text.Color = CONFIG.colors.text
    text.Position = Vector2.new(
        self.minimizedPosition.X + CONFIG.minimizedSize / 2 - 7,
        self.minimizedPosition.Y + CONFIG.minimizedSize / 2 - 12
    )
    text.Transparency = 1
    text.Visible = true
    table.insert(self.drawings, text)
end

function GUI:drawWindow()
    self:clearDrawings()
    
    -- Window background with rounded corners
    local bgDrawings = createRoundedRect(
        self.position,
        Vector2.new(CONFIG.windowWidth, CONFIG.windowHeight),
        CONFIG.colors.background,
        0.95,
        true
    )
    for _, drawing in ipairs(bgDrawings) do
        table.insert(self.drawings, drawing)
    end
    
    -- Header background
    local headerBg = Drawing.new("Square")
    headerBg.Position = Vector2.new(self.position.X + 8, self.position.Y + 8)
    headerBg.Size = Vector2.new(CONFIG.windowWidth - 16, CONFIG.headerHeight)
    headerBg.Color = CONFIG.colors.header
    headerBg.Filled = true
    headerBg.Transparency = 0.95
    headerBg.Visible = true
    table.insert(self.drawings, headerBg)
    
    -- Header text
    local headerText = Drawing.new("Text")
    headerText.Text = "Arkan Scripts"
    headerText.Font = Drawing.Fonts.Plex
    headerText.Size = 20
    headerText.Color = CONFIG.colors.text
    headerText.Position = Vector2.new(self.position.X + 20, self.position.Y + 15)
    headerText.Transparency = 1
    headerText.Visible = true
    table.insert(self.drawings, headerText)
    
    -- Minimize button
    local minimizeBtn = Drawing.new("Circle")
    minimizeBtn.Position = Vector2.new(
        self.position.X + CONFIG.windowWidth - 25,
        self.position.Y + CONFIG.headerHeight / 2 + 8
    )
    minimizeBtn.Radius = 8
    minimizeBtn.Color = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Filled = true
    minimizeBtn.NumSides = 16
    minimizeBtn.Transparency = 0.9
    minimizeBtn.Visible = true
    table.insert(self.drawings, minimizeBtn)
    
    -- Minimize text
    local minimizeText = Drawing.new("Text")
    minimizeText.Text = "-"
    minimizeText.Font = Drawing.Fonts.System
    minimizeText.Size = 16
    minimizeText.Color = CONFIG.colors.background
    minimizeText.Position = Vector2.new(
        self.position.X + CONFIG.windowWidth - 29,
        self.position.Y + CONFIG.headerHeight / 2 - 2
    )
    minimizeText.Transparency = 1
    minimizeText.Visible = true
    table.insert(self.drawings, minimizeText)
    
    -- Sidebar background
    local sidebarBg = Drawing.new("Square")
    sidebarBg.Position = Vector2.new(
        self.position.X + 8,
        self.position.Y + CONFIG.headerHeight + 16
    )
    sidebarBg.Size = Vector2.new(
        CONFIG.sidebarWidth,
        CONFIG.windowHeight - CONFIG.headerHeight - 24
    )
    sidebarBg.Color = CONFIG.colors.sidebar
    sidebarBg.Filled = true
    sidebarBg.Transparency = 0.95
    sidebarBg.Visible = true
    table.insert(self.drawings, sidebarBg)
    
    -- Draw menu items
    for i, menu in ipairs(self.menus) do
        local yOffset = self.position.Y + CONFIG.headerHeight + 24 + (i - 1) * 40
        
        -- Highlight selected or hovered item
        if i == self.selectedMenu or i == self.hoveredMenuItem then
            local highlightBg = Drawing.new("Square")
            highlightBg.Position = Vector2.new(
                self.position.X + 12,
                yOffset - 4
            )
            highlightBg.Size = Vector2.new(CONFIG.sidebarWidth - 8, 32)
            highlightBg.Color = i == self.selectedMenu and CONFIG.colors.accent or CONFIG.colors.hover
            highlightBg.Filled = true
            highlightBg.Transparency = i == self.selectedMenu and 0.9 or 0.7
            highlightBg.Visible = true
            table.insert(self.drawings, highlightBg)
        end
        
        -- Menu text
        local menuText = Drawing.new("Text")
        menuText.Text = menu.name
        menuText.Font = Drawing.Fonts.System
        menuText.Size = 16
        menuText.Color = i == self.selectedMenu and CONFIG.colors.text or CONFIG.colors.textDim
        menuText.Position = Vector2.new(self.position.X + 20, yOffset)
        menuText.Transparency = 1
        menuText.Visible = true
        table.insert(self.drawings, menuText)
    end
    
    -- Content area background
    local contentBg = Drawing.new("Square")
    contentBg.Position = Vector2.new(
        self.position.X + CONFIG.sidebarWidth + 16,
        self.position.Y + CONFIG.headerHeight + 16
    )
    contentBg.Size = Vector2.new(
        CONFIG.windowWidth - CONFIG.sidebarWidth - 32,
        CONFIG.windowHeight - CONFIG.headerHeight - 24
    )
    contentBg.Color = CONFIG.colors.content
    contentBg.Filled = true
    contentBg.Transparency = 0.95
    contentBg.Visible = true
    table.insert(self.drawings, contentBg)
    
    -- Draw features for selected menu
    local selectedMenuData = self.menus[self.selectedMenu]
    if selectedMenuData then
        -- Content title
        local titleText = Drawing.new("Text")
        titleText.Text = selectedMenuData.name .. " Features"
        titleText.Font = Drawing.Fonts.Plex
        titleText.Size = 18
        titleText.Color = CONFIG.colors.text
        titleText.Position = Vector2.new(
            self.position.X + CONFIG.sidebarWidth + 30,
            self.position.Y + CONFIG.headerHeight + 30
        )
        titleText.Transparency = 1
        titleText.Visible = true
        table.insert(self.drawings, titleText)
        
        -- Draw features
        for i, feature in ipairs(selectedMenuData.features) do
            local featureY = self.position.Y + CONFIG.headerHeight + 70 + (i - 1) * 50
            
            -- Feature name
            local featureName = Drawing.new("Text")
            featureName.Text = feature.name
            featureName.Font = Drawing.Fonts.System
            featureName.Size = 16
            featureName.Color = CONFIG.colors.text
            featureName.Position = Vector2.new(
                self.position.X + CONFIG.sidebarWidth + 30,
                featureY
            )
            featureName.Transparency = 1
            featureName.Visible = true
            table.insert(self.drawings, featureName)
            
            -- Feature description
            local featureDesc = Drawing.new("Text")
            featureDesc.Text = feature.description
            featureDesc.Font = Drawing.Fonts.System
            featureDesc.Size = 12
            featureDesc.Color = CONFIG.colors.textDim
            featureDesc.Position = Vector2.new(
                self.position.X + CONFIG.sidebarWidth + 30,
                featureY + 18
            )
            featureDesc.Transparency = 1
            featureDesc.Visible = true
            table.insert(self.drawings, featureDesc)
            
            -- Toggle button background
            local toggleBg = Drawing.new("Square")
            toggleBg.Position = Vector2.new(
                self.position.X + CONFIG.windowWidth - 80,
                featureY + 5
            )
            toggleBg.Size = Vector2.new(40, 20)
            toggleBg.Color = feature.enabled and CONFIG.colors.accent or CONFIG.colors.border
            toggleBg.Filled = true
            toggleBg.Transparency = 0.9
            toggleBg.Visible = true
            table.insert(self.drawings, toggleBg)
            
            -- Toggle button circle
            local toggleCircle = Drawing.new("Circle")
            toggleCircle.Position = Vector2.new(
                self.position.X + CONFIG.windowWidth - (feature.enabled and 65 or 75),
                featureY + 15
            )
            toggleCircle.Radius = 7
            toggleCircle.Color = CONFIG.colors.text
            toggleCircle.Filled = true
            toggleCircle.NumSides = 16
            toggleCircle.Transparency = 1
            toggleCircle.Visible = true
            table.insert(self.drawings, toggleCircle)
        end
    end
end

function GUI:handleMouse(input)
    local mousePos = input.Position
    
    if self.minimized then
        -- Handle minimized state
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local center = Vector2.new(
                self.minimizedPosition.X + CONFIG.minimizedSize / 2,
                self.minimizedPosition.Y + CONFIG.minimizedSize / 2
            )
            
            if input.UserInputState == Enum.UserInputState.Begin then
                if isPointInCircle(mousePos, center, CONFIG.minimizedSize / 2) then
                    if self.dragging then
                        self.dragging = false
                    else
                        -- Check for double-click to restore
                        if self.lastClickTime and tick() - self.lastClickTime < 0.5 then
                            self.minimized = false
                            self:drawWindow()
                        else
                            self.dragging = true
                            self.dragOffset = Vector2.new(
                                mousePos.X - self.minimizedPosition.X,
                                mousePos.Y - self.minimizedPosition.Y
                            )
                        end
                        self.lastClickTime = tick()
                    end
                end
            elseif input.UserInputState == Enum.UserInputState.End then
                self.dragging = false
            end
        end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.dragging then
            self.minimizedPosition = Vector2.new(
                mousePos.X - self.dragOffset.X,
                mousePos.Y - self.dragOffset.Y
            )
            self:drawMinimized()
        end
    else
        -- Handle normal window state
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputState == Enum.UserInputState.Begin then
                -- Check minimize button with better hit detection
                local minimizeBtnCenter = Vector2.new(
                    self.position.X + CONFIG.windowWidth - 25,
                    self.position.Y + CONFIG.headerHeight / 2 + 8
                )
                
                if isPointInCircle(mousePos, minimizeBtnCenter, 10) then
                    self.minimized = true
                    self:drawMinimized()
                    return
                end
                
                -- Check header for dragging
                local headerRect = {
                    position = self.position,
                    size = Vector2.new(CONFIG.windowWidth, CONFIG.headerHeight)
                }
                
                if isPointInRect(mousePos, headerRect.position, headerRect.size) then
                    self.dragging = true
                    self.dragOffset = Vector2.new(
                        mousePos.X - self.position.X,
                        mousePos.Y - self.position.Y
                    )
                    return
                end
                
                -- Check menu items with improved hit detection
                for i, menu in ipairs(self.menus) do
                    local menuY = self.position.Y + CONFIG.headerHeight + 24 + (i - 1) * 40
                    local menuRect = {
                        position = Vector2.new(self.position.X + 8, menuY - 8),
                        size = Vector2.new(CONFIG.sidebarWidth, 40)
                    }
                    
                    if isPointInRect(mousePos, menuRect.position, menuRect.size) then
                        self.selectedMenu = i
                        self:drawWindow()
                        return
                    end
                end
                
                -- Check feature toggles with improved hit detection
                local selectedMenuData = self.menus[self.selectedMenu]
                if selectedMenuData then
                    for i, feature in ipairs(selectedMenuData.features) do
                        local featureY = self.position.Y + CONFIG.headerHeight + 70 + (i - 1) * 50
                        local toggleRect = {
                            position = Vector2.new(self.position.X + CONFIG.windowWidth - 85, featureY),
                            size = Vector2.new(50, 30)
                        }
                        
                        if isPointInRect(mousePos, toggleRect.position, toggleRect.size) then
                            feature.enabled = not feature.enabled
                            self:drawWindow()
                            return
                        end
                    end
                end
            elseif input.UserInputState == Enum.UserInputState.End then
                self.dragging = false
            end
        end
        
        -- Handle mouse movement for hover effects
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if self.dragging then
                self.position = Vector2.new(
                    mousePos.X - self.dragOffset.X,
                    mousePos.Y - self.dragOffset.Y
                )
                self:drawWindow()
            else
                -- Check for menu item hover
                local previousHovered = self.hoveredMenuItem
                self.hoveredMenuItem = nil
                
                for i, menu in ipairs(self.menus) do
                    local menuY = self.position.Y + CONFIG.headerHeight + 24 + (i - 1) * 40
                    local menuRect = {
                        position = Vector2.new(self.position.X + 8, menuY - 8),
                        size = Vector2.new(CONFIG.sidebarWidth, 40)
                    }
                    
                    if isPointInRect(mousePos, menuRect.position, menuRect.size) and i ~= self.selectedMenu then
                        self.hoveredMenuItem = i
                        break
                    end
                end
                
                if previousHovered ~= self.hoveredMenuItem then
                    self:drawWindow()
                end
            end
        end
    end
end

function GUI:show()
    self.visible = true
    self:drawWindow()
    
    -- Setup mouse input handling
    self.mouseConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            self:handleMouse(input)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
        if not gameProcessed then
            self:handleMouse(input)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed then
            self:handleMouse(input)
        end
    end)
end

function GUI:hide()
    self.visible = false
    self:clearDrawings()
    
    if self.mouseConnection then
        self.mouseConnection:Disconnect()
        self.mouseConnection = nil
    end
end

-- Initialize and show the GUI
local gui = GUI.new()
gui:show()
