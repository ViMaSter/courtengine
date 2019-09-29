--[[
  The "Screen" system allows us to configure a generic screen to be toggled
  by a specific key. In order for a screen to be recognized by the game, the
  file providing the functionality must be required and an object
  detailing the configuration of the screen must be in the global screens,
  defined below.

  The configuration object requires the following to be defined:

    displayed   bool            The initial display state of this screen

    draw        func            A function that is responsible for drawing or calling other
                                functions to draw the screen. This is expected to be run
                                during love.update, so state variables should not be updated
                                here.

  The configuration object also supports the following optional properties:

    displayKey      str         The key that should be used to toggle the display state of
                                this screen.
                                NOTE: If this is not provided, it's up to the implementation
                                to manually set the displayed boolean

    displayCondition    func    A function that returns whether or not the screen is ready to
                                be displayed when the displayKey is pressed. This can be used
                                to prevent screens from appearing during certain events.

    onDisplay       func        A function that will be called when a screen is being
                                displayed. This can be used to initialize variables for the
                                screen's use.

    onKeyPressed    func(str)   A function that will be called on keypress events while the
                                screen is displayed. This will be passed the string value of
                                the key pressed, and can be used for things like navigation
                                or interactions with UI elements in the screen.
                                NOTE: This should also be used for removing the screen if
                                displayKey was not set.
]]

require "code/screens/title"
require "code/screens/pause"
require "code/screens/courtrecords"

screens = {
<<<<<<< HEAD
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
                    Episode:begin()
                else
                    -- replace this and handle new game logic
                    Episode:begin()
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
            return Episode.loaded;
        end;
        onDisplay = function ()
            NavigationIndex = CurrentScene.currentEventIndex
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
            DrawPauseScreen()
        end
    };
=======
    title = TitleScreenConfig,
    pause = PauseScreenConfig,
    courtRecords = CourtRecordsConfig,
>>>>>>> Convert Court Records into a screen, add documention for screens
}
