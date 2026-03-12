local SUMMER_NPC_DAMAGE_PER_TICK = 2
local AUTUMN_NPC_SLOWNESS = 1 --Seems to have an upper cap? Since at 1 they're still very slow
local SPRING_BOOGER_CHANCE = 0.25


local SLOW_COLOR_OFFSET = 40 / 255
local SLOW_COLOR = Color
(
    1, 1, 1.3, 1,
    SLOW_COLOR_OFFSET, SLOW_COLOR_OFFSET, SLOW_COLOR_OFFSET
)



local game = Game()

TheGauntlet.Items.Demeter.CollectibleType = Isaac.GetItemIdByName("Demeter")

---@enum Season
TheGauntlet.Items.Demeter.Season = {
    NO_SEASON = -1,
    WINTER = 0,
    SPRING = 1,
    SUMMER = 2,
    AUTUMN = 3,
    FALL = 3,
    COUNT = 4,
}

TheGauntlet.SaveManager.Utility.AddDefaultRunData(TheGauntlet.SaveManager.DefaultSaveKeys.GLOBAL, {
    DemeterCurrentSeason = TheGauntlet.Items.Demeter.Season.NO_SEASON,
    DemeterTempSavedSeason = nil,
})

---Returns the current Demeter season.
---@return Season
function TheGauntlet.Items.Demeter.GetSeason()
    return TheGauntlet.SaveManager.GetRunSave().DemeterCurrentSeason
end

---Sets the current Demeter season.
---@param value Season
function TheGauntlet.Items.Demeter.SetSeason(value)
    TheGauntlet.SaveManager.GetRunSave().DemeterCurrentSeason = value
    TheGauntlet.Items.Demeter.RefreshSeasonVisuals()
end

---If Demeter is active, increments the season by one (winter -> spring -> summer -> autumn -> winter -> ...). Otherwise, does nothing
function TheGauntlet.Items.Demeter.IncrementSeason()
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if runSave.DemeterCurrentSeason == TheGauntlet.Items.Demeter.Season.NO_SEASON then return end

    runSave.DemeterCurrentSeason = runSave.DemeterCurrentSeason + 1
    runSave.DemeterCurrentSeason = runSave.DemeterCurrentSeason % TheGauntlet.Items.Demeter.Season.COUNT

    TheGauntlet.Items.Demeter.RefreshSeasonVisuals()
end

---@param npc EntityNPC
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.EARLY, function (_, npc)
    local season = TheGauntlet.Items.Demeter.GetSeason()

    local owner = PlayerManager.FirstCollectibleOwner(TheGauntlet.Items.Demeter.CollectibleType)
    if season == TheGauntlet.Items.Demeter.Season.WINTER then
        npc:AddIce(EntityRef(owner), 30)
    elseif season == TheGauntlet.Items.Demeter.Season.SUMMER then
        npc:AddBurn(EntityRef(owner), 30, SUMMER_NPC_DAMAGE_PER_TICK)
    elseif season == TheGauntlet.Items.Demeter.Season.AUTUMN then
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
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.CollectibleType)

    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.SPRING then
        if rng:RandomFloat() < SPRING_BOOGER_CHANCE then
            tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_BOOGER
            tearParams.TearVariant = TearVariant.BOOGER
        end
    end
end)

--The current season needs to be unset because enemies spawn before MC_POST_NEW_ROOM is called (so, enemies spawn with the effects of the previous season).
--But, MC_POST_NEW_ROOM still needs to be used because Room:IsFirstVisit() fails in MC_PRE_NEW_ROOM.
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then return end

    local room = game:GetRoom()

    if not room:IsFirstVisit() then return end
    
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    runSave.DemeterTempSavedSeason = runSave.DemeterCurrentSeason
    runSave.DemeterCurrentSeason = nil
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.CollectibleType) then return end

    local room = game:GetRoom()

    if not room:IsFirstVisit() then return end

    local runSave = TheGauntlet.SaveManager.GetRunSave()

    runSave.DemeterCurrentSeason = runSave.DemeterTempSavedSeason
    runSave.DemeterTempSavedSeason = nil

    TheGauntlet.Items.Demeter.IncrementSeason()
end)

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.NO_SEASON then
        TheGauntlet.Items.Demeter.SetSeason(TheGauntlet.Items.Demeter.Season.WINTER)
    end
end, TheGauntlet.Items.Demeter.CollectibleType)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wisp boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wisp)
    if PlayerManager.AnyoneHasCollectible(collectibleType) then return end

    TheGauntlet.Items.Demeter.SetSeason(TheGauntlet.Items.Demeter.Season.NO_SEASON)
end, TheGauntlet.Items.Apollo.CollectibleType)