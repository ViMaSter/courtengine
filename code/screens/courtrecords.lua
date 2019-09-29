function DrawCourtRecords()
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.rectangle("fill", 0,24,GraphicsWidth,92)

    love.graphics.setColor(0,0,0)
    love.graphics.printf("Court Record", 0,0, GraphicsWidth, "center")

    love.graphics.setColor(1,1,1)

    if #Episode.courtRecords >= CourtRecordIndex then
        local sprite = Episode.courtRecords[CourtRecordIndex].sprite
        love.graphics.draw(sprite,GraphicsWidth/2,GraphicsHeight/2 - 48, 0, 1,1, sprite:getWidth()/2,sprite:getHeight()/2)

        local name = Episode.courtRecords[CourtRecordIndex].externalName
        local rectWidth = #name*8
        love.graphics.printf(name, GraphicsWidth/2 - rectWidth/2,GraphicsHeight/2 -16, rectWidth, "center")

        local name = Episode.courtRecords[CourtRecordIndex].info
        local rectWidth = #name*8
        love.graphics.setFont(SmallFont)
        love.graphics.printf(name, GraphicsWidth/2 - rectWidth/2,GraphicsHeight/2, rectWidth, "center")
        love.graphics.setFont(GameFont)

    else
        love.graphics.printf("empty", 0,48, GraphicsWidth, "center")
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
