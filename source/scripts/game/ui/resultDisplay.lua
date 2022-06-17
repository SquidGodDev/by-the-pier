local pd <const> = playdate
local gfx <const> = pd.graphics

class('ResultDisplay').extends(gfx.sprite)

function ResultDisplay:init(fish, fishingRod)
    self.fishingRod = fishingRod

    local fishCatchSound = pd.sound.sampleplayer.new("sound/FishCatch")
    fishCatchSound:play()

    local notebookImage = gfx.image.new("images/game/notebook")
    gfx.pushContext(notebookImage)
        local imageX = 92
        local imageY = 63
        local fishImage = gfx.image.new("images/game/fish/" .. fish["imagePath"])
        fishImage:drawAnchored(imageX, imageY, 0.5, 0.5)
        local flavorText = string.upper(fish["flavorText"])
        local fishName = "*" .. fish["name"] .. "*"
        gfx.drawTextAligned(fishName, 92, 125, kTextAlignment.center)
        local xmen = gfx.font.new("images/xmenExtended")
        xmen:setTracking(-2)
        xmen:setLeading(7)
        gfx.drawTextInRect(flavorText, 23, 150, 145, 30, nil, nil, kTextAlignment.left, xmen)
        local fishSize = self:calculateSize(fish)
        xmen:setTracking(0)
        xmen:drawTextAligned(fishSize, 92, 182, kTextAlignment.center)
    gfx.popContext()
    self:setImage(notebookImage)

    self.animateTime = 1000
    self.animateIn = gfx.animator.new(self.animateTime, -110, 120, pd.easingFunctions.outCubic)
    self.animateOut = nil

    self:setZIndex(300)
    self:moveTo(200, -120)
    self:add()
end

function ResultDisplay:update()
    if self.animateIn then
        self:moveTo(self.x, self.animateIn:currentValue())
        if self.animateIn:ended() then
            self.animateIn = nil
        end
    elseif self.animateOut then
        self:moveTo(self.x, self.animateOut:currentValue())
        if self.animateOut:ended() then
            self.animateOut = nil
            self.fishingRod:resultDisplayDismissed()
            self:remove()
        end
    else
        if pd.buttonJustPressed(pd.kButtonA) then
            self.animateOut = gfx.animator.new(self.animateTime, 120, -110, pd.easingFunctions.inOutCubic)
        end
    end
end

function ResultDisplay:calculateSize(fish)
    local mean = fish["lengthMean"]
    local variance = fish["lengthVariance"]
    local size = self:gaussian(mean, variance)
    if size <= 1 then
        size = 1
    end

    local newLength = false

    local oldLength = CAUGHT_FISH[fish["name"]]
    if not oldLength or size > oldLength then
        newLength = true
        CAUGHT_FISH[fish["name"]] = size
    end

    local returnString
    if size >= 100 then
        size = math.ceil(size) / 100
        returnString = tostring(size) .. " M"
    else
        size = math.ceil(size * 100) / 100
        returnString = tostring(size) .. " CM"
    end

    if newLength then
        returnString = "NEW - " .. returnString
    end

    return returnString
end

function ResultDisplay:gaussian(mean, variance)
    return  math.sqrt(-2 * variance * math.log(math.random())) *
            math.cos(2 * math.pi * math.random()) + mean
end