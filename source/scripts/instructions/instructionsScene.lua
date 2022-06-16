import "scripts/title/titleScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('InstructionsScene').extends(gfx.sprite)

function InstructionsScene:init()
    SHOW_CRANK_INDICATOR = true
    local instructionImage = gfx.image.new("images/instructions/instructions")
    local width, height = instructionImage:getSize()
    self.maxHeight = -height + 240

    self:setImage(instructionImage)
    self:setCenter(0, 0)
    self:moveTo(0, 0)
    self:setZIndex(-100)
    self:add()
end

function InstructionsScene:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        SceneManager:switchScene(TitleScene)
    end

    local change, acceleratedChange = pd.getCrankChange()
    self:moveBy(0, -change / 3)
    if self.y <= self.maxHeight then
        self:moveTo(0, self.maxHeight)
    elseif self.y >= 0 then
        self:moveTo(0, 0)
    end
end