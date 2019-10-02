function DrawCourtRecords()
    local bodyOptions = {}
    for i=1, #Episode.courtRecords do
        table.insert(bodyOptions, Episode.courtRecords[i].sprite)
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
            }
        },
        title = "Evidence",
        body = {
            selected = {
                image = Episode.courtRecords[CourtRecordIndex].sprite,
                title = Episode.courtRecords[CourtRecordIndex].externalName,
                details = Episode.courtRecords[CourtRecordIndex].info
            },
            options = bodyOptions
        }
    })
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
    end;
    onKeyPressed = function (key)
        if key == controls.press_left and CourtRecordIndex > 1 then
            CourtRecordIndex = CourtRecordIndex - 1
        elseif key == controls.press_right and CourtRecordIndex < #Episode.courtRecords then
            CourtRecordIndex = CourtRecordIndex + 1
        elseif key == controls.press_confirm then
            -- TODO: Implement what happens when you confirm?
        end
    end;
    draw = function ()
        DrawCourtRecords()
    end
}
