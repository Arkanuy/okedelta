-- Modern GUI Menu System for DeltaExploit
-- Created with smooth interactions and professional design

local GUI = {}

-- Mouse position tracking
local mouse = {
    X = 0,
    Y = 0,
    Pressed = false,
    Released = false
}

-- GUI State
local GUIState = {
    Minimized = false,
    Dragging = false,
    DragOffset = Vector2.new(0, 0),
    SelectedMenu = "Combat",
    MouseDown = false,
    LastClickTime = 0
}

-- Menu structure data
local MenuData = {
    Combat = {
        {"Auto Farm", false},
        {"Kill Aura", false},
        {"Trigger Bot", false},
        {"Hit Box Expand", false},
        {"Silent Aim", false}
    },
    Player = {
        {"Speed Hack", false},
        {"Jump Power", false},
        {"No Clip", false},
        {"Fly", false},
        {"Infinite Jump", false}
    },
    World = {
        {"No Fog", false},
        {"Full Bright", false},
        {"Time Changer", false},
        {"Gravity", false},
        {"Destroy Map", false}
    },
    Teleport = {
        {"Teleport to Player", false},
        {"Save Location", false},
        {"Load Location", false},
        {"Teleport to Base", false},
        {"Auto Teleport", false}
    },
    Settings = {
        {"UI Theme", false},
        {"Keybinds", false},
        {"Configs", false},
        {"Notifications", false},
        {"Save Settings", false}
    }
}

-- GUI Drawing Objects
local DrawingObjects = {
    Window = {
        Background = nil,
        Header = nil,
        HeaderText = nil,
        MinimizeButton = nil,
        MinimizeButtonText = nil
    },
    LeftPanel = {
        Background = nil,
        MenuItems = {}
    },
    RightPanel = {
        Background = nil,
        ContentItems = {},
        SectionHeaders = {}
    },
    Minimized = {
        Circle = nil,
        Text = nil
    }
}

-- Color Scheme
local Colors = {
    Background = Color3.fromRGB(28, 28, 36),
    Header = Color3.fromRGB(45, 45, 55),
    Primary = Color3.fromRGB(0, 150, 255),
    PrimaryHover = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(60, 60, 75),
    SecondaryHover = Color3.fromRGB(70, 70, 85),
    Text = Color3.fromRGB(240, 240, 240),
    TextMuted = Color3.fromRGB(180, 180, 190),
    Accent = Color3.fromRGB(255, 65, 105)
}

-- Initialize GUI
function GUI.Init()
    -- Window Background (rounded corners using multiple squares)
    DrawingObjects.Window.Background = Drawing.new("Square")
    DrawingObjects.Window.Background.Size = Vector2.new(500, 400)
    DrawingObjects.Window.Background.Position = Vector2.new(700, 300)
    DrawingObjects.Window.Background.Color = Colors.Background
    DrawingObjects.Window.Background.Filled = true
    DrawingObjects.Window.Background.Transparency = 0.95
    DrawingObjects.Window.Background.Visible = true

    -- Header
    DrawingObjects.Window.Header = Drawing.new("Square")
    DrawingObjects.Window.Header.Size = Vector2.new(500, 40)
    DrawingObjects.Window.Header.Position = Vector2.new(700, 300)
    DrawingObjects.Window.Header.Color = Colors.Header
    DrawingObjects.Window.Header.Filled = true
    DrawingObjects.Window.Header.Transparency = 0.98
    DrawingObjects.Window.Header.Visible = true

    -- Header Text
    DrawingObjects.Window.HeaderText = Drawing.new("Text")
    DrawingObjects.Window.HeaderText.Text = "Arkan Scripts"
    DrawingObjects.Window.HeaderText.Size = 18
    DrawingObjects.Window.HeaderText.Color = Colors.Text
    DrawingObjects.Window.HeaderText.Outline = true
    DrawingObjects.Window.HeaderText.OutlineColor = Color3.new(0, 0, 0)
    DrawingObjects.Window.HeaderText.Font = Drawing.Fonts.UI
    DrawingObjects.Window.HeaderText.Position = Vector2.new(720, 308)
    DrawingObjects.Window.HeaderText.Visible = true

    -- Minimize Button
    DrawingObjects.Window.MinimizeButton = Drawing.new("Square")
    DrawingObjects.Window.MinimizeButton.Size = Vector2.new(20, 20)
    DrawingObjects.Window.MinimizeButton.Position = Vector2.new(1170, 305)
    DrawingObjects.Window.MinimizeButton.Color = Colors.Accent
    DrawingObjects.Window.MinimizeButton.Filled = true
    DrawingObjects.Window.MinimizeButton.Transparency = 0.9
    DrawingObjects.Window.MinimizeButton.Visible = true

    DrawingObjects.Window.MinimizeButtonText = Drawing.new("Text")
    DrawingObjects.Window.MinimizeButtonText.Text = "-"
    DrawingObjects.Window.MinimizeButtonText.Size = 16
    DrawingObjects.Window.MinimizeButtonText.Color = Colors.Text
    DrawingObjects.Window.MinimizeButtonText.Outline = true
    DrawingObjects.Window.MinimizeButtonText.OutlineColor = Color3.new(0, 0, 0)
    DrawingObjects.Window.MinimizeButtonText.Font = Drawing.Fonts.UI
    DrawingObjects.Window.MinimizeButtonText.Position = Vector2.new(1176, 306)
    DrawingObjects.Window.MinimizeButtonText.Visible = true

    -- Left Panel Background
    DrawingObjects.LeftPanel.Background = Drawing.new("Square")
    DrawingObjects.LeftPanel.Background.Size = Vector2.new(150, 360)
    DrawingObjects.LeftPanel.Background.Position = Vector2.new(700, 340)
    DrawingObjects.LeftPanel.Background.Color = Colors.Secondary
    DrawingObjects.LeftPanel.Background.Filled = true
    DrawingObjects.LeftPanel.Background.Transparency = 0.95
    DrawingObjects.LeftPanel.Background.Visible = true

    -- Right Panel Background
    DrawingObjects.RightPanel.Background = Drawing.new("Square")
    DrawingObjects.RightPanel.Background.Size = Vector2.new(350, 360)
    DrawingObjects.RightPanel.Background.Position = Vector2.new(850, 340)
    DrawingObjects.RightPanel.Background.Color = Colors.Background
    DrawingObjects.RightPanel.Background.Filled = true
    DrawingObjects.RightPanel.Background.Transparency = 0.95
    DrawingObjects.RightPanel.Background.Visible = true

    -- Create menu items
    GUI.CreateMenuItems()
    
    -- Create minimized version (hidden initially)
    GUI.CreateMinimizedVersion()
    
    -- Update content for initial selected menu
    GUI.UpdateContentPanel()
end

-- Create menu items in left panel
function GUI.CreateMenuItems()
    local menus = {"Combat", "Player", "World", "Teleport", "Settings"}
    
    for i, menuName in ipairs(menus) do
        local yPos = 350 + (i * 40)
        
        -- Menu item background
        local menuItem = Drawing.new("Square")
        menuItem.Size = Vector2.new(140, 35)
        menuItem.Position = Vector2.new(705, yPos)
        menuItem.Color = menuName == GUIState.SelectedMenu and Colors.Primary or Colors.Secondary
        menuItem.Filled = true
        menuItem.Transparency = 0.9
        menuItem.Visible = true
        
        -- Menu item text
        local menuText = Drawing.new("Text")
        menuText.Text = menuName
        menuText.Size = 16
        menuText.Color = Colors.Text
        menuText.Outline = true
        menuText.OutlineColor = Color3.new(0, 0, 0)
        menuText.Font = Drawing.Fonts.UI
        menuText.Position = Vector2.new(725, yPos + 10)
        menuText.Visible = true
        
        table.insert(DrawingObjects.LeftPanel.MenuItems, {
            Name = menuName,
            Background = menuItem,
            Text = menuText,
            Position = Vector2.new(705, yPos),
            Size = Vector2.new(140, 35)
        })
    end
end

-- Create minimized version
function GUI.CreateMinimizedVersion()
    DrawingObjects.Minimized.Circle = Drawing.new("Circle")
    DrawingObjects.Minimized.Circle.Radius = 25
    DrawingObjects.Minimized.Circle.Position = Vector2.new(700, 300)
    DrawingObjects.Minimized.Circle.Color = Colors.Primary
    DrawingObjects.Minimized.Circle.Filled = true
    DrawingObjects.Minimized.Circle.Transparency = 0.9
    DrawingObjects.Minimized.Circle.NumSides = 32
    DrawingObjects.Minimized.Circle.Visible = false
    
    DrawingObjects.Minimized.Text = Drawing.new("Text")
    DrawingObjects.Minimized.Text.Text = "A"
    DrawingObjects.Minimized.Text.Size = 16
    DrawingObjects.Minimized.Text.Color = Colors.Text
    DrawingObjects.Minimized.Text.Outline = true
    DrawingObjects.Minimized.Text.OutlineColor = Color3.new(0, 0, 0)
    DrawingObjects.Minimized.Text.Font = Drawing.Fonts.UI
    DrawingObjects.Minimized.Text.Position = Vector2.new(695, 292)
    DrawingObjects.Minimized.Text.Visible = false
end

-- Update content panel based on selected menu
function GUI.UpdateContentPanel()
    -- Clear previous content
    for _, item in ipairs(DrawingObjects.RightPanel.ContentItems) do
        item:Destroy()
    end
    for _, header in ipairs(DrawingObjects.RightPanel.SectionHeaders) do
        header:Destroy()
    end
    
    DrawingObjects.RightPanel.ContentItems = {}
    DrawingObjects.RightPanel.SectionHeaders = {}
    
    local menuItems = MenuData[GUIState.SelectedMenu]
    if not menuItems then return end
    
    -- Section header
    local sectionHeader = Drawing.new("Text")
    sectionHeader.Text = GUIState.SelectedMenu .. " Features"
    sectionHeader.Size = 18
    sectionHeader.Color = Colors.Text
    sectionHeader.Outline = true
    sectionHeader.OutlineColor = Color3.new(0, 0, 0)
    sectionHeader.Font = Drawing.Fonts.UI
    sectionHeader.Position = Vector2.new(870, 355)
    sectionHeader.Visible = true
    
    table.insert(DrawingObjects.RightPanel.SectionHeaders, sectionHeader)
    
    -- Create feature items
    for i, featureData in ipairs(menuItems) do
        local featureName, featureState = featureData[1], featureData[2]
        local yPos = 390 + (i * 45)
        
        -- Feature background
        local featureBg = Drawing.new("Square")
        featureBg.Size = Vector2.new(320, 40)
        featureBg.Position = Vector2.new(860, yPos)
        featureBg.Color = featureState and Colors.Primary or Colors.Secondary
        featureBg.Filled = true
        featureBg.Transparency = 0.9
        featureBg.Visible = true
        
        -- Feature text
        local featureText = Drawing.new("Text")
        featureText.Text = featureName
        featureText.Size = 15
        featureText.Color = Colors.Text
        featureText.Outline = true
        featureText.OutlineColor = Color3.new(0, 0, 0)
        featureText.Font = Drawing.Fonts.UI
        featureText.Position = Vector2.new(880, yPos + 12)
        featureText.Visible = true
        
        -- Status indicator
        local statusIndicator = Drawing.new("Circle")
        statusIndicator.Radius = 6
        statusIndicator.Position = Vector2.new(1150, yPos + 20)
        statusIndicator.Color = featureState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        statusIndicator.Filled = true
        statusIndicator.Transparency = 0.9
        statusIndicator.NumSides = 16
        statusIndicator.Visible = true
        
        table.insert(DrawingObjects.RightPanel.ContentItems, {
            Name = featureName,
            Background = featureBg,
            Text = featureText,
            Status = statusIndicator,
            Position = Vector2.new(860, yPos),
            Size = Vector2.new(320, 40),
            State = featureState
        })
    end
end

-- Toggle minimize state
function GUI.ToggleMinimize()
    GUIState.Minimized = not GUIState.Minimized
    
    -- Toggle visibility of main window elements
    local visible = not GUIState.Minimized
    DrawingObjects.Window.Background.Visible = visible
    DrawingObjects.Window.Header.Visible = visible
    DrawingObjects.Window.HeaderText.Visible = visible
    DrawingObjects.Window.MinimizeButton.Visible = visible
    DrawingObjects.Window.MinimizeButtonText.Visible = visible
    DrawingObjects.LeftPanel.Background.Visible = visible
    DrawingObjects.RightPanel.Background.Visible = visible
    
    -- Toggle menu items
    for _, item in ipairs(DrawingObjects.LeftPanel.MenuItems) do
        item.Background.Visible = visible
        item.Text.Visible = visible
    end
    
    -- Toggle content items
    for _, item in ipairs(DrawingObjects.RightPanel.ContentItems) do
        item.Background.Visible = visible
        item.Text.Visible = visible
        if item.Status then
            item.Status.Visible = visible
        end
    end
    
    -- Toggle section headers
    for _, header in ipairs(DrawingObjects.RightPanel.SectionHeaders) do
        header.Visible = visible
    end
    
    -- Toggle minimized version
    DrawingObjects.Minimized.Circle.Visible = GUIState.Minimized
    DrawingObjects.Minimized.Text.Visible = GUIState.Minimized
end

-- Improved click detection with tolerance
function GUI.IsPointInBounds(point, boundsPos, boundsSize, tolerance)
    tolerance = tolerance or 5
    return point.X >= boundsPos.X - tolerance and 
           point.X <= boundsPos.X + boundsSize.X + tolerance and
           point.Y >= boundsPos.Y - tolerance and 
           point.Y <= boundsPos.Y + boundsSize.Y + tolerance
end

-- Handle mouse input
function GUI.HandleInput()
    local currentTime = tick()
    
    -- Check for minimize button click
    if GUI.IsPointInBounds(
        Vector2.new(mouse.X, mouse.Y), 
        DrawingObjects.Window.MinimizeButton.Position, 
        DrawingObjects.Window.MinimizeButton.Size
    ) and mouse.Released then
        GUI.ToggleMinimize()
        mouse.Released = false
        return
    end
    
    -- Handle dragging when minimized
    if GUIState.Minimized then
        if GUI.IsPointInBounds(
            Vector2.new(mouse.X, mouse.Y),
            Vector2.new(
                DrawingObjects.Minimized.Circle.Position.X - DrawingObjects.Minimized.Circle.Radius,
                DrawingObjects.Minimized.Circle.Position.Y - DrawingObjects.Minimized.Circle.Radius
            ),
            Vector2.new(
                DrawingObjects.Minimized.Circle.Radius * 2,
                DrawingObjects.Minimized.Circle.Radius * 2
            )
        ) then
            if mouse.Pressed and not GUIState.Dragging then
                GUIState.Dragging = true
                GUIState.DragOffset = Vector2.new(
                    mouse.X - DrawingObjects.Minimized.Circle.Position.X,
                    mouse.Y - DrawingObjects.Minimized.Circle.Position.Y
                )
            elseif mouse.Released then
                -- Click to restore when minimized
                if currentTime - GUIState.LastClickTime < 0.3 then -- Double click detection
                    GUI.ToggleMinimize()
                end
                GUIState.LastClickTime = currentTime
                GUIState.Dragging = false
            end
        end
        
        if GUIState.Dragging and mouse.Pressed then
            DrawingObjects.Minimized.Circle.Position = Vector2.new(
                mouse.X - GUIState.DragOffset.X,
                mouse.Y - GUIState.DragOffset.Y
            )
            DrawingObjects.Minimized.Text.Position = Vector2.new(
                mouse.X - GUIState.DragOffset.X - 5,
                mouse.Y - GUIState.DragOffset.Y - 8
            )
        end
        
        return
    end
    
    -- Handle window dragging
    if GUI.IsPointInBounds(
        Vector2.new(mouse.X, mouse.Y),
        DrawingObjects.Window.Header.Position,
        DrawingObjects.Window.Header.Size
    ) and not GUI.IsPointInBounds(
        Vector2.new(mouse.X, mouse.Y),
        DrawingObjects.Window.MinimizeButton.Position,
        DrawingObjects.Window.MinimizeButton.Size
    ) then
        if mouse.Pressed and not GUIState.Dragging then
            GUIState.Dragging = true
            GUIState.DragOffset = Vector2.new(
                mouse.X - DrawingObjects.Window.Background.Position.X,
                mouse.Y - DrawingObjects.Window.Background.Position.Y
            )
        end
    end
    
    if GUIState.Dragging then
        if mouse.Pressed then
            local newPos = Vector2.new(
                mouse.X - GUIState.DragOffset.X,
                mouse.Y - GUIState.DragOffset.Y
            )
            
            -- Update all positions
            local offset = newPos - DrawingObjects.Window.Background.Position
            
            DrawingObjects.Window.Background.Position = newPos
            DrawingObjects.Window.Header.Position = newPos
            DrawingObjects.Window.HeaderText.Position = DrawingObjects.Window.HeaderText.Position + offset
            DrawingObjects.Window.MinimizeButton.Position = Vector2.new(
                newPos.X + 470,
                newPos.Y + 5
            )
            DrawingObjects.Window.MinimizeButtonText.Position = Vector2.new(
                newPos.X + 476,
                newPos.Y + 6
            )
            DrawingObjects.LeftPanel.Background.Position = Vector2.new(newPos.X, newPos.Y + 40)
            DrawingObjects.RightPanel.Background.Position = Vector2.new(newPos.X + 150, newPos.Y + 40)
            
            -- Update menu items
            for _, item in ipairs(DrawingObjects.LeftPanel.MenuItems) do
                item.Background.Position = item.Background.Position + offset
                item.Text.Position = item.Text.Position + offset
                item.Position = item.Position + offset
            end
            
            -- Update content items
            for _, item in ipairs(DrawingObjects.RightPanel.ContentItems) do
                item.Background.Position = item.Background.Position + offset
                item.Text.Position = item.Text.Position + offset
                if item.Status then
                    item.Status.Position = item.Status.Position + offset
                end
                item.Position = item.Position + offset
            end
            
            -- Update section headers
            for _, header in ipairs(DrawingObjects.RightPanel.SectionHeaders) do
                header.Position = header.Position + offset
            end
        else
            GUIState.Dragging = false
        end
    end
    
    -- Handle menu item clicks
    if mouse.Released and not GUIState.Dragging then
        for _, menuItem in ipairs(DrawingObjects.LeftPanel.MenuItems) do
            if GUI.IsPointInBounds(
                Vector2.new(mouse.X, mouse.Y),
                menuItem.Position,
                menuItem.Size
            ) then
                GUIState.SelectedMenu = menuItem.Name
                
                -- Update menu item colors
                for _, item in ipairs(DrawingObjects.LeftPanel.MenuItems) do
                    item.Background.Color = item.Name == GUIState.SelectedMenu and Colors.Primary or Colors.Secondary
                end
                
                GUI.UpdateContentPanel()
                break
            end
        end
        
        -- Handle feature toggles
        for _, feature in ipairs(DrawingObjects.RightPanel.ContentItems) do
            if GUI.IsPointInBounds(
                Vector2.new(mouse.X, mouse.Y),
                feature.Position,
                feature.Size
            ) then
                feature.State = not feature.State
                feature.Background.Color = feature.State and Colors.Primary or Colors.Secondary
                feature.Status.Color = feature.State and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
                
                -- Update the data
                for _, featureData in ipairs(MenuData[GUIState.SelectedMenu]) do
                    if featureData[1] == feature.Name then
                        featureData[2] = feature.State
                        break
                    end
                end
                break
            end
        end
        
        mouse.Released = false
    end
end

-- Update mouse state (this should be called from your mouse input handlers)
function GUI.UpdateMouse(x, y, pressed, released)
    mouse.X = x
    mouse.Y = y
    mouse.Pressed = pressed
    mouse.Released = released
end

-- Cleanup function
function GUI.Destroy()
    for _, obj in pairs(DrawingObjects.Window) do
        if obj and type(obj.Destroy) == "function" then
            obj:Destroy()
        end
    end
    
    for _, item in ipairs(DrawingObjects.LeftPanel.MenuItems) do
        if item.Background then item.Background:Destroy() end
        if item.Text then item.Text:Destroy() end
    end
    
    for _, item in ipairs(DrawingObjects.RightPanel.ContentItems) do
        if item.Background then item.Background:Destroy() end
        if item.Text then item.Text:Destroy() end
        if item.Status then item.Status:Destroy() end
    end
    
    for _, header in ipairs(DrawingObjects.RightPanel.SectionHeaders) do
        if header then header:Destroy() end
    end
    
    if DrawingObjects.LeftPanel.Background then DrawingObjects.LeftPanel.Background:Destroy() end
    if DrawingObjects.RightPanel.Background then DrawingObjects.RightPanel.Background:Destroy() end
    if DrawingObjects.Minimized.Circle then DrawingObjects.Minimized.Circle:Destroy() end
    if DrawingObjects.Minimized.Text then DrawingObjects.Minimized.Text:Destroy() end
end

-- Initialize the GUI
GUI.Init()

-- Return the GUI module
return {
    GUI = GUI,
    UpdateMouse = GUI.UpdateMouse,
    HandleInput = GUI.HandleInput,
    Destroy = GUI.Destroy
}
