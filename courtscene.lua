function NewCourtScene(scriptPath)
    local self = {}
    self.background = Backgrounds.courtDefense

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
        love.graphics.draw(self.background[1])
        if self.background[2] ~= nil then
            love.graphics.draw(self.background[2])
        end

        love.graphics.setColor(0,0,0)
        love.graphics.print(self.text)
    end

    return self
end
