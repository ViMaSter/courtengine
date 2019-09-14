function NewCourtScene(scriptPath)
    local self = {}
    self.location = "COURT_DEFENSE"
    self.characterLocations = {}
    self.characters = {}

    self.text = "empty"
    self.events = LoadScript(scriptPath)

    self.update = function (self, dt)
        if #self.events >= 1 then
            if not self.events[1]:update(self, dt) then
                table.remove(self.events, 1)
            end
        end
    end

    self.draw = function (self, dt)
        love.graphics.setColor(1,1,1)
        local background = Backgrounds[self.location]
        love.graphics.draw(background[1])

        local character = self.characterLocations[self.location]
        if character ~= nil then
            love.graphics.draw(self.characters[character].NORMAL)
        end

        if background[2] ~= nil then
            love.graphics.draw(background[2])
        end

        -- draw the textbox
        love.graphics.setColor(0,0,0, 0.65)
        love.graphics.rectangle("fill", 0,GraphicsHeight()-64,GraphicsWidth(),GraphicsHeight())

        -- draw the text
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.text, 4, GraphicsHeight()-60)
    end

    return self
end
