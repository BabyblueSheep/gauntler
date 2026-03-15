local game = Game()

local GAUNTLET_ROOM_CHANCE_PER_COMPLETED_CHALLENGE_ROOM = 0.1
local GAUNTLET_ROOM_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM = 0.25

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

function TheGauntlet.GauntletRoom.RecomputeGenerationChance()
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if game:IsGreedMode() then
        runSave.GauntletGenerationChance = 0
        return
    end

    if not TheGauntlet.Utility.CanChallengeRoomsSpawn() then
        runSave.GauntletGenerationChance = 0
        return
    end

    local defaultChance = 0.01

    if runSave.GauntletRoomsCompleted > 0 then
        runSave.GauntletGenerationChance = defaultChance
        return
    end

    local challengeRoomCompletionChance = runSave.ChallengeRoomsCompleted * GAUNTLET_ROOM_CHANCE_PER_COMPLETED_CHALLENGE_ROOM
    local bossChallengeRoomCompletionChance = runSave.BossChallengeRoomsCompleted * GAUNTLET_ROOM_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM

    local totalChance = defaultChance + challengeRoomCompletionChance + bossChallengeRoomCompletionChance

    runSave.GauntletGenerationChance = totalChance
end

function TheGauntlet.GauntletRoom.GetGenerationChance()
    return TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance
end

TheGauntlet:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.EARLY, function (_)
    TheGauntlet.GauntletRoom.RecomputeGenerationChance()
end)