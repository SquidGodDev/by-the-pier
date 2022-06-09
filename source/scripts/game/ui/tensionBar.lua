local pd <const> = playdate
local gfx <const> = pd.graphics

class('TensionBar').extends(gfx.sprite)

function TensionBar:init(tension, tensionRate, fishingLine)
    self.tension = tension
    self.tensionRate = tensionRate
    self.fishingLine = fishingLine
    self.tensionLossVelocity = 0
    self.tensionLossAcceleration = 0.05
    self.maxTension = 100

    self.tensionBarWidth = 15
    self.tensionBarHeight = 120
    self.tensionBarCornerRadius = 2

    self.tensionBarRunning = true

    local tensionBarImage = gfx.image.new(self.tensionBarWidth, self.tensionBarHeight)
    gfx.pushContext(tensionBarImage)
        gfx.drawRoundRect(0, 0, self.tensionBarWidth, self.tensionBarHeight, self.tensionBarCornerRadius)
    gfx.popContext()
    self:setImage(tensionBarImage)

    local lineBreakIconImage = gfx.image.new("images/game/lineBreakIcon")
    self.lineBreakIcon = gfx.sprite.new(lineBreakIconImage)

    self.transitionTime = 800
    self.offScreenX = 420
    self.tensionBarX = 380
    self.enterAnimator = gfx.animator.new(self.transitionTime, self.offScreenX, self.tensionBarX, pd.easingFunctions.inOutCubic)
    self.exitAnimator = nil

    self.tensionBarY = 100
    self:moveTo(self.offScreenX, self.tensionBarY)
    self.lineBreakIcon:moveTo(self.offScreenX, self.tensionBarY - self.tensionBarHeight / 2 - 15)

    self:add()
    self.lineBreakIcon:add()
end

function TensionBar:drawTensionBar()
    local tensionLevelHeight = (self.tension / self.maxTension) * self.tensionBarHeight
    local tensionLevelY = self.tensionBarHeight - tensionLevelHeight
    local tensionBarImage = gfx.image.new(self.tensionBarWidth, self.tensionBarHeight)
    print(self.tension)
    gfx.pushContext(tensionBarImage)
        gfx.drawRoundRect(0, 0, self.tensionBarWidth, self.tensionBarHeight, self.tensionBarCornerRadius)
        gfx.fillRoundRect(0, tensionLevelY, self.tensionBarWidth, tensionLevelHeight, self.tensionBarCornerRadius)
    gfx.popContext()
    self:setImage(tensionBarImage)
end

function TensionBar:increaseTension()
    if self.tensionBarRunning then
        self.tension += self.tensionRate
        self.tensionLossVelocity = 0
        if self.tension >= self.maxTension then
            self.fishingLine:reeledIn()
        end
    end
end

function TensionBar:stopTensionBar()
    self.tensionBarRunning = false
    if not self.exitAnimator then
        self.exitAnimator = gfx.animator.new(self.transitionTime, self.tensionBarX, self.offScreenX, pd.easingFunctions.inOutCubic)
    end
end

function TensionBar:update()
    if self.enterAnimator then
        local xPos = self.enterAnimator:currentValue()
        self:moveTo(xPos, self.y)
        self.lineBreakIcon:moveTo(xPos, self.lineBreakIcon.y)
        if self.enterAnimator:ended() then
            self.enterAnimator = nil
        end
    elseif self.exitAnimator then
        local xPos = self.exitAnimator:currentValue()
        self:moveTo(xPos, self.y)
        self.lineBreakIcon:moveTo(xPos, self.lineBreakIcon.y)
        if self.exitAnimator:ended() then
            self:remove()
        end
    end

    if self.tensionBarRunning then
        self.tensionLossVelocity += self.tensionLossAcceleration
        self.tension -= self.tensionLossVelocity
        if self.tension <= 0 then
            self.tension = 0
        end
        self:drawTensionBar()
    end
end