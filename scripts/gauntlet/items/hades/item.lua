local SKULL_STATUS_DURATION = 30 * 5
local CHANCE_TO_APPLY_SKULL = 0.05


local TEAR_BONE_COLOR = Color(0.2, 0.2, 0.2, 1)
local TEAR_VARIANTS_THAT_CANNOT_BE_BONED = {
    [TearVariant.FETUS] = true,
    [TearVariant.BALLOON] = true,
    [TearVariant.BALLOON_BOMB] = true,
    [TearVariant.BALLOON_BRIMSTONE] = true,
}

local BOMB_BONE_COLOR = Color(0.2, 0.2, 0.2, 1)

local AQUARIUS_CREEP_COLOR = Color
(
    0, 0, 0, 1,
    0.1, 0.1, 0.1
)



TheGauntlet.Items.Hades.CollectibleType = Isaac.GetItemIdByName("Hades")

---@param player EntityPlayer
---@return boolean
function TheGauntlet.Items.Hades.ShouldProc(player)
    if not player:HasCollectible(TheGauntlet.Items.Hades.CollectibleType) then return false end
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hades.CollectibleType)

    return rng:RandomFloat() < CHANCE_TO_APPLY_SKULL
end

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end

    local data = source.Entity:GetData()

    local shouldApplyTear = source.Type == EntityType.ENTITY_TEAR and data.TheGauntletHadesAppliesSkull
    local shouldApplyBomb = source.Type == EntityType.ENTITY_BOMB and data.TheGauntletHadesAppliesSkull
    local shouldApplyRocket = source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.ROCKET and data.TheGauntletHadesAppliesSkull
    local shouldApplyAquarius = source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL and data.TheGauntletHadesAppliesSkull

    if not (shouldApplyTear or shouldApplyBomb or shouldApplyRocket or shouldApplyAquarius) then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity, true)
    if player == nil then return end

    TheGauntlet.Items.Hades.InflictStatusEffect(entity, SKULL_STATUS_DURATION, EntityRef(player))
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end
    local shouldApplyLaser = damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER
    local shouldApplyKnife = source.Type == EntityType.ENTITY_KNIFE and (source.Variant == KnifeVariant.MOMS_KNIFE or source.Variant == KnifeVariant.SUMPTORIUM)

    if not (shouldApplyKnife or shouldApplyLaser) then return end

    local player
    if shouldApplyLaser then
        player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity, true)
    elseif shouldApplyKnife then
        player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity, true)
    end

    if not player then return end

    if not TheGauntlet.Items.Hades.ShouldProc(player) then return end

    TheGauntlet.Items.Hades.InflictStatusEffect(entity, SKULL_STATUS_DURATION, EntityRef(player))
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not source.Entity then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity, true)
    if not player then
        player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity, true)
    end

    if not player then return end

    local shouldProc = false

    local hitIndex = entity:GetHitListIndex()

    local function IterateOverKnives(variant, subtype, checkData)
        for _, entityKnife in ipairs(Isaac.FindByType(EntityType.ENTITY_KNIFE, variant, subtype)) do
            ---@type EntityKnife
            ---@diagnostic disable-next-line assign-type-mismatch
            local knife = entityKnife:ToKnife()

            local playerCopy = TheGauntlet.Utility.GetPlayerFromEntity(knife.SpawnerEntity, true)
            if playerCopy and GetPtrHash(playerCopy) == GetPtrHash(player) and knife:GetIsSwinging() then
                for _, i in ipairs(knife:GetHitList()) do
                    if i == hitIndex then
                        if checkData then
                            shouldProc = knife:GetData().TheGauntletHadesAppliesSkull
                        else
                            shouldProc = TheGauntlet.Items.Hades.ShouldProc(player)
                        end
                    end
                end
            end
        end
    end
    
    IterateOverKnives(KnifeVariant.BONE_CLUB, KnifeSubType.CLUB_HITBOX, false)
    IterateOverKnives(KnifeVariant.BONE_SCYTHE, KnifeSubType.CLUB_HITBOX, false)
    IterateOverKnives(KnifeVariant.BERSERK_CLUB, KnifeSubType.CLUB_HITBOX, false)

    --Despite Spirit Sword knives having tear flags, they are not passed as entity sources when damaging entities. AWESOME!
    IterateOverKnives(KnifeVariant.SPIRIT_SWORD, 0, true)
    IterateOverKnives(KnifeVariant.TECH_SWORD, 0, true)

    if not shouldProc then return end

    if not TheGauntlet.Items.Hades.ShouldProc(player) then return end

    TheGauntlet.Items.Hades.InflictStatusEffect(entity, SKULL_STATUS_DURATION, EntityRef(player))
end)

--#region Tears

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        tear:GetData().TheGauntletHadesAppliesSkull = true

        if not TEAR_VARIANTS_THAT_CANNOT_BE_BONED[tear.Variant] then
            tear:ChangeVariant(TearVariant.BONE)
            tear.Color = TEAR_BONE_COLOR
        end
    end
end)

---@param tear EntityTear
---@param sourceEntity Entity
---@param splitTearType SplitTearType | string
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_SPLIT_TEAR, function (_, tear, sourceEntity, splitTearType)
    if sourceEntity.Type == EntityType.ENTITY_TEAR then
        tear:GetData().TheGauntletHadesAppliesSkull = sourceEntity:GetData().TheGauntletHadesAppliesSkull
    end
end)

--#endregion

--#region Tears (Ludovico)

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function (_, tear)
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
end)

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    if tear.Parent ~= nil and tear.Parent.Type == EntityType.ENTITY_TEAR then
        tear:GetData().TheGauntletHadesAppliesSkull = tear.Parent:GetData().TheGauntletHadesAppliesSkull
    else
        if tear.FrameCount % 10 == 0 then
            tear:GetData().TheGauntletHadesAppliesSkull = TheGauntlet.Items.Hades.ShouldProc(player)
        end
    end
end)

--#endregion

--#region Bombs

---@param bomb EntityBomb
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, function (_, bomb)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(bomb.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        bomb:GetData().TheGauntletHadesAppliesSkull = true

        bomb.Color = BOMB_BONE_COLOR
    end
end)

--#endregion

--#region Epic Fetus rockets

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(effect.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        effect:GetData().TheGauntletHadesAppliesSkull = true
    end
end, EffectVariant.ROCKET)

--#endregion

--#region Aquarius

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(effect.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        effect:GetData().TheGauntletHadesAppliesSkull = true
    end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect:GetData().TheGauntletHadesAppliesSkull and effect.FrameCount == 0 then
        effect.Color = AQUARIUS_CREEP_COLOR
    end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

--#endregion

--#region Spirit Sword

---@param knife EntityKnife
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_SWORD, function (_, knife)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(knife.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        knife:GetData().TheGauntletHadesAppliesSkull = true
    end
end)

--#endregion