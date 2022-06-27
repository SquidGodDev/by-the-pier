-- Basically the same as the scene manager from Escape from Complex 32, so I won't re-explain everything, except for
-- two changes. First is that I made it a wave transition, and second is I made it not a sprite anymore. What I found was
-- I didn't like having the scene manager itself be a sprite, because if you ever called removeAll on sprites, you would lose
-- the ability to switch to new scenes and would have to reinstantiate the scene manager. So, I made it so the update method
-- gets called in main.lua. I think that's much cleaner/better

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
    if self.repeatingSound then
        self.repeatingSound:stop()
    end
    gfx.sprite.removeAll()
    self:createTransitionSprite(true)
    self.transitionAnimator = gfx.animator.new(self.transitionTime, 0, self.waveWidth, pd.easingFunctions.inCubic)
    self.transitioningIn = false
    self.newScene()
end

-- Not a sprite update method. It gets called in main.lua manually
function SceneManager:update()
    if self.transitionAnimator then
        local transitionValue = self.transitionAnimator:currentValue()
        -- To get the wave to move vertically as well as horizontally, I basically created
        -- an image of a wave that was a little bigger than the screen, and I move it up/down as
        -- I'm moving it right/left at a rate that is half the horizontal rate
        self.transitionSprite:moveTo(-transitionValue, -transitionValue / 2)
        if self.transitioningIn and self.transitionAnimator:ended() then
            self:loadNewScene()
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

-- This handles the ocean waves sound. I found it helpful to make it sort of a global soud
function SceneManager:playRepeatingSound(soundSample)
    self.repeatingSound = soundSample
    self.repeatingSound:play(0)
end