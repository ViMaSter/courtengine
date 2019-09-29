require "config" -- controls text file
require "code/events/index"
require "code/utils/index"
require "code/screens/index"
require "code/assets"
require "code/courtscene"
require "code/scriptloader"

function love.load(arg)
    InitGlobalConfigVariables()
    love.window.setMode(WindowWidth, WindowHeight, {})
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")
    Renderable = love.graphics.newCanvas(GraphicsWidth, GraphicsHeight)
    ScreenShake = 0
    DtReset = false -- so scene load times don't factor into dt

    LoadAssets()
    LoadEpisode(settings.episode_path)

    local arguments = {}
    local argIndex = 1
    -- First pass through the arguments to see what we're requesting
    while argIndex <= #arg do
        if arg[argIndex] == "debug" then
            arguments.debug = true
            argIndex = argIndex + 1
        else
            arguments[arg[argIndex]] = arg[argIndex + 1]
            argIndex = argIndex + 2
        end
    end

    -- Initialize the game based on our arguments
    if arguments.debug then
        controls.debug = arguments.debug
    end

    if arguments.script ~= nil then
        CurrentScene = NewScene(arguments.script)
        CurrentScene:update(0)
    else
        -- Select the first scene in the loaded episode
        CurrentScene = NewScene(Episode[1])
    end

    if arguments.skip ~= nil then
        for i=1, tonumber(arguments.skip) do
            table.remove(CurrentScene.events, 1)
            CurrentScene.currentEventIndex = CurrentScene.currentEventIndex + 1
        end
    else
        -- Title screen will take the player to the next scene on keypress
        screens.title.displayed = true
    end

end

function LoadEpisode(episodePath)
    Episode = {}
    for line in love.filesystem.lines(episodePath) do
        table.insert(Episode, line)
    end
end

function BeginEpisode()
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
    -- TODO: Decide if this applies to all screens that can be displayed
    if not screens.title.displayed and not screens.pause.displayed then
        CurrentScene:update(dt)
    end
end

function love.keypressed(key)
    for screenName, screenConfig in pairs(screens) do
        if screenConfig.displayKey and key == screenConfig.displayKey and
            (screenConfig.displayCondition == nil or screenConfig.displayCondition()) then
            screenConfig.displayed = not screenConfig.displayed
        elseif screenConfig.keyhandler then
            screenConfig.keyhandler(key)
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

    for screenName, screenConfig in pairs(screens) do
        if screenConfig.displayed then
            screenConfig.drawScreen()
        end
    end
end
