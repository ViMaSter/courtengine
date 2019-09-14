function LoadScript(scriptPath)
    local script = io.open(scriptPath)
    local events = {}

    local queuedSpeak = nil

    local canRead = true
    while canRead do
        local line = script:read("*l")

        if line == nil then
            canRead = false
        else
            local lineParts = DisectLine(line)

            if queuedSpeak ~= nil then
                --print(queuedSpeak[1], lineParts[1])
                table.insert(events, NewSpeakEvent(queuedSpeak[1], lineParts[1]))
                queuedSpeak = nil
            else
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    table.insert(events, NewCharInitEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    table.insert(events, NewCharLocationEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "JUMPCUT" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                end
                if lineParts[1] == "POSE" then
                    table.insert(events, NewPoseEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "OBJECTION" then
                    table.insert(events, NewObjectionEvent(lineParts[2]))
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2]}
                end
            end
        end
    end

    return events
end

function DisectLine(line)
    local words = {}
    local wordStart = 1
    local inDialogue = false
    local isComment = false
    local wasWord = false

    for i=1, #line do
        local thisChar = string.sub(line, i,i)

        if not isComment then
            if not inDialogue then
                local wordCharacter = true

                -- spaces determine where words stop
                -- but only advance to the next word if there was a word there to begin with
                -- this allows for indentation
                if thisChar == " " then
                    if wasWord then
                        table.insert(words, string.sub(line, wordStart, i-1))
                        wordStart = i+1
                    end
                    wasWord = false
                    wordCharacter = false
                end

                -- handle quotation marks, they denote dialogue
                -- they also act as one whole word
                if thisChar == '"' then
                    inDialogue = true
                    wordStart = i+1
                end

                -- double slash is a comment, so disregard this line
                if i < #line 
                and string.sub(line,i,i) == "/" 
                and string.sub(line,i+1,i+1) == "/" then
                    isComment = true
                    wordCharacter = false
                end

                if wordCharacter then
                    wasWord = true
                end
            else
                -- treat what is in "" as one big word
                if thisChar == '"' then
                    inDialogue = false
                    table.insert(words, string.sub(line, wordStart, i-1))
                    wordStart = i+1
                end
            end
        end

        if i == #line then
            table.insert(words, string.sub(line, wordStart, i))
        end
    end

    return words
end

function NewCharInitEvent(name, location)
    local self = {}
    self.name = name
    self.location = location

    self.update = function (self, scene, dt)
        scene.characters[self.name] = {
            poses = {
                NORMAL = love.graphics.newImage(self.location.."/normal.png"),
                POINT = love.graphics.newImage(self.location.."/point.png"),
            },

            name = self.name,
            frame = "NORMAL",
        }

        return false
    end

    return self
end

function NewCharLocationEvent(name, location)
    local self = {}
    self.name = name
    self.location = location

    self.update = function (self, scene, dt)
        scene.characterLocations[self.location] = scene.characters[self.name]

        return false
    end

    return self
end

function NewPoseEvent(name, pose)
    local self = {}
    self.name = name
    self.pose = pose

    self.update = function (self, scene, dt)
        scene.characters[self.name].frame = self.pose

        return false
    end

    return self
end

function NewCutToEvent(cutTo)
    local self = {}
    self.cutTo = cutTo

    self.update = function (self, scene, dt)
        scene.location = self.cutTo
        return false
    end

    return self
end

function NewSpeakEvent(who, text)
    local self = {}
    self.text = text
    self.textScroll = 1
    self.wasPressing = true

    self.update = function (self, scene, dt)
        self.textScroll = math.min(self.textScroll + dt*20, #self.text)
        scene.text = string.sub(self.text, 1, math.floor(self.textScroll))

        local pressing = love.keyboard.isDown("x")
        if pressing and not self.wasPressing and self.textScroll >= #self.text then
            return false
        end
        self.wasPressing = pressing

        return true
    end

    return self
end

function NewObjectionEvent(who)
    local self = {}
    self.timer = 0
    self.x,self.y = 0,0

    self.update = function (self, scene, dt)
        scene.textHidden = true
        self.timer = self.timer + dt
        self.x = self.x + love.math.random()*choose{1,-1}*2
        self.y = self.y + love.math.random()*choose{1,-1}*2

        return self.timer < 0.5
    end

    self.draw = function (self, scene)
        love.graphics.draw(ObjectionSprite, self.x,self.y)
    end

    return self
end
