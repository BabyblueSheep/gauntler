local game = Game()

---@param originalLayout RoomConfigRoom
TheGauntlet:AddCallback(TheGauntlet.Utility.Callbacks.PRE_SELECT_GAUNTLET_ROOM_WAVE, function (originalLayout)
    local room = game:GetRoom()

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local tempSave = TheGauntlet.SaveManager.GetTempSave()

    if StageAPI == nil then return end

    if StageAPI.CurrentStage == nil then return end
    if StageAPI.CurrentStage.ChallengeWaves == nil then return end

    local currentStageAPIRoom = StageAPI.GetCurrentRoom()
    local challengeWaveIDs
    if currentStageAPIRoom then
        StageAPI.Challenge.WaveSubtype = currentStageAPIRoom.Layout.SubType

        if not currentStageAPIRoom.Data.ChallengeWaveIDs then
            currentStageAPIRoom.Data.ChallengeWaveIDs = {}
        end

        challengeWaveIDs = currentStageAPIRoom.Data.ChallengeWaveIDs
    end

    local waveConfigurations = Game().Difficulty == Difficulty.DIFFICULTY_HARD and TheGauntlet.GauntletRoom.WAVE_CONFIGURATIONS_HARD_MODE or TheGauntlet.GauntletRoom.WAVE_CONFIGURATIONS_NORMAL_MODE
    local waveConfiguration = waveConfigurations[tempSave.WaveNumber]

    local waveLayoutsToUse = StageAPI.CurrentStage.ChallengeWaves.Normal
    if waveConfiguration.RoomSubtype == RoomSubType.CHALLENGE_WAVE_BOSS then
        waveLayoutsToUse = StageAPI.CurrentStage.ChallengeWaves.Boss
    end

    local wave = StageAPI.ChooseRoomLayout({
        RoomList = waveLayoutsToUse,
        Seed = roomSave.WaveSeed,
        Shape = room:GetRoomShape(),
        RoomType = room:GetType(),
        RequireRoomType = false,
        Doors = nil,
        IgnoreDoors = false,
        DisallowIDs = challengeWaveIDs,
        MinDifficulty = waveConfiguration.MinDifficulty,
        MaxDifficulty = waveConfiguration.MaxDifficulty,
    })

    if currentStageAPIRoom then
        table.insert(currentStageAPIRoom.Data.ChallengeWaveIDs, wave.StageAPIID)
    end

    return wave
end)