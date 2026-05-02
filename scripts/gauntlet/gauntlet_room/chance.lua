local game = Game()

TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_CHALLENGE_ROOM = 0.1
TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM = 0.25

TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_IF_ANYONE_OWNS_SAUSAGE = 0.069
TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_IF_ANYONE_OWNS_CHAMPION_BELT = 0.15
TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_IF_ANYONE_OWNS_PURPLE_HEART = 0.15

TheGauntlet.SaveManager.Utility.AddDefaultRunData(TheGauntlet.SaveManager.DefaultSaveKeys.GLOBAL, {
    BossChallengeRoomsCompleted = 0,
    ChallengeRoomsCompleted = 0,
    GauntletRoomsCompleted = 0,

    GauntletGenerationChance = 0,
})

---@param challengeRoomType ChallengeRoomType
TheGauntlet:AddCallback(TheGauntlet.Utility.Callbacks.POST_CHALLENGE_ROOM_TRIGGER_CLEARED, function (_, challengeRoomType)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.NORMAL then
        runSave.ChallengeRoomsCompleted = runSave.ChallengeRoomsCompleted + 1
    elseif challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.BOSS then
        runSave.BossChallengeRoomsCompleted = runSave.BossChallengeRoomsCompleted + 1
    elseif challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.GAUNTLET then
        runSave.GauntletRoomsCompleted = runSave.GauntletRoomsCompleted + 1
    end
end)

local function InnerCalculateChance()
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if game:IsGreedMode() then
        return 0
    end

    if Isaac.GetChallenge() ~= Challenge.CHALLENGE_NULL then
        local challenge = game:GetChallengeParams()
        local roomFilter = challenge:GetRoomFilter()
        for _, roomType in ipairs(roomFilter) do
            if roomType == RoomType.ROOM_CHALLENGE then
                return 0
            end
        end
    end

    local defaultChance = 0.01
    local newChance = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_GAUNTLET_ROOM_GENERATION_CHANCE_GET_DEFAULT_CHANCE, defaultChance)
    if newChance ~= nil and type(newChance) == "number" then
        defaultChance = newChance
    end

    local shouldApplyStagePenalty = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_STAGE_PENALTY)
    if shouldApplyStagePenalty == nil or type(shouldApplyStagePenalty) ~= "boolean" then
        shouldApplyStagePenalty = not TheGauntlet.Utility.CanAnyChallengeRoomsSpawn()
    end

    if shouldApplyStagePenalty then
        return 0
    end

    local shouldApplyGauntletPenalty = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_GAUNTLET_PENALTY)
    if shouldApplyGauntletPenalty == nil or type(shouldApplyGauntletPenalty) ~= "boolean" then
        shouldApplyGauntletPenalty = runSave.GauntletRoomsCompleted > 0
    end

    if shouldApplyGauntletPenalty then
        return defaultChance
    end

    local totalChance = defaultChance

    newChance = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_BOOSTS, totalChance)
    if newChance ~= nil and type(newChance) == "number" then
        totalChance = newChance
    end

    
    local challengeRoomCompletionChance = runSave.ChallengeRoomsCompleted * TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_CHALLENGE_ROOM
    local bossChallengeRoomCompletionChance = runSave.BossChallengeRoomsCompleted * TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM

    local itemChance = 0
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_SAUSAGE) then
        itemChance = itemChance + TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_IF_ANYONE_OWNS_SAUSAGE
    end
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT) then
        itemChance = itemChance + TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_IF_ANYONE_OWNS_CHAMPION_BELT
    end
    if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_PURPLE_HEART) then
        itemChance = itemChance + TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_IF_ANYONE_OWNS_PURPLE_HEART
    end

    totalChance = totalChance + challengeRoomCompletionChance + bossChallengeRoomCompletionChance + itemChance

    newChance = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.POST_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_BOOSTS, totalChance)
    if newChance ~= nil and type(newChance) == "number" then
        totalChance = newChance
    end

    return totalChance
end

---Recomputes the generation chance. Automatically called on new floors.
function TheGauntlet.GauntletRoom.RecomputeGenerationChance()
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    local totalChance = InnerCalculateChance()

    local newChance = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.POST_GAUNTLET_ROOM_GENERATION_CHANCE_CALCULATE, totalChance)
    if newChance ~= nil and type(newChance) == "number" then
        totalChance = newChance
    end

    runSave.GauntletGenerationChance = totalChance
end

---Returns the current Gauntlet Room spawn chance.
function TheGauntlet.GauntletRoom.GetGenerationChance()
    if TheGauntlet.Settings.ForceGauntletSpawn() then
        return 1
    end
    return TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance
end

TheGauntlet:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.EARLY, function (_)
    TheGauntlet.GauntletRoom.RecomputeGenerationChance()
end)

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
---@param varData integer
TheGauntlet:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, collectibleType, rng, player, useFlags, slot, varData)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    runSave.BossChallengeRoomsCompleted = 0
    runSave.ChallengeRoomsCompleted = 0
    runSave.GauntletRoomsCompleted = 0
end, CollectibleType.COLLECTIBLE_R_KEY)