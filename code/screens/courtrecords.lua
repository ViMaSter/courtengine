function DrawCourtRecords(ui)
    local bodyOptions = {}

    if ui == "evidence" then
        -- Draw evidence UI
        for i=1, #Episode.courtRecords.evidence do
            table.insert(bodyOptions, Episode.courtRecords.evidence[i].sprite)
        end
        
        DrawCenteredRectangle({
            width = love.graphics.getWidth() * 4/5,
            height = love.graphics.getHeight() - 120,
            buttons = {
                {
                    title = "Back",
                    key = controls.press_court_record
                },
                {
                    title = "Present",
                    key = controls.press_confirm
                },
                {
                    title = "Profiles",
                    key = controls.press_toggle_profiles
                }
            },
            title = "Evidence",
            body = {
                selected = {
                    image = Episode.courtRecords.evidence[CourtRecordIndex].sprite,
                    title = Episode.courtRecords.evidence[CourtRecordIndex].externalName,
                    details = Episode.courtRecords.evidence[CourtRecordIndex].info
                },
                options = bodyOptions
            }
        })
    else
        -- Draw profiles UI
        for i=1, #Episode.courtRecords.profiles do
            table.insert(bodyOptions, Episode.courtRecords.profiles[i].sprite)
        end
        
        DrawCenteredRectangle({
            width = love.graphics.getWidth() * 4/5,
            height = love.graphics.getHeight() - 120,
            buttons = {
                {
                    title = "Back",
                    key = controls.press_court_record
                },
                {
                    title = "Present",
                    key = controls.press_confirm
                },
                {
                    title = "Evidence",
                    key = controls.press_toggle_profiles
                }
            },
            title = "Profiles",
            body = {
                selected = {
                    image = Episode.courtRecords.profiles[CourtRecordIndex].sprite,
                    title = Episode.courtRecords.profiles[CourtRecordIndex].characterName .. " (Age: " .. Episode.courtRecords.profiles[CourtRecordIndex].age .. ")",
                    details = Episode.courtRecords.profiles[CourtRecordIndex].info
                },
                options = bodyOptions
            }
        })
    end
end

CourtRecordsConfig = {
    displayed = false;
    displayKey = controls.press_court_record;
    displayCondition = function ()
        -- You can only view your court records
        print()
        return true;
    end;
    onDisplay = function ()
        CourtRecordIndex = 1
        menu_type = "evidence"
    end;
    onKeyPressed = function (key)
        if key == controls.press_left and CourtRecordIndex > 1 then
            CourtRecordIndex = CourtRecordIndex - 1
        elseif key == controls.press_right then
            if menu_type == "evidence" and CourtRecordIndex < #Episode.courtRecords.evidence then
                CourtRecordIndex = CourtRecordIndex + 1
            elseif menu_type == "profiles" and CourtRecordIndex < #Episode.courtRecords.profiles then
                CourtRecordIndex = CourtRecordIndex + 1
            end
        elseif key == controls.press_confirm then
            -- TODO: Implement what happens when you confirm?
        elseif key == controls.press_toggle_profiles then
            CourtRecordIndex = 1
            if menu_type == "evidence" then
                -- Toggle on profiles UI
                menu_type = "profiles"
            else
                -- Toggle off profiles UI
                menu_type = "evidence"
            end
        end
    end;
    draw = function ()
        DrawCourtRecords(menu_type)
    end
}
