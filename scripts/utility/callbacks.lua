TheGauntlet.Utility.Callbacks = {
    ---Called when finishing all waves of a challenge room.
    ---
    ---Parameters:
    --- - [ChallengeRoomType](lua://ChallengeRoomType) - the type of the current challenge room;
    ---
    ---Optional Parameter:
    --- - [ChallengeRoomType](lua://ChallengeRoomType) - the type of the current challenge room;
    POST_CHALLENGE_ROOM_TRIGGER_CLEARED = "TheGauntlet POST_CHALLENGE_ROOM_TRIGGER_CLEARED",

    ---Called before Apollo refreshes its path to the boss room. Can be used to modify the list of rooms that grant a damage up.
    ---
    ---Returns:
    --- - Return an [integer](lua://integer) to set the boss room to path towards.ItemConfig.CARDTYPE_SPECIAL_OBJECT.<br>
    --- - Alternatively, return a [table](lua://table) in the form of an integer list to set a custom list of rooms. 
    PRE_APOLLO_REFRESH_PATH_TO_BOSS = "TheGauntlet PRE_APOLLO_REFRESH_PATH_TO_BOSS",
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

        Isaac.RunCallbackWithParam(TheGauntlet.Utility.Callbacks.POST_CHALLENGE_ROOM_TRIGGER_CLEARED, roomType, roomType)
    end

    roomSave.WasAmbushDone = room:IsAmbushDone()
end)