require "code/screens/title"
require "code/screens/pause"

screens = {
    title = {
        displayed = false;
        keyhandler = function (key)
            if key == controls.start_button then
                -- Since there's no displayKey, this screen
                -- is responsible for removing itself
                screens.title.displayed = false;
                love.graphics.clear(0,0,0);
                if TitleSelection == "Load Game" then
                    -- replace this and handle load game logic
                    BeginEpisode()
                else
                    -- replace this and handle new game logic
                    BeginEpisode()
                end
            elseif key == controls.press_right then
                TitleSelection = "Load Game"
            elseif key == controls.press_left then
                TitleSelection = "New Game"
            end
        end;
        drawScreen = function ()
            DrawTitleScreen()
        end;
    };
    pause = {
        displayed = false;
        displayKey = controls.pause;
        displayCondition = function ()
            -- Don't let the pause menu show until the scene has
            -- started (AKA we're off the title screen)
            return SceneIndex ~= nil;
        end;
        keyhandler = function (key)
            -- Let the user navigate
            if key == controls.pause_nav_up and NavigationIndex > 1 then
                NavigationIndex = NavigationIndex - 1
            elseif key == controls.pause_nav_down and NavigationIndex < #CurrentScene.sceneScript then
                NavigationIndex = NavigationIndex + 1
            elseif key == controls.pause_confirm then
                -- TODO: Implement some sort of navigation tool
            end
        end;
        drawScreen = function ()
            NavigationIndex = CurrentScene.currentEventIndex
            DrawPauseScreen()
        end
    };
}
