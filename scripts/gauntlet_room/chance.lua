local game = Game()

local GAUNTLET_ROOM_CHANCE_PER_COMPLETED_CHALLENGE_ROOM = 0.1
local GAUNTLET_ROOM_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM = 0.25

---@param challengeRoomType ChallengeRoomType
TheGauntlet:AddCallback(TheGauntlet.Utility.Callbacks.POST_CHALLENGE_ROOM_TRIGGER_CLEARED, function (_, challengeRoomType)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if runSave.BossChallengeRoomsCompleted == nil then
        runSave.BossChallengeRoomsCompleted = 0
    end
    if runSave.ChallengeRoomsCompleted == nil then
        runSave.ChallengeRoomsCompleted = 0
    end
    if runSave.GauntletRoomsCompleted == nil then
        runSave.GauntletRoomsCompleted = 0
    end

    if challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.NORMAL then
        runSave.ChallengeRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().ChallengeRoomsCompleted + 1
    elseif challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.BOSS then
        runSave.BossChallengeRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().BossChallengeRoomsCompleted + 1
    elseif challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.GAUNTLET then
        runSave.GauntletRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().GauntletRoomsCompleted + 1
    end

    TheGauntlet.GauntletRoom.RecomputeGenerationChance()
end)

function TheGauntlet.GauntletRoom.RecomputeGenerationChance()
    if game:IsGreedMode() then
        TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance = 0
        return
    end

    if not TheGauntlet.Utility.CanChallengeRoomsSpawn() then
        TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance = 0
        return
    end

    local runSave = TheGauntlet.SaveManager.GetRunSave()

    local defaultChance = 0.01

    if runSave.GauntletRoomsCompleted > 0 then
        TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance = defaultChance
        return
    end

    local challengeRoomCompletionChance = runSave.ChallengeRoomsCompleted * GAUNTLET_ROOM_CHANCE_PER_COMPLETED_CHALLENGE_ROOM
    local bossChallengeRoomCompletionChance = runSave.BossChallengeRoomsCompleted * GAUNTLET_ROOM_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM

    local totalChance = defaultChance + challengeRoomCompletionChance + bossChallengeRoomCompletionChance

    TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance = totalChance
end

function TheGauntlet.GauntletRoom.GetGenerationChance()
    return TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    local runSave = TheGauntlet.SaveManager.GetRunSave()

    if runSave.BossChallengeRoomsCompleted == nil then
        runSave.BossChallengeRoomsCompleted = 0
    end
    if runSave.ChallengeRoomsCompleted == nil then
        runSave.ChallengeRoomsCompleted = 0
    end
    if runSave.GauntletRoomsCompleted == nil then
        runSave.GauntletRoomsCompleted = 0
    end

    TheGauntlet.GauntletRoom.RecomputeGenerationChance()
end)