local NO_COLOR     = { 0.0, 0.0, 0.0, 0.0 }
local WINTER_COLOR = { 0.8, 1.2, 1.5, 0.3 }
local SPRING_COLOR = { 0.0, 1.5, 0.5, 0.1 }
local SUMMER_COLOR = { 2.0, 1.5, 1.0, 0.3 }
local AUTUMN_COLOR = { 1.5, 1.0, 1.0, 0.3 }

local currentColor = TheGauntlet.Utility.CopyTableShallow(NO_COLOR)
local targetColor = TheGauntlet.Utility.CopyTableShallow(NO_COLOR)
local colorUpdateCounter = 0

function TheGauntlet.Items.Demeter.RefreshSeasonVisuals()
    local season = TheGauntlet.Items.Demeter.GetSeason()

    if season == TheGauntlet.Items.Demeter.Season.WINTER then
        targetColor = TheGauntlet.Utility.CopyTableShallow(WINTER_COLOR)
    elseif season == TheGauntlet.Items.Demeter.Season.SPRING then
        targetColor = TheGauntlet.Utility.CopyTableShallow(SPRING_COLOR)
    elseif season == TheGauntlet.Items.Demeter.Season.SUMMER then
        targetColor = TheGauntlet.Utility.CopyTableShallow(SUMMER_COLOR)
    elseif season == TheGauntlet.Items.Demeter.Season.AUTUMN then
        targetColor = TheGauntlet.Utility.CopyTableShallow(AUTUMN_COLOR)
    else
        targetColor = TheGauntlet.Utility.CopyTableShallow(NO_COLOR)
    end

    colorUpdateCounter = 30
end

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    currentColor = TheGauntlet.Utility.CopyTableShallow(NO_COLOR)
    targetColor = TheGauntlet.Utility.CopyTableShallow(NO_COLOR)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shaderName)
    if colorUpdateCounter > 0 then
        currentColor[1] = TheGauntlet.Utility.Lerp(currentColor[1], targetColor[1], 0.05)
        currentColor[2] = TheGauntlet.Utility.Lerp(currentColor[2], targetColor[2], 0.05)
        currentColor[3] = TheGauntlet.Utility.Lerp(currentColor[3], targetColor[3], 0.05)
        currentColor[4] = TheGauntlet.Utility.Lerp(currentColor[4], targetColor[4], 0.05)

        colorUpdateCounter = colorUpdateCounter - 1
    else
        currentColor = TheGauntlet.Utility.CopyTableShallow(targetColor)
    end

    if shaderName ~= "TheGauntlet ScreenColorize" then return end

    if not TheGauntlet.Settings.EnableDemeterTint() then
        return {
            ColorToChangeTo = NO_COLOR
        }
    end

    return {
        ColorToChangeTo = currentColor
    }
end)