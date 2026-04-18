local game = Game()

TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(CollectibleType.COLLECTIBLE_ERASER, function (configItem, player, slot)
    return 0
end)

---@param tear EntityTear
---@param collider Entity
---@param low boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, function (_, tear, collider, low)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Zeus.CollectibleType) then return end

    if not game:IsErased(collider) then return end

    local boltAmount = 10

    for i = 1, boltAmount do
        TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
    end
end, TearVariant.ERASER)