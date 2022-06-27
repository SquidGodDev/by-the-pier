-- This loads data from fish.json to get info about fish,
-- which includes the name, flavor text the fish image,
-- what level the tension bar should be at when the fish
-- bites, how much the fish should pull on the line, how
-- long the player has to catch the fish, how often the fish
-- enters the struggle state, and the mean/variance of the size
-- of the fish

local pd <const> = playdate
local gfx <const> = pd.graphics

local fishTable = json.decodeFile("fish.json")

class('FishManager').extends()

function FishManager:init(fishingLine)
    self.fishingLine = fishingLine

    self.hooked = false
    self.hookTimeMin = 3000
    self.hookTimeMax = 10000
    local hookTime = math.random(self.hookTimeMin, self.hookTimeMax)
    -- I use this timer to let fishingLine.lua know when a bite occurs.
    -- Takes between 3 to 10 seconds
    self.hookTimer = pd.timer.new(hookTime, function()
        self.hooked = true
        self:initializeFishData()
        self.struggleTimer = self:getStruggleTimer()
    end)
end

-- Handles whether or not the fish is struggling
function FishManager:getStruggleTimer()
    local struggleTime = math.random(self.struggleTimeMin, self.struggleTimeMax)
    if self.struggling then
        struggleTime = math.random(self.struggleWaitTimeMin, self.struggleWaitTimeMax)
    end
    return pd.timer.new(struggleTime, function()
        self.struggleTimer = self:getStruggleTimer()
        self.struggling = not self.struggling
    end)
end

-- Bite timer gets rest when you move the line. Don't touch the line!
function FishManager:resetTime()
    self.hookTimer:reset()
end

function FishManager:initializeFishData()
    local distance = self.fishingLine.hookX - self.fishingLine.rodX
    local fishOptions
    -- Different fish live at different distances from the shore. I determine
    -- how far the line is from the shore and choose a fish based on that
    if distance < 104 then
        fishOptions = fishTable["close"]
    elseif distance < 194 then
        fishOptions = fishTable["mid"]
    else
        fishOptions = fishTable["far"]
    end

    local fishIndex = math.random(1, #fishOptions)
    self.hookedFish = fishOptions[fishIndex]

    -- Slight randomization to the pullStrength, struggleTime, and struggleWait
    -- +-20% and +-30%
    local pullStrength = self.hookedFish["pullStrength"]
    self.pullStrength = math.random(math.ceil(pullStrength * 0.8 * 100), math.ceil(pullStrength * 1.2 * 100)) / 100

    self.struggling = false
    local struggleTimeMedian = self.hookedFish["struggleTime"]
    self.struggleTimeMin = struggleTimeMedian * 0.7
    self.struggleTimeMax = struggleTimeMedian * 1.3
    local struggleWaitTimeMedian = self.hookedFish["struggleWaitTime"]
    self.struggleWaitTimeMin = struggleWaitTimeMedian * 0.7
    self.struggleWaitTimeMax = struggleWaitTimeMedian * 1.3
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
    return self.hookedFish
end

-- Doubles how much the fish pulls on the line if the fish is struggling
function FishManager:getPullStrength()
    if self.struggling then
        return self.pullStrength * 2
    else
        return self.pullStrength
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