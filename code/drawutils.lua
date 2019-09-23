function DrawCenteredRectangle(options)
    local borderSize = options.borderSize or 2
    local borderColorAlpha = options.borderColorAlpha or {1, 1, 1, 1}
    local colorAlpha = options.colorAlpha or {0.169, 0.526, 0.722}

    local buttons = options.buttons or {}
    local title = options.title
    local titleHeight = options.titleHeight or 30

    local width = options.width
    local height = options.height
    local topLeftX = (love.graphics.getWidth() - width)/2
    local topLeftY = (love.graphics.getHeight() - height)/2


    -- Shift the box down a little to account for the tab
    if title then
        height = height - titleHeight
        topLeftY = topLeftY + titleHeight
    end

    if borderSize > 0 then
        love.graphics.setColor(unpack(borderColorAlpha))
        love.graphics.rectangle(
            "fill",
            topLeftX - borderSize,
            topLeftY - borderSize,
            width + (2 * borderSize),
            height + (2 * borderSize)
        )
    end

    love.graphics.setColor(unpack(colorAlpha))
    love.graphics.rectangle(
        "fill",
        topLeftX,
        topLeftY,
        width,
        height
    )

    if title then
        local titleColorAlpha = options.titleColorAlpha or {1, 1, 1, 1}
        local titleWidth = options.titleWidth or 180
        local titlePadding = options.titlePadding or 5
        local titleSlantWidth = options.titleSlantWidth or 20

        if borderSize > 0 then
            -- Title tab border
            love.graphics.setColor(unpack(borderColorAlpha))
            love.graphics.polygon(
                "fill",
                topLeftX - borderSize,
                topLeftY - titleHeight - borderSize,
                topLeftX + titleWidth + borderSize,
                topLeftY - titleHeight - borderSize,
                topLeftX + titleWidth + titleSlantWidth + borderSize,
                topLeftY,
                topLeftX - borderSize,
                topLeftY
            )
        end

        -- Title tab background
        love.graphics.setColor(unpack(colorAlpha))
        love.graphics.polygon(
            "fill",
            topLeftX,
            topLeftY - titleHeight,
            topLeftX + titleWidth,
            topLeftY - titleHeight,
            topLeftX + titleWidth + titleSlantWidth,
            topLeftY,
            topLeftX,
            topLeftY
        )

        -- Title tab text
        love.graphics.setColor(unpack(titleColorAlpha))
        love.graphics.print(title, topLeftX + titlePadding, topLeftY - titleHeight + titlePadding - 3, 0, 2, 2)
    end

    if #buttons > 0 then
        local buttonColorAlpha = options.buttonColorAlpha or {0, 0, 0, 1}
        local buttonTabColorAlpha = options.buttonTabColorAlpha or {1, 1, 1, 1}
        local buttonKeyColorAlpha = options.buttonKeyColorAlpha or {1, 1, 1, 1}
        local buttonKeyBackgroundColorAlpha = options.buttonKeyBackgroundColorAlpha or {0.169, 0.526, 0.722}
        local buttonPadding = options.buttonPadding or 30
        local buttonSlantWidth = options.buttonSlantWidth or 30
        local buttonTabHeight = options.buttonHeight or 30
        local buttonTabWidth = options.buttonTabWidth or 0
        local buttonTextPadding = options.buttonTextPadding or 5

        -- Approximate the width we'll need to display all the buttons
        -- Eventually this could just be an asset
        if buttonTabWidth == 0 then
            for i=1, #buttons do
                buttonTabWidth = buttonTabWidth +
                    (buttonPadding * 2) +
                    #(buttons[i].key) +
                    #(buttons[i].title) +
                    (buttonTextPadding * 4)
            end

            -- If there's only one button, we don't need extra padding
            -- on the right
            if #buttons > 2 then
                buttonTabWidth = buttonTabWidth + buttonPadding
            end
        end


        local bottomRightX = topLeftX + width
        local bottomRightY = topLeftY + height

        -- Button tab background
        love.graphics.setColor(unpack(buttonTabColorAlpha))
        love.graphics.polygon(
            "fill",
            bottomRightX - buttonTabWidth,
            bottomRightY - buttonTabHeight,
            bottomRightX,
            bottomRightY - buttonTabHeight,
            bottomRightX,
            bottomRightY,
            bottomRightX - buttonTabWidth - buttonSlantWidth,
            bottomRightY
        )

        local lastX = bottomRightX - buttonTabWidth
        for i=1, #buttons do
            local keyLen = #(buttons[i].key)
            local keyX = lastX + (buttonPadding * (i - 1)) + buttonTextPadding
            local keyY = bottomRightY - buttonTabHeight + buttonTextPadding
            local keyHeight = buttonTabHeight - (buttonTextPadding * 2)
            local keyWidth = keyLen > 1 and (#(buttons[i].key) * 10) or keyHeight

            -- Button key indicator
            love.graphics.setColor(unpack(buttonKeyBackgroundColorAlpha))
            love.graphics.rectangle(
                "fill",
                keyX,
                keyY,
                keyWidth,
                keyHeight,
                2,
                2
            )

            -- Button key text
            love.graphics.setColor(unpack(buttonKeyColorAlpha))
            love.graphics.print(buttons[i].key, keyX + (keyLen > 1 and buttonTextPadding or (keyWidth / 2 - 4)), keyY + 2, 0, 1, 1)

            -- Button command text
            love.graphics.setColor(unpack(buttonColorAlpha))
            love.graphics.print(buttons[i].title, keyX + keyWidth + buttonTextPadding, keyY + 2, 0, 1, 1)

            -- Keep track of where this button ended so we know where to start
            lastX = keyX + keyWidth + (#(buttons[i].title) * 5)
        end
    end
end

-- TODO: This matches the Switch UI but not the DS UI, and should be updated
-- after the art team has established the look
function DrawPauseScreen(self)
    -- Add a light overlay
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Add the settings box with a 2px white outline
    DrawCenteredRectangle({
        width = love.graphics.getWidth() * 3/5,
        height = love.graphics.getHeight() - 120,
        buttons = {
            {
                title = "Back",
                key = "Esc"
            },
        },
    })

    -- Temporary text where the settings should go
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("THE GAME IS PAUSED", love.graphics.getWidth()/3 + 15, 120, 0, 2, 2)

    -- Temporary(?) tools for easier developing/testing
    love.graphics.print("Scene Script - navigate with arrow keys", 240, 220, 0, 1, 1)
    local boxWidth = love.graphics.getWidth() * 3/5 - 70
    local boxHeight = 400
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle(
        "fill",
        240,
        240,
        boxWidth,
        boxHeight
    )

    -- Only show up to 10 events for them to go back and forth between
    love.graphics.setColor(1, 1, 1)

    local firstIndex = NavigationIndex > 5 and (NavigationIndex - 5) or 1
    local displayedIndex = 1
    for i=firstIndex, firstIndex + 9 do
        if i < #CurrentScene.sceneScript then
            local label = i
            for j=1, #CurrentScene.sceneScript[i].lineParts do
                label = label.." "..CurrentScene.sceneScript[i].lineParts[j]
            end

            if i == NavigationIndex then
                love.graphics.setColor(0.98, 0.82, 0.38)
            else
                love.graphics.setColor(1, 1, 1)
            end

            love.graphics.print(label, 245, 250 + 40 * (displayedIndex - 1), 0, 1, 1)
            displayedIndex = displayedIndex + 1
        end
    end
end

function DrawMainMenu(self)
    myButton = {
		x = 10, y = 10, image=love.graphics.newImage("main_logo.png"), clicked = false
    }
end