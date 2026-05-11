TheGauntlet.Items.Demeter.Constants = {
    SUMMER_NPC_DAMAGE_PER_TICK = 2,
    AUTUMN_NPC_SLOWNESS = 1, --Seems to have an upper cap? Since at 1 they're still very slow
    SPRING_BOOGER_CHANCE = 0.25,
}

local SLOW_COLOR_OFFSET = 40 / 255
local SLOW_COLOR = Color
(
    1, 1, 1.3, 1,
    SLOW_COLOR_OFFSET, SLOW_COLOR_OFFSET, SLOW_COLOR_OFFSET
)



local game = Game()

TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Demeter")

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

    local owner = PlayerManager.FirstCollectibleOwner(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)
    if season == TheGauntlet.Items.Demeter.Season.WINTER then
        npc:AddIce(EntityRef(owner), 30)
    elseif season == TheGauntlet.Items.Demeter.Season.SUMMER then
        npc:AddBurn(EntityRef(owner), 30, TheGauntlet.Items.Demeter.Constants.SUMMER_NPC_DAMAGE_PER_TICK, true)
    elseif season == TheGauntlet.Items.Demeter.Season.AUTUMN then
        npc:AddSlowing(EntityRef(owner), 30, TheGauntlet.Items.Demeter.Constants.AUTUMN_NPC_SLOWNESS, SLOW_COLOR, true)
    end
end)

---@param player EntityPlayer
---@param tearParams TearParams
---@param weaponType WeaponType
---@param damageScale number
---@param tearDisplacement integer
---@param source Entity
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, function (_, player, tearParams, weaponType, damageScale, tearDisplacement, source)
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)

    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.SPRING then
        if rng:RandomFloat() < TheGauntlet.Items.Demeter.Constants.SPRING_BOOGER_CHANCE then
            tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_BOOGER
            tearParams.TearVariant = TearVariant.BOOGER
        end
    end
end)

---@param silent boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, function (_, silent)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE) then return end

    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.NO_SEASON then
        TheGauntlet.Items.Demeter.SetSeason(TheGauntlet.Items.Demeter.Season.WINTER)
    else
        TheGauntlet.Items.Demeter.IncrementSeason()
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_START_GREED_WAVE, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE) then return end

    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.NO_SEASON then
        TheGauntlet.Items.Demeter.SetSeason(TheGauntlet.Items.Demeter.Season.WINTER)
    else
        TheGauntlet.Items.Demeter.IncrementSeason()
    end
end)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param firstTime boolean
---@param wispOrInnate boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_ADDED, function (_, player, collectibleType, firstTime, wispOrInnate)
    if TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.NO_SEASON then
        TheGauntlet.Items.Demeter.SetSeason(TheGauntlet.Items.Demeter.Season.WINTER)
    end
end, TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wispOrInnate boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wispOrInnate)
    if PlayerManager.AnyoneHasCollectible(collectibleType) then return end

    TheGauntlet.Items.Demeter.SetSeason(TheGauntlet.Items.Demeter.Season.NO_SEASON)
end, TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)

---@param statusEffect StatusEffect
---@param entity Entity
---@param source EntityRef
---@param duration integer
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_STATUS_EFFECT_APPLY, function (_, statusEffect, entity, source, duration)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE) then return end
    if TheGauntlet.Items.Demeter.GetSeason() ~= TheGauntlet.Items.Demeter.Season.WINTER then return end
    if statusEffect ~= StatusEffect.POISON then return end

    return duration + 30
end)