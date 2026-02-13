TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = Game():GetRoom()
    
    if room:IsAmbushDone() then return end

    Ambush.StartChallenge()

    local rng = RNG(room:GetAwardSeed())

    --[[Ambush.GetNextWave() = RoomConfig.GetRandomRoom
    (
        rng:Next(),
        true,
        StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        nil, nil,
        0,
        TheGauntlet.GauntletRoom.CHALLENGE_ROOM_GAUNTLET_SUBTYPE
    )]]
end)