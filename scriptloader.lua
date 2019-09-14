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
                if lineParts[1] == "EVIDENCE_INITIALIZE" then
                    table.insert(events, NewEvidenceInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5]))
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
                if lineParts[1] == "PLAY_MUSIC" then
                    table.insert(events, NewPlayMusicEvent(lineParts[2]))
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
                    end
                    wordStart = i+1
                    wasWord = false
                    wordCharacter = false
                end

                -- handle quotation marks, they denote dialogue
                -- they also act as one whole word
                if thisChar == '"' then
                    inDialogue = true
                    wordStart = i+1
                    wordCharacter = false
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

function NewEvidenceInitEvent(name, externalName, info, file)
    local self = {}
    self.name = name
    self.externalName = name
    self.info = info
    self.file = file
    print("name " .. name)
    print("externalName " .. externalName)
    print("info " .. info)
    print("file " .. file)

    self.update = function (self, scene, dt)
        scene.evidence[self.name] = {
            externalName = self.externalName,
            info = self.info,
            sprite = love.graphics.newImage(self.file),
        }

        return false
    end

    return self
end
