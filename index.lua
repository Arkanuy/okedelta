-- Modern Drawing GUI for DeltaExploit (Roblox Drawing API)
-- Features:
--  - Centered rounded window, header "Arkan Scripts"
--  - Left vertical menu (Combat, Player, World, Teleport, Settings)
--  - Right panel showing options for selected menu
--  - Clickable menu items, hover & active states
--  - Minimize -> circular draggable button with "A"
--  - Window drag, click-tolerance to reduce misclicks
--  - Clean API: DestroyUI() to cleanup

-- CONFIG
local UI = {}
UI.Window = {
    Width = 760,
    Height = 440,
    CornerRadius = 16,
    X = (workspace and workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize and (workspace.CurrentCamera.ViewportSize.X/2)) or 960,
    Y = (workspace and workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize and (workspace.CurrentCamera.ViewportSize.Y/2)) or 540
}
UI.Colors = {
    Background = Color3.fromRGB(24, 26, 31),
    Panel = Color3.fromRGB(28, 31, 38),
    Accent = Color3.fromRGB(86, 120, 255),
    TextPrimary = Color3.fromRGB(230, 230, 235),
    TextSecondary = Color3.fromRGB(160, 165, 180),
    Hover = Color3.fromRGB(60, 65, 78),
    Minimize = Color3.fromRGB(40, 44, 52),
    Shadow = Color3.fromRGB(0,0,0)
}
UI.Transparency = 0.9
UI.MenuList = {"Combat", "Player", "World", "Teleport", "Settings"}
UI.DefaultMenu = 1

-- INTERNALS
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MouseFallback = (LocalPlayer and LocalPlayer:GetMouse())

local drawingCache = {}  -- all drawing objects for cleanup
local interactables = {} -- hitboxes for input handling
local state = {
    centerX = UI.Window.X,
    centerY = UI.Window.Y,
    width = UI.Window.Width,
    height = UI.Window.Height,
    radius = UI.Window.CornerRadius,
    minimized = false,
    minimizedPos = Vector2.new(100,100),
    dragging = false,
    dragOffset = Vector2.new(0,0),
    minimizedDragging = false,
    minDragOffset = Vector2.new(0,0),
    selectedMenu = UI.DefaultMenu,
    hovering = nil,
    renderConn = nil
}

-- UTILS
local function makeDrawing(typeName)
    local d = Drawing.new(typeName)
    drawingCache[#drawingCache+1] = d
    return d
end

local function v2(x,y) return Vector2.new(x,y) end

-- read mouse location robustly (returns Vector2)
local function getMousePos()
    -- Prefer UserInputService:GetMouseLocation()
    local ok, pos = pcall(function() return UserInputService:GetMouseLocation() end)
    if ok and pos then
        -- In some contexts Y includes top bar offset; to be safe, use pos directly
        return v2(pos.X, pos.Y)
    end
    if MouseFallback then
        return v2(MouseFallback.X, MouseFallback.Y)
    end
    return v2(0,0)
end

-- simple point-in-rect with tolerance
local function pointInRect(px, py, x, y, w, h, tol)
    tol = tol or 0
    return px >= x - tol and py >= y - tol and px <= x + w + tol and py <= y + h + tol
end

-- distance
local function dist(a,b) return (a-b).Magnitude end

-- create rounded rectangle by composing 3 squares + 4 circles
local function createRoundedRect(x,y,w,h,r,color,transparency,zindex)
    -- center rectangle (middle)
    local mainW = w - 2*r
    if mainW < 0 then mainW = w end
    local rectCenter = makeDrawing("Square")
    rectCenter.Position = v2(x + r, y)
    rectCenter.Size = v2(mainW, h)
    rectCenter.Filled = true
    rectCenter.Color = color
    rectCenter.Transparency = transparency or 1
    rectCenter.ZIndex = zindex or 1
    rectCenter.Visible = true

    -- left rect
    local leftRect = makeDrawing("Square")
    leftRect.Position = v2(x, y + r)
    leftRect.Size = v2(r, h - 2*r)
    leftRect.Filled = true
    leftRect.Color = color
    leftRect.Transparency = transparency or 1
    leftRect.ZIndex = zindex or 1
    leftRect.Visible = true

    -- right rect
    local rightRect = makeDrawing("Square")
    rightRect.Position = v2(x+w-r, y + r)
    rightRect.Size = v2(r, h - 2*r)
    rightRect.Filled = true
    rightRect.Color = color
    rightRect.Transparency = transparency or 1
    rightRect.ZIndex = zindex or 1
    rightRect.Visible = true

    -- four corner circles
    local corners = {}
    local coords = {
        {x + r, y + r},
        {x + w - r, y + r},
        {x + r, y + h - r},
        {x + w - r, y + h - r},
    }
    for i=1,4 do
        local c = makeDrawing("Circle")
        c.Position = v2(coords[i][1], coords[i][2])
        c.Radius = r
        c.Filled = true
        c.Color = color
        c.Transparency = transparency or 1
        c.ZIndex = (zindex or 1)
        c.Visible = true
        corners[#corners+1] = c
    end

    return {
        center = rectCenter,
        left = leftRect,
        right = rightRect,
        corners = corners
    }
end

-- TEXT helper
local function createText(txt, pos, size, font, center, color, outline, zindex)
    local t = makeDrawing("Text")
    t.Text = txt
    t.Position = pos
    t.Size = size or 18
    t.Font = font or Drawing.Fonts.Plex
    t.Center = center or false
    t.Color = color or UI.Colors.TextPrimary
    t.Outline = outline or false
    t.Visible = true
    t.ZIndex = zindex or 5
    return t
end

-- Add interactive hitbox
-- item: {x,y,w,h, onClick(function), onHover(function), id}
local function addHitbox(item)
    item.tolerance = item.tolerance or 6 -- click tolerance to reduce misclicks
    interactables[#interactables+1] = item
    return item
end

-- Clear interactables
local function clearHitboxes()
    interactables = {}
end

-- UI BUILD
local comps = {} -- store references to created UI elements for toggling visibility

local function buildWindow()
    local w = state.width
    local h = state.height
    local r = state.radius
    local cx = state.centerX - w/2
    local cy = state.centerY - h/2

    -- shadow (big semi-transparent rounded rect behind)
    local shadow = createRoundedRect(cx+8, cy+8, w, h, r+4, UI.Colors.Shadow, 0.85, 1)
    -- change shadow parts to use slightly transparent black
    for _,c in pairs(shadow.corners) do c.Transparency = 0.85 end
    shadow.center.Transparency = 0.85
    shadow.left.Transparency = 0.85
    shadow.right.Transparency = 0.85
    comps.shadow = shadow

    -- main background
    local bg = createRoundedRect(cx, cy, w, h, r, UI.Colors.Background, 1 - (1 - UI.Transparency), 2)
    comps.bg = bg

    -- header bar (slightly darker strip on top)
    local headerH = 56
    local header = createRoundedRect(cx, cy, w, headerH, r, UI.Colors.Panel, 1 - (1 - UI.Transparency), 3)
    -- we need to cut bottom corners for header: draw a rectangle that covers header width minus corner overlap
    -- We'll overlay a center rectangle to ensure top bar has straight bottom edge
    local headerStrip = makeDrawing("Square")
    headerStrip.Position = v2(cx + r, cy)
    headerStrip.Size = v2(w - 2*r, headerH)
    headerStrip.Filled = true
    headerStrip.Color = UI.Colors.Panel
    headerStrip.Transparency = 1 - (1 - UI.Transparency)
    headerStrip.ZIndex = 4
    comps.header = {wrap = header, strip = headerStrip}

    -- Title text "Arkan Scripts"
    local title = createText("Arkan Scripts", v2((state.centerX - w/2) + 24, cy + 14), 20, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 6)
    comps.title = title

    -- minimize button (top-right small circle)
    local minRadius = 14
    local minX = cx + w - 20 - minRadius
    local minY = cy + 20
    local minCircle = makeDrawing("Circle")
    minCircle.Position = v2(minX + minRadius, minY + minRadius)
    minCircle.Radius = minRadius
    minCircle.Filled = true
    minCircle.Color = UI.Colors.Minimize
    minCircle.Transparency = 1 - (1 - UI.Transparency)
    minCircle.ZIndex = 8
    minCircle.Visible = true

    local minText = createText("—", v2(minX + minRadius - 6, minY + minRadius - 8), 20, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 9)
    comps.minBtn = {circle = minCircle, text = minText, center = v2(minX + minRadius, minY + minRadius), radius = minRadius}

    -- Left panel
    local leftW = 200
    local leftX = cx + 12
    local leftY = cy + headerH + 12
    local leftH = h - headerH - 24
    local leftPanelBg = createRoundedRect(leftX, leftY, leftW, leftH, 12, UI.Colors.Panel, 1 - (1 - UI.Transparency), 3)
    comps.leftPanel = leftPanelBg

    -- Right panel area coords
    local rightX = cx + leftW + 24
    local rightY = leftY
    local rightW = w - leftW - 36
    local rightH = leftH
    local rightPanelBg = createRoundedRect(rightX, rightY, rightW, rightH, 12, UI.Colors.Panel, 1 - (1 - UI.Transparency), 3)
    comps.rightPanel = rightPanelBg

    -- Build menu items vertically
    local menuStartY = leftY + 12
    local itemH = 38
    local itemPad = 8

    clearHitboxes()
    -- window drag hitbox (header area)
    addHitbox{
        id = "windowDrag",
        x = cx,
        y = cy,
        w = w,
        h = headerH,
        onInputBegan = function(pos) -- start drag
            state.dragging = true
            local center = v2(state.centerX, state.centerY)
            state.dragOffset = center - pos
        end,
        onInputEnded = function()
            state.dragging = false
        end
    }

    -- minimize button hitbox
    addHitbox{
        id = "minBtn",
        x = comps.minBtn.center.X - comps.minBtn.radius,
        y = comps.minBtn.center.Y - comps.minBtn.radius,
        w = comps.minBtn.radius*2,
        h = comps.minBtn.radius*2,
        onClick = function()
            -- toggle minimize
            state.minimized = not state.minimized
        end,
        isCircle = true,
        center = comps.minBtn.center,
        radius = comps.minBtn.radius,
    }

    -- menu items
    comps.menuItems = {}
    for i, name in ipairs(UI.MenuList) do
        local y = menuStartY + (i-1)*(itemH + itemPad)
        -- background rect for hover/active
        local bgRect = makeDrawing("Square")
        bgRect.Position = v2(leftX + 8, y)
        bgRect.Size = v2(leftW - 16, itemH)
        bgRect.Filled = true
        bgRect.Color = UI.Colors.Panel
        bgRect.Transparency = 1.0
        bgRect.ZIndex = 6
        bgRect.Visible = true

        local txt = createText(name, v2(leftX + 22, y + 8), 18, Drawing.Fonts.Plex, false, UI.Colors.TextSecondary, false, 7)

        comps.menuItems[i] = {bg = bgRect, text = txt, x = leftX + 8, y = y, w = leftW - 16, h = itemH}

        -- hitbox for menu item
        addHitbox{
            id = "menu_"..i,
            x = leftX + 8,
            y = y,
            w = leftW - 16,
            h = itemH,
            onClick = (function(idx) return function() state.selectedMenu = idx end end)(i),
            onHover = function(isHover)
                -- visual feedback handled in render loop
            end
        }
    end

    -- Build right panel content placeholder (populate by updateContent)
    comps.rightContent = {} -- will be updated by updateContent()

    -- Minimize draggable circle (hidden while not minimized)
    local miniCirc = makeDrawing("Circle")
    miniCirc.Position = state.minimizedPos
    miniCirc.Radius = 26
    miniCirc.Filled = true
    miniCirc.Color = UI.Colors.Minimize
    miniCirc.Transparency = 1
    miniCirc.ZIndex = 12
    miniCirc.Visible = false
    local miniText = createText("A", state.minimizedPos - v2(7, 10), 20, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 13)
    miniText.Visible = false
    comps.minimized = {circle = miniCirc, text = miniText, radius = 26}

    -- Toggle full UI visibility based on state.minimized handled in render

    -- initial content build
    return comps
end

local function clearRightContent()
    for _,c in ipairs(comps.rightContent) do
        -- destroy drawing objects individually
        if c and c.Destroy then
            pcall(function() c:Destroy() end)
        end
    end
    comps.rightContent = {}
end

-- Create some UI controls (toggle, slider) drawing-only simulation:
local function makeToggle(x,y,label,initial)
    local box = makeDrawing("Square")
    box.Position = v2(x, y)
    box.Size = v2(14, 14)
    box.Filled = true
    box.Color = UI.Colors.Minimize
    box.Transparency = 1
    box.ZIndex = 8
    box.Visible = true

    local outline = makeDrawing("Square")
    outline.Position = v2(x-2,y-2)
    outline.Size = v2(18, 18)
    outline.Filled = false
    outline.Color = UI.Colors.TextSecondary
    outline.Transparency = 1
    outline.Thickness = 1
    outline.ZIndex = 7
    outline.Visible = true

    local txt = createText(label, v2(x + 24, y - 2), 17, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 8)

    local checked = initial or false
    local checkMark = createText(checked and "✓" or "", v2(x + 2, y - 12), 20, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 9)

    local hit = addHitbox{
        x = x-4,
        y = y-4,
        w = 28,
        h = 20,
        onClick = function()
            checked = not checked
            checkMark.Text = checked and "✓" or ""
        end
    }

    -- return references so caller can manage
    local refs = {box=box, outline=outline, txt=txt, checkMark=checkMark, hit=hit, getState=function() return checked end}
    comps.rightContent[#comps.rightContent+1] = box
    comps.rightContent[#comps.rightContent+1] = outline
    comps.rightContent[#comps.rightContent+1] = txt
    comps.rightContent[#comps.rightContent+1] = checkMark
    return refs
end

local function makeSlider(x,y,label,minVal,maxVal,initial)
    local w = 260
    local h = 12
    local barBg = makeDrawing("Square")
    barBg.Position = v2(x, y)
    barBg.Size = v2(w, h)
    barBg.Filled = true
    barBg.Color = UI.Colors.Hover
    barBg.Transparency = 1
    barBg.ZIndex = 8
    barBg.Visible = true

    local filled = makeDrawing("Square")
    filled.Position = v2(x, y)
    filled.Size = v2((initial - minVal)/(maxVal - minVal) * w, h)
    filled.Filled = true
    filled.Color = UI.Colors.Accent
    filled.Transparency = 1
    filled.ZIndex = 9
    filled.Visible = true

    local knob = makeDrawing("Circle")
    knob.Position = v2(x + filled.Size.X, y + h/2)
    knob.Radius = 8
    knob.Filled = true
    knob.Color = UI.Colors.Minimize
    knob.Transparency = 1
    knob.ZIndex = 10
    knob.Visible = true

    local txt = createText(label .. ": " .. tostring(initial), v2(x, y - 18), 16, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 11)

    local dragging = false
    local value = initial

    local hit = addHitbox{
        x = x - 8,
        y = y - 8,
        w = w + 16,
        h = h + 16,
        onInputBegan = function(pos)
            dragging = true
        end,
        onInputChanged = function(pos)
            if dragging then
                local nx = math.clamp(pos.X - x, 0, w)
                filled.Size = v2(nx, h)
                knob.Position = v2(x + nx, y + h/2)
                value = minVal + (nx/w)*(maxVal - minVal)
                txt.Text = label .. ": " .. math.floor(value)
            end
        end,
        onInputEnded = function()
            dragging = false
        end
    }

    comps.rightContent[#comps.rightContent+1] = barBg
    comps.rightContent[#comps.rightContent+1] = filled
    comps.rightContent[#comps.rightContent+1] = knob
    comps.rightContent[#comps.rightContent+1] = txt

    return {getValue = function() return value end, setValue = function(v)
        value = math.clamp(v, minVal, maxVal)
        local nx = (value - minVal)/(maxVal - minVal)*w
        filled.Size = v2(nx,h)
        knob.Position = v2(x + nx, y + h/2)
        txt.Text = label .. ": " .. math.floor(value)
    end}
end

-- populate right panel based on selected menu
local function updateRightPanel()
    clearRightContent()
    -- find right panel coords
    local w = state.width
    local h = state.height
    local cx = state.centerX - w/2
    local cy = state.centerY - h/2
    local leftW = 200
    local rightX = cx + leftW + 24
    local rightY = cy + 56 + 12
    local rightW = w - leftW - 36

    local menu = UI.MenuList[state.selectedMenu]
    local headerTxt = createText(menu, v2(rightX + 18, rightY + 6), 20, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 10)
    comps.rightContent[#comps.rightContent+1] = headerTxt

    if menu == "Combat" then
        makeToggle(rightX + 20, rightY + 36, "Auto Farm", false)
        makeToggle(rightX + 20, rightY + 76, "Kill Aura", true)
        local s = makeSlider(rightX + 20, rightY + 116, "Attack Range", 10, 200, 80)
    elseif menu == "Player" then
        makeToggle(rightX + 20, rightY + 36, "God Mode", false)
        local s = makeSlider(rightX + 20, rightY + 76, "Speed", 16, 200, 40)
        local s2 = makeSlider(rightX + 20, rightY + 116, "Jump Power", 20, 300, 50)
    elseif menu == "World" then
        makeToggle(rightX + 20, rightY + 36, "Day Cycle", true)
        makeToggle(rightX + 20, rightY + 76, "Weather Control", false)
    elseif menu == "Teleport" then
        createText("Pick a location:", v2(rightX + 20, rightY + 36), 17, Drawing.Fonts.Plex, false, UI.Colors.TextSecondary, false, 10)
        -- Example teleport items as clickable boxes
        for i,name in ipairs({"Spawn","City","Arena","Hidden Base"}) do
            local by = rightY + 36 + 28 + (i-1)*38
            local b = makeDrawing("Square")
            b.Position = v2(rightX + 20, by)
            b.Size = v2(200, 30)
            b.Filled = true
            b.Color = UI.Colors.Hover
            b.Transparency = 1
            b.ZIndex = 9
            b.Visible = true
            comps.rightContent[#comps.rightContent+1] = b
            local txt = createText(name, v2(rightX + 28, by + 6), 17, Drawing.Fonts.Plex, false, UI.Colors.TextPrimary, false, 10)
            comps.rightContent[#comps.rightContent+1] = txt

            addHitbox{
                id = "teleport_"..i,
                x = rightX + 20,
                y = by,
                w = 200,
                h = 30,
                onClick = function()
                    -- dummy feedback: flash color then revert
                    b.Color = UI.Colors.Accent
                    delay(0.18, function() b.Color = UI.Colors.Hover end)
                end
            }
        end
    elseif menu == "Settings" then
        makeToggle(rightX + 20, rightY + 36, "Enable Notifications", true)
        makeToggle(rightX + 20, rightY + 76, "Auto Update UI", true)
        createText("Theme", v2(rightX + 20, rightY + 120), 16, Drawing.Fonts.Plex, false, UI.Colors.TextSecondary, false, 11)
    end
end

-- Render loop updates visuals, hover states, minimize toggles
local function renderStep()
    -- update positions based on state
    local w = state.width
    local h = state.height
    local r = state.radius
    local cx = state.centerX - w/2
    local cy = state.centerY - h/2

    -- Shadow
    do
        local sh = comps.shadow
        if sh then
            sh.center.Position = v2(cx + 8 + r, cy + 8)
            sh.center.Size = v2(w - 2*r, h)
            sh.left.Position = v2(cx + 8, cy + 8 + r)
            sh.left.Size = v2(r, h - 2*r)
            sh.right.Position = v2(cx + 8 + w - r, cy + 8 + r)
            sh.right.Size = v2(r, h - 2*r)
            for i,c in ipairs(sh.corners) do
                local coords = {
                    v2(cx + 8 + r, cy + 8 + r),
                    v2(cx + 8 + w - r, cy + 8 + r),
                    v2(cx + 8 + r, cy + 8 + h - r),
                    v2(cx + 8 + w - r, cy + 8 + h - r)
                }
                c.Position = coords[i]
                c.Radius = r + 4
            end
        end
    end

    -- BG
    do
        local bg = comps.bg
        if bg then
            bg.center.Position = v2(cx + r, cy)
            bg.center.Size = v2(w - 2*r, h)
            bg.left.Position = v2(cx, cy + r)
            bg.left.Size = v2(r, h - 2*r)
            bg.right.Position = v2(cx + w - r, cy + r)
            bg.right.Size = v2(r, h - 2*r)
            for i,c in ipairs(bg.corners) do
                local coords = {
                    v2(cx + r, cy + r),
                    v2(cx + w - r, cy + r),
                    v2(cx + r, cy + h - r),
                    v2(cx + w - r, cy + h - r)
                }
                c.Position = coords[i]
                c.Radius = r
            end
        end
    end

    -- header
    do
        local he = comps.header
        if he then
            he.wrap.center.Position = v2(cx, cy)
            he.wrap.center.Size = v2(w, 56)
            he.wrap.left.Position = v2(cx, cy + r)
            he.wrap.left.Size = v2(r, 56 - 2*r)
            he.wrap.right.Position = v2(cx + w - r, cy + r)
            he.wrap.right.Size = v2(r, 56 - 2*r)
            for i,c in ipairs(he.wrap.corners) do
                local coords = {
                    v2(cx + r, cy + r),
                    v2(cx + w - r, cy + r),
                    v2(cx + r, cy + 56 - r),
                    v2(cx + w - r, cy + 56 - r)
                }
                c.Position = coords[i]
                c.Radius = r
            end
            he.strip.Position = v2(cx + r, cy)
            he.strip.Size = v2(w - 2*r, 56)
        end
    end

    -- title
    comps.title.Position = v2(cx + 24, cy + 14)

    -- minimize button
    do
        local min = comps.minBtn
        local minX = cx + w - 20 - min.radius
        local minY = cy + 20
        min.circle.Position = v2(minX + min.radius, minY + min.radius)
        min.text.Position = v2(minX + min.radius - 6, minY + min.radius - 8)
        min.center = v2(minX + min.radius, minY + min.radius)
    end

    -- left & right panels
    local leftW = 200
    local leftX = cx + 12
    local leftY = cy + 56 + 12
    local leftH = h - 56 - 24
    do
        local lp = comps.leftPanel
        if lp then
            lp.center.Position = v2(leftX + 12, leftY)
            lp.center.Size = v2(leftW - 24, leftH)
            lp.left.Position = v2(leftX, leftY + r)
            lp.left.Size = v2(12, leftH - 2*r)
            lp.right.Position = v2(leftX + leftW - 12, leftY + r)
            lp.right.Size = v2(12, leftH - 2*r)
            for i,c in ipairs(lp.corners) do
                local coords = {
                    v2(leftX + 12, leftY + r),
                    v2(leftX + leftW - 12, leftY + r),
                    v2(leftX + 12, leftY + leftH - r),
                    v2(leftX + leftW - 12, leftY + leftH - r)
                }
                c.Position = coords[i]
                c.Radius = 12
            end
        end
    end
    do
        local rightX = cx + leftW + 24
        local rightY = leftY
        local rightW = w - leftW - 36
        local rp = comps.rightPanel
        if rp then
            rp.center.Position = v2(rightX + 12, rightY)
            rp.center.Size = v2(rightW - 24, leftH)
            rp.left.Position = v2(rightX, rightY + r)
            rp.left.Size = v2(12, leftH - 2*r)
            rp.right.Position = v2(rightX + rightW - 12, rightY + r)
            rp.right.Size = v2(12, leftH - 2*r)
            for i,c in ipairs(rp.corners) do
                local coords = {
                    v2(rightX + 12, rightY + r),
                    v2(rightX + rightW - 12, rightY + r),
                    v2(rightX + 12, rightY + leftH - r),
                    v2(rightX + rightW - 12, rightY + leftH - r)
                }
                c.Position = coords[i]
                c.Radius = 12
            end
        end
    end

    -- menu items visuals & hover/active
    for i,item in ipairs(comps.menuItems) do
        local m = item
        local isSelected = (i == state.selectedMenu)
        m.bg.Color = isSelected and UI.Colors.Accent or UI.Colors.Panel
        m.text.Color = isSelected and Color3.new(1,1,1) or UI.Colors.TextSecondary
        -- hover handled by interactable detection (below)
    end

    -- update minimized state visuals
    if state.minimized then
        -- hide window components
        for k,v in pairs(comps) do
            if k ~= "minimized" and k ~= "minBtn" and k ~= "title" and k ~= "shadow" then
                -- hide many, but keep minimized circle visible
                if type(v) == "table" then
                    -- composite
                    for _,sub in pairs(v) do
                        if type(sub) == "table" then
                            -- ignore inner composites
                        else
                            if sub and sub.Visible ~= nil then sub.Visible = false end
                        end
                    end
                else
                    if v and v.Visible ~= nil then
                        v.Visible = false
                    end
                end
            end
        end
        -- show minimized circle
        comps.minimized.circle.Visible = true
        comps.minimized.text.Visible = true
        comps.minimized.circle.Position = state.minimizedPos
        comps.minimized.text.Position = state.minimizedPos - v2(7, 10)
        -- ensure minBtn hidden
        comps.minBtn.circle.Visible = false
        comps.minBtn.text.Visible = false
    else
        -- show main window components
        for _,obj in pairs(drawingCache) do
            if obj and obj.Visible ~= nil then
                obj.Visible = true
            end
        end
        comps.minimized.circle.Visible = false
        comps.minimized.text.Visible = false
    end
end

-- Input handling
local inputState = {
    mouseDown = false,
    mouseStartPos = nil,
    activeHit = nil,
    lastInputPos = nil
}

local function findHitboxAt(pos)
    for i,item in ipairs(interactables) do
        if item.isCircle and item.center and item.radius then
            if dist(pos, item.center) <= (item.radius + (item.tolerance or 6)) then
                return item
            end
        else
            if pointInRect(pos.X, pos.Y, item.x, item.y, item.w, item.h, item.tolerance or 6) then
                return item
            end
        end
    end
    return nil
end

-- handle InputBegan
local function onInputBegan(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        inputState.mouseDown = true
        local pos = getMousePos()
        inputState.mouseStartPos = pos
        inputState.lastInputPos = pos
        local hit = findHitboxAt(pos)
        inputState.activeHit = hit
        -- call onInputBegan if present
        if hit and hit.onInputBegan then
            pcall(function() hit.onInputBegan(pos) end)
        end
    end
end

local function onInputChanged(input)
    if not inputState.mouseDown then return end
    local pos = getMousePos()
    inputState.lastInputPos = pos
    local hit = inputState.activeHit
    if hit and hit.onInputChanged then
        pcall(function() hit.onInputChanged(pos) end)
    end
end

local function onInputEnded(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        inputState.mouseDown = false
        local pos = getMousePos()
        local startPos = inputState.mouseStartPos or pos
        local moved = dist(pos, startPos)
        local hit = inputState.activeHit
        if hit then
            if hit.onInputEnded then
                pcall(function() hit.onInputEnded() end)
            end
            -- if hasn't moved much -> treat as click
            if moved <= 10 and hit.onClick then
                pcall(function() hit.onClick() end)
            end
        end
        inputState.activeHit = nil
        inputState.mouseStartPos = nil
    end
end

-- We'll also detect hover by polling mouse position each render step
local function pollHover()
    local pos = getMousePos()
    local hit = findHitboxAt(pos)
    if hit ~= state.hovering then
        -- new hover
        if state.hovering and state.hovering.onHover then
            pcall(function() state.hovering.onHover(false) end)
        end
        if hit and hit.onHover then
            pcall(function() hit.onHover(true) end)
        end
        state.hovering = hit
    end

    -- support dragging window or minimized circle while holding mouse
    if state.dragging then
        -- compute new center from mouse pos + offset
        local newCenter = pos + state.dragOffset
        state.centerX = newCenter.X
        state.centerY = newCenter.Y
    end

    if state.minimizedDragging then
        state.minimizedPos = pos + state.minDragOffset
    end

    -- Support slider dragging via interactable events: call onInputChanged for activeHit
    if inputState.mouseDown and inputState.activeHit and inputState.activeHit.onInputChanged then
        inputState.activeHit.onInputChanged(pos)
    end
end

-- Hook input events and render
local function start()
    -- build UI
    buildWindow()
    updateRightPanel()

    -- Input
    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(function(i) onInputChanged(i) end)
    UserInputService.InputEnded:Connect(onInputEnded)

    -- Also allow Mouse fallback events for some executors (safety)
    if MouseFallback then
        pcall(function()
            MouseFallback.Button1Down:Connect(function()
                onInputBegan({UserInputType = Enum.UserInputType.MouseButton1}, false)
            end)
            MouseFallback.Button1Up:Connect(function()
                onInputEnded({UserInputType = Enum.UserInputType.MouseButton1}, false)
            end)
        end)
    end

    -- RenderStepped
    state.renderConn = RunService.RenderStepped:Connect(function()
        -- Poll hover and dragging
        pollHover()

        -- If not minimized, update right panel if selection changed
        updateRightPanel()

        -- Render visuals
        renderStep()
    end)

    -- extra: setup hitbox actions for minimize circle & minimized drag
    -- search for minBtn & minimized in interactables
    for _,hit in ipairs(interactables) do
        if hit.id == "minBtn" then
            -- when clicked, toggle minimize (handled by onClick already)
            -- when input began and user holds -> allow drag of minBtn? Not necessary.
        end
    end

    -- Interactables for minimized circle
    addHitbox{
        id = "minimizedCircle",
        x = 0, y = 0, w = 0, h = 0, -- coords will be checked via isCircle check manually
        isCircle = true,
        center = state.minimizedPos,
        radius = comps and comps.minimized and comps.minimized.radius or 26,
        tolerance = 6,
        onInputBegan = function(pos)
            if state.minimized then
                -- start dragging minimized
                state.minimizedDragging = true
                state.minDragOffset = state.minimizedPos - pos
            end
        end,
        onInputEnded = function()
            state.minimizedDragging = false
        end,
        onClick = function()
            if state.minimized then state.minimized = false end
        end
    }

    -- window drag is already in hitboxes (see in buildWindow)
end

-- Cleanup
local function DestroyUI()
    if state.renderConn then
        pcall(function() state.renderConn:Disconnect() end)
        state.renderConn = nil
    end
    for _,d in ipairs(drawingCache) do
        pcall(function() d:Destroy() end)
    end
    drawingCache = {}
    interactables = {}
end

-- Start UI
start()

-- Expose API
return {
    DestroyUI = DestroyUI,
    GetState = function() return state end,
    SetPosition = function(x,y) state.centerX = x; state.centerY = y end,
    Minimize = function() state.minimized = true end,
    Restore = function() state.minimized = false end
}
