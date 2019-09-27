require "../config"

function NewTitleScene()
    local self = {}
    self.image = love.graphics.newImage("main_logo.png")

    self.update = function (self, dt)
        if love.keyboard.isDown(controls.start_button) then
            LoadEpisode("scripts/episode1.meta")
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

        love.graphics.setColor(1,0,0)
        local startText = love.graphics.newText(GameFont, "Press "..GetKeyDisplayName(controls.start_button).." to start")
        love.graphics.draw(
            startText,
            GetCenterOffset(startText:getWidth()),
            -- Make sure text is below the image
            (self.image:getHeight() * logoScale)
        )
    end

    return self
end
