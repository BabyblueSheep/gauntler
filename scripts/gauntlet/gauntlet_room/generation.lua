local game = Game()

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_, player)
    local level = game:GetLevel()

    local rng = RNG(level:GetDungeonPlacementSeed())

    if rng:RandomFloat() > TheGauntlet.GauntletRoom.GetGenerationChance() then return end

    local isOnMines = (level:GetStage() == LevelStage.STAGE2_1 or level:GetStage() == LevelStage.STAGE2_2) and (level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B)
    local subtypeToUse = TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE
    if isOnMines then
        subtypeToUse = TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_MINES_SUBTYPE
    end

    local entranceRoomConfigToPlace = RoomConfig.GetRandomRoom
    (
        rng:Next(),
        true,
        StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        nil, nil,
        0,
        subtypeToUse,
        0
    )

    if entranceRoomConfigToPlace == nil then return end

    local entranceRoomValidPlacementIndexes = level:FindValidRoomPlacementLocations
    (
        entranceRoomConfigToPlace, nil,
        false, false
    )

    if #entranceRoomValidPlacementIndexes == 0 then return end

    level:TryPlaceRoom(entranceRoomConfigToPlace, entranceRoomValidPlacementIndexes[1], nil, rng:Next(), false)

    level:UpdateVisibility()
end)