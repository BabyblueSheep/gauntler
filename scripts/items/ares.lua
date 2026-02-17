TheGauntlet.Items.Ares = {}
TheGauntlet.Items.Ares.CollectibleType = Isaac.GetItemIdByName("Ares")

---@param levelGenerator LevelGenerator
TheGauntlet:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, function (_, levelGenerator)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Ares.CollectibleType) then return end

    local rng = RNG(Game():GetLevel():GetDungeonPlacementSeed())
    local deadEnds = levelGenerator:GetDeadEnds()
    TheGauntlet.Utility.ShuffleListInPlace(deadEnds, rng)

    while #deadEnds > 0 do
        local deadEnd = deadEnds[#deadEnds]

        print(deadEnd:Row(), deadEnd:Column(), "Neighbours:")

        for _, neighbour in deadEnd:Neighbors() do
            print(neighbour)
        end
        
        table.remove(deadEnds, #deadEnds)
    end

    --levelGenerator:
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_, player)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Ares.CollectibleType) then return end
    
    local level = Game():GetLevel()



    local rng = RNG(level:GetDungeonPlacementSeed())


    local entranceRoomConfigToPlace = RoomConfig.GetRandomRoom
    (
        rng:Next(),
        true,
        StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        nil, nil,
        0,
        TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE
    )

    local entranceRoomValidPlacementIndexes = level:FindValidRoomPlacementLocations
    (
        entranceRoomConfigToPlace, nil,
        false, false
    )

    if #entranceRoomValidPlacementIndexes == 0 then return end

    level:TryPlaceRoom(entranceRoomConfigToPlace, entranceRoomValidPlacementIndexes[1], nil, rng:Next(), false)

    level:UpdateVisibility()
end)