--[[

Automatic Asset Import To-Do List:
✓ Auto import backgrounds
✓ Auto import music
- Auto import sprites
✓ Auto import shouts
✓ Auto import sfx
✓ Set up scripts to accept custom backgrounds
- Set up scripts to accept custom music
- Set up scripts to accept custom sprites
✓ Set up scripts to accept custom shouts
- Set up scripts to accept custom sfx
✓ Set up backgrounds to support layered imports (through numbered filenames)

--]]

function LoadBackgrounds()
    Backgrounds = {
        NONE = {},
    }

    files = love.filesystem.getDirectoryItems("backgrounds/")

    for b, i in ipairs(files) do
        print(i)
        if string.match(i,".png") then
            if string.match(i,"_1") then
                local a = i:gsub(".png","")
                local a = a:gsub("_1","")
                print("1 "..a)
                Backgrounds[a] = {love.graphics.newImage("backgrounds/"..i)}
            elseif string.match(i,"_2") then
                local a = i:gsub(".png","")
                local a = a:gsub("_2","")
                print("2 "..a)
                table.insert(Backgrounds[a],love.graphics.newImage("backgrounds/"..i))
            else
                local a = i:gsub(".png","")
                print("Clean "..a)
                Backgrounds[a] = {love.graphics.newImage("backgrounds/"..i)}
            end
        end
    end
end

function LoadMusic()
    Music = {}

    files = love.filesystem.getDirectoryItems("music/")

    for b, i in ipairs(files) do
        if string.match(i,".mp3") then
            local a = i:gsub(".mp3",""):upper()
            Music[a] = love.audio.newSource("music/"..i, "static")
        elseif string.match(i,".wav") then
            local a = i:gsub(".wav",""):upper()
            Music[a] = love.audio.newSource("music/"..i, "static")
        end
    end

    for i,v in pairs(Music) do
        v:setLooping(true)
        v:setVolume(MasterVolume)
    end
end

function LoadSprites()
    TextBoxSprite = love.graphics.newImage("sprites/chatbox.png")
    AnonTextBoxSprite = love.graphics.newImage("sprites/chatbox_headless.png")
    CrossExaminationSprite = love.graphics.newImage("sprites/cross_examination.png")
    WideShotSprite = love.graphics.newImage("backgrounds/wideshot.png")
    PenaltySprite = love.graphics.newImage("sprites/exclamation.png")

    GavelAnimation = {
        love.graphics.newImage("sprites/gavel1.png"),
        love.graphics.newImage("sprites/gavel2.png"),
        love.graphics.newImage("sprites/gavel3.png"),
    }
    TalkingHeadAnimation = {
        love.graphics.newImage("sprites/talkingheads1.png"),
        love.graphics.newImage("sprites/talkingheads2.png"),
        love.graphics.newImage("sprites/talkingheads3.png"),
        love.graphics.newImage("sprites/talkingheads2.png"),
    }
end

function LoadShouts()
    Shouts = {}

    files = love.filesystem.getDirectoryItems("sprites/shouts/")

    for b, i in ipairs(files) do
        if string.match(i,".png") then
            local a = i:gsub(".png","")
            Shouts[a] = love.graphics.newImage("sprites/shouts/"..i)
        end
    end
end

function LoadSFX()
    Sounds = {}

    files = love.filesystem.getDirectoryItems("sounds/")

    for b, i in ipairs(files) do
        if string.match(i,".mp3") then
            local a = i:gsub(".mp3",""):upper()
            Sounds[a] = love.audio.newSource("sounds/"..i, "static")
        elseif string.match(i,".wav") then
            local a = i:gsub(".wav",""):upper()
            Sounds[a] = love.audio.newSource("sounds/"..i, "static")
        end
    end

    for i,v in pairs(Sounds) do
        v:setVolume(MasterVolume/2)
    end
end

function LoadMisc()
    GameFont = love.graphics.newImageFont("sprites/FontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():,-'*" .. '`"', 2)
    SmallFont = love.graphics.newImageFont("sprites/SmallFontImage.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?~():", 1)
    love.graphics.setFont(GameFont)
end

function LoadAssets()
    LoadBackgrounds()
    LoadMusic()
    LoadSprites()
    LoadShouts()
    LoadSFX()
    LoadMisc()
end
