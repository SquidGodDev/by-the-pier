local pd <const> = playdate
local gfx <const> = pd.graphics

class('CatchTimer').extends(gfx.sprite)

function CatchTimer:init(time, fishingLine)
    self.time = math.random(math.ceil(time * 0.8), math.ceil(time * 1.2))
    self.timeRemaining = self.time
    self.fishingLine = fishingLine
    self.timerWidth = 200
    self.timerHeight = 15
    self.timerCornerRadius = 5
    local timerBackgroundImage = gfx.image.new(self.timerWidth, self.timerHeight)
    gfx.pushContext(timerBackgroundImage)
        gfx.fillRoundRect(0, 0, self.timerWidth, self.timerHeight, self.timerCornerRadius)
    gfx.popContext()
    self:setImage(timerBackgroundImage)

    local fishIconImage = gfx.image.new("images/game/fishIcon")
    self.fishSprite = gfx.sprite.new(fishIconImage)
    self:setZIndex(100)
    self.fishSprite:setZIndex(101)

    self.transitionTime = 800
    self.timerOffScreenY = -10
    self.timerY = 20
    self.enterAnimator = gfx.animator.new(self.transitionTime, self.timerOffScreenY, self.timerY, pd.easingFunctions.inOutCubic)
    self.exitAnimator = nil

    self.timerRunning = true

    self:moveTo(200, self.timerOffScreenY)
    self.fishSpriteStartX = 200 + self.timerWidth / 2
    self.fishSprite:moveTo(200 + self.timerWidth / 2, self.timerOffScreenY)

    self:add()
    self.fishSprite:add()

    self.lineSnapSound = pd.sound.sampleplayer.new("sound/LineSnap")
end

function CatchTimer:endTimer()
    self.timerRunning = false
    if not self.exitAnimator then
        self.exitAnimator = gfx.animator.new(self.transitionTime, self.timerY, self.timerOffScreenY, pd.easingFunctions.inOutCubic)
    end
end

function CatchTimer:update()
    if self.enterAnimator then
        local yPos = self.enterAnimator:currentValue()
        self:moveTo(self.x, yPos)
        self.fishSprite:moveTo(self.fishSprite.x, yPos)
        if self.enterAnimator:ended() then
            self.enterAnimator = nil
        end
    elseif self.exitAnimator then
        local yPos = self.exitAnimator:currentValue()
        self:moveTo(self.x, yPos)
        self.fishSprite:moveTo(self.fishSprite.x, yPos)
        if self.exitAnimator:ended() then
            self:remove()
        end
    end

    if self.timerRunning then
        local newFishX = self.x - (self.timerWidth / 2) + (self.timeRemaining / self.time) * self.timerWidth
        newFishX = math.floor(newFishX)
        self.fishSprite:moveTo(newFishX, self.fishSprite.y)
        self.timeRemaining -= 1
        if self.timeRemaining <= 0 then
            self.lineSnapSound:play()
            self.fishingLine:reeledIn(false)
        end
    end
end