require "code/courtscene"
require "code/scriptloader"
require "code/utils"
require "code/assets"
require "code/drawutils"
require "code/titlescene"
require "config" -- controls text file


function love.load(arg)
    InitConfig()
    love.window.setMode(WindowWidth, WindowHeight, {})
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")
    Renderable = love.graphics.newCanvas(GraphicsWidth, GraphicsHeight)
    ScreenShake = 0
    DtReset = false -- so scene load times don't factor into dt
    script_loaded = false

    --[[ 
        currently we only support the args being used in the order 
        `love . script "x" skip y`
        if you load them in the opposite, we don't skip the lines currently, 
        this is something we may look at for the future.
    ]]

    LoadAssets()
    CurrentScene = NewTitleScene()


    local argIndex = 1
    while argIndex <= #arg do
        if arg[argIndex] == "script" then
            script_loaded = true
            CurrentScene = NewScene(arg[argIndex+1])
            CurrentScene:update(0)
        end
        if arg[argIndex] == "skip" then
            if script_loaded then
                for i=1, tonumber(arg[argIndex+1]) do
                    table.remove(CurrentScene.events, 1)
                    CurrentScene.currentEventIndex = CurrentScene.currentEventIndex + 1
                end
            end
            if script_loaded == false then
                LoadEpisode("scripts/episode1.meta")
                for i=1, tonumber(arg[argIndex+1]) do
                    table.remove(CurrentScene.events, 1)
                    CurrentScene.currentEventIndex = CurrentScene.currentEventIndex + 1
                end
            end
        end
        if arg[argIndex] == "debug" then
            controls.debug = true
        end
        argIndex = argIndex + 1
    end
end

function LoadEpisode(episodePath)
    -- set up the current scene
    Episode = {}
    
    for line in love.filesystem.lines(episodePath) do
        table.insert(Episode, line)
    end
    SceneIndex = 0
    NextScene()
end

function NextScene()
    SceneIndex = SceneIndex + 1

    for i,v in pairs(Music) do
        v:stop()
    end
    
    if SceneIndex <= #Episode then
        CurrentScene = NewScene(Episode[SceneIndex])
        CurrentScene:update(0)
        DtReset = true
    else
        love.event.push("quit")
    end
end

-- love.update and love.draw get called 60 times per second
-- transfer the update and draw over to the current game scene 
function love.update(dt)
    if DtReset then
        dt = 1/60
        DtReset = false
    end

    ScreenShake = math.max(ScreenShake - dt, 0)
    if not game_paused then
        CurrentScene:update(dt)
    end
end

function love.keypressed(key)
    -- If the scene has been loaded and the pause button was pressed,
    -- show the pause menu
    if key == controls.pause and CurrentScene.sceneScript ~= nil then
        NavigationIndex = CurrentScene.currentEventIndex
        game_paused = not game_paused
    -- If the game is already paused, let the user interact with the
    -- pause menu
    elseif game_paused then
        -- Let the user navigate
        if key == controls.pause_nav_up and NavigationIndex > 1 then
            NavigationIndex = NavigationIndex - 1
        elseif key == controls.pause_nav_down and NavigationIndex < #CurrentScene.sceneScript then
            NavigationIndex = NavigationIndex + 1
        elseif key == controls.pause_confirm then
            -- TODO: Implement some sort of navigation tool
        end
    end
end
    

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas(Renderable)
    love.graphics.clear(0,0,0)
    CurrentScene:draw()
    love.graphics.setCanvas()

    local dx,dy = 0,0
    if ScreenShake > 0 then
        dx = love.math.random()*choose{1,-1}*2
        dy = love.math.random()*choose{1,-1}*2
    end
    love.graphics.setColor(1,1,1)

    love.graphics.draw(
        Renderable, 
        dx*love.graphics.getWidth()/GraphicsWidth,
        dy*love.graphics.getHeight()/GraphicsHeight,
        0, 
        love.graphics.getWidth()/GraphicsWidth,
        love.graphics.getHeight()/GraphicsHeight
    )

    -- Added pause, additional cleaner graphics can be added in the future
    if game_paused then
        DrawPauseScreen()
    end
end
