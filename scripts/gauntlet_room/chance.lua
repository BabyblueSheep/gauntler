local GAUNTLET_ROOM_CHANCE_PER_COMPLETED_CHALLENGE_ROOM = 0.1
local GAUNTLET_ROOM_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM = 0.25

local FLOORS_WITH_BOSS_CHALLENGE_ROOMS = {
    [LevelStage.STAGE1_2] = true,
    [LevelStage.STAGE2_2] = true,
    [LevelStage.STAGE3_2] = true,
    [LevelStage.STAGE4_2] = true,
}

local FLOORS_WITH_CHALLENGE_ROOMS = {
    [LevelStage.STAGE2_1] = true,
    [LevelStage.STAGE3_1] = true,
    [LevelStage.STAGE4_1] = true,
    [LevelStage.STAGE5] = true,
}

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    local room = Game():GetRoom()
    local level = Game():GetLevel()

    if level:GetCurrentRoomDesc().Data.Type ~= RoomType.ROOM_CHALLENGE then return end

    local runSave = TheGauntlet.SaveManager.GetRunSave()
    local roomSave = TheGauntlet.SaveManager.GetRoomSave()

    if roomSave.RoomAccountedFor == true then return end

    if room:IsAmbushDone() then
        if runSave.BossChallengeRoomsCompleted == nil then
            runSave.BossChallengeRoomsCompleted = 0
        end
        if runSave.ChallengeRoomsCompleted == nil then
            runSave.ChallengeRoomsCompleted = 0
        end

        roomSave.RoomAccountedFor = true

        if level:GetCurrentRoomDesc().Data.Subtype == 1 then
            runSave.BossChallengeRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().BossChallengeRoomsCompleted + 1
        else
            runSave.ChallengeRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().ChallengeRoomsCompleted + 1
        end
    end
end)

function TheGauntlet.GauntletRoom.RecomputeGenerationChance()
    local stage = Game():GetLevel():GetStage()
    if not FLOORS_WITH_CHALLENGE_ROOMS[stage] and not FLOORS_WITH_BOSS_CHALLENGE_ROOMS[stage] then
        return 0
    end

    local defaultChance = 0.01

    local challengeRoomCompletionChance = TheGauntlet.SaveManager.GetRunSave().ChallengeRoomsCompleted * GAUNTLET_ROOM_CHANCE_PER_COMPLETED_CHALLENGE_ROOM
    local bossChallengeRoomCompletionChance = TheGauntlet.SaveManager.GetRunSave().BossChallengeRoomsCompleted * GAUNTLET_ROOM_CHANCE_PER_COMPLETED_BOSS_CHALLENGE_ROOM

    local totalChance = defaultChance + challengeRoomCompletionChance + bossChallengeRoomCompletionChance

    TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance = totalChance
end

function TheGauntlet.GauntletRoom.GetGenerationChance()
    return TheGauntlet.SaveManager.GetRunSave().GauntletGenerationChance
end