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

---@param isContinued boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function (_, isContinued)
    if not isContinued then
        TheGauntlet.SaveManager.GetRunSave().BossChallengeRoomsCompleted = 0
        TheGauntlet.SaveManager.GetRunSave().ChallengeRoomsCompleted = 0
    end
end)


---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, function (_, player)
    --ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR doesn't trigger after completing challenge waves
    --So, use ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR and call only on one player
    if player:GetPlayerIndex() ~= 0 then return end

    local level = Game():GetLevel()

    if level:GetCurrentRoomDesc().Data.Type ~= RoomType.ROOM_CHALLENGE then return end

    if FLOORS_WITH_BOSS_CHALLENGE_ROOMS[level:GetStage()] then
        TheGauntlet.SaveManager.GetRunSave().BossChallengeRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().BossChallengeRoomsCompleted + 1
    else
        TheGauntlet.SaveManager.GetRunSave().ChallengeRoomsCompleted = TheGauntlet.SaveManager.GetRunSave().ChallengeRoomsCompleted + 1
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