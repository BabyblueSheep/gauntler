local game = Game()

if StageAPI == nil then return end

local stageAPICallbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.UnregisterCallbacks("The Gauntlet")

---@param originalLayout RoomConfigRoom
TheGauntlet:AddCallback(TheGauntlet.Utility.Callbacks.PRE_SELECT_GAUNTLET_ROOM_WAVE, function (originalLayout)
    local room = game:GetRoom()

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()

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

    local waveConfigurations = TheGauntlet.GauntletRoom.GetDefaultWaveConfigurations()
    local waveConfiguration = waveConfigurations[TheGauntlet.GauntletRoom.GetCurrentWaveNumber()]

    local waveLayoutsToUse = StageAPI.CurrentStage.ChallengeWaves.Normal
    if waveConfiguration.RoomSubtype == RoomSubType.CHALLENGE_WAVE_BOSS then
        waveLayoutsToUse = StageAPI.CurrentStage.ChallengeWaves.Boss
    end

    local wave = StageAPI.ChooseRoomLayout({
        RoomList = waveLayoutsToUse,
        Seed = roomSave.GauntletRoom.WaveSeed,
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

StageAPI.AddCallback("The Gauntlet", stageAPICallbacks.POST_SELECT_STAGE_MUSIC, 1, function (currentstage, musicID, roomType, musicRNG)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = game:GetRoom()

    if room:IsAmbushDone() then return end

    local tempSave = TheGauntlet.DataHolder.GetTemporaryNoHourglassData()

    if not tempSave.GauntletRoom.IsGauntletAmbushOngoing then return end

    return Music.MUSIC_CHALLENGE_FIGHT
end)