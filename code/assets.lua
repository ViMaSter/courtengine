--[[

Automatic Asset Import To-Do List:
✓ Auto import backgrounds
✓ Auto import music
- Auto import sprites
- Auto import shouts
- Auto import sfx
- Set up scripts to accept custom backgrounds
- Set up scripts to accept custom music
- Set up scripts to accept custom sprites
✓ Set up scripts to accept custom shouts
- Set up scripts to accept custom sfx

--]]

function LoadBackgrounds()
    Backgrounds = {
        NONE = {},
        BLACK_SCREEN = {love.graphics.newImage("backgrounds/base/blackscreen.png")},
        LOBBY = {love.graphics.newImage("backgrounds/base/lobby.png")},
        COURT_DEFENSE = {love.graphics.newImage("backgrounds/base/defenseempty.png"), love.graphics.newImage("backgrounds/base/defensedesk.png")},
        COURT_PROSECUTION = {love.graphics.newImage("backgrounds/base/prosecutorempty.png"), love.graphics.newImage("backgrounds/base/prosecutiondesk.png")},
        COURT_JUDGE = {love.graphics.newImage("backgrounds/base/judgestand.png")},
        COURT_WITNESS = {love.graphics.newImage("backgrounds/base/witnessempty.png"), love.graphics.newImage("backgrounds/base/stand.png")},
        COURT_ASSISTANT = {love.graphics.newImage("backgrounds/base/helperstand.png")},
    }

    files = love.filesystem.getDirectoryItems("backgrounds/")

    for b, i in ipairs(files) do
        if string.match(i,".png") then
            local a = i:gsub(".png","")
            Backgrounds[a] = {love.graphics.newImage("backgrounds/"..i)}
        end
    end
end

function LoadMusic()
    Music = {}

    files = love.filesystem.getDirectoryItems("music/")

    for b, i in ipairs(files) do
        if string.match(i,".mp3") then
            print(i)
            local a = i:gsub(".mp3",""):upper()
            print(a)
            Music[a] = love.audio.newSource("music/"..i, "static")
        elseif string.match(i,".wav") then
            print(i)
            local a = i:gsub(".wav",""):upper()
            print(a)
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
    WideShotSprite = love.graphics.newImage("backgrounds/base/wideshot.png")
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
    objection = love.graphics.newImage("sprites/shouts/objection.png")
    holdit = love.graphics.newImage("sprites/shouts/holdit.png")
    holdit = love.graphics.newImage("sprites/shouts/takethat.png")
end

function LoadSFX()
    Sounds = {
        MUTTER = love.audio.newSource("sounds/sfx-gallery.wav", "static"),
        GAVEL = love.audio.newSource("sounds/sfx-gavel.wav", "static"),
        MALETALK = love.audio.newSource("sounds/sfx-blipmale.wav", "static"),
        FEMALETALK = love.audio.newSource("sounds/sfx-blipfemale.wav", "static"),
        TYPEWRITER = love.audio.newSource("sounds/sfx-typewriter.wav", "static"),
    }

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
