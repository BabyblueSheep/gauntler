TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE = 89

---@return boolean
function TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom()
    local level = Game():GetLevel()
    local roomDescriptor = level:GetCurrentRoomDesc()

    local typeIsCorrect = roomDescriptor.Data.Type == RoomType.ROOM_CHALLENGE
    local subtypesMatch = roomDescriptor.Data.Subtype == TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE

    return typeIsCorrect and subtypesMatch
end

---@param roomDescriptor RoomDescriptor
---@return boolean
function TheGauntlet.GauntletRoom.IsRoomGauntletRoom(roomDescriptor)
    local typeIsCorrect = roomDescriptor.Data.Type == RoomType.ROOM_CHALLENGE
    local subtypesMatch = roomDescriptor.Data.Subtype == TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE

    return typeIsCorrect and subtypesMatch
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_, player)
    local level = Game():GetLevel()

    local rng = RNG(level:GetDungeonPlacementSeed())

    --if rng:RandomFloat() > TheGauntlet.GauntletRoom.GetGenerationChance() then return end

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

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    local room = Game():GetRoom()
    if not room:IsFirstVisit() then return end

    local level = Game():GetLevel()

    local currentRoomDescriptor = level:GetCurrentRoomDesc()
    local neighbourRooms = currentRoomDescriptor:GetNeighboringRooms()
    for doorSlot, roomDescriptorNeighbour in pairs(neighbourRooms) do
        if TheGauntlet.GauntletRoom.IsRoomGauntletRoom(roomDescriptorNeighbour) then
            local doorGridEntity = room:GetDoor(doorSlot):ToDoor()

            doorGridEntity:Close(true)
            doorGridEntity:SetVariant(DoorVariant.DOOR_LOCKED)
            doorGridEntity.State = DoorState.STATE_CLOSED
            doorGridEntity.VarData = 1
            doorGridEntity:SetRoomTypes(RoomType.ROOM_DEFAULT, RoomType.ROOM_SECRET_EXIT)
            doorGridEntity:GetSprite():Load("gfx/grid/door_mausoleum.anm2", true);
            doorGridEntity:Update()
        end
    end
end)