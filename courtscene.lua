function NewCourtScene(scriptPath)
    local self = {}
    self.location = "COURT_DEFENSE"
    self.characterLocations = {}
    self.characters = {}

    self.textHidden = false
    self.text = "empty"
    self.textTalker = ""
    self.events = LoadScript(scriptPath)

    self.update = function (self, dt)
        self.textHidden = false
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

        -- draw the textbox
        if not self.textHidden then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(TextBox,0,GraphicsHeight()-TextBox:getHeight())
            love.graphics.printf(self.text, 4, GraphicsHeight()-60, 224, "left")
            love.graphics.print(self.textTalker, 4, GraphicsHeight()-TextBox:getHeight())
        end
    end

    return self
end
