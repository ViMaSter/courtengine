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
                print(queuedSpeak[1], lineParts[1])
                table.insert(events, NewSpeakEvent(queuedSpeak[1], lineParts[1]))
                queuedSpeak = nil
            else
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    table.insert(events, NewCharInitEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    table.insert(events, NewCharLocationEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CUTTO" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
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

    for i=1, #line do
        local thisChar = string.sub(line, i,i)

        if not isComment then
            if not inDialogue then
                if thisChar == " " then
                    table.insert(words, string.sub(line, wordStart, i-1))
                    wordStart = i+1
                end

                if thisChar == '"' then
                    inDialogue = true
                    wordStart = i+1
                end

                if i < #line 
                and string.sub(line,i,i) == "/" 
                and string.sub(line,i+1,i+1) == "/" then
                    isComment = true
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
            NORMAL = love.graphics.newImage(self.location.."/normal.png"),
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
        scene.characterLocations[self.location] = self.name

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

    self.update = function (self, scene, dt)
        self.textScroll = math.min(self.textScroll + dt*20, #self.text)
        scene.text = string.sub(self.text, 1, math.floor(self.textScroll))

        if love.keyboard.isDown("x") and self.textScroll >= #self.text then
            return false
        end

        return true
    end

    return self
end
