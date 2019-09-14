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
        self.textScroll = math.min(self.textScroll + dt*20, #self.text)
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

function NewCourtRecordAdd(evidence)
    local self = {}
    self.evidence = evidence

    self.update = function (self, scene, dt)
        table.insert(scene.courtRecord, self.evidence)
        return false
    end

    return self
end
