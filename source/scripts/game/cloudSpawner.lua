import "scripts/game/cloud"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('CloudSpawner').extends(gfx.sprite)

function CloudSpawner:init()
    self.cloudCount = 7
    self.cloudArray = {}
    for i=1,self.cloudCount do
        local cloudImage = gfx.image.new("images/game/clouds/cloud" .. i)
        table.insert(self.cloudArray, cloudImage)
    end

    self.cloudSpawnMin = 60
    self.cloudSpawnMax = 150
    self.cloudTimer = 0

    self.spawnYMin = 0
    self.spawnYMax = 80

    self:add()
end

function CloudSpawner:update()
    self.cloudTimer -= 1
    if self.cloudTimer <= 0 then
        self.cloudTimer = math.random(self.cloudSpawnMin, self.cloudSpawnMax)
        local spawnY = math.random(self.spawnYMin, self.spawnYMax)
        local cloudImage = self.cloudArray[math.random(self.cloudCount)]
        Cloud(false, 440, spawnY, cloudImage)
    end
end