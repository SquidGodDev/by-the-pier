import "scripts/game/fishingLine"

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

function FishingRod:throwLine()
    -- Todo: Scale cast forward time with cast strength
    local worldSpaceX = self.handX + self.rodEndX
    local worldSpaceY = self.handY + self.rodEndY
    local averageSpeed = 0

    if #self.accelerometerValues > 0 then
        if #self.accelerometerValues > 10 then
            local shortenedValueArray = {}
            for i=1,10 do
                shortenedValueArray[i] = self.accelerometerValues[i]
            end
            self.accelerometerValues = shortenedValueArray
        end

        local firstPositiveIndex = 1
        local curDiff = self.accelerometerValues[1]
        while curDiff <= 0 and firstPositiveIndex < #self.accelerometerValues do
            firstPositiveIndex += 1
            curDiff = self.accelerometerValues[firstPositiveIndex]
        end

        local lastPositiveIndex = firstPositiveIndex
        if lastPositiveIndex < #self.accelerometerValues then
            curDiff = self.accelerometerValues[lastPositiveIndex + 1]
            while lastPositiveIndex < #self.accelerometerValues and curDiff > 0 do
                lastPositiveIndex += 1
                curDiff = self.accelerometerValues[lastPositiveIndex + 1]
            end
        end

        local splicedTable = {}
        local differenceSum = 0
        for i=firstPositiveIndex,lastPositiveIndex do
            table.insert(splicedTable, self.accelerometerValues[i])
            differenceSum += self.accelerometerValues[i]
        end
        averageSpeed = differenceSum / (lastPositiveIndex - firstPositiveIndex + 1)
    end
    if averageSpeed <= 0 then
        averageSpeed = .2
    elseif averageSpeed > 1 then
        averageSpeed = 1
    end
    local castStrength = averageSpeed * 8 + 1
    self.fishingLine = FishingLine(self, worldSpaceX, worldSpaceY, castStrength, 45)
    self.rodAnimator = nil
end

function FishingRod:reeledIn(fish)
    if self.fishingLine then
        self.fishingLine:remove()
        self.fishingLine = nil
        self.castingBack = true
    end
end

function FishingRod:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        self.accelerometerValues = {}
        pd.startAccelerometer()
        local x, y, z = pd.readAccelerometer()
        self.currentZ = z
        self:castBack()
    elseif pd.buttonIsPressed(pd.kButtonA) then
        local x, y, z = pd.readAccelerometer()
        table.insert(self.accelerometerValues, 1, z - self.currentZ)
        self.currentZ = z
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
                self:throwLine()
            end
        end
    end
    self:drawRod()
end