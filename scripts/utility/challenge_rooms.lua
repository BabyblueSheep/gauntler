local game = Game()

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

---Returns whether normal (non-boss) challenge rooms are allowed to spawn on the current floor.
---@return boolean
function TheGauntlet.Utility.CanNormalChallengeRoomsSpawn()
    local level = game:GetLevel()
    local stage = level:GetStage()

    return FLOORS_WITH_CHALLENGE_ROOMS[stage]
end

---Returns whether boss challenge rooms are allowed to spawn on the current floor.
---@return boolean
function TheGauntlet.Utility.CanBossChallengeRoomsSpawn()
    local level = game:GetLevel()
    local stage = level:GetStage()
    
    return FLOORS_WITH_BOSS_CHALLENGE_ROOMS[stage]
end

---Returns whether any challenge rooms are allowed to spawn on the current floor.
---@return boolean
function TheGauntlet.Utility.CanChallengeRoomsSpawn()
    local level = game:GetLevel()
    local stage = level:GetStage()
    
    return FLOORS_WITH_CHALLENGE_ROOMS[stage] or FLOORS_WITH_BOSS_CHALLENGE_ROOMS[stage]
end