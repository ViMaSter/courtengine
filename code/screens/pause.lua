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
                key = controls.pause
            },
            {
                title = "Court Records",
                key = controls.press_court_record
            },
            {
                title = "Grump Out",
                key = "delete"
            },
            {
                title = "Cheat Codes",
                key = "lctrl"
            }
        },
    })

    -- Temporary text where the settings should go
    local pauseHeader = love.graphics.newText(GameFont, "THE GAME IS PAUSED")
    love.graphics.setColor(unpack(colors.white))
    love.graphics.draw(pauseHeader, GetCenterOffset(pauseHeader:getWidth() * 2, false), 120, 0, 2, 2)

    -- Temporary(?) tools for easier developing/testing
    local scriptHeader = love.graphics.newText(GameFont, "Scene Script - navigate with arrow keys")
    love.graphics.draw(scriptHeader, GetCenterOffset(scriptHeader:getWidth(), false), 220)
    local boxWidth = love.graphics.getWidth() * 3/5 - 70
    local boxHeight = 360
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle(
        "fill",
        240 + 33.25,
        240,
        boxWidth,
        boxHeight
    )

    -- Only a few events for them to go back and forth between
    love.graphics.setColor(unpack(colors.white))

    local firstIndex = NavigationIndex > 5 and (NavigationIndex - 5) or 1
    local displayedIndex = 1
    for i=firstIndex, firstIndex + 8 do
        if i < #CurrentScene.sceneScript then
            local label = i
            for j=1, #CurrentScene.sceneScript[i].lineParts do
                label = label.." "..CurrentScene.sceneScript[i].lineParts[j]
            end

            if i == NavigationIndex then
                love.graphics.setColor(0.98, 0.82, 0.38)
            else
                love.graphics.setColor(unpack(colors.white))
            end

            love.graphics.print(label, 245 + 33.25, 250 + 40 * (displayedIndex - 1), 0, 1, 1)
            displayedIndex = displayedIndex + 1
        end
    end
end

PauseScreenConfig = {
    displayed = false;
    displayKey = controls.pause;
    displayCondition = function ()
        -- Don't let the pause menu show until the scene has
        -- started (AKA we're off the title screen)
        return Episode.loaded;
    end;
    onDisplay = function ()
        NavigationIndex = CurrentScene.currentEventIndex
    end;
    onKeyPressed = function (key)
        -- Let the user navigate
        if key == controls.pause_nav_up and NavigationIndex > 1 then
            NavigationIndex = NavigationIndex - 1
        elseif key == controls.pause_nav_down and NavigationIndex < #CurrentScene.sceneScript then
            NavigationIndex = NavigationIndex + 1
        elseif key == controls.pause_confirm then
            -- TODO: Implement some sort of navigation tool
        end
    end;
    draw = function ()
        DrawPauseScreen()
    end
}