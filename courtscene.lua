function NewCourtScene(scriptPath)
    local self = {}
    self.location = "COURT_DEFENSE"
    self.characterLocations = {}
    self.characters = {}
    self.evidence = {}
    self.courtRecord = {}

    self.penalties = 5
    self.textHidden = false
    self.text = "empty"
    self.textTalker = ""
    self.textColor = {1,1,1}
    self.showCourtRecord = false
    self.wasPressingCourtRecord = false
    self.courtRecordIndex = 1

    self.wasPressingRight = false
    self.wasPressingLeft = false

    LoadScript(self, scriptPath)

    self.runDefinition = function (self, defName)
        local definition = self.definitions[defName]
        for i=#definition, 1, -1 do
            table.insert(self.events, 1, definition[i])
        end
    end

    self.update = function (self, dt)
        -- update the active event
        self.textHidden = false
        self.canShowCourtRecord = true
        while #self.events >= 1 and not self.events[1]:update(self, dt) do
            table.remove(self.events, 1)
        end

        -- open and close the court record
        local pressingCourtRecord = love.keyboard.isDown("z")
        if pressingCourtRecord and not self.wasPressingCourtRecord then
            self.showCourtRecord = not self.showCourtRecord
        end
        self.wasPressingCourtRecord = pressingCourtRecord

        if not self.canShowCourtRecord then
            self.showCourtRecord = false
        end

        if not self.showCourtRecord then
            self.courtRecordIndex = 1
        end

        -- move left and right through the court record
        local pressingRight = love.keyboard.isDown("right")
        local pressingLeft = love.keyboard.isDown("left")

        if pressingRight and not self.wasPressingRight then
            self.courtRecordIndex = self.courtRecordIndex + 1

            if self.courtRecordIndex > #self.courtRecord then
                self.courtRecordIndex = 1
            end
        end
        if pressingLeft and not self.wasPressingLeft then
            self.courtRecordIndex = self.courtRecordIndex - 1

            if self.courtRecordIndex < 1 then
                self.courtRecordIndex = #self.courtRecord
            end
        end

        self.wasPressingRight = pressingRight
        self.wasPressingLeft = pressingLeft
    end

    self.draw = function (self, dt)
        love.graphics.setColor(1,1,1)
        local background = Backgrounds[self.location]
        love.graphics.draw(background[1])

        local character = self.characterLocations[self.location]
        if character ~= nil then
            love.graphics.draw(self.characters[character.name].poses[character.frame])
        end

        if background[2] ~= nil then
            love.graphics.draw(background[2])
        end

        if #self.events >= 1 then
            if self.events[1].draw ~= nil then
                self.events[1]:draw(scene)
            end
        end

        if self.showCourtRecord then
            love.graphics.setColor(0.2,0.2,0.2)
            love.graphics.rectangle("fill", 0,24,GraphicsWidth(),92)

            love.graphics.setColor(1,1,1)
            local sprite = self.courtRecord[self.courtRecordIndex].sprite
            love.graphics.draw(sprite,GraphicsWidth()/2,GraphicsHeight()/2 - 48, 0, 1,1, sprite:getWidth()/2,sprite:getHeight()/2)

            local name = self.courtRecord[self.courtRecordIndex].externalName
            local rectWidth = #name*8
            love.graphics.printf(name, GraphicsWidth()/2 - rectWidth/2,GraphicsHeight()/2 -16, rectWidth, "center")

            local name = self.courtRecord[self.courtRecordIndex].info
            local rectWidth = #name*8
            love.graphics.printf(name, GraphicsWidth()/2 - rectWidth/2,GraphicsHeight()/2, rectWidth, "center")
        end

        -- draw the textbox
        if not self.textHidden then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(TextBox,0,GraphicsHeight()-TextBox:getHeight())
            love.graphics.print(self.textTalker, 4, GraphicsHeight()-TextBox:getHeight())

            love.graphics.setColor(unpack(self.textColor))
            love.graphics.printf(self.text, 4, GraphicsHeight()-60, 224, "left")
        end

        love.graphics.setColor(0,0,0)
        love.graphics.print("penalties left: " .. self.penalties)
    end

    return self
end
