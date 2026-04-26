TheGauntlet.Items.Hades.Constants.LOCUST_STATUS_EFFECT_DURATION = 30 * 5
TheGauntlet.Items.Hades.Constants.LOCUST_CHANCE_TO_APPLY_STATUS_EFFECT = 0.05



---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end

    if source.Entity.Type ~= EntityType.ENTITY_FAMILIAR then return end
    if source.Entity.Variant ~= FamiliarVariant.ABYSS_LOCUST then return end
    if source.Entity.SubType ~= TheGauntlet.Items.Hades.COLLECTIBLE_TYPE then return end

    --Repentance+ locusts seem not to have Siren compatibility, so neither won't mine
    if source.Entity:ToFamiliar():IsCharmed() then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity)
    if not player then return end

    if player:GetCollectibleRNG(TheGauntlet.Items.Hades.COLLECTIBLE_TYPE):RandomFloat() >= TheGauntlet.Items.Hades.Constants.LOCUST_CHANCE_TO_APPLY_STATUS_EFFECT then return end

    TheGauntlet.Items.Hades.InflictStatusEffect(entity, TheGauntlet.Items.Hades.Constants.LOCUST_STATUS_EFFECT_DURATION, source)
end)