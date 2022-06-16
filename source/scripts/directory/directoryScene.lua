local pd <const> = playdate
local gfx <const> = pd.graphics

local fishTable = json.decodeFile("fish.json")

class('DirectoryScene').extends(gfx.sprite)

function DirectoryScene:init()
    local fishes = self:populateFishArray()
    local fishCount = #fishes
    self.listview = pd.ui.gridview.new(0, 40)
    self.listview.backgroundImage = gfx.nineSlice.new('images/directory/directoryBackground', 4, 4, 26, 26)
    self.listview:setNumberOfRows(fishCount)
    -- self.listview:setCellPadding(0, 0, 13, 10)
    -- self.listview:setContentInset(24, 24, 13, 11)

    local notebookSprite = gfx.sprite.new()
    notebookSprite:setCenter(0, 0)
    notebookSprite:moveTo(200, 20)
    notebookSprite:add()

    function self.listview:drawCell(section, row, column, selected, x, y, width, height)
        local curFishData = fishes[row]
        local curFish = curFishData[1]
        local maxLength = curFishData[2]
        local fishName = curFish["name"]
        local fishImage = gfx.image.new("images/game/fish/" .. curFish["imagePath"])
        local flavorText = string.upper(curFish["flavorText"])

        if maxLength == -1 then
            fishName = "?????"
            fishImage = gfx.image.new("images/directory/questionMark")
            flavorText = "?????"
        end

        if selected then
            local notebookImage = gfx.image.new("images/game/notebook")
            gfx.pushContext(notebookImage)
                local imageX = 92
                local imageY = 63
                fishImage:drawAnchored(imageX, imageY, 0.5, 0.5)
                gfx.drawTextAligned("*" .. fishName .. "*", 92, 125, kTextAlignment.center)
                local xmen = gfx.font.new("images/xmenExtended")
                xmen:setTracking(-2)
                xmen:setLeading(7)
                gfx.drawTextInRect(flavorText, 23, 150, 145, 30, nil, nil, kTextAlignment.left, xmen)
                xmen:setTracking(0)
                if maxLength ~= -1 then
                    local maxLengthText
                    if maxLength >= 100 then
                        maxLength = math.ceil(maxLength) / 100
                        maxLengthText = tostring(maxLength) .. " M"
                    else
                        maxLength = math.ceil(maxLength * 100) / 100
                        maxLengthText = tostring(maxLength) .. " CM"
                    end
                    xmen:drawTextAligned(maxLengthText, 92, 182, kTextAlignment.center)
                end
            gfx.popContext()
            notebookSprite:setImage(notebookImage)
            gfx.fillRoundRect(x, y, width, height, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end

        gfx.drawTextInRect(fishName, x, y + height/4, width, height, nil, "...", kTextAlignment.center)
    end

    self:setCenter(0, 0)
    self:moveTo(0, 0)
    self:add()
end

function DirectoryScene:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        SceneManager:switchScene(TitleScene)
    end

    local listImage = gfx.image.new(400, 240)
    gfx.pushContext(listImage)
        self.listview:drawInRect(20, 20, 150, 210)
    gfx.popContext()
    self:setImage(listImage)

    if pd.buttonJustPressed(pd.kButtonUp) then
        self.listview:selectPreviousRow(true)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.listview:selectNextRow(true)
    end
end

function DirectoryScene:populateFishArray()
    local fishes = {}
    for i,fish in ipairs(fishTable["close"]) do
        fishes = self:addFish(fishes, fish)
    end
    for i,fish in ipairs(fishTable["mid"]) do
        fishes = self:addFish(fishes, fish)
    end
    for i,fish in ipairs(fishTable["far"]) do
        fishes = self:addFish(fishes, fish)
    end

    return fishes
end

function DirectoryScene:addFish(fishes, fish)
    local fishName = fish["name"]
    local biggestCatchSize = CAUGHT_FISH[fishName]
    if biggestCatchSize then
        table.insert(fishes, {fish, biggestCatchSize})
    else
        table.insert(fishes, {fish, -1})
    end
    return fishes
end