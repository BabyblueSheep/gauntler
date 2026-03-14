TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE = 89
TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_MINES_SUBTYPE = 90

---@return boolean
function TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom()
    local level = Game():GetLevel()
    local roomDescriptor = level:GetCurrentRoomDesc()

    return TheGauntlet.GauntletRoom.IsRoomGauntletRoom(roomDescriptor)
end

---@param roomDescriptor RoomDescriptor
---@return boolean
function TheGauntlet.GauntletRoom.IsRoomGauntletRoom(roomDescriptor)
    local typeIsCorrect = roomDescriptor.Data.Type == RoomType.ROOM_CHALLENGE
    local subtypesMatch = (roomDescriptor.Data.Subtype == TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE) or (roomDescriptor.Data.Subtype == TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_MINES_SUBTYPE)

    return typeIsCorrect and subtypesMatch
end