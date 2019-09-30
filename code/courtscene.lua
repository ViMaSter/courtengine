require "../config"

function NewScene(scriptPath)
    local self = {}
    self.location = "NONE"
    self.characterLocations = {}
    self.characters = {}
    self.evidence = {}
    self.courtRecord = {}
    self.flags = {}

    self.penalties = 5
    self.textHidden = false
    self.text = "empty"
    self.fullText = "empty"
    self.textTalker = ""
    self.textBoxSprite = Sprites["TextBox"]
    self.textColor = {1,1,1}
    self.textCentered = false
    self.showCourtRecord = false
    self.wasPressingCourtRecord = false
    self.courtRecordIndex = 1

    self.charAnimIndex = 1

    self.wasPressingRight = false
    self.wasPressingLeft = false

    -- the script is loaded into the court scene's events table
    -- function definitions are stored in the court scene's definitions table
    -- the script is made up of individual "events"
    -- events are defined in scriptevents.lua
    LoadScript(self, scriptPath)
    self.currentEventIndex = 1

    -- run a function definition defined in the script
    self.runDefinition = function (self, defName, loc)
        if loc == nil then
            loc = 1
        end

        local definition = deepcopy(self.definitions[defName])
        for i=#definition, 1, -1 do
            table.insert(self.events, loc, definition[i])
        end
    end

    self.update = function (self, dt)
        -- update the active event
        self.textHidden = false
        self.canShowCourtRecord = true
        self.canShowCharacter = true
        self.textCentered = false
        self.textBoxSprite = Sprites["TextBox"]
        self.characterTalking = false
        self.canShowBgTopLayer = true

        while #self.events >= 1 and not self.events[1]:update(self, dt) do
            table.remove(self.events, 1)
            self.currentEventIndex = self.currentEventIndex + 1
        end

        self.charAnimIndex = self.charAnimIndex + dt*5

        -- open and close the court record
        local pressingCourtRecord = love.keyboard.isDown(controls.press_court_record)
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
        local pressingRight = love.keyboard.isDown(controls.press_right)
        local pressingLeft = love.keyboard.isDown(controls.press_left)

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

    self.drawCharacterAt = function (self, characterLocation, x,y)
        local character = self.characterLocations[characterLocation]
        if character ~= nil
        and self.characters[character.name].poses[character.frame] ~= nil then
            local char = self.characters[character.name]
            local pose = char.poses[character.frame]

            if self.characterTalking and char.name == self.textTalker then
                pose = char.poses[character.frame.."Talking"]
            end

            if self.charAnimIndex >= #pose.anim then
                self.charAnimIndex = 1
            end
            local animIndex = math.max(math.floor(self.charAnimIndex +0.5), 1)
            local nextPose = pose.anim[animIndex]
            local curX, curY, width, height = nextPose:getViewport()
            -- If x is 0, we expect we wanted to center the image. Right now, not
            -- every asset has been updated to the correct aspect ratio, so calculate
            -- the amount we need to move it over by based on the width of the frame
            if x == 0 then
                love.graphics.draw(pose.source, nextPose, GetCenterOffset(width),y)
            else
                love.graphics.draw(pose.source, nextPose, x,y)
            end
        end
    end

    self.drawBackgroundTopLayer = function (self, location, x,y)
        local background = Backgrounds[location]

        if background[2] ~= nil then
            love.graphics.draw(background[2], x,y)
        end
    end

    self.draw = function (self, dt)
        love.graphics.setColor(1,1,1)

        -- draw the background of the current location
        local background = Backgrounds[self.location]
        if background[1] ~= nil then
            love.graphics.draw(background[1])
        end

        -- draw the character who is at the current location
        if self.canShowCharacter then
            self:drawCharacterAt(self.location, 0,0)
        end

        love.graphics.setColor(1,1,1)
        if #self.events >= 1 then
            if self.events[1].characterDraw ~= nil then
                self.events[1]:characterDraw(self)
            end
        end

        -- draw the top layer of the environment, like desk on top of character
        if self.canShowBgTopLayer then
            self:drawBackgroundTopLayer(self.location, 0,0)
        end

        -- if the current event has an associated graphic, draw it
        love.graphics.setColor(1,1,1)
        if #self.events >= 1 then
            if self.events[1].draw ~= nil then
                self.events[1]:draw(self)
            end
        end

        -- draw the court record
        if self.showCourtRecord then
            love.graphics.setColor(0.2,0.2,0.2)
            love.graphics.rectangle("fill", 0,24,GraphicsWidth(),92)

            love.graphics.setColor(0,0,0)
            love.graphics.printf("Court Record", 0,0, GraphicsWidth(), "center")

            love.graphics.setColor(1,1,1)
            if #self.courtRecord >= self.courtRecordIndex then
                local sprite = self.courtRecord[self.courtRecordIndex].sprite
                love.graphics.draw(sprite,GraphicsWidth()/2,GraphicsHeight()/2 - 48, 0, 1,1, sprite:getWidth()/2,sprite:getHeight()/2)

                local name = self.courtRecord[self.courtRecordIndex].externalName
                local rectWidth = #name*8
                love.graphics.printf(name, GraphicsWidth()/2 - rectWidth/2,GraphicsHeight()/2 -16, rectWidth, "center")

                local name = self.courtRecord[self.courtRecordIndex].info
                local rectWidth = #name*8
                love.graphics.setFont(SmallFont)
                love.graphics.printf(name, GraphicsWidth()/2 - rectWidth/2,GraphicsHeight()/2, rectWidth, "center")
                love.graphics.setFont(GameFont)

            else
                love.graphics.printf("empty", 0,48, GraphicsWidth(), "center")
            end
        end

        -- draw the textbox
        if not self.textHidden then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(self.textBoxSprite,0,GraphicsHeight()-self.textBoxSprite:getHeight())

            -- draw who is talking
            love.graphics.setFont(SmallFont)
            love.graphics.print(self.textTalker, 4, GraphicsHeight()-self.textBoxSprite:getHeight())
            love.graphics.setFont(GameFont)

            -- draw the current scrolling text
            love.graphics.setColor(unpack(self.textColor))

            if not self.textCentered then
                local wrapIndices = {}

                local lineTable = {"", "", ""}
                local spaces = {}
                local lineTableIndex = 1
                local fullwords = ""
                local working = ""
                -- Space to allocate to the left and right of the text within the box
                local sidePadding = 20
                local wrapWidth = self.textBoxSprite:getWidth() - (sidePadding * 2)

                --
                for i=1, #self.fullText do
                    local char = string.sub(self.fullText, i,i)

                    if char == " " or char == "#" then
                        table.insert(spaces, i)
                    end

                    local wtest = working .. char
                    if lineTableIndex < 3 then
                        if GameFont:getWidth(wtest) >= wrapWidth or char == "#" then
                            wrapIndices[lineTableIndex] = spaces[#spaces] +1
                            lineTableIndex = lineTableIndex + 1
                            working = ""
                            fullwords = ""
                        end
                    end

                    working = working .. char
                end

                local lineTableIndex = 1

                for i=1, #self.text do
                    local char = string.sub(self.text, i,i)

                    if i == wrapIndices[lineTableIndex] then
                        lineTableIndex = lineTableIndex + 1
                    end

                    lineTable[lineTableIndex] = lineTable[lineTableIndex] .. char
                end

                local coloredLine1 = {}
                local coloredLine2 = {}
                local coloredLine3 = {}
                local string = ""

                --[[
                Supposed to iterate over each line, and then each character in
                each line to formulate the colored table to be sent to print.
                Doesn't work currently, Alex can't figure out why.
                ]]

                for i=1, #lineTable do
                    for j=1, #lineTable[i] do
                        if i == 1 then
                            coloredTable = coloredLine1
                        elseif i == 2 then
                            coloredTable = coloredLine2
                        elseif i == 3 then
                            coloredTable = coloredLine3
                        end

                        if string.match(lineTable[i], "0") then

                            local char = string.sub(lineTable[i], j,j)

                            --[[
                            The way love.graphics.print() works is you can give it a
                            table in the format of {colorTable,string,colorTable,string,...}
                            and it will print it with the colors corresponding to the
                            strings. This first line is just supposed to check if this
                            is the first charcter, and if so, just add the regular color
                            to the table to begin with, but for some reason if you
                            active this, it will just print the color codes as their text.
                            ]]
                            ---[[
                            if j == 1 then
                                table.insert(coloredTable,self.textColor)
                            end
                            --]]

                            if char == "0" then --End of a colored segment, add the colored string to the table, then add the normal color back
                                table.insert(coloredTable,string)
                                string = ""
                                table.insert(coloredTable,self.textColor)
                            elseif char == "1" then -- Start of a colored segment, add the string before the new color to the table, then add the new color
                                table.insert(coloredTable,string)
                                string = ""
                                local tempColor = {1,0,0}
                                table.insert(coloredTable,tempColor)
                            else -- If not the start or end of a colored segment, simply add the character to the string to be added to the table
                                string = string..char
                            end

                            if j == #lineTable[i] then -- If it's the end of the line, add the string to the table, always ends on a string
                                table.insert(coloredTable,string)
                                string = ""
                            end
                        else
                            table.insert(coloredTable,lineTable[i])
                        end
                    end
                end

                -- If these lines are empty, adds a blank string to ensure it doesn't crash
                if coloredLine2[1] == nil then coloredLine2[1] = "" end
                if coloredLine3[1] == nil then coloredLine3[1] = "" end

                -- Combine the colored line tables into a single colored line table
                local coloredLineTable = {coloredLine1,coloredLine2,coloredLine3}

                -- Prints
                for i=1, #lineTable do
                    love.graphics.print(unpack(coloredLineTable[i]), 8, GraphicsHeight()-60 + (i-1)*16)
                end
            -- Centered Text, untouched by inline colored text
            else
                local lineTable = {"", "", ""}
                local lineIndex = 1

                for i=1, #self.text do
                    local char = string.sub(self.text, i,i)

                    if char == "#" then
                        lineIndex = lineIndex + 1
                    else
                        lineTable[lineIndex] = lineTable[lineIndex] .. char
                    end
                end

                local lineTableFull = {"", "", ""}
                local lineIndex = 1

                for i=1, #self.fullText do
                    local char = string.sub(self.fullText, i,i)

                    if char == "#" then
                        lineIndex = lineIndex + 1
                    else
                        lineTableFull[lineIndex] = lineTableFull[lineIndex] .. char
                    end
                end



                for i=1, #lineTable do
                    local xText = GraphicsWidth()/2 - GameFont:getWidth(lineTableFull[i])/2
                    love.graphics.print(lineTable[i], xText, GraphicsHeight()-60 + (i-1)*16)
                end
            end
        end
    end

    return self
end
