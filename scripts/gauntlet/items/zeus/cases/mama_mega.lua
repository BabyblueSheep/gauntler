TheGauntlet.Items.Zeus.Constants.MAMA_MEGA_BOLT_AMOUNT = 6



local game = Game()

TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(CollectibleType.COLLECTIBLE_MAMA_MEGA, function (configItem, player, slot)
    return 6
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    local level = game:GetLevel()
    local roomFlags = level:GetCurrentRoomDesc().Flags

    local newRoomWithMamaMega = level:GetStateFlag(LevelStateFlag.STATE_MAMA_MEGA_USED) and roomFlags & RoomDescriptor.FLAG_MAMA_MEGA == 0

    if not newRoomWithMamaMega then return end

    local boltAmount = 6
    for i = 1, boltAmount do
        ---@diagnostic disable-next-line: param-type-mismatch
        TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, PlayerManager.FirstCollectibleOwner(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE))
    end
end)