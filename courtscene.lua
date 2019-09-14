function NewCourtScene(scriptPath)
    local self = {}
    self.location = "COURT_DEFENSE"
    self.characterLocations = {}
    self.characters = {}
    self.evidence = {}
    self.courtRecord = {}

    self.textHidden = false
    self.text = "empty"
    self.textTalker = ""
    self.textColor = {1,1,1}
    self.showCourtRecord = false
    self.wasPressingCourtRecord = false

    LoadScript(self, scriptPath)

    self.runDefinition = function (self, defName)
        local definition = self.definitions[defName]
        for i=#definition, 1, -1 do
            table.insert(self.events, 1, definition[i])
        end
    end

    self.update = function (self, dt)
        self.textHidden = false
        while #self.events >= 1 and not self.events[1]:update(self, dt) do
            table.remove(self.events, 1)
        end

        local pressingCourtRecord = love.keyboard.isDown("z")
        if pressingCourtRecord and not self.wasPressingCourtRecord then
            self.showCourtRecord = not self.showCourtRecord
        end
        self.wasPressingCourtRecord = pressingCourtRecord
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
            for i=1, #self.courtRecord do
                love.graphics.draw(self.courtRecord[i].sprite,(i-1)*64,0)
            end
        end

        -- draw the textbox
        if not self.textHidden then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(TextBox,0,GraphicsHeight()-TextBox:getHeight())
            love.graphics.print(self.textTalker, 4, GraphicsHeight()-TextBox:getHeight())

            love.graphics.setColor(unpack(self.textColor))
            love.graphics.printf(self.text, 4, GraphicsHeight()-60, 224, "left")
        end
    end

    return self
end
