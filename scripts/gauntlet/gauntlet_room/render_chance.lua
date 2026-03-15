--GIGA lifted from HudHelper the Planetarium Chance mod.
--Also parts were taken from Guantol's decompilation.
--Thank you!!

local game = Game()
local hud = Game():GetHUD()

local oldChanceToDisplay = 0
local chanceToDisplay = 0
local currentChangeDisplayTimer = 0

local CHANCE_DISPLAY_EPSILON = 0.0001

local CHANCE_DIFFERENCE_DISPLAY_DURATION = 150
local CHANCE_DIFFERENCE_DISPLAY_FADEIN_END = 135
local CHANCE_DIFFERENCE_DISPLAY_FADEOUT_START = 30

local hudStatSprite = Sprite("gfx/gauntlet/ui/gauntlet_stat_icon.anm2", true)--Sprite("gfx/ui/hudstats2.anm2", true)
hudStatSprite:Play("Idle")--hudStatSprite:SetFrame("Idle", 8)
hudStatSprite.Color = Color(1, 1, 1, 0.5)

local hudStatFont = Font()
hudStatFont:Load("font/luaminioutlined.fnt")

local function GetStatDisplayOffset(statNumber)
    local hudOffset = Vector(0, 74) --Speed is located at Y 74. Important to keep it that way because co-op/Jacob & Esau add extra distance between all stat indicators
    local distanceBetweenStatIndicators = Vector(0, 12)

    local shiftBecauseOfTrueHudStats = false

    local isAnyoneTaintedBlueBaby = false
    local isAnyoneNotTaintedBlueBaby = false

    for playerIndex, player in ipairs(PlayerManager.GetPlayers()) do
        local playerType = player:GetPlayerType()

        if playerIndex > 1 and player.Parent == nil and playerType == player:GetMainTwin():GetPlayerType() then
            shiftBecauseOfTrueHudStats = true
        end

        if playerType == PlayerType.PLAYER_BLUEBABY_B then
            isAnyoneTaintedBlueBaby = true
        else
            isAnyoneNotTaintedBlueBaby = true
        end
    end

    if Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_JACOB then
        --Why is it different??
        hudOffset = hudOffset + Vector(0, 14)
        distanceBetweenStatIndicators = distanceBetweenStatIndicators + Vector(0, 2)
    elseif shiftBecauseOfTrueHudStats then
        distanceBetweenStatIndicators = distanceBetweenStatIndicators + Vector(0, 2)
    end

    local shiftBecauseOfBothPoopAndBombsExisting = isAnyoneTaintedBlueBaby and isAnyoneNotTaintedBlueBaby
    if shiftBecauseOfBothPoopAndBombsExisting then
        hudOffset = hudOffset + Vector(0, 9)
    end

    local shiftBecauseOfSoulCharge = PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY)
    local shiftBecauseOfBloodCharge = PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY_B)
    if shiftBecauseOfSoulCharge then
        hudOffset = hudOffset + Vector(0, 9)

        --What???
        if shiftBecauseOfBothPoopAndBombsExisting then
            hudOffset = hudOffset + Vector(0, 2)
        end
    end

    if shiftBecauseOfBloodCharge then
        hudOffset = hudOffset + Vector(0, 9)
    end

    --???
    if shiftBecauseOfSoulCharge and shiftBecauseOfBloodCharge then
        hudOffset = hudOffset + Vector(0, 2)
    end

    --Duality removes one of the deal chance displays
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY) and statNumber >= 7 then
        statNumber = statNumber - 1
    end

    hudOffset = hudOffset + distanceBetweenStatIndicators * statNumber + Options.HUDOffset * Vector(20, 12)

    return hudOffset
end

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    chanceToDisplay = TheGauntlet.GauntletRoom.GetGenerationChance()
    oldChanceToDisplay = chanceToDisplay
    currentChangeDisplayTimer = 0
end)

TheGauntlet:AddCallback(ModCallbacks.MC_HUD_POST_UPDATE, function (_)
    local newChance = TheGauntlet.GauntletRoom.GetGenerationChance()

    if math.abs(newChance - chanceToDisplay) > CHANCE_DISPLAY_EPSILON then
        if currentChangeDisplayTimer >= CHANCE_DIFFERENCE_DISPLAY_FADEOUT_START + 1 then
            currentChangeDisplayTimer = math.max(currentChangeDisplayTimer, CHANCE_DIFFERENCE_DISPLAY_FADEIN_END)
        else
            oldChanceToDisplay = chanceToDisplay
            currentChangeDisplayTimer = CHANCE_DIFFERENCE_DISPLAY_DURATION
        end

        chanceToDisplay = newChance
    end

    if currentChangeDisplayTimer > 0 then
        currentChangeDisplayTimer = currentChangeDisplayTimer - 1
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function (_)
    local room = game:GetRoom()
    local level = game:GetLevel()

    if not Options.FoundHUD then return end
    if not hud:IsVisible() then return end
    if game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) then return end
    if room:GetType() == RoomType.ROOM_DUNGEON and level:GetStage() == LevelStage.STAGE8 then return end --Beast room (stats aren't rendered there)

    local hudOffset = GetStatDisplayOffset(9)

    hudStatSprite:Render(hudOffset)

    local baseChanceDisplayed = string.format("%.1f%%", chanceToDisplay * 100)
    hudStatFont:DrawString
    (
        baseChanceDisplayed,
        hudOffset.X + 16 + game.ScreenShakeOffset.X, hudOffset.Y + 1 + game.ScreenShakeOffset.Y,
        KColor(1, 1, 1, 0.5),
        0, false
    )


    local differenceChance = chanceToDisplay - oldChanceToDisplay

    if math.abs(differenceChance) < CHANCE_DISPLAY_EPSILON then return end

    local differenceChanceDisplayed = string.format("%.1f%%", differenceChance * 100)
    if differenceChance > 0 then
        differenceChanceDisplayed = "+"..differenceChanceDisplayed
    end
    local differenceTextAlpha = 1.0
    local differenceTextOffsetX = 0

    if currentChangeDisplayTimer > CHANCE_DIFFERENCE_DISPLAY_FADEIN_END then
        local fadeInProgress = TheGauntlet.Utility.InverseLerp(CHANCE_DIFFERENCE_DISPLAY_DURATION, CHANCE_DIFFERENCE_DISPLAY_FADEIN_END, currentChangeDisplayTimer)
        local easedProgress = (1.0 - fadeInProgress) ^ 2 --Quadratic ease-in

        differenceTextAlpha = fadeInProgress
        differenceTextOffsetX = easedProgress * -20.0
    elseif currentChangeDisplayTimer <= CHANCE_DIFFERENCE_DISPLAY_FADEOUT_START then
        local fadeOutProgress = TheGauntlet.Utility.InverseLerp(0.0, CHANCE_DIFFERENCE_DISPLAY_FADEOUT_START, currentChangeDisplayTimer)
        differenceTextAlpha = fadeOutProgress
    end

    local differenceTextColor = KColor(0.03, 0.9, 0.03, differenceTextAlpha * 0.5)
    if differenceChance < 0 then
        differenceTextColor = KColor(0.9, 0.03, 0.03, differenceTextAlpha * 0.5)
    end

    hudStatFont:DrawString
    (
        differenceChanceDisplayed,
        hudOffset.X + 16 + 30 + differenceTextOffsetX + game.ScreenShakeOffset.X, hudOffset.Y + 1 + game.ScreenShakeOffset.Y,
        differenceTextColor,
        0, false
    )
end)