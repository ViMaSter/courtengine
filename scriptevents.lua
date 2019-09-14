function NewCharLocationEvent(name, location)
    local self = {}
    self.name = name
    self.location = location

    self.update = function (self, scene, dt)
        scene.characterLocations[self.location] = scene.characters[self.name]

        return false
    end

    return self
end

function NewPoseEvent(name, pose)
    local self = {}
    self.name = name
    self.pose = pose

    self.update = function (self, scene, dt)
        scene.characters[self.name].frame = self.pose

        return false
    end

    return self
end

function NewCutToEvent(cutTo)
    local self = {}
    self.cutTo = cutTo

    self.update = function (self, scene, dt)
        scene.location = self.cutTo
        return false
    end

    return self
end

function NewSpeakEvent(who, text)
    local self = {}
    self.text = text
    self.textScroll = 1
    self.wasPressing = true
    self.who = who

    self.update = function (self, scene, dt)
        self.textScroll = math.min(self.textScroll + dt*TextScrollSpeed, #self.text)
        scene.textColor = {1,1,1}
        scene.text = string.sub(self.text, 1, math.floor(self.textScroll))
        scene.textTalker = self.who

        local pressing = love.keyboard.isDown("x")
        if pressing and not self.wasPressing and self.textScroll >= #self.text then
            return false
        end
        self.wasPressing = pressing

        return true
    end

    return self
end

function NewObjectionEvent(who)
    local self = {}
    self.timer = 0
    self.x,self.y = 0,0

    self.update = function (self, scene, dt)
        scene.textHidden = true
        self.timer = self.timer + dt
        self.x = self.x + love.math.random()*choose{1,-1}*2
        self.y = self.y + love.math.random()*choose{1,-1}*2

        return self.timer < 0.5
    end

    self.draw = function (self, scene)
        love.graphics.draw(ObjectionSprite, self.x,self.y)
    end

    return self
end

function NewHoldItEvent(who)
    local self = {}
    self.timer = 0
    self.x,self.y = 0,0

    self.update = function (self, scene, dt)
        scene.textHidden = true
        self.timer = self.timer + dt
        self.x = self.x + love.math.random()*choose{1,-1}*2
        self.y = self.y + love.math.random()*choose{1,-1}*2

        return self.timer < 0.5
    end

    self.draw = function (self, scene)
        love.graphics.draw(HoldItSprite, self.x,self.y)
    end

    return self
end

function NewPlayMusicEvent(music)
    local self = {}
    self.music = music

    self.update = function (self, scene, dt)
        for i,v in pairs(Music) do
            v:stop()
        end

        Music[self.music]:play()

        return false
    end

    return self
end

function NewCourtRecordAddEvent(evidence)
    local self = {}
    self.evidence = evidence

    self.update = function (self, scene, dt)
        table.insert(scene.courtRecord, scene.evidence[self.evidence])
        return false
    end

    return self
end

function NewCrossExaminationEvent(queue)
    local self = {}
    self.queue = queue
    self.textScroll = 1
    self.textIndex = 3
    self.wasPressing = true
    self.who = queue[1]

    for i,v in pairs(queue) do
        print(i,v)
    end

    self.advanceText = function (self)
        self.textIndex = self.textIndex + 3
        self.textScroll = 1
        self.wasPressing = true

        if self.textIndex > #self.queue then
            self.textIndex = 3
        end
    end

    self.update = function (self, scene, dt)
        local text = self.queue[self.textIndex]

        self.textScroll = math.min(self.textScroll + dt*TextScrollSpeed, #text)
        scene.textColor = {0,1,0.25}
        scene.text = string.sub(text, 1, math.floor(self.textScroll))
        scene.textTalker = self.who

        local pressing = love.keyboard.isDown("x")
        if pressing 
        and not self.wasPressing 
        and self.textScroll >= #text then
            self:advanceText()
        end
        self.wasPressing = pressing

        if love.keyboard.isDown("c")
        and self.textScroll >= #text then
            scene:runDefinition(self.queue[self.textIndex+1])
            self:advanceText()
        end

        return true
    end

    return self
end
