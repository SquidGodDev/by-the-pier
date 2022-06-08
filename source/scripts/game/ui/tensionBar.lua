local pd <const> = playdate
local gfx <const> = pd.graphics

class('TensionBar').extends(gfx.sprite)

function TensionBar:init(tension, tensionRate)
    self.tension = tension
    self.tensionRate = tensionRate
end

function TensionBar:increaseTension()
    self.tension += self.tensionRate
end

function TensionBar:update()
    
end