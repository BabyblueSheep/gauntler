TheGauntlet.Items.Zeus.Constants.BERSERK_TIME_INTERVAL_SECONDS = 2



local timeIntervalFrames = TheGauntlet.Items.Zeus.Constants.BERSERK_TIME_INTERVAL_SECONDS * 30

TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(CollectibleType.COLLECTIBLE_BERSERK, function (configItem, player, slot)
    return 0
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    local temporaryEffects = player:GetEffects()
    local breathOfLifeEffect = temporaryEffects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK)

    if breathOfLifeEffect == nil then return end

    if player.FrameCount % timeIntervalFrames == 0 then
        TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_POSITION, player)
    end
end)