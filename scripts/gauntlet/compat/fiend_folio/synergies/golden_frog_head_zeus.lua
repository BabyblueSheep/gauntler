if FiendFolio == nil then return end



TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(FiendFolio.ITEM.COLLECTIBLE.FROG_HEAD, function (configItem, player, slot)
    return 0
end)

local blockedAnimations = {
    ["Appear"] = true,
    ["Death"] = true,
}

TheGauntlet:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.EARLY, function(_, player)
    local data = player:GetData()
    local sprite = player:GetSprite()

    local isSlippy = player:GetPlayerType() == FiendFolio.PLAYER.SLIPPY
    if not (isSlippy or player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FROG_HEAD)) then return end

    if ( data.frogStop or (isSlippy and ((not player.ControlsEnabled) or blockedAnimations[sprite:GetAnimation()])) ) then
        return
    end

    if data.frogTimer and data.frogTimer > 80 then
        TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
    end
    if data.frogTimer and data.frogTimer > 150 then
        TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
    end
end)