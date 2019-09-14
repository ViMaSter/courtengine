require "courtscene"
require "scriptloader"

function love.load()
    love.window.setMode(GraphicsWidth()*4, GraphicsHeight()*4, {})
    love.graphics.setDefaultFilter("nearest")
    Renderable = love.graphics.newCanvas(GraphicsWidth(), GraphicsHeight())
    GameFont = love.graphics.newFont("Ace-Attorney.ttf", 16)
    --love.graphics.setFont(GameFont)

    Backgrounds = {
        COURT_DEFENSE = {love.graphics.newImage("backgrounds/defenseempty.png"), love.graphics.newImage("backgrounds/defensedesk.png")},
        COURT_PROSECUTION = {love.graphics.newImage("backgrounds/prosecutorempty.png"), love.graphics.newImage("backgrounds/prosecutiondesk.png")},
        COURT_JUDGE = {love.graphics.newImage("backgrounds/judgestand.png")},
    }
    TextBox = love.graphics.newImage("sprites/chatbox.png")
    ObjectionSprite = love.graphics.newImage("sprites/objection.png")

    CurrentScene = NewCourtScene("test.script")
end

function GraphicsWidth()
    return 256
end
function GraphicsHeight()
    return 192
end

function love.update(dt)
    CurrentScene:update(dt)
end

function love.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas(Renderable)
    love.graphics.clear(1,1,1)
    CurrentScene:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(1,1,1)
    love.graphics.draw(Renderable, 0,0, 0, love.graphics.getWidth()/GraphicsWidth(), love.graphics.getHeight()/GraphicsHeight())
end

-- utility functions 

function Clamp(n,min,max)
    return math.max(math.min(n,max), min)
end
function choose(arr)
    return arr[math.floor(love.math.random()*(#arr))+1]
end
function rand(min,max, interval)
    local interval = interval or 1
    local c = {}
    local index = 1
    for i=min, max, interval do
        c[index] = i
        index = index + 1
    end

    return choose(c)
end

function GetSign(n)
    if n > 0 then
        return 1
    end
    if n < 0 then
        return -1
    end
    return 0
end
function Lerp(a,b,t) return (1-t)*a + t*b end
function DeltaLerp(a,b,t, dt)
    return Lerp(a,b, 1 - t^(dt))
end


