local game = Game()

TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_CHALLENGE_ROOM = 0.1
TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM = 0.25

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

---Recomputes the generation chance. Automatically called on new floors.
function TheGauntlet.GauntletRoom.RecomputeGenerationChance()
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if game:IsGreedMode() then
        runSave.GauntletGenerationChance = 0
        return
    end

    if Isaac.GetChallenge() ~= Challenge.CHALLENGE_NULL then
        local challenge = game:GetChallengeParams()
        local roomFilter = challenge:GetRoomFilter()
        for _, roomType in ipairs(roomFilter) do
            if roomType == RoomType.ROOM_CHALLENGE then
                runSave.GauntletGenerationChance = 0
                return
            end
        end
    end

    local shouldApplyStagePenalty = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_STAGE_PENALTY)
    if shouldApplyStagePenalty == nil or type(shouldApplyStagePenalty) ~= "boolean" then
        shouldApplyStagePenalty = not TheGauntlet.Utility.CanAnyChallengeRoomsSpawn()
    end

    if shouldApplyStagePenalty then
        runSave.GauntletGenerationChance = 0
        goto skipCalculations
    end

    local defaultChance = 0.01

    local shouldApplyGauntletPenalty = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_GAUNTLET_ROOM_GENERATION_CHANCE_APPLY_GAUNTLET_PENALTY)
    if shouldApplyGauntletPenalty == nil or type(shouldApplyGauntletPenalty) ~= "boolean" then
        shouldApplyGauntletPenalty = runSave.GauntletRoomsCompleted > 0
    end

    if shouldApplyGauntletPenalty then
        runSave.GauntletGenerationChance = defaultChance
        goto skipCalculations
    end

    local challengeRoomCompletionChance = runSave.ChallengeRoomsCompleted * TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_CHALLENGE_ROOM
    local bossChallengeRoomCompletionChance = runSave.BossChallengeRoomsCompleted * TheGauntlet.GauntletRoom.Constants.GENERATION_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM

    local itemChance = 0
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_SAUSAGE) then
        itemChance = itemChance + 0.069
    end

    local totalChance = defaultChance + challengeRoomCompletionChance + bossChallengeRoomCompletionChance + itemChance

    runSave.GauntletGenerationChance = totalChance

    ::skipCalculations::
end

---Returns the current Gauntlet room spawn chance.
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