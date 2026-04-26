TheGauntlet.Items.Zeus.Constants.NOTCHED_AXE_BOLT_AMOUNT = 8



TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(CollectibleType.COLLECTIBLE_NOTCHED_AXE, function (configItem, player, slot)
    return 0
end)

---@param entity Entity
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
    if entity.Type ~= EntityType.ENTITY_KNIFE then return end
    if entity.Variant ~= KnifeVariant.NOTCHED_AXE then return end
    if entity.SubType ~= 0 then return end

    if entity.Parent == nil then return end --Somehow, this callback can get called twice with the Parent being nil in the second call?

    local player = entity.Parent:ToPlayer()
    if not player then return end

    if not player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then return end

    Isaac.CreateTimer(function ()
        if string.sub(player:GetSprite():GetAnimation(), 1, 6) == "Pickup" then return end

        for i = 1, TheGauntlet.Items.Zeus.Constants.NOTCHED_AXE_BOLT_AMOUNT do
            TheGauntlet.Items.Zeus.ScheduleLightningBolt(TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE, player)
        end
    end, 1, 1, false)
end)