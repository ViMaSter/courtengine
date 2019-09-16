function LoadScript(scene, scriptPath)
    scene.events = {}
    scene.definitions = {}
    scene.type = ""

    local events = scene.events
    local definitions = {}

    local queuedSpeak = nil
    local queuedTypewriter = nil
    local crossExaminationQueue = nil
    local choiceQueue = nil
    local invMenuQueue = nil
    local evidenceAddQueue = nil

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

            if choiceQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_CHOICE" then
                    for i=1, #lineParts do
                        table.insert(choiceQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewChoiceEvent(choiceQueue))
                    choiceQueue = nil
                end

                canExecuteLine = false
            end

            if invMenuQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_INVESTIGATION_MENU" then
                    for i=1, #lineParts do
                        table.insert(invMenuQueue, lineParts[i])
                    end
                else
                    table.insert(events, NewInvestigationMenuEvent(invMenuQueue))
                    invMenuQueue = nil
                end

                canExecuteLine = false
            end

            if canExecuteLine and queuedSpeak ~= nil then
                table.insert(events, NewSpeakEvent(queuedSpeak[1], lineParts[1], queuedSpeak[2]))
                queuedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedTypewriter ~= nil then
                table.insert(events, NewTypeWriterEvent(lineParts[1]))
                queuedTypewriter = nil

                canExecuteLine = false
            end

            if canExecuteLine and evidenceAddQueue ~= nil then
                table.insert(events, NewAddToCourtRecordAnimationEvent(lineParts[1], evidenceAddQueue[1]))
                evidenceAddQueue = nil

                canExecuteLine = false
            end

            if canExecuteLine then
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    table.insert(events, NewCharInitEvent(lineParts[2], lineParts[3]))
                end
                if lineParts[1] == "CHARACTER_INITIALIZE_POSE" then
                    table.insert(events, NewCharPoseInitEvent(lineParts[2], lineParts[3]))
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

                if lineParts[1] == "SET_SCENE_TYPE" then
                    scene.type = lineParts[2]
                end
                if lineParts[1] == "END_SCENE" then
                    table.insert(events, NewSceneEndEvent())
                end

                if lineParts[1] == "DEFINE" then
                    scene.definitions[lineParts[2]] = {}
                    events = scene.definitions[lineParts[2]]
                end
                if lineParts[1] == "END_DEFINE" then
                    events = scene.events
                end
                if lineParts[1] == "JUMP" then
                    table.insert(events, NewClearExecuteDefinitionEvent(lineParts[2]))
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
                if lineParts[1] == "STOP_MUSIC" then
                    table.insert(events, NewStopMusicEvent())
                end
                if lineParts[1] == "ISSUE_PENALTY" then
                    table.insert(events, NewIssuePenaltyEvent())
                end
                if lineParts[1] == "GAME_OVER" then
                    table.insert(events, NewGameOverEvent())
                end

                if lineParts[1] == "OBJECTION" then
                    table.insert(events, NewObjectionEvent(lineParts[2]))
                end
                if lineParts[1] == "HOLD_IT" then
                    table.insert(events, NewHoldItEvent(lineParts[2]))
                end
                if lineParts[1] == "WIDESHOT" then
                    table.insert(events, NewWideShotEvent())
                end
                if lineParts[1] == "GAVEL" then
                    table.insert(events, NewGavelEvent())
                end
                if lineParts[1] == "FADE_TO_BLACK" then
                    table.insert(events, NewFadeToBlackEvent())
                end

                if lineParts[1] == "CROSS_EXAMINATION" then
                    crossExaminationQueue = {lineParts[2], lineParts[3], lineParts[4]}
                end
                if lineParts[1] == "CHOICE" then
                    choiceQueue = {}
                end
                if lineParts[1] == "INVESTIGATION_MENU" then
                    invMenuQueue = {}
                end
                if lineParts[1] == "EXAMINE" then
                    table.insert(events, NewExamineEvent())
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2], "literal"}
                end
                if lineParts[1] == "SPEAK_FROM" then
                    table.insert(events, NewCutToEvent(lineParts[2]))
                    queuedSpeak = {lineParts[2], "location"}
                end
                if lineParts[1] == "TYPEWRITER" then
                    queuedTypewriter = {}
                end
                if lineParts[1] == "COURT_RECORD_ADD_ANIMATION" then
                    evidenceAddQueue = {lineParts[2]}
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
                Normal = love.graphics.newImage(self.location.."/Normal.png"),
            },

            location = self.location,
            wideshot = love.graphics.newImage(self.location .. "/wideshot.png"),
            name = self.name,
            frame = "Normal",
        }

        return false
    end

    return self
end

function NewCharPoseInitEvent(name, pose)
    local self = {}
    self.name = name
    self.pose = pose

    self.update = function(self, scene, dt)
        local location = scene.characters[self.name].location
        scene.characters[self.name].poses[self.pose] = love.graphics.newImage(location .. "/" .. self.pose .. ".png")

        for i,v in pairs(scene.characters[self.name].poses) do
        end

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
