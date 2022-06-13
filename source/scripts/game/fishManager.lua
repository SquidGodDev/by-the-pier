local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishManager').extends()

function FishManager:init(distance)
    self.distance = distance
    self.hooked = false
    self.hookTimeMin = 1000
    self.hookTimeMax = 3000
    local hookTime = math.random(self.hookTimeMin, self.hookTimeMax)
    self.hookTimer = pd.timer.new(hookTime, function()
        self.hooked = true
        self.struggleTimer = self:getStruggleTimer()
    end)

    self.struggling = false
    self.struggleTimeMin = 500
    self.struggleTimeMax = 2000
    self.struggleWaitTimeMin = 3000
    self.struggleWaitTimeMax = 5000
end

function FishManager:getStruggleTimer()
    local struggleTime = math.random(self.struggleTimeMin, self.struggleTimeMax)
    if self.struggling then
        struggleTime = math.random(self.struggleWaitTimeMin, self.struggleWaitTimeMax)
    end
    return pd.timer.new(struggleTime, function()
        print(self.struggling)
        self.struggleTimer = self:getStruggleTimer()
        self.struggling = not self.struggling
    end)
end

function FishManager:resetTime()
    self.hookTimer:reset()
end

-- Fish Variables:
-- 1. TensionRate (Maybe make it correspond to pull speed?)
-- 2. Inital Tension
-- 3. Time to catch (Maybe not this one)
-- 4. Pull speed
-- 5. Probability of catch
-- 6. Name
-- 7. Distance to be caught at
-- 8. Struggle time
function FishManager:getFishInfo()
    
end

function FishManager:getPullStrength()
    if self.struggling then
        return 1
    else
        return 0.5
    end
end

function FishManager:isStruggling()
    return self.struggling
end

function FishManager:isHooked()
    return self.hooked
end

function FishManager:clear()
    if self.struggleTimer then
        self.struggleTimer:remove()
    end
end