TheGauntlet.Items.Zeus.Constants.LOCUST_CHANCE_TO_SUMMON_BOLT = 0.1



TheGauntlet.Items.Zeus.LOCUST_TEAR_FLAG = TearFlagsLib.RegisterTearFlag("TheGauntlet_LocustZeus")

---@param locust EntityFamiliar
---@param player EntityPlayer
TheGauntlet:AddCallback(TearFlagsLib.Callback.POLL_LOCUST_TEARFLAGS, function(_, locust, player)
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE)
    if rng:RandomFloat() < TheGauntlet.Items.Zeus.Constants.LOCUST_CHANCE_TO_SUMMON_BOLT then
        TearFlagsLib.AddTearFlags(locust, TheGauntlet.Items.Zeus.LOCUST_TEAR_FLAG)
    end
end, TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE)

---@param targetEntity EntityNPC
---@param player EntityPlayer
---@param weaponEntity Entity
---@param weaponFlags any
---@param params table
TheGauntlet:AddCallback(TearFlagsLib.Callback.APPLY_TEARFLAG_EFFECT, function(_, targetEntity, player, weaponEntity, weaponFlags, params)
    if weaponFlags & TearFlagsLib.WeaponFlag.LOCUST == 0 then return end
    TheGauntlet.Items.Zeus.SpawnLightningBolt(weaponEntity.Position, player)
end, TheGauntlet.Items.Zeus.LOCUST_TEAR_FLAG)

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
    if source.Entity.SubType ~= TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE and source.Entity.SubType ~= TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE_ACTIVE then return end

    --Repentance+ locusts seem not to have Siren compatibility, so neither won't mine
    if source.Entity:ToFamiliar():IsCharmed() then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity)
    if not player then return end

    if player:GetCollectibleRNG(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE):RandomFloat() >= TheGauntlet.Items.Zeus.Constants.LOCUST_CHANCE_TO_SUMMON_BOLT then return end

    TheGauntlet.Items.Zeus.SpawnLightningBolt(entity.Position, player)
end)
]]