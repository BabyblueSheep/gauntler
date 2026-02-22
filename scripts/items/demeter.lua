TheGauntlet.Items.Demeter = {}
TheGauntlet.Items.Demeter.CollectibleType = Isaac.GetItemIdByName("Demeter")

local SUMMER_NPC_DAMAGE_PER_TICK = 2
local AUTUMN_NPC_SLOWNESS = 1
local SPRING_BOOGER_CHANCE = 0.25

local SEASON_TYPE = {
    WINTER = 0,
    SPRING = 1,
    SUMMER = 2,
    AUTUMN = 3,
    FALL = 3,
    COUNT = 4,
}

local NO_COLOR     = { 0.0, 0.0, 0.0, 0.0 }
local WINTER_COLOR = { 0.2, 0.2, 1.0, 0.2 }
local SPRING_COLOR = { 0.0, 1.0, 0.5, 0.1 }
local SUMMER_COLOR = { 1.5, 1.0, 0.0, 0.3 }
local AUTUMN_COLOR = { 1.0, 0.0, 0.5, 0.2 }

local currentColor = TheGauntlet.Utility.CopyTable(NO_COLOR)
local targetColor = TheGauntlet.Utility.CopyTable(NO_COLOR)
local colorUpdateCounter = 0

local SLOW_COLOR_OFFSET = 40/255
local SLOW_COLOR = Color(1, 1, 1.3, 1, SLOW_COLOR_OFFSET, SLOW_COLOR_OFFSET, SLOW_COLOR_OFFSET)

local function SetUpSeasonVisuals(season)
    if season == SEASON_TYPE.WINTER then
        targetColor = TheGauntlet.Utility.CopyTable(WINTER_COLOR)
    elseif season == SEASON_TYPE.SPRING then
        targetColor = TheGauntlet.Utility.CopyTable(SPRING_COLOR)
    elseif season == SEASON_TYPE.SUMMER then
        targetColor = TheGauntlet.Utility.CopyTable(SUMMER_COLOR)
    elseif season == SEASON_TYPE.AUTUMN then
        targetColor = TheGauntlet.Utility.CopyTable(AUTUMN_COLOR)
    end

    colorUpdateCounter = 30
end

TheGauntlet:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function (_, shaderName)
    if colorUpdateCounter > 0 then
        currentColor[1] = TheGauntlet.Utility.Lerp(currentColor[1], targetColor[1], 0.05)
        currentColor[2] = TheGauntlet.Utility.Lerp(currentColor[2], targetColor[2], 0.05)
        currentColor[3] = TheGauntlet.Utility.Lerp(currentColor[3], targetColor[3], 0.05)
        currentColor[4] = TheGauntlet.Utility.Lerp(currentColor[4], targetColor[4], 0.05)

        colorUpdateCounter = colorUpdateCounter - 1
    else
        currentColor = TheGauntlet.Utility.CopyTable(targetColor)
    end

    if shaderName ~= "TheGauntlet ScreenColorize" then return end

    return {
        ColorToChangeTo = currentColor
    }
end)

---@param npc EntityNPC
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.EARLY, function (_, npc)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    local owner = PlayerManager.FirstCollectibleOwner(TheGauntlet.Items.Demeter.CollectibleType)
    if runSave.DemeterSeason == SEASON_TYPE.WINTER then
        npc:AddIce(EntityRef(owner), 30)
    elseif runSave.DemeterSeason == SEASON_TYPE.SUMMER then
        npc:AddBurn(EntityRef(owner), 30, SUMMER_NPC_DAMAGE_PER_TICK)
    elseif runSave.DemeterSeason == SEASON_TYPE.AUTUMN then
        npc:AddSlowing(EntityRef(owner), 30, AUTUMN_NPC_SLOWNESS, SLOW_COLOR)
    end
end)

---@param player EntityPlayer
---@param tearParams TearParams
---@param weaponType WeaponType
---@param damageScale number
---@param tearDisplacement integer
---@param source Entity
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, function (_, player, tearParams, weaponType, damageScale, tearDisplacement, source)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.CollectibleType)

    if runSave.DemeterSeason == SEASON_TYPE.SPRING then
        if rng:RandomFloat() < SPRING_BOOGER_CHANCE then
            tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_BOOGER
            tearParams.TearVariant = TearVariant.BOOGER
        end
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then return end

    local room = Game():GetRoom()

    if not room:IsFirstVisit() then return end
    
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    runSave.SavedDemeterSeason = runSave.DemeterSeason
    runSave.DemeterSeason = nil
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then return end

    local room = Game():GetRoom()

    if not room:IsFirstVisit() then return end

    local runSave = TheGauntlet.SaveManager.GetRunSave()

    runSave.DemeterSeason = runSave.SavedDemeterSeason
    runSave.DemeterSeason = runSave.DemeterSeason + 1
    runSave.DemeterSeason = runSave.DemeterSeason % SEASON_TYPE.COUNT
    runSave.SavedDemeterSeason = nil

    SetUpSeasonVisuals(runSave.DemeterSeason)
end)

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    currentColor = TheGauntlet.Utility.CopyTable(NO_COLOR)
    targetColor = TheGauntlet.Utility.CopyTable(NO_COLOR)
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then
        local runSave = TheGauntlet.SaveManager.GetRunSave()
        if runSave.DemeterSeason ~= nil then
            runSave.DemeterSeason = nil

            targetColor = TheGauntlet.Utility.CopyTable(NO_COLOR)
            colorUpdateCounter = 30
        end
    end
end)

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if runSave.DemeterSeason == nil then
        runSave.DemeterSeason = SEASON_TYPE.WINTER

        SetUpSeasonVisuals(runSave.DemeterSeason)
    end
end, TheGauntlet.Items.Demeter.CollectibleType)