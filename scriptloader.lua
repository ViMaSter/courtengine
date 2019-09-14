function LoadScript(scriptPath)
    local script = io.open(scriptPath)
    local events = {}

    local canRead = true
    while canRead do
        local line = script:read("*l")

        if line == nil then
            canRead = false
        else
            local lineParts = DisectLine(line)

            for i=1, #lineParts do
                if lineParts[i] == "SPEAK" then
                    table.insert(events, NewSpeakEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[i] == "CUTTO" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
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

    for i=1, #line do
        local thisChar = string.sub(line, i,i)

        if not inDialogue then
            if thisChar == " " then
                table.insert(words, string.sub(line, wordStart, i-1))
                wordStart = i+1
            end

            if thisChar == '"' then
                inDialogue = true
                wordStart = i+1
            end
        else
            if thisChar == '"' then
                inDialogue = false
                table.insert(words, string.sub(line, wordStart, i-1))
                wordStart = i+1
            end
        end

        if i == #line then
            table.insert(words, string.sub(line, wordStart, i))
        end
    end

    return words
end

function NewCutToEvent(cutTo)
    local self = {}
    self.cutTo = cutTo

    self.update = function (self, scene, dt)
        scene.background = Backgrounds[self.cutTo]
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
