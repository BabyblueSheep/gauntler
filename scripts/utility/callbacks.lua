TheGauntlet.Utility.Callbacks = {
    POST_CHALLENGE_ROOM_TRIGGER_CLEARED = "TheGauntlet POST_CHALLENGE_ROOM_TRIGGER_CLEARED"
}

---@enum ChallengeRoomType
TheGauntlet.Utility.ChallengeRoomType = {
    NORMAL = 0,
    BOSS = 1,
    GAUNTLET = 2,
}

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    local room = Game():GetRoom()
    local level = Game():GetLevel()

    if level:GetCurrentRoomDesc().Data.Type ~= RoomType.ROOM_CHALLENGE then return end

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()

    if roomSave.WasAmbushDone == nil then
        roomSave.WasAmbushDone = room:IsAmbushDone()
    end
    
    if room:IsAmbushDone() and not roomSave.WasAmbushDone then
        local roomType = TheGauntlet.Utility.ChallengeRoomType.NORMAL
        if level:GetCurrentRoomDesc().Data.Subtype == TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE then
            roomType = TheGauntlet.Utility.ChallengeRoomType.GAUNTLET
        elseif level:GetCurrentRoomDesc().Data.Subtype == RoomSubType.CHALLENGE_BOSS then
            roomType = TheGauntlet.Utility.ChallengeRoomType.BOSS
        end

        Isaac.RunCallback(TheGauntlet.Utility.Callbacks.POST_CHALLENGE_ROOM_TRIGGER_CLEARED, roomType)
    end

    roomSave.WasAmbushDone = room:IsAmbushDone()
end)