local game = Game()

local roomNeighbourOffsets = {
    1, -1, 13, -13
}

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

    local validRoomIndex = entranceRoomValidPlacementIndexes[1]
    
    if level:HasMirrorDimension() then
        validRoomIndex = -1

        for _, potentialRoomIndex in ipairs(entranceRoomValidPlacementIndexes) do
            local isThisRoomValid = true
            
            for _, neighbourOffset in ipairs(roomNeighbourOffsets) do
                local potentialNeighbour = level:GetRoomByIdx(potentialRoomIndex + neighbourOffset)

                if potentialNeighbour.Data ~= nil and potentialNeighbour.Data.Subtype == RoomSubType.DOWNPOUR_MIRROR then
                    isThisRoomValid = false
                end
            end

            if isThisRoomValid then
                validRoomIndex = potentialRoomIndex
                break
            end
        end

        if validRoomIndex == -1 then return end
    end

    local returnValue = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_PLACE_GAUNTLET_ROOM, validRoomIndex, entranceRoomConfigToPlace, Dimension.NORMAL)
    if type(returnValue) == "userdata" and getmetatable(returnValue).__type == "RoomConfigRoom" then
        entranceRoomConfigToPlace = returnValue
    end

    level:TryPlaceRoom(entranceRoomConfigToPlace, validRoomIndex, Dimension.NORMAL, rng:Next(), false)
    Isaac.RunCallback(TheGauntlet.Utility.Callbacks.POST_PLACE_GAUNTLET_ROOM, validRoomIndex, entranceRoomConfigToPlace, Dimension.NORMAL)
    if level:HasMirrorDimension() then
        level:TryPlaceRoom(entranceRoomConfigToPlace, validRoomIndex, Dimension.MIRROR, rng:Next(), false)
        Isaac.RunCallback(TheGauntlet.Utility.Callbacks.POST_PLACE_GAUNTLET_ROOM, validRoomIndex, entranceRoomConfigToPlace, Dimension.MIRROR)
    end

    level:UpdateVisibility()
end)