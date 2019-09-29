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
        local buttonTextPadding = options.buttonTextPadding or 5

        -- Approximate the width we'll need to display all the buttons
        -- Eventually this could just be an asset
        local buttonTabWidth = 0
        for i=1, #buttons do
            local buttonKey = love.graphics.newText(GameFont, buttons[i].key)
            local buttonTitle = love.graphics.newText(GameFont, buttons[i].title)

            local keyLen = #(buttons[i].key)
            local keyHeight = buttonTabHeight - (buttonTextPadding * 2)
            local keyWidth = keyLen > 1 and buttonKey:getWidth() + (buttonTextPadding * 2) or keyHeight

            buttonTabWidth = buttonTabWidth +
                (i > 1 and buttonPadding or 0) +
                keyWidth +
                buttonTitle:getWidth() + (buttonTextPadding * 2)
        end

        -- If there's only one button, we don't need extra padding
        -- on the right
        -- if #buttons > 2 then
        --     buttonTabWidth = buttonTabWidth + buttonPadding
        -- end

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
        local keyY = bottomRightY - buttonTabHeight + buttonTextPadding
        local keyHeight = buttonTabHeight - (buttonTextPadding * 2)
        for i=1, #buttons do
            local buttonKey = love.graphics.newText(GameFont, GetKeyDisplayName(buttons[i].key))
            local buttonTitle = love.graphics.newText(GameFont, buttons[i].title)

            local keyLen = #(buttons[i].key)
            local keyX = lastX + (i > 1 and buttonPadding or 0)
            local keyWidth = keyLen > 1 and buttonKey:getWidth() + (buttonTextPadding * 2) or keyHeight

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
            love.graphics.draw(buttonKey, keyX + buttonTextPadding, keyY + 2, 0, 1, 1)

            -- Button command text
            love.graphics.setColor(unpack(buttonColorAlpha))
            love.graphics.draw(buttonTitle, keyX + keyWidth + buttonTextPadding, keyY + 2, 0, 1, 1)

            -- Keep track of where this button ended so we know where to start
            lastX = keyX + keyWidth + buttonTextPadding + buttonTitle:getWidth()
        end
    end
end

-- Given the width of the drawable, return the x value to use to center the element
-- on the screen
function GetCenterOffset(elementWidth, isScaled)
    isScaled = isScaled == nil and true or isScaled
    if isScaled then
        return ((dimensions.window_width / dimensions.graphics_scale) - elementWidth) / 2
    else
        return (dimensions.window_width - elementWidth) / 2
    end
end
