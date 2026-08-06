TheGauntlet.Items.Demeter.Constants.LOCUST_BOOGER_STICK_CHANCE = 0.25
TheGauntlet.Items.Demeter.Constants.LOCUST_BOOGER_DURATION = 30



TheGauntlet.Items.Demeter.LOCUST_BOOGER_TEAR_FLAG = TearFlagsLib.RegisterTearFlag("TheGauntlet_LocustDemeterBooger")

---@param locust EntityFamiliar
---@param player EntityPlayer
TheGauntlet:AddCallback(TearFlagsLib.Callback.POLL_LOCUST_TEARFLAGS, function(_, locust, player)
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)
    if rng:RandomFloat() < TheGauntlet.Items.Demeter.Constants.LOCUST_BOOGER_STICK_CHANCE then
        TearFlagsLib.AddTearFlags(locust, TheGauntlet.Items.Demeter.LOCUST_BOOGER_TEAR_FLAG)
    end
end, TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)

---@param targetEntity EntityNPC
---@param player EntityPlayer
---@param weaponEntity Entity
---@param weaponFlags any
---@param params table
TheGauntlet:AddCallback(TearFlagsLib.Callback.APPLY_TEARFLAG_EFFECT, function(_, targetEntity, player, weaponEntity, weaponFlags, params)
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)

    local tear = TheGauntlet.Utility.SpawnTear
    (
        EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0,
        weaponEntity.Position, Vector.Zero,
        player, nil
    )
    tear:SetInitSound(SoundEffect.SOUND_NULL)
    tear:AddTearFlags(TearFlags.TEAR_BOOGER)

    tear:Update()
    tear:ForceCollide(targetEntity, false)
    tear.StickTimer = TheGauntlet.Items.Demeter.Constants.LOCUST_BOOGER_DURATION

    local sprite = tear:GetSprite()
    local frameCount = sprite:GetCurrentAnimationData():GetLength()
    sprite:SetFrame(rng:RandomInt(frameCount))
end, TheGauntlet.Items.Demeter.LOCUST_BOOGER_TEAR_FLAG)

--[[
---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end

    if source.Entity.Type ~= EntityType.ENTITY_FAMILIAR then return end
    if source.Entity.Variant ~= FamiliarVariant.ABYSS_LOCUST then return end
    if source.Entity.SubType ~= TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE then return end

    --Repentance+ locusts seem not to have Siren compatibility, so neither won't mine
    if source.Entity:ToFamiliar():IsCharmed() then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity)
    if not player then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE)
    if rng:RandomFloat() >= TheGauntlet.Items.Demeter.Constants.LOCUST_BOOGER_STICK_CHANCE then return end

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
    tear.StickTimer = TheGauntlet.Items.Demeter.Constants.LOCUST_BOOGER_DURATION

    local sprite = tear:GetSprite()
    local frameCount = sprite:GetCurrentAnimationData():GetLength()
    sprite:SetFrame(rng:RandomInt(frameCount))

end)
]]