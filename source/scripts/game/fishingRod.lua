-- Here is where the fishing rod gets drawn, but also where I handle
-- calculating how far to toss the line based on accelerometer inputs

import "scripts/game/fishingLine"
import "scripts/game/ui/resultDisplay"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishingRod').extends(gfx.sprite)

function FishingRod:init(water)
    self.water = water
    self.handX = 67
    self.handY = 154
    self.rodLength = 12
    self.endAngle = 290
    self.backArc = pd.geometry.arc.new(0, 0, self.rodLength, 45, self.endAngle, false)
    self.forwardArc = pd.geometry.arc.new(0, 0, self.rodLength, self.endAngle, 50, true)
    self.castBackTime = 400
    self.castForwardTime = 500
    self.castingBack = true

    self.drawPadding = 2
    local rodEndX, rodEndY = self.backArc:pointOnArc(0):unpack()
    self.rodEndX = rodEndX
    self.rodEndY = rodEndY
    self.lastRodEndX = -1
    self.lastRodEndY = -1

    self.castSound = pd.sound.sampleplayer.new("sound/Reel")

    self:moveTo(self.handX, self.handY)
    self:add()
end

function FishingRod:drawRod()
    if self.lastRodEndX ~= self.rodEndX or self.lastRodEndY ~= self.rodEndY then
        self.lastRodEndX = self.rodEndX
        self.lastRodEndY = self.rodEndY
        local rodImage = gfx.image.new(self.rodLength * 2 + self.drawPadding, self.rodLength * 2 + self.drawPadding)
        gfx.pushContext(rodImage)
            gfx.setLineWidth(2)
            gfx.setLineCapStyle(gfx.kLineCapStyleRound)
            local imageCenter = self.rodLength + self.drawPadding
            gfx.drawLine(imageCenter, imageCenter, self.rodEndX + imageCenter, self.rodEndY + imageCenter)
        gfx.popContext()
        self:setImage(rodImage)
    end
end

-- Just using an animator to handle the angle of the rod. I created geometry
-- arc objects and stored them into self.forwardArc and self.backArc and animated
-- along those arcs
function FishingRod:cast()
    if not self.castingBack then
        return
    end
    self.rodAnimator = gfx.animator.new(self.castForwardTime, self.forwardArc, pd.easingFunctions.inCubic)
    self.castingBack = false
end

function FishingRod:castBack()
    if self.fishingLine or self.rodAnimator then
        return
    end
    self.rodAnimator = gfx.animator.new(self.castBackTime, self.backArc, pd.easingFunctions.outCubic)
end

-- Here's a summary of how I do the casting calculation. It's a bit more complex than
-- how I described it in the video. The complexity comes from wanting to accomplish these
-- things:
-- 1. If you press A, then swing back then forward, it should still work
-- 2. If you don't follow through with your cast and slow down at the end, it should take that
--    somewhat into consideration
-- 3. It should provide enough leeway to handle some impreciseness
-- The solution I came up with is to record all the accelerometer z-axis values every frame the A button
-- is being held down. Then, throw out every value except the last 10, since that will capture the
-- final velocity right before the A button is let go. Then, calculate the difference between adjacent values
-- to get the distance traveled each frame. Then, go through that list and get the indices of the first positive
-- difference and the last positive difference. This way we can effectively cut off the negative distances at the end
-- which account for if the player pulls back slightly at the end of a cast, is pulling back slightly in the beggining
-- of a cast, or some slight accelerometer reading errors. We can then add up all the differences and divide by the number
-- of elements, which is directly related to the number of frames, which is directly related to the time passed, so we
-- now officially have some number that can be considered our "velocity". However, the range on the velocity is really
-- large, so while it can go up to 10, I clamp it down to a range between 0 and 1 and use anything >= 1 as the max distance
function FishingRod:throwLine()
    -- Todo: Scale cast forward time with cast strength
    local worldSpaceX = self.handX + self.rodEndX
    local worldSpaceY = self.handY + self.rodEndY
    local averageSpeed = 0

    if #self.accelerometerValues > 0 then
        -- Shortening the array down to 10 elements here
        if #self.accelerometerValues > 10 then
            local shortenedValueArray = {}
            for i=1,10 do
                shortenedValueArray[i] = self.accelerometerValues[i]
            end
            self.accelerometerValues = shortenedValueArray
        end

        -- Finding out what the index of the first positive difference is
        local firstPositiveIndex = 1
        local curDiff = self.accelerometerValues[1]
        while curDiff <= 0 and firstPositiveIndex < #self.accelerometerValues do
            firstPositiveIndex += 1
            curDiff = self.accelerometerValues[firstPositiveIndex]
        end

        -- Find out what the last positive difference is
        local lastPositiveIndex = firstPositiveIndex
        if lastPositiveIndex < #self.accelerometerValues then
            curDiff = self.accelerometerValues[lastPositiveIndex + 1]
            while lastPositiveIndex < #self.accelerometerValues and curDiff > 0 do
                lastPositiveIndex += 1
                curDiff = self.accelerometerValues[lastPositiveIndex + 1]
            end
        end

        -- Calculating the speed by adding up all the differences and dividing
        -- by the number of frames elapsed
        local splicedTable = {}
        local differenceSum = 0
        for i=firstPositiveIndex,lastPositiveIndex do
            table.insert(splicedTable, self.accelerometerValues[i])
            differenceSum += self.accelerometerValues[i]
        end
        averageSpeed = differenceSum / (lastPositiveIndex - firstPositiveIndex + 1)
    end
    -- Clamping the velocity. Even if you don't move the playdate at all, you get a minimum
    -- cast velocity of .2, and if you throw it super fast, it still maxes out at 1. This was
    -- just found through trial and error, but I found 1 to be a good max since you don't need
    -- to turn the Playdate extremely quickly, just relatively fast, to get at least >= 1
    if averageSpeed <= 0 then
        averageSpeed = .2
    elseif averageSpeed > 1 then
        averageSpeed = 1
    end
    -- Converting the range of 0 to 1 up to a 1 to 9. This is because I found a cast
    -- strength of 9 in the FishingLine class would throw the line out to the end of
    -- the screen and I just found that through trial and error
    local castStrength = averageSpeed * 8 + 1
    self.fishingLine = FishingLine(self, worldSpaceX, worldSpaceY, castStrength, 45)
    self.rodAnimator = nil
end

function FishingRod:reeledIn(fish)
    if fish then
        self.resultDisplay = ResultDisplay(fish, self)
    end
    if self.fishingLine then
        self.fishingLine:remove()
        self.fishingLine = nil
        self.castingBack = true
    end
end

function FishingRod:update()
    if self.resultDisplay then
        -- Do Nothing
    elseif pd.buttonJustPressed(pd.kButtonA) then
        pd.startAccelerometer()
        self.accelerometerValues = {}
        local x, y, z = pd.readAccelerometer()
        self.currentZ = z
        self:castBack()
    elseif pd.buttonIsPressed(pd.kButtonA) then
        if pd.accelerometerIsRunning() then
            local x, y, z = pd.readAccelerometer()
            table.insert(self.accelerometerValues, 1, z - self.currentZ)
            self.currentZ = z
        end
    elseif pd.buttonJustReleased(pd.kButtonA) then
        self:cast()
        pd.stopAccelerometer()
    end

    if self.rodAnimator then
        local rodEndPoint = self.rodAnimator:currentValue()
        self.rodEndX = rodEndPoint.x
        self.rodEndY = rodEndPoint.y
        if self.rodAnimator:ended() then
            if not self.castingBack then
                self.castSound:play()
                self:throwLine()
            end
        end
    end
    self:drawRod()
end

function FishingRod:resultDisplayDismissed()
    self.resultDisplay = nil
end