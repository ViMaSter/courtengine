function LoadScript(scene, scriptPath)
    scene.events = {}
    scene.sceneScript = {}
    scene.definitions = {}
    scene.type = ""

    local events = scene.events
    local sceneScript = scene.sceneScript
    local definitions = {}

    local queuedSpeak = nil
    local queuedThink = nil
    local queuedTypewriter = nil
    local crossExaminationQueue = nil
    local choiceQueue = nil
    local fakeChoiceQueue = nil
    local invMenuQueue = nil
    local evidenceAddQueue = nil
    local examinationQueue = nil

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
                    AddToStack(events, sceneScript, NewCrossExaminationEvent(crossExaminationQueue), lineParts)
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
                    AddToStack(events, sceneScript, NewChoiceEvent(choiceQueue), lineParts)
                    choiceQueue = nil
                end

                canExecuteLine = false
            end

            if fakeChoiceQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_CHOICE" then
                    for i=1, #lineParts do
                        table.insert(fakeChoiceQueue, lineParts[i])
                    end
                else
                    AddToStack(events, sceneScript, NewFakeChoiceEvent(fakeChoiceQueue), lineParts)
                    fakeChoiceQueue = nil
                end

                canExecuteLine = false
            end

            if invMenuQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_INVESTIGATION_MENU" then
                    for i=1, #lineParts do
                        table.insert(invMenuQueue, lineParts[i])
                    end
                else
                    AddToStack(events, sceneScript, NewInvestigationMenuEvent(invMenuQueue), lineParts)
                    invMenuQueue = nil
                end

                canExecuteLine = false
            end

            if examinationQueue ~= nil and canExecuteLine then
                if #lineParts > 0 and lineParts[1] ~= "END_EXAMINATION" then
                    for i=1, #lineParts do
                        table.insert(examinationQueue, lineParts[i])
                    end
                else
                    AddToStack(events, sceneScript, NewExamineEvent(examinationQueue), lineParts)
                    examinationQueue = nil
                end

                canExecuteLine = false
            end

            if canExecuteLine and queuedSpeak ~= nil then
                AddToStack(events, sceneScript, NewSpeakEvent(queuedSpeak[1], lineParts[1], queuedSpeak[2], queuedSpeak[3]), {"queuedSpeak "..queuedSpeak[1], unpack(lineParts)})
                queuedSpeak = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedThink ~= nil then
                AddToStack(events, sceneScript, NewThinkEvent(queuedThink[1], lineParts[1], queuedThink[2], queuedThink[3]), {"queuedThink "..queuedThink[1], unpack(lineParts)})
                queuedThink = nil

                canExecuteLine = false
            end

            if canExecuteLine and queuedTypewriter ~= nil then
                AddToStack(events, sceneScript, NewTypeWriterEvent(lineParts[1]), {"queuedTypewriter", unpack(lineParts)})
                queuedTypewriter = nil

                canExecuteLine = false
            end

            if canExecuteLine and evidenceAddQueue ~= nil then
                AddToStack(events, sceneScript, NewAddToCourtRecordAnimationEvent(lineParts[1], evidenceAddQueue[1]), {"evidenceAddQueue "..evidenceAddQueue[1], unpack(lineParts)})
                evidenceAddQueue = nil

                canExecuteLine = false
            end

            if canExecuteLine then
                if lineParts[1] == "CHARACTER_INITIALIZE" then
                    AddToStack(events, sceneScript, NewCharInitEvent(lineParts[2], lineParts[3], lineParts[4]), lineParts)
                end
                if lineParts[1] == "CHARACTER_LOCATION" then
                    AddToStack(events, sceneScript, NewCharLocationEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "EVIDENCE_INITIALIZE" then
                    AddToStack(events, sceneScript, NewEvidenceInitEvent(lineParts[2], lineParts[3], lineParts[4], lineParts[5]), lineParts)
                end
                if lineParts[1] == "COURT_RECORD_ADD" then
                    AddToStack(events, sceneScript, NewCourtRecordAddEvent(lineParts[2]), lineParts)
                end

                if lineParts[1] == "SET_SCENE_TYPE" then
                    scene.type = lineParts[2]
                end
                if lineParts[1] == "END_SCENE" then
                    AddToStack(events, sceneScript, NewSceneEndEvent(), lineParts)
                end

                if lineParts[1] == "DEFINE" then
                    scene.definitions[lineParts[2]] = {}
                    events = scene.definitions[lineParts[2]]
                end
                if lineParts[1] == "END_DEFINE" then
                    events = scene.events
                end
                if lineParts[1] == "JUMP" then
                    AddToStack(events, sceneScript, NewClearExecuteDefinitionEvent(lineParts[2]), lineParts)
                end

                if lineParts[1] == "JUMPCUT" then
                    AddToStack(events, sceneScript, NewCutToEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "PAN" then
                    AddToStack(events, sceneScript, NewPanEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "POSE" then
                    AddToStack(events, sceneScript, NewPoseEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "WAIT" then
                    AddToStack(events, sceneScript, NewWaitEvent(lineParts[2]))
                end
                if lineParts[1] == "ANIMATION" then
                    if #lineParts == 4 then
                        AddToStack(events, sceneScript, NewAnimationEvent(lineParts[2], lineParts[3], lineParts[4]), lineParts)
                    else
                        AddToStack(events, sceneScript, NewAnimationEvent(lineParts[2], lineParts[3]), lineParts)
                    end
                end
                if lineParts[1] == "PLAY_MUSIC" then
                    AddToStack(events, sceneScript, NewPlayMusicEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "STOP_MUSIC" then
                    AddToStack(events, sceneScript, NewStopMusicEvent(), lineParts)
                end
                if lineParts[1] == "SFX" then
                    AddToStack(events, sceneScript, NewPlaySoundEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "ISSUE_PENALTY" then
                    AddToStack(events, sceneScript, NewIssuePenaltyEvent(), lineParts)
                end
                if lineParts[1] == "GAME_OVER" then
                    AddToStack(events, sceneScript, NewGameOverEvent(), lineParts)
                end

                if lineParts[1] == "SHOUT" then
                    AddToStack(events, sceneScript, NewShoutEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "WIDESHOT" then
                    AddToStack(events, sceneScript, NewWideShotEvent(), lineParts)
                end
                if lineParts[1] == "GAVEL" then
                    AddToStack(events, sceneScript, NewGavelEvent(), lineParts)
                end
                if lineParts[1] == "FADE_TO_BLACK" then
                    AddToStack(events, sceneScript, NewFadeToBlackEvent(), lineParts)
                end
                if lineParts[1] == "SCREEN_SHAKE" then
                    AddToStack(events, sceneScript, NewScreenShakeEvent(), lineParts)
                end

                if lineParts[1] == "CROSS_EXAMINATION" then
                    crossExaminationQueue = {lineParts[2], lineParts[3], lineParts[4]}
                end
                if lineParts[1] == "CHOICE" then
                    choiceQueue = {}
                end
                if lineParts[1] == "FAKE_CHOICE" then
                    fakeChoiceQueue = {}
                end
                if lineParts[1] == "INVESTIGATION_MENU" then
                    invMenuQueue = {}
                end
                if lineParts[1] == "EXAMINE" then
                    examinationQueue = {}
                end

                if lineParts[1] == "SET_FLAG" then
                    AddToStack(events, sceneScript, NewSetFlagEvent(lineParts[2], lineParts[3]), lineParts)
                end
                if lineParts[1] == "IF"
                and lineParts[3] == "IS"
                and lineParts[5] == "THEN" then
                    AddToStack(events, sceneScript, NewIfEvent(lineParts[2], lineParts[4], lineParts[6]), lineParts)
                end

                if lineParts[1] == "SPEAK" then
                    queuedSpeak = {lineParts[2], "literal", lineParts[3]}
                end
                if lineParts[1] == "THINK" then
                    queuedThink = {lineParts[2], "literal", nil}
                end
                if lineParts[1] == "SPEAK_FROM" then
                    AddToStack(events, sceneScript, NewCutToEvent(lineParts[2]), {"SPEAK_FROM", unpack(lineParts)})
                    queuedSpeak = {lineParts[2], "location", lineParts[3]}
                end
                if lineParts[1] == "THINK_FROM" then
                    AddToStack(events, sceneScript, NewCutToEvent(lineParts[2]), {"THINK_FROM", unpack(lineParts)})
                    queuedThink = {lineParts[2], "location", nil}
                end
                if lineParts[1] == "TYPEWRITER" then
                    queuedTypewriter = {}
                end
                if lineParts[1] == "COURT_RECORD_ADD_ANIMATION" then
                    AddToStack(events, sceneScript, NewCourtRecordAddEvent(lineParts[2]), lineParts)
                    AddToStack(events, sceneScript, NewAddToCourtRecordAnimationEvent(lineParts[2]), lineParts)
                end
                if lineParts[1] == "CLEAR_LOCATION" then
                    AddToStack(events, sceneScript, NewClearLocationEvent(lineParts[2]), lineParts)
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
    local openQuote = true

    local i = 1
    while i <= #line do
        local thisChar = string.sub(line, i,i)
        local thisDoubleChar = string.sub(line, i,i+1)
        local canAddToWord = true

        if thisDoubleChar == "//" then
            isComment = true
        end

        if isComment then
            canAddToWord = false
        end

        if thisDoubleChar == "$q" then
            canAddToWord = false
            if openQuote then
                -- backtick corresponds to open quotation marks in the font image
                wordBuild = wordBuild .. '`'
            else
                -- quotation marks correspond to closed quotation marks in the font image
                wordBuild = wordBuild .. '"'
            end

            openQuote = not openQuote
            i=i+1
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

        i=i+1
    end

    if #wordBuild > 0 then
        table.insert(words, wordBuild)
        wordBuild = ""
    end

    return words
end
