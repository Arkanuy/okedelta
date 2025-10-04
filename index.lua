-- Arkan Scripts GUI
-- Contoh GUI menggunakan Drawing API (untuk executor seperti DeltaExploit)
-- Fitur:
-- - Window di tengah layar (rounded corners dibuat dari Square + 4 Circle)
-- - Di kiri ada list menu, klik untuk ubah konten di kanan
-- - Judul "Arkan Scripts" di atas, center
-- - Tombol minimize: mengecil jadi circle dengan huruf 'A', klik lagi untuk restore
-- Catatan: beberapa executor punya perbedaan (font, default Visible). Simpan referensi objek supaya tidak GC.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player and player:GetMouse()

-- Helper: make a rounded-rectangle using one Square and 4 Circles at corners
local function CreateRoundedRect(pos, size, color, radius, zindex)
    local parts = {}
    local sq = Drawing.new("Square")
    sq.Position = Vector2.new(pos.X + radius, pos.Y + radius)
    sq.Size = Vector2.new(math.max(0, size.X - radius * 2), math.max(0, size.Y - radius * 2))
    sq.Filled = true
    sq.Color = color
    sq.Transparency = 1
    sq.ZIndex = zindex or 1
    table.insert(parts, sq)

    -- left/right vertical rectangles (cover edges)
    local left = Drawing.new("Square")
    left.Position = Vector2.new(pos.X, pos.Y + radius)
    left.Size = Vector2.new(radius, math.max(0, size.Y - radius * 2))
    left.Filled = true
    left.Color = color
    left.Transparency = 1
    left.ZIndex = zindex or 1
    table.insert(parts, left)

    local right = Drawing.new("Square")
    right.Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius)
    right.Size = Vector2.new(radius, math.max(0, size.Y - radius * 2))
    right.Filled = true
    right.Color = color
    right.Transparency = 1
    right.ZIndex = zindex or 1
    table.insert(parts, right)

    -- top/bottom horizontal rectangles
    local top = Drawing.new("Square")
    top.Position = Vector2.new(pos.X + radius, pos.Y)
    top.Size = Vector2.new(math.max(0, size.X - radius * 2), radius)
    top.Filled = true
    top.Color = color
    top.Transparency = 1
    top.ZIndex = zindex or 1
    table.insert(parts, top)

    local bottom = Drawing.new("Square")
    bottom.Position = Vector2.new(pos.X + radius, pos.Y + size.Y - radius)
    bottom.Size = Vector2.new(math.max(0, size.X - radius * 2), radius)
    bottom.Filled = true
    bottom.Color = color
    bottom.Transparency = 1
    bottom.ZIndex = zindex or 1
    table.insert(parts, bottom)

    -- 4 corner circles
    local c1 = Drawing.new("Circle")
    c1.Position = Vector2.new(pos.X + radius, pos.Y + radius)
    c1.Radius = radius
    c1.Filled = true
    c1.Color = color
    c1.Transparency = 1
    c1.NumSides = 32
    c1.ZIndex = zindex or 1
    table.insert(parts, c1)

    local c2 = Drawing.new("Circle")
    c2.Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius)
    c2.Radius = radius
    c2.Filled = true
    c2.Color = color
    c2.Transparency = 1
    c2.NumSides = 32
    c2.ZIndex = zindex or 1
    table.insert(parts, c2)

    local c3 = Drawing.new("Circle")
    c3.Position = Vector2.new(pos.X + radius, pos.Y + size.Y - radius)
    c3.Radius = radius
    c3.Filled = true
    c3.Color = color
    c3.Transparency = 1
    c3.NumSides = 32
    c3.ZIndex = zindex or 1
    table.insert(parts, c3)

    local c4 = Drawing.new("Circle")
    c4.Position = Vector2.new(pos.X + size.X - radius, pos.Y + size.Y - radius)
    c4.Radius = radius
    c4.Filled = true
    c4.Color = color
    c4.Transparency = 1
    c4.NumSides = 32
    c4.ZIndex = zindex or 1
    table.insert(parts, c4)

    local api = {}
    function api:SetVisible(v)
        for _, p in pairs(parts) do p.Visible = v end
    end
    function api:Destroy()
        for _, p in pairs(parts) do p:Destroy() end
        parts = {}
    end
    function api:SetColor(col)
        for _, p in pairs(parts) do p.Color = col end
    end
    function api:SetPosition(newPos)
        pos = newPos
        sq.Position = Vector2.new(pos.X + radius, pos.Y + radius)
        left.Position = Vector2.new(pos.X, pos.Y + radius)
        right.Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius)
        top.Position = Vector2.new(pos.X + radius, pos.Y)
        bottom.Position = Vector2.new(pos.X + radius, pos.Y + size.Y - radius)
        c1.Position = Vector2.new(pos.X + radius, pos.Y + radius)
        c2.Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius)
        c3.Position = Vector2.new(pos.X + radius, pos.Y + size.Y - radius)
        c4.Position = Vector2.new(pos.X + size.X - radius, pos.Y + size.Y - radius)
    end
    function api:SetSize(newSize)
        size = newSize
        -- update squares/circles similarly
        sq.Size = Vector2.new(math.max(0, size.X - radius * 2), math.max(0, size.Y - radius * 2))
        left.Size = Vector2.new(radius, math.max(0, size.Y - radius * 2))
        right.Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius)
        right.Size = Vector2.new(radius, math.max(0, size.Y - radius * 2))
        top.Size = Vector2.new(math.max(0, size.X - radius * 2), radius)
        bottom.Position = Vector2.new(pos.X + radius, pos.Y + size.Y - radius)
        bottom.Size = Vector2.new(math.max(0, size.X - radius * 2), radius)
        c2.Position = Vector2.new(pos.X + size.X - radius, pos.Y + radius)
        c3.Position = Vector2.new(pos.X + radius, pos.Y + size.Y - radius)
        c4.Position = Vector2.new(pos.X + size.X - radius, pos.Y + size.Y - radius)
    end

    -- expose parts for fine control if needed
    api._parts = parts
    return api
end

-- Main layout
local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
local windowSize = Vector2.new(700, 420) -- tidak terlalu besar
local windowPos = Vector2.new(screenCenter.X - windowSize.X/2, screenCenter.Y - windowSize.Y/2)
local bgColor = Color3.fromRGB(30, 30, 35)
local panelColor = Color3.fromRGB(40, 40, 45)
local accent = Color3.fromRGB(88, 101, 242)

local wnd = CreateRoundedRect(windowPos, windowSize, bgColor, 12, 2)
wnd:SetVisible(true)

-- left panel (menu)
local leftPos = Vector2.new(windowPos.X + 18, windowPos.Y + 64)
local leftSize = Vector2.new(180, windowSize.Y - 90)
local leftPanel = CreateRoundedRect(leftPos, leftSize, panelColor, 8, 3)
leftPanel:SetVisible(true)

-- right panel (content)
local rightPos = Vector2.new(windowPos.X + 210, windowPos.Y + 64)
local rightSize = Vector2.new(windowSize.X - 228, windowSize.Y - 90)
local rightPanel = CreateRoundedRect(rightPos, rightSize, panelColor, 8, 3)
rightPanel:SetVisible(true)

-- Title text centered top
local title = Drawing.new("Text")
title.Text = "Arkan Scripts"
title.Font = Drawing.Fonts.Plex
title.Size = 28
title.Position = Vector2.new(screenCenter.X, windowPos.Y + 18)
title.Center = true
title.Outline = true
title.OutlineColor = Color3.new(0,0,0)
title.Color = Color3.fromRGB(235,235,235)
title.Visible = true

-- Minimize button (small circle top-right inside window)
local minCircle = Drawing.new("Circle")
minCircle.Radius = 12
minCircle.Position = Vector2.new(windowPos.X + windowSize.X - 28, windowPos.Y + 24)
minCircle.Filled = true
minCircle.Color = accent
minCircle.Transparency = 1
minCircle.NumSides = 32
minCircle.ZIndex = 5
minCircle.Visible = true

local minText = Drawing.new("Text")
minText.Text = "-"
minText.Font = Drawing.Fonts.Plex
minText.Size = 18
minText.Position = Vector2.new(minCircle.Position.X, minCircle.Position.Y - 8)
minText.Center = true
minText.Outline = true
minText.OutlineColor = Color3.new(0,0,0)
minText.Color = Color3.new(1,1,1)
minText.Visible = true

-- Minimized state circle with 'A' (hidden initially)
local mini = Drawing.new("Circle")
mini.Radius = 18
mini.Position = Vector2.new(screenCenter.X, screenCenter.Y)
mini.Filled = true
mini.Color = accent
mini.NumSides = 32
mini.Visible = false
mini.ZIndex = 10

local miniText = Drawing.new("Text")
miniText.Text = "A"
miniText.Font = Drawing.Fonts.Plex
miniText.Size = 20
miniText.Position = Vector2.new(screenCenter.X, screenCenter.Y - 10)
miniText.Center = true
miniText.Outline = true
miniText.OutlineColor = Color3.new(0,0,0)
miniText.Color = Color3.new(1,1,1)
miniText.Visible = false
miniText.ZIndex = 11

-- Menu items data
local menus = {"Home", "Player", "Visuals", "Settings"}
local menuTexts = {}
local menuStartY = leftPos.Y + 12
for i, name in ipairs(menus) do
    local t = Drawing.new("Text")
    t.Text = name
    t.Font = Drawing.Fonts.Plex
    t.Size = 20
    t.Position = Vector2.new(leftPos.X + leftSize.X/2, menuStartY + (i-1)*36)
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.new(0,0,0)
    t.Color = Color3.fromRGB(220,220,220)
    t.Visible = true
    t.ZIndex = 6
    menuTexts[i] = {text = t, name = name, pos = Vector2.new(t.Position.X - 80, t.Position.Y - 12), size = Vector2.new(160, 28)}
end

-- Content area text (changes when menu clicked)
local contentTitle = Drawing.new("Text")
contentTitle.Text = "Home"
contentTitle.Font = Drawing.Fonts.Plex
contentTitle.Size = 22
contentTitle.Position = Vector2.new(rightPos.X + 12, rightPos.Y + 10)
contentTitle.Outline = true
contentTitle.OutlineColor = Color3.new(0,0,0)
contentTitle.Color = Color3.fromRGB(235,235,235)
contentTitle.Visible = true
contentTitle.ZIndex = 6

local contentBody = {}
for i=1,6 do
    local t = Drawing.new("Text")
    t.Text = ""
    t.Font = Drawing.Fonts.Plex
    t.Size = 18
    t.Position = Vector2.new(rightPos.X + 20, rightPos.Y + 40 + (i-1)*28)
    t.Outline = true
    t.OutlineColor = Color3.new(0,0,0)
    t.Color = Color3.fromRGB(200,200,200)
    t.Visible = true
    t.ZIndex = 6
    table.insert(contentBody, t)
end

local function updateContent(menuName)
    contentTitle.Text = menuName
    -- contoh isi setiap menu
    local items = {}
    if menuName == "Home" then
        items = {"Welcome to Arkan Scripts","Version: 1.0","Click left menu to explore"}
    elseif menuName == "Player" then
        items = {"Speed: Toggle","JumpBoost: Toggle","Invisibility: Toggle"}
    elseif menuName == "Visuals" then
        items = {"ESP: Toggle","Chams: Toggle","Tracer: Toggle"}
    elseif menuName == "Settings" then
        items = {"UI Theme","Keybinds","About"}
    end
    for i, t in ipairs(contentBody) do
        t.Text = items[i] or ""
    end
end

updateContent("Home")

-- Utility: check if a 2D point inside rectangle defined by pos & size
local function pointInRect(p, rectPos, rectSize)
    return p.X >= rectPos.X and p.X <= rectPos.X + rectSize.X and p.Y >= rectPos.Y and p.Y <= rectPos.Y + rectSize.Y
end

-- Click handling
local minimized = false

local function toggleMinimize()
    if minimized then
        -- restore: hide mini and show full
        mini.Visible = false
        miniText.Visible = false
        wnd:SetVisible(true)
        leftPanel:SetVisible(true)
        rightPanel:SetVisible(true)
        title.Visible = true
        minCircle.Visible = true
        minText.Visible = true
        for _, v in ipairs(menuTexts) do v.text.Visible = true end
        contentTitle.Visible = true
        for _, v in ipairs(contentBody) do v.Visible = true end
        minimized = false
    else
        -- minimize: hide full, show small circle with A
        wnd:SetVisible(false)
        leftPanel:SetVisible(false)
        rightPanel:SetVisible(false)
        title.Visible = false
        minCircle.Visible = false
        minText.Visible = false
        for _, v in ipairs(menuTexts) do v.text.Visible = false end
        contentTitle.Visible = false
        for _, v in ipairs(contentBody) do v.Visible = false end
        mini.Visible = true
        miniText.Visible = true
        minimized = true
    end
end

-- Input: left-click
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mPos = Vector2.new(mouse.X, mouse.Y)
        -- check minimize button
        if pointInRect(mPos, Vector2.new(minCircle.Position.X - minCircle.Radius, minCircle.Position.Y - minCircle.Radius), Vector2.new(minCircle.Radius*2, minCircle.Radius*2)) and minCircle.Visible then
            toggleMinimize()
            return
        end
        -- if minimized, check mini circle click
        if minimized and mini.Visible then
            if (mPos - mini.Position).Magnitude <= mini.Radius then
                toggleMinimize()
            end
            return
        end
        -- check menu items
        for i, entry in ipairs(menuTexts) do
            if entry.text.Visible and pointInRect(mPos, entry.pos, entry.size) then
                -- highlight selected
                for _, e in ipairs(menuTexts) do e.text.Color = Color3.fromRGB(220,220,220) end
                entry.text.Color = accent
                updateContent(entry.name)
                return
            end
        end
    end
end)

-- Make UI follow camera resize
local function repositionCenter()
    screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    windowPos = Vector2.new(screenCenter.X - windowSize.X/2, screenCenter.Y - windowSize.Y/2)
    wnd:SetPosition(windowPos)
    leftPos = Vector2.new(windowPos.X + 18, windowPos.Y + 64)
    rightPos = Vector2.new(windowPos.X + 210, windowPos.Y + 64)
    leftPanel:SetPosition(leftPos)
    rightPanel:SetPosition(rightPos)
    title.Position = Vector2.new(screenCenter.X, windowPos.Y + 18)
    minCircle.Position = Vector2.new(windowPos.X + windowSize.X - 28, windowPos.Y + 24)
    minText.Position = Vector2.new(minCircle.Position.X, minCircle.Position.Y - 8)
    mini.Position = Vector2.new(screenCenter.X, screenCenter.Y)
    miniText.Position = Vector2.new(screenCenter.X, screenCenter.Y - 10)
    -- update menu texts positions
    for i, entry in ipairs(menuTexts) do
        entry.text.Position = Vector2.new(leftPos.X + leftSize.X/2, menuStartY + (i-1)*36)
        entry.pos = Vector2.new(entry.text.Position.X - 80, entry.text.Position.Y - 12)
    end
    contentTitle.Position = Vector2.new(rightPos.X + 12, rightPos.Y + 10)
    for i, t in ipairs(contentBody) do
        t.Position = Vector2.new(rightPos.X + 20, rightPos.Y + 40 + (i-1)*28)
    end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    repositionCenter()
end)

-- Initial select first menu
menuTexts[1].text.Color = accent

-- Keep references to avoid GC
local _refs = {wnd=wnd, left=leftPanel, right=rightPanel, title=title, minCircle=minCircle, minText=minText, mini=mini, miniText=miniText, menus=menuTexts, contentTitle=contentTitle, contentBody=contentBody}

-- Done
print("Arkan Scripts GUI loaded")
