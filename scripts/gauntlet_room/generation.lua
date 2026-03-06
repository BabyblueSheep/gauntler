local game = Game()

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_, player)
    local level = Game():GetLevel()

    if game:IsGreedMode() then return end

    local rng = RNG(level:GetDungeonPlacementSeed())

    if rng:RandomFloat() > TheGauntlet.GauntletRoom.GetGenerationChance() then return end

    local entranceRoomConfigToPlace = RoomConfig.GetRandomRoom
    (
        rng:Next(),
        true,
        StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        nil, nil,
        0,
        TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE,
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