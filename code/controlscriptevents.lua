function PauseMenuEvent()
    if love.keyboard.isDown("p") then
        game_paused = not game_paused
    end
end