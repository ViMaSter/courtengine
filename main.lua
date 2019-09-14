require "courtscene"
require "scriptloader"

function love.load()
    love.window.setMode(GraphicsWidth()*4, GraphicsHeight()*4, {})
    love.graphics.setDefaultFilter("nearest")
    Renderable = love.graphics.newCanvas(GraphicsWidth(), GraphicsHeight())
    GameFont = love.graphics.newFont("Ace-Attorney.ttf", 16)
    love.graphics.setFont(GameFont)

    Backgrounds = {
        COURT_DEFENSE = {love.graphics.newImage("backgrounds/defenseempty.png"), love.graphics.newImage("backgrounds/defensedesk.png")},
        COURT_PROSECUTION = {love.graphics.newImage("backgrounds/prosecutorempty.png"), love.graphics.newImage("backgrounds/prosecutiondesk.png")},
        COURT_JUDGE = {love.graphics.newImage("backgrounds/judgestand.png")},
    }

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
