
local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SceneManager').extends()

function SceneManager:init()
    self.waveWidth = 416

    self.transitionTime = 1200
    self.transitioningIn = false

    self.transitionSound = pd.sound.sampleplayer.new("sound/RiverTransition")
end

function SceneManager:switchScene(scene)
    if self.transitioningIn then
        return
    end
    self.transitionAnimator = gfx.animator.new(self.transitionTime, self.waveWidth, 0, pd.easingFunctions.outCubic)
    self.transitioningIn = true

    self.transitionSound:play()
    self.newScene = scene
    self:createTransitionSprite(false)
end

function SceneManager:loadNewScene()
    gfx.sprite.removeAll()
    self:createTransitionSprite(true)
    self.transitionAnimator = gfx.animator.new(self.transitionTime, 0, self.waveWidth, pd.easingFunctions.inCubic)
    self.transitioningIn = false
    self.newScene()
end

function SceneManager:update()
    if self.transitionAnimator then
        local transitionValue = self.transitionAnimator:currentValue()
        self.transitionSprite:moveTo(-transitionValue, -transitionValue / 2)
        if self.transitioningIn and self.transitionAnimator:ended() then
            self:loadNewScene()
            -- self.transitionOutSound:play()
        elseif self.transitionAnimator:ended() then
            self.transitionAnimator = nil
        end
    end
end

function SceneManager:createTransitionSprite(filled)
    self.transitionSprite = gfx.sprite.new()
    self.transitionSprite:setCenter(0, 0)
    local waveImage = gfx.image.new("images/wave")
    self.transitionSprite:setImage(waveImage)
    if filled then
        self.transitionSprite:moveTo(0, 0)
    else
        self.transitionSprite:moveTo(-self.waveWidth, 0)
    end
    self.transitionSprite:setIgnoresDrawOffset(true)
    self.transitionSprite:setZIndex(1000)
    self.transitionSprite:add()
end