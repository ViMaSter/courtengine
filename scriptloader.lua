function LoadScript(scene, scriptPath)
    scene.events = {}
    scene.definitions = {}

    local events = scene.events
    local definitions = {}

    local queuedSpeak = nil
    local crossExaminationQueue = nil

    for line in love.filesystem.lines(scriptPath) do

        if line == nil then
            canRead = false
        else
            local lineParts = DisectLine(line)
            local canExecuteLine = true

            if crossExaminationQueue ~= nil then
                if #lineParts > 0 then
                    for i=1, #lineParts do
                        table.insert(crossExaminationQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewCrossExaminationEvent(crossExaminationQueue))
                    crossExaminationQueue = nil
                end

                canExecuteLine = false
            end

            if canExecuteLine and queuedSpeak ~= nil then
                table.insert(events, NewSpeakEvent(queuedSpeak[1], lineParts[1], queuedSpeak[2]))
                queuedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine then
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    table.insert(events, NewCharInitEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    table.insert(events, NewCharLocationEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "EVIDENCE_INITIALIZE" then
                    table.insert(events, NewEvidenceInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5]))
                end
                if lineParts[1] == "COURT_RECORD_ADD" then
                    table.insert(events, NewCourtRecordAddEvent(lineParts[2]))
                end

                if lineParts[1] == "DEFINE" then
                    scene.definitions[lineParts[2]] = {}
                    events = scene.definitions[lineParts[2]]
                end
                if lineParts[1] == "END_DEFINE" then
                    events = scene.events
                end
                if lineParts[1] == "@" then
                    table.insert(events, NewExecuteDefinitionEvent(lineParts[2]))
                end

                if lineParts[1] == "JUMPCUT" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                end
                if lineParts[1] == "POSE" then
                    table.insert(events, NewPoseEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "PLAY_MUSIC" then
                    table.insert(events, NewPlayMusicEvent(lineParts[2]))
                end
                if lineParts[1] == "ISSUE_PENALTY" then
                    table.insert(events, NewIssuePenaltyEvent())
                end

                if lineParts[1] == "OBJECTION" then
                    table.insert(events, NewObjectionEvent(lineParts[2]))
                end
                if lineParts[1] == "HOLD_IT" then
                    table.insert(events, NewHoldItEvent(lineParts[2]))
                end

                if lineParts[1] == "CROSS_EXAMINATION" then
                    crossExaminationQueue = {lineParts[2], lineParts[3], lineParts[4]}
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2], "literal"}
                end
                if lineParts[1] == "SPEAK_FROM" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                    queuedSpeak = {lineParts[2], "location"}
                end
            end
        end
    end
end

function DisectLine(line)
    local words = {}
    local isDialogue = false
    local isComment = false
    local wordBuild = ""

    for i=1, #line do
        local thisChar = string.sub(line, i,i)
        local thisDoubleChar = string.sub(line, i,i+1)
        local canAddToWord = true

        if thisDoubleChar == "//" then
            isComment = true
        end

        if isComment then
            canAddToWord = false
        end

        if canAddToWord 
        and thisChar == "@"
        and not isDialogue then
            canAddToWord = false

            table.insert(words, "@")
        end

        if canAddToWord and thisChar == '"' then
            canAddToWord = false

            if isDialogue then
                table.insert(words, wordBuild)
                wordBuild = ""
            end

            isDialogue = not isDialogue
        end

        if canAddToWord and not isDialogue and thisChar == " " then
            canAddToWord = false

            if #wordBuild > 0 then
                table.insert(words, wordBuild)
                wordBuild = ""
            end
        end

        if canAddToWord then
            wordBuild = wordBuild .. thisChar
        end
    end

    if #wordBuild > 0 then
        table.insert(words, wordBuild)
        wordBuild = ""
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
    self.externalName = externalName
    self.info = info
    self.file = file

    self.update = function (self, scene, dt)
        scene.evidence[self.name] = {
            name = self.name,
            externalName = self.externalName,
            info = self.info,
            sprite = love.graphics.newImage(self.file),
        }

        return false
    end

    return self
end
