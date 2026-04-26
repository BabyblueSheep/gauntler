TheGauntlet.Items.Zeus.Constants.ERASER_BOLT_AMOUNT = 12



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

    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    if not game:IsErased(collider) then return end

    for i = 1, TheGauntlet.Items.Zeus.Constants.ERASER_BOLT_AMOUNT do
        TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
    end
end, TearVariant.ERASER)