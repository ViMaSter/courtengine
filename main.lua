require "courtscene"
require "scriptloader"
require "scriptevents"

function love.load()
    love.window.setMode(GraphicsWidth()*4, GraphicsHeight()*4, {})
    love.graphics.setDefaultFilter("nearest")
    Renderable = love.graphics.newCanvas(GraphicsWidth(), GraphicsHeight())
    GameFont = love.graphics.newFont("Ace-Attorney.ttf", 16)
    MasterVolume = 0.25
    TextScrollSpeed = 30
    --love.graphics.setFont(GameFont)

    Backgrounds = {
        COURT_DEFENSE = {love.graphics.newImage("backgrounds/defenseempty.png"), love.graphics.newImage("backgrounds/defensedesk.png")},
        COURT_PROSECUTION = {love.graphics.newImage("backgrounds/prosecutorempty.png"), love.graphics.newImage("backgrounds/prosecutiondesk.png")},
        COURT_JUDGE = {love.graphics.newImage("backgrounds/judgestand.png")},
        COURT_WITNESS = {love.graphics.newImage("backgrounds/witnessempty.png"), love.graphics.newImage("backgrounds/stand.png")},
        COURT_ASSISTANT = {love.graphics.newImage("backgrounds/helperstand.png")},
    }

    Music = {
        TRIAL = love.audio.newSource("music/trial.mp3", "static"),
        OBJECTION = love.audio.newSource("music/objection.mp3", "static"),
        SUSPENCE = love.audio.newSource("music/suspence.mp3", "static"),
        QUESTIONING_ALLEGRO = love.audio.newSource("music/questioning_allegro.mp3", "static"),
        QUESTIONING = love.audio.newSource("music/questioning.mp3", "static"),
        PRELUDE = love.audio.newSource("music/prelude.mp3", "static"),
        LOGIC_AND_TRICK = love.audio.newSource("music/logic_and_trick.mp3", "static"),
    }

    for i,v in pairs(Music) do
        v:setLooping(true)
        v:setVolume(MasterVolume)
    end
    
    TextBox = love.graphics.newImage("sprites/chatbox.png")
    ObjectionSprite = love.graphics.newImage("sprites/objection.png")
    HoldItSprite = love.graphics.newImage("sprites/holdit.png")
    CrossExaminationSprite = love.graphics.newImage("sprites/cross_examination.png")

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

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
