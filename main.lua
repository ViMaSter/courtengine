require "config" -- controls text file
require "code/events/index"
require "code/utils/index"
require "code/screens/index"
require "code/assets"
require "code/episode"
require "code/scene"
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
    Episode = NewEpisode(settings.episode_path)

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
        CurrentScene = NewScene(Episode.scenes[1])
    end

    if arguments.skip ~= nil then
        for i=1, tonumber(arguments.skip) do
            table.remove(CurrentScene.events, 1)
            CurrentScene.currentEventIndex = CurrentScene.currentEventIndex + 1
        end
    elseif arguments.script == nil then
        -- Title screen will take the player to the next scene on keypress
        screens.title.displayed = true
    end

end

-- love.update and love.draw get called 60 times per second
-- transfer the update and draw over to the current game scene 
function love.update(dt)
    if DtReset then
        dt = 1/60
        DtReset = false
    end

    Episode:update(dt)
end

function love.keypressed(key)
    for screenName, screenConfig in pairs(screens) do
        if screenConfig.displayKey and key == screenConfig.displayKey and
            (screenConfig.displayCondition == nil or screenConfig.displayCondition()) then
            screenConfig.displayed = not screenConfig.displayed
            if screenConfig.displayed and screenConfig.onDisplay then
                screenConfig.onDisplay()
            end
        elseif screenConfig.displayed and screenConfig.onKeyPressed then
            screenConfig.onKeyPressed(key)
        end
    end
end

function love.draw()
    love.graphics.setColor(unpack(colors.white))
    love.graphics.setCanvas(Renderable)
    love.graphics.clear(unpack(colors.black))
    CurrentScene:draw()
    love.graphics.setCanvas()

    local dx,dy = 0,0
    if ScreenShake > 0 then
        dx = love.math.random()*choose{1,-1}*2
        dy = love.math.random()*choose{1,-1}*2
    end
    love.graphics.setColor(unpack(colors.white))

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
            screenConfig.draw()
        end
    end
end
