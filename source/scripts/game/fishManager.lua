local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishManager').extends()

function FishManager:init(distance)
    self.distance = distance
    self.hooked = false
    local hookTime = math.random(1000, 3000)
    self.hookTimer = pd.timer.new(hookTime, function()
        self.hooked = true
    end)
end

-- Fish Variables:
-- 1. TensionRate
-- 2. Inital Tension
-- 3. Time to catch
-- 4. Pull speed
-- 5. Probability of catch
-- 6. Name
-- 7. Distance to be caught at
function FishManager:getFishInfo()
    
end

function FishManager:getPullStrength()
    return 1
end

function FishManager:isHooked()
    return self.hooked
end