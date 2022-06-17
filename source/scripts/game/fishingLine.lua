import "scripts/game/fishManager"
import "scripts/game/ui/catchTimer"
import "scripts/game/ui/tensionBar"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishingLine').extends(gfx.sprite)

function FishingLine:init(fishingRod, rodX, rodY, strength, angle)
    self.fishingRod = fishingRod
    self.waterLevel = 198
    self.strength = strength
    self.rodX = rodX
    self.rodY = rodY
    self.hookX = rodX
    self.hookY = rodY
    self.lastX = -1
    self.lastY = -1
    self.xVelocity = math.cos(math.rad(angle)) * strength
    self.yVelocity = -math.sin(math.rad(angle)) * strength
    self.casting = true

    self.reelSpeed = 1.5
    self.reelingUp = false
    self.reelUpSpeed = 3

    self.fishCaught = false

    self.topYOffset = 50
    self.bottomYOffset = 30

    self:setCenter(0, 0)
    self:moveTo(self.rodX, self.topYOffset)
    self:add()

    local struggleIcon = gfx.image.new("images/game/struggleIcon")
    self.struggleIndicator = gfx.sprite.new(struggleIcon)
    self.struggleIndicator:setVisible(false)
    self.struggleIndicator:add()

    self.splashSound = pd.sound.sampleplayer.new("sound/Splash")
    self.fishCatchSound = pd.sound.sampleplayer.new("sound/FishCatch")
    self.reelInSound = pd.sound.sampleplayer.new("sound/ReelIn")
    self.reelOutSound = pd.sound.sampleplayer.new("sound/ReelOut")
end

function FishingLine:drawLine()
    if self.lastX ~= self.hookX or self.lastY ~= self.hookY then
        self.lastX = self.hookX
        self.lastY = self.hookY
        local lineHeight = math.abs(self.rodY - self.hookY)
        local lineWidth = self.hookX - self.rodX
        local lineImage
        if lineHeight <= 1 or lineWidth <= 1 then
            self:moveTo(self.rodX, self.topYOffset)
            lineImage = gfx.image.new(400 - self.rodX, 240 - self.topYOffset - self.bottomYOffset)
            gfx.pushContext(lineImage)
                gfx.drawLine(self.rodX - self.rodX, self.rodY - self.topYOffset, self.hookX - self.rodX, self.hookY - self.topYOffset)
            gfx.popContext()
        elseif self.hookY > self.rodY then
            self:moveTo(self.rodX, self.rodY)
            lineImage = gfx.image.new(lineWidth, lineHeight)
            gfx.pushContext(lineImage)
                gfx.drawLine(0, 0, lineWidth, self.hookY - self.rodY)
            gfx.popContext()
        else
            self:moveTo(self.rodX, self.hookY)
            lineImage = gfx.image.new(lineWidth, lineHeight)
            gfx.pushContext(lineImage)
                gfx.drawLine(0, lineHeight, lineWidth, 0)
            gfx.popContext()
        end
        self:setImage(lineImage)
    end
end

function FishingLine:reelUp()
    self.hookX = self.rodX
    self.reelingUp = true
end

function FishingLine:reeledIn(caught)
    self.reelInSound:stop()
    self.reelOutSound:stop()
    self.struggleIndicator:setVisible(false)
    if caught and self.fishManager:isHooked() then
        self.fishingRod:reeledIn(self.fishManager:getFishInfo())
    else
        self.fishingRod:reeledIn()
    end
    if self.fishManager then
        self.fishManager:clear()
    end
    if self.catchTimer then
        self.catchTimer:endTimer()
    end
    if self.tensionBar then
        self.tensionBar:stopTensionBar()
    end
end

function FishingLine:update()
    if self.casting then
        self:handleCastPhysics()
    else
        if self.reelingUp then
            self:handleReelUpAnimation()
        else
            if self.fishHooked then
                self:fishPullOnLine()
                self:handleStruggleIndicator()
            else
                if self.fishManager:isHooked() then
                    self:startFishing()
                end
            end
            self:handleCrankInput()
        end
    end
    self:drawLine()
end

function FishingLine:handleCrankInput()
    local crankInput = pd.getCrankTicks(18)
    if crankInput ~= 0 then
        self.reelOutSound:stop()
        if not self.reelInSound:isPlaying() then
            self.reelInSound:play(0)
        end
        if not self.fishHooked then
            self.fishManager:resetTime()
        end
        if self:hookAtRod() then
            self.fishCatchSound:play()
            self:stopCatchTimerAndTensionBar()
            self:reelUp()
        else
            local struggling = self.fishManager:isStruggling()
            self.hookX -= self.reelSpeed
            if self.tensionBar then
                self.tensionBar:increaseTension(struggling)
            end
        end
    else
        self.reelInSound:stop()
        if self.fishHooked then
            if not self.reelOutSound:isPlaying() then
                self.reelOutSound:play(0)
            end
        else
            self.reelOutSound:stop()
        end
    end
end

function FishingLine:stopCatchTimerAndTensionBar()
    if self.catchTimer then
        self.catchTimer:endTimer()
    end
    if self.tensionBar then
        self.tensionBar:stopTensionBar()
    end
end

function FishingLine:hookAtRod()
    return self.hookX <= self.rodX + 3
end

function FishingLine:startFishing()
    self.fishHooked = true
    self.fishingRod.water:impulse(self.hookX)
    self.splashSound:play()
    local hookedFish = self.fishManager:getFishInfo()
    local catchTime = hookedFish["catchTime"]
    self.catchTimer = CatchTimer(catchTime, self)
    local initialTension = hookedFish["initialTension"]
    local tensionRate = hookedFish["pullStrength"] * 2
    self.tensionBar = TensionBar(initialTension, tensionRate, self)
end

function FishingLine:fishPullOnLine()
    self.hookX += self.fishManager:getPullStrength()
    if self.hookX >= 400 then
        self.hookX = 400
    end
end

function FishingLine:handleReelUpAnimation()
    self.hookY -= self.reelUpSpeed
    if self.hookY <= self.rodY then
        self.hookY = self.rodY
        self:reeledIn(true)
    end
end

function FishingLine:handleCastPhysics()
    self.yVelocity += 9.8/30
    self.hookX += self.xVelocity
    self.hookY += self.yVelocity
    if self.hookY >= self.waterLevel then
        self.splashSound:play()
        self.hookY = self.waterLevel
        self.xVelocity = 0
        self.yVelocity = 0
        self.casting = false
        self.fishingRod.water:impulse(self.hookX)
        self.fishManager = FishManager(self)
    end
end

function FishingLine:handleStruggleIndicator()
    if self.fishManager:isStruggling() then
        self.struggleIndicator:moveTo(self.hookX, self.waterLevel - 30)
        self.struggleIndicator:setVisible(true)
    else
        self.struggleIndicator:setVisible(false)
    end
end