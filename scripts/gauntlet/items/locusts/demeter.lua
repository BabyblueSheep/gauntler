BOOGER_STICK_CHANCE = 0.25
BOOGER_DURATION = 30



---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end

    if source.Entity.Type ~= EntityType.ENTITY_FAMILIAR then return end
    if source.Entity.Variant ~= FamiliarVariant.ABYSS_LOCUST then return end
    if source.Entity.SubType ~= TheGauntlet.Items.Demeter.CollectibleType then return end

    --Repentance+ locusts seem not to have Siren compatibility, so neither won't mine
    if source.Entity:ToFamiliar():IsCharmed() then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity)
    if not player then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.CollectibleType)
    if rng:RandomFloat() >= BOOGER_STICK_CHANCE then return end

    local tear = TheGauntlet.Utility.SpawnTear
    (
        EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0,
        source.Entity.Position, Vector.Zero,
        player, nil
    )
    tear:SetInitSound(SoundEffect.SOUND_NULL)
    tear:AddTearFlags(TearFlags.TEAR_BOOGER)

    tear:Update()
    tear:ForceCollide(entity, false)
    tear.StickTimer = BOOGER_DURATION

    local sprite = tear:GetSprite()
    local frameCount = sprite:GetCurrentAnimationData():GetLength()
    sprite:SetFrame(rng:RandomInt(frameCount))

end)