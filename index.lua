-- Simple GUI using Drawing API for DeltaExploit
local Drawing = Drawing
local task = task

-- Create GUI elements
local window = Drawing.new("Square")
window.Size = Vector2.new(300, 200)
window.Position = Vector2.new(500, 300)
window.Color = Color3.fromRGB(50, 50, 50)
window.Filled = true
window.Transparency = 0.9
window.Visible = true
window.ZIndex = 1

local title = Drawing.new("Text")
title.Text = "Simple GUI"
title.Font = Drawing.Fonts.UI
title.Size = 24
title.Position = Vector2.new(510, 310)
title.Color = Color3.fromRGB(255, 255, 255)
title.Center = true
title.Outline = true
title.OutlineColor = Color3.fromRGB(0, 0, 0)
title.Visible = true
title.ZIndex = 2

local button = Drawing.new("Square")
button.Size = Vector2.new(100, 40)
button.Position = Vector2.new(550, 400)
button.Color = Color3.fromRGB(0, 120, 255)
button.Filled = true
button.Transparency = 0.8
button.Visible = true
button.ZIndex = 3

local buttonText = Drawing.new("Text")
buttonText.Text = "Click Me"
buttonText.Font = Drawing.Fonts.Plex
buttonText.Size = 18
buttonText.Position = Vector2.new(600, 410)
buttonText.Color = Color3.fromRGB(255, 255, 255)
buttonText.Center = true
buttonText.Outline = true
buttonText.OutlineColor = Color3.fromRGB(0, 0, 0)
buttonText.Visible = true
buttonText.ZIndex = 4

local closeButton = Drawing.new("Square")
closeButton.Size = Vector2.new(20, 20)
closeButton.Position = Vector2.new(780, 305)
closeButton.Color = Color3.fromRGB(255, 0, 0)
closeButton.Filled = true
closeButton.Transparency = 0.8
closeButton.Visible = true
closeButton.ZIndex = 3

local closeButtonText = Drawing.new("Text")
closeButtonText.Text = "X"
closeButtonText.Font = Drawing.Fonts.UI
closeButtonText.Size = 16
closeButtonText.Position = Vector2.new(790, 310)
closeButtonText.Color = Color3.fromRGB(255, 255, 255)
closeButtonText.Center = true
closeButtonText.Outline = true
closeButtonText.OutlineColor = Color3.fromRGB(0, 0, 0)
closeButtonText.Visible = true
closeButtonText.ZIndex = 4

-- Function to check if a point is inside a square
local function isPointInSquare(point, squarePos, squareSize)
    return point.X >= squarePos.X and point.X <= squarePos.X + squareSize.X
        and point.Y >= squarePos.Y and point.Y <= squarePos.Y + squareSize.Y
end

-- Placeholder for mouse input (assumes DeltaExploit provides mouse.Position)
local mouse = { Position = Vector2.new(0, 0) } -- Replace with actual mouse input
local isRunning = true

-- Main loop for interactivity
task.spawn(function()
    while isRunning do
        -- Update mouse position (placeholder, replace with DeltaExploit's mouse API)
        -- Example: mouse.Position = getMousePosition()

        -- Button hover effect
        if isPointInSquare(mouse.Position, button.Position, button.Size) then
            setrenderproperty(button, "Color", Color3.fromRGB(0, 180, 255))
        else
            setrenderproperty(button, "Color", Color3.fromRGB(0, 120, 255))
        end

        -- Close button click
        if isPointInSquare(mouse.Position, closeButton.Position, closeButton.Size) then
            setrenderproperty(closeButton, "Color", Color3.fromRGB(255, 100, 100))
            -- Assuming a click event (replace with actual input check)
            if mouseClicked then -- Placeholder for click detection
                isRunning = false
                window:Destroy()
                title:Destroy()
                button:Destroy()
                buttonText:Destroy()
                closeButton:Destroy()
                closeButtonText:Destroy()
            end
        else
            setrenderproperty(closeButton, "Color", Color3.fromRGB(255, 0, 0))
        end

        task.wait(1 / 60) -- 60 FPS update
    end
end)

-- Cleanup after 10 seconds if not closed
task.delay(10, function()
    if isRunning then
        cleardrawcache()
    end
end)
