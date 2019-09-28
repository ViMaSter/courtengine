function NewTitleScreen()
    local self = {}
    self.image = love.graphics.newImage("main_logo.png")
    self.selection = "New Game"
    self.keyDown = false

    self.update = function (self, dt)
        -- this logic forces the selection to only toggle once while a key is held down
        if love.keyboard.isDown(controls.press_right, controls.press_left) and self.keyDown == false then
            self.keyDown = true
            if self.selection == "New Game" then
                self.selection = "Load Game"
            else
                self.selection = "New Game"
            end
        elseif not love.keyboard.isDown(controls.press_right, controls.press_left) then
            self.keyDown = false
        end

        if love.keyboard.isDown(controls.start_button) then
            if self.selection == "New Game" then
                -- replace this and handle new game logic
                LoadEpisode("scripts/episode1.meta")
            else
              -- replace this and handle load game logic
                LoadEpisode("scripts/episode1.meta")
            end
        end
    end

    self.draw = function (self, dt)
        love.graphics.clear(1,1,1)

        local logoScale = 0.16
        love.graphics.draw(
            self.image,
            -- Center the logo in the window regardless of image or window size
            GetCenterOffset(self.image:getWidth() * logoScale),
            0,
            0,
            logoScale,
            logoScale
        )

        -- get dimensions for New Game and Load Game buttons
        local newX = (dimensions.window_width * 1/9)/dimensions.graphics_scale
        local newW = (dimensions.window_width * 1/3)/dimensions.graphics_scale
        local newY = self.image:getHeight()*logoScale
        local newH = 20

        local loadW = (dimensions.window_width * 1/3)/dimensions.graphics_scale
        local loadX = (dimensions.window_width * 8/9)/dimensions.graphics_scale - loadW
        local loadY = self.image:getHeight()*logoScale
        local loadH = 20

        -- blue bounding box offset
        local dx = 2
        local dy = 2

        love.graphics.setColor(0.44,0.56,0.89) -- roughly GG blue
        if self.selection == "New Game" then
            love.graphics.rectangle("fill", newX-dx, newY-dy, newW+2*dx, newH+2*dy)
        else
            love.graphics.rectangle("fill", loadX-dx, loadY-dy, loadW+2*dx, loadH+2*dy)
        end

        -- draw New Game, Load Game, and text
        love.graphics.setColor(0.96,0.53,0.23) -- roughly GG orange
        love.graphics.rectangle("fill", newX, newY, newW, newH)

        love.graphics.setColor(0.3,0.3,0.3) -- greyed out
        love.graphics.rectangle("fill", loadX, loadY, loadW, loadH)

        love.graphics.setColor(1,1,1)
        local newGameText = love.graphics.newText(GameFont, "New Game")
        love.graphics.draw(
            newGameText,
            newX + newW/2-newGameText:getWidth()/2,
            newY + newH/2-newGameText:getHeight()/2
        )

        local loadGameText = love.graphics.newText(GameFont, "Load Game")
        love.graphics.draw(
            loadGameText,
            loadX + loadW/2-loadGameText:getWidth()/2,
            loadY + loadH/2-loadGameText:getHeight()/2
        )
    end

    return self
end
