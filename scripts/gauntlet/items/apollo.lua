TheGauntlet.Items.Apollo = {}
TheGauntlet.Items.Apollo.CollectibleType = Isaac.GetItemIdByName("Apollo")
TheGauntlet.Items.Apollo.FamiliarVariant = Isaac.GetEntityVariantByName("TheGauntlet Apollo Baby")
TheGauntlet.Items.Apollo.FamiliarSubType = Isaac.GetEntitySubTypeByName("TheGauntlet Apollo Baby")

---@param player EntityPlayer
---@param cache CacheFlag
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cache)
    local familiarsToSpawn = player:GetCollectibleNum(TheGauntlet.Items.Apollo.CollectibleType) + player:GetEffects():GetCollectibleEffectNum(TheGauntlet.Items.Apollo.CollectibleType)
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider, low)
    if familiar.SubType ~= TheGauntlet.Items.Apollo.FamiliarSubType then return end

    print("test"..tostring(collider.Type))
end, TheGauntlet.Items.Apollo.FamiliarVariant)