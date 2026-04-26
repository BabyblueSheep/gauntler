TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(CollectibleType.COLLECTIBLE_BREATH_OF_LIFE, function (configItem, player, slot)
    return 0
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    local temporaryEffects = player:GetEffects()
    local breathOfLifeEffect = temporaryEffects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BREATH_OF_LIFE)

    if breathOfLifeEffect == nil then return end
    if breathOfLifeEffect.Cooldown ~= 30 then return end
    
    TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_POSITION, player)
end)