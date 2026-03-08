local game = Game()

TheGauntlet.Items.Ares = {}
TheGauntlet.Items.Ares.CollectibleType = Isaac.GetItemIdByName("Ares")
TheGauntlet.Items.Ares.CollectibleTypeNullChallenge = Isaac.GetNullItemIdByName("Ares Challenge Room Stats")
TheGauntlet.Items.Ares.CollectibleTypeNullBossChallenge = Isaac.GetNullItemIdByName("Ares Boss Challenge Room Stats")

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Ares.CollectibleTypeNullChallenge, -1)
        player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Ares.CollectibleTypeNullBossChallenge, -1)
    end

    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Ares.CollectibleType) then return end

    if game:IsGreedMode() then return end

    local level = game:GetLevel()
    
    local roomSubtype = -1
    if TheGauntlet.Utility.CanBossChallengeRoomsSpawn() then
        roomSubtype = 1
    elseif TheGauntlet.Utility.CanNormalChallengeRoomsSpawn() then
        roomSubtype = 0
    end
    
    if roomSubtype == -1 then return end

    local rng = RNG(level:GetDungeonPlacementSeed())

    local entranceRoomConfigToPlace = nil
    local entranceRoomValidPlacementIndexes = nil

    local GENERATION_ATTEMPT_COUNT = 5

    for _ = 1, GENERATION_ATTEMPT_COUNT do
        entranceRoomConfigToPlace = RoomConfig.GetRandomRoom
        (
            rng:Next(),
            true,
            StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, nil,
            nil, nil,
            nil, nil,
            0,
            roomSubtype,
            0
        )

        entranceRoomValidPlacementIndexes = level:FindValidRoomPlacementLocations
        (
            entranceRoomConfigToPlace, nil,
            false, false
        )

        if #entranceRoomValidPlacementIndexes ~= 0 then break end
    end

    if #entranceRoomValidPlacementIndexes == 0 then return end

    level:TryPlaceRoom(entranceRoomConfigToPlace, entranceRoomValidPlacementIndexes[1], nil, rng:Next(), false)

    level:UpdateVisibility()
end)

---@param challengeRoomType ChallengeRoomType
TheGauntlet:AddCallback(TheGauntlet.Utility.Callbacks.POST_CHALLENGE_ROOM_TRIGGER_CLEARED, function (_, challengeRoomType)
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(TheGauntlet.Items.Ares.CollectibleType) then
            if challengeRoomType == TheGauntlet.Utility.ChallengeRoomType.NORMAL then
                player:GetEffects():AddNullEffect(TheGauntlet.Items.Ares.CollectibleTypeNullChallenge)
            else
                player:GetEffects():AddNullEffect(TheGauntlet.Items.Ares.CollectibleTypeNullBossChallenge)
            end
        end
    end
end)