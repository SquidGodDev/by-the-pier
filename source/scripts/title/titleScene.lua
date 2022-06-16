
local pd <const> = playdate
local gfx <const> = pd.graphics

class('TitleScene').extends(gfx.sprite)

function TitleScene:init()
    local titleImage = gfx.image.new("images/title/title")
    self:setImage(titleImage)
    self:setZIndex(-200)
    self:moveTo(200, 120)
    self:add()

    local waterImage = gfx.image.new("images/title/water")
    local waterSprite = gfx.sprite.new(waterImage)
    waterSprite:setZIndex(-100)
    waterSprite:moveTo(200, 140)
    waterSprite:add()
    self.waterAnimateTime = 2000
    self.waterOffset = 15
    self.waterEasingFunction = pd.easingFunctions.inOutSine
    self.waterSpriteAnimator = gfx.animator.new(self.waterAnimateTime, 0, self.waterOffset, self.waterEasingFunction)
    self.animatingUp = true
    self.waterSprite = waterSprite

    local fishingRodImage = gfx.image.new("images/title/fishingRod")
    local fishingRodSprite = gfx.sprite.new(fishingRodImage)
    fishingRodSprite:setZIndex(-50)
    fishingRodSprite:moveTo(200, 120)
    fishingRodSprite:add()

    local titleTextSprite = gfx.sprite.new()
    titleTextSprite:moveTo(200, 70)
    titleTextSprite:add()
    self.titleTextSprite = titleTextSprite

    local fadeAnimationTime = 2000
    self.titleTextAnimator = gfx.animator.new(fadeAnimationTime, 0, 1, pd.easingFunctions.inOutCubic)

    local promptStartY = 260
    local promptSprite = gfx.sprite.new()
    promptSprite:moveTo(200, promptStartY)
    local promptText = "Press *A* to Start"
    local promptTextImage = gfx.image.new(gfx.getTextSize(promptText))
    gfx.pushContext(promptTextImage)
        gfx.drawText(promptText, 0, 0)
    gfx.popContext()
    promptSprite:setImage(promptTextImage)
    promptSprite:add()
    self.promptSprite = promptSprite

    local promptAnimationTime = 1500
    local promptTimeOffset = 500
    self.promptAnimator = gfx.animator.new(promptAnimationTime, promptStartY, 210, pd.easingFunctions.inOutCubic, promptTimeOffset)

    local howToPlayImage = gfx.image.new("images/title/howToPlay")
    howToPlaySprite = gfx.sprite.new(howToPlayImage)
    howToPlaySprite:setCenter(0, 0)
    howToPlaySprite:moveTo(350, -70)
    local howToPlaySpriteY = 10
    self.howToPlaySpriteAnimator = gfx.animator.new(promptAnimationTime, howToPlaySprite.y, howToPlaySpriteY, pd.easingFunctions.inOutCubic, promptTimeOffset)
    howToPlaySprite:add()
    self.howToPlaySprite = howToPlaySprite
end

function TitleScene:update()
    if not self.titleTextAnimator:ended() then
        local titleTextImage = gfx.image.new("images/title/titleText")
        local fadedTitle = gfx.image.new(titleTextImage:getSize())
        gfx.pushContext(fadedTitle)
            titleTextImage:drawFaded(0, 0, self.titleTextAnimator:currentValue(), gfx.image.kDitherTypeBayer8x8)
        gfx.popContext()
        self.titleTextSprite:setImage(fadedTitle)
    end
    if not self.promptAnimator:ended() then
        self.promptSprite:moveTo(self.promptSprite.x, self.promptAnimator:currentValue())
    end
    if not self.howToPlaySpriteAnimator:ended() then
        self.howToPlaySprite:moveTo(self.howToPlaySprite.x, self.howToPlaySpriteAnimator:currentValue())
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        SceneManager:switchScene(GameScene)
    end

    if self.waterSpriteAnimator:ended() then
        if self.animatingUp then
            self.waterSpriteAnimator = gfx.animator.new(self.waterAnimateTime, self.waterOffset, 0, self.waterEasingFunction)
        else
            self.waterSpriteAnimator = gfx.animator.new(self.waterAnimateTime, 0, self.waterOffset, self.waterEasingFunction)
        end
        self.animatingUp = not self.animatingUp
    end
    self.waterSprite:moveTo(200, 140 - self.waterSpriteAnimator:currentValue())
end