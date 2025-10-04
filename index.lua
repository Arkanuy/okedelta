-- GUI Sederhana menggunakan Drawing API (UNC Standard)
-- Contoh: Menu Panel dengan Button dan Text

-- Konfigurasi
local screenCenter = Vector2.new(500, 400)
local panelWidth = 300
local panelHeight = 200

-- ===== BACKGROUND PANEL =====
local panel = Drawing.new("Square")
panel.Size = Vector2.new(panelWidth, panelHeight)
panel.Position = Vector2.new(screenCenter.X - panelWidth/2, screenCenter.Y - panelHeight/2)
panel.Color = Color3.fromRGB(30, 30, 40)
panel.Filled = true
panel.Transparency = 0.9
panel.Visible = true
panel.ZIndex = 1

-- ===== BORDER PANEL =====
local panelBorder = Drawing.new("Square")
panelBorder.Size = Vector2.new(panelWidth, panelHeight)
panelBorder.Position = Vector2.new(screenCenter.X - panelWidth/2, screenCenter.Y - panelHeight/2)
panelBorder.Color = Color3.fromRGB(100, 150, 255)
panelBorder.Filled = false
panelBorder.Thickness = 2
panelBorder.Transparency = 1
panelBorder.Visible = true
panelBorder.ZIndex = 2

-- ===== HEADER BAR =====
local header = Drawing.new("Square")
header.Size = Vector2.new(panelWidth, 35)
header.Position = Vector2.new(screenCenter.X - panelWidth/2, screenCenter.Y - panelHeight/2)
header.Color = Color3.fromRGB(100, 150, 255)
header.Filled = true
header.Transparency = 1
header.Visible = true
header.ZIndex = 2

-- ===== TITLE TEXT =====
local titleText = Drawing.new("Text")
titleText.Text = "Delta Exploit GUI"
titleText.Size = 18
titleText.Font = Drawing.Fonts.Plex
titleText.Position = Vector2.new(screenCenter.X - panelWidth/2 + 10, screenCenter.Y - panelHeight/2 + 8)
titleText.Color = Color3.fromRGB(255, 255, 255)
titleText.Transparency = 1
titleText.Outline = true
titleText.OutlineColor = Color3.fromRGB(0, 0, 0)
titleText.Visible = true
titleText.ZIndex = 3

-- ===== BUTTON 1 =====
local button1 = Drawing.new("Square")
button1.Size = Vector2.new(panelWidth - 40, 35)
button1.Position = Vector2.new(screenCenter.X - (panelWidth - 40)/2, screenCenter.Y - panelHeight/2 + 60)
button1.Color = Color3.fromRGB(50, 50, 60)
button1.Filled = true
button1.Transparency = 1
button1.Visible = true
button1.ZIndex = 2

local button1Border = Drawing.new("Square")
button1Border.Size = Vector2.new(panelWidth - 40, 35)
button1Border.Position = Vector2.new(screenCenter.X - (panelWidth - 40)/2, screenCenter.Y - panelHeight/2 + 60)
button1Border.Color = Color3.fromRGB(80, 120, 200)
button1Border.Filled = false
button1Border.Thickness = 1
button1Border.Transparency = 1
button1Border.Visible = true
button1Border.ZIndex = 3

local button1Text = Drawing.new("Text")
button1Text.Text = "Execute Script"
button1Text.Size = 16
button1Text.Font = Drawing.Fonts.UI
button1Text.Position = Vector2.new(screenCenter.X - (panelWidth - 40)/2 + 10, screenCenter.Y - panelHeight/2 + 68)
button1Text.Color = Color3.fromRGB(255, 255, 255)
button1Text.Transparency = 1
button1Text.Visible = true
button1Text.ZIndex = 4

-- ===== BUTTON 2 =====
local button2 = Drawing.new("Square")
button2.Size = Vector2.new(panelWidth - 40, 35)
button2.Position = Vector2.new(screenCenter.X - (panelWidth - 40)/2, screenCenter.Y - panelHeight/2 + 110)
button2.Color = Color3.fromRGB(50, 50, 60)
button2.Filled = true
button2.Transparency = 1
button2.Visible = true
button2.ZIndex = 2

local button2Border = Drawing.new("Square")
button2Border.Size = Vector2.new(panelWidth - 40, 35)
button2Border.Position = Vector2.new(screenCenter.X - (panelWidth - 40)/2, screenCenter.Y - panelHeight/2 + 110)
button2Border.Color = Color3.fromRGB(80, 120, 200)
button2Border.Filled = false
button2Border.Thickness = 1
button2Border.Transparency = 1
button2Border.Visible = true
button2Border.ZIndex = 3

local button2Text = Drawing.new("Text")
button2Text.Text = "Clear Cache"
button2Text.Size = 16
button2Text.Font = Drawing.Fonts.UI
button2Text.Position = Vector2.new(screenCenter.X - (panelWidth - 40)/2 + 10, screenCenter.Y - panelHeight/2 + 118)
button2Text.Color = Color3.fromRGB(255, 255, 255)
button2Text.Transparency = 1
button2Text.Visible = true
button2Text.ZIndex = 4

-- ===== STATUS TEXT =====
local statusText = Drawing.new("Text")
statusText.Text = "Status: Ready"
statusText.Size = 14
statusText.Font = Drawing.Fonts.Monospace
statusText.Position = Vector2.new(screenCenter.X - panelWidth/2 + 10, screenCenter.Y - panelHeight/2 + 165)
statusText.Color = Color3.fromRGB(100, 255, 100)
statusText.Transparency = 1
statusText.Outline = true
statusText.OutlineColor = Color3.fromRGB(0, 0, 0)
statusText.Visible = true
statusText.ZIndex = 3

-- ===== FUNGSI UNTUK DESTROY GUI =====
function destroyGUI()
    panel:Destroy()
    panelBorder:Destroy()
    header:Destroy()
    titleText:Destroy()
    button1:Destroy()
    button1Border:Destroy()
    button1Text:Destroy()
    button2:Destroy()
    button2Border:Destroy()
    button2Text:Destroy()
    statusText:Destroy()
    print("GUI Destroyed!")
end

-- GUI akan otomatis hilang setelah 5 detik
print("GUI Created! Will auto-destroy in 5 seconds...")
task.wait(5)
destroyGUI()

-- Alternatif: Gunakan cleardrawcache() untuk clear semua drawing sekaligus
-- cleardrawcache()
