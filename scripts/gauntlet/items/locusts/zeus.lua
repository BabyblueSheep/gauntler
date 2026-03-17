local CHANCE_TO_SUMMON_BOLT = 0.1



---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end

    if source.Entity.Type ~= EntityType.ENTITY_FAMILIAR then return end
    if source.Entity.Variant ~= FamiliarVariant.ABYSS_LOCUST then return end
    if source.Entity.SubType ~= TheGauntlet.Items.Zeus.CollectibleType and source.Entity.SubType ~= TheGauntlet.Items.Zeus.CollectibleTypeActive then return end

    --Repentance+ locusts seem not to have Siren compatibility, so neither won't mine
    if source.Entity:ToFamiliar():IsCharmed() then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity)
    if not player then return end

    if player:GetCollectibleRNG(TheGauntlet.Items.Zeus.CollectibleType):RandomFloat() >= CHANCE_TO_SUMMON_BOLT then return end

    TheGauntlet.Items.Zeus.SpawnLightningBolt(entity.Position, player)
end)