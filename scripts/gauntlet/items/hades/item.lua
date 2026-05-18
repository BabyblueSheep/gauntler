TheGauntlet.Items.Hades.Constants = {
    SKULL_STATUS_DURATION = 30 * 5,
    CHANCE_TO_APPLY_SKULL = 0.05,
}


local TEAR_BONE_COLOR = Color(1.0, 1.0, 1.0, 1.0)
local TEAR_VARIANTS_THAT_CANNOT_BE_BONED = {
    [TearVariant.FETUS] = true,
    [TearVariant.BALLOON] = true,
    [TearVariant.BALLOON_BOMB] = true,
    [TearVariant.BALLOON_BRIMSTONE] = true,
}

local BOMB_BONE_COLOR = Color
(
    1.0, 1.0, 1.0, 1.0,
    0.15, 0.15, 0.15,
    1.0, 1.0, 1.0, 1.0
)

local AQUARIUS_CREEP_COLOR = Color
(
    0, 0, 0, 1,
    0.8, 0.8, 0.8
)

local bombRocketIds = {
	[BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_ROCKET] = true,
	[BombVariant.BOMB_ROCKET_GIGA] = true
}



TheGauntlet.Items.Hades.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Hades")

---Whether the effect should proc after calling this.
---@param player EntityPlayer
---@return boolean
function TheGauntlet.Items.Hades.ShouldProc(player)
    if not player:HasCollectible(TheGauntlet.Items.Hades.COLLECTIBLE_TYPE) then return false end
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hades.COLLECTIBLE_TYPE)

    return rng:RandomFloat() < TheGauntlet.Items.Hades.Constants.CHANCE_TO_APPLY_SKULL
end

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
---@param extraSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown, extraSource)
    if not source.Entity then return end

    local shouldApplyTear = source.Type == EntityType.ENTITY_TEAR
    local shouldApplyBomb = source.Type == EntityType.ENTITY_BOMB
    local shouldApplyRocket = source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.ROCKET
    local shouldApplyAquarius = source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL
    local shouldApplySpiritSword = false
    if extraSource ~= nil and extraSource.Entity ~= nil then
        shouldApplySpiritSword = extraSource.Type == EntityType.ENTITY_KNIFE and (extraSource.Variant == KnifeVariant.SPIRIT_SWORD or extraSource.Variant == KnifeVariant.TECH_SWORD)
    end
    if not (shouldApplyTear or shouldApplyBomb or shouldApplyRocket or shouldApplyAquarius or shouldApplySpiritSword) then return end

    local hasSkull = false
    if shouldApplySpiritSword and extraSource ~= nil and extraSource.Entity ~= nil then
        local data = TheGauntlet.DataHolder.GetTemporaryData(extraSource.Entity:ToKnife():GetHitboxParentKnife())
        hasSkull = data.Hades ~= nil and data.Hades.AppliesSkull
    elseif shouldApplyBomb and bombRocketIds[source.Variant] ~= true then
        local data = TheGauntlet.SaveManager.GetRoomSave(source.Entity)
        hasSkull = data.Hades ~= nil and data.Hades.AppliesSkull
    else
        local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(source.Entity)
        hasSkull = data.Hades ~= nil and data.Hades.AppliesSkull
    end

    if not hasSkull then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity, true)
    if player == nil then
        if extraSource ~= nil and extraSource.Entity ~= nil then
            player = TheGauntlet.Utility.GetPlayerFromEntity(extraSource.Entity.SpawnerEntity, true)
        end

        if player == nil then return end
    end

    TheGauntlet.Items.Hades.InflictStatusEffect(entity, TheGauntlet.Items.Hades.Constants.SKULL_STATUS_DURATION, EntityRef(player))
end)

--TODO: make all of this not random per hit. But also, who would even care lol????
---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
---@param extraSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown, extraSource)
    if not source.Entity then return end
    local shouldApplyLaser = damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER
    local shouldApplyKnife = source.Type == EntityType.ENTITY_KNIFE and (source.Variant == KnifeVariant.MOMS_KNIFE or source.Variant == KnifeVariant.SUMPTORIUM)
    local shouldApplyClub = false
    if extraSource ~= nil and extraSource.Entity ~= nil then
        shouldApplyClub = source.Type == EntityType.ENTITY_KNIFE and (source.Variant == KnifeVariant.BONE_CLUB or source.Variant == KnifeVariant.BONE_SCYTHE or source.Variant == KnifeVariant.BERSERK_CLUB)
    end

    if not (shouldApplyKnife or shouldApplyLaser or shouldApplyClub) then return end

    local player
    if shouldApplyLaser or shouldApplyClub then
        player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity, true)
    elseif shouldApplyKnife then
        player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity, true)
    end

    if not player then return end

    if not TheGauntlet.Items.Hades.ShouldProc(player) then return end

    TheGauntlet.Items.Hades.InflictStatusEffect(entity, TheGauntlet.Items.Hades.Constants.SKULL_STATUS_DURATION, EntityRef(player))
end)

--#region Tears

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        TheGauntlet.DataHolder.GetTemporaryNoHourglassData(tear).Hades = {
            AppliesSkull = true
        }

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
        local sourceData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(sourceEntity)
        local tearData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(tear)

        if sourceData.Hades then
            tearData.Hades = {
                AppliesSkull = sourceData.Hades.AppliesSkull
            }
        end
    elseif sourceEntity.Type == EntityType.ENTITY_KNIFE then
        if not (sourceEntity.Variant == KnifeVariant.SPIRIT_SWORD or sourceEntity.Variant == KnifeVariant.TECH_SWORD) then return end

        local sourceData = TheGauntlet.DataHolder.GetTemporaryData(sourceEntity)
        local tearData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(tear)

        if sourceData.Hades then
            tearData.Hades = {
                AppliesSkull = sourceData.Hades.AppliesSkull
            }
        end
    end
end)

--#endregion

--#region Tears (Ludovico)

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    local tearData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(tear)
    if tearData.Hades == nil then
        tearData.Hades = {
            AppliesSkull = false
        }
    end

    if tear.Parent ~= nil and tear.Parent.Type == EntityType.ENTITY_TEAR then
        local parentData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(tear.Parent)
        if parentData.Hades ~= nil then
            tearData.Hades.AppliesSkull = parentData.Hades.AppliesSkull
        end
    else
        if tear.FrameCount % 10 == 0 then
            tearData.Hades.AppliesSkull = TheGauntlet.Items.Hades.ShouldProc(player)
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
        if bombRocketIds[bomb.Variant] == true then
            local tearData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(bomb)
            tearData.Hades = {
                AppliesSkull = false
            }
        else
            TheGauntlet.SaveManager.GetRoomSave(bomb).Hades = {
                AppliesSkull = true
            }
        end

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
        TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect).Hades = {
            AppliesSkull = true
        }
    end
end, EffectVariant.ROCKET)

--#endregion

--#region Aquarius

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(effect.SpawnerEntity, true)
    if player == nil then return end

    if TheGauntlet.Items.Hades.ShouldProc(player) then
        TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect).Hades = {
            AppliesSkull = true
        }
    end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)
    if data.Hades and data.Hades.AppliesSkull and effect.FrameCount == 0 then
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
        local data = TheGauntlet.DataHolder.GetTemporaryData(knife)
        data.Hades = {
            AppliesSkull = true
        }
    end
end)

--#endregion