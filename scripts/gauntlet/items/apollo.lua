local CHANCE_TO_GIVE_BOOST = 0.15



local itemConfig = Isaac.GetItemConfig()
local sfxManager = SFXManager()

TheGauntlet.Items.Apollo = {}
TheGauntlet.Items.Apollo.CollectibleType = Isaac.GetItemIdByName("Apollo")
TheGauntlet.Items.Apollo.CollectibleTypeMultishot = Isaac.GetNullItemIdByName("Apollo Multishot")
TheGauntlet.Items.Apollo.FamiliarVariant = Isaac.GetEntityVariantByName("TheGauntlet Apollo Baby")
TheGauntlet.Items.Apollo.FamiliarSubType = Isaac.GetEntitySubTypeByName("TheGauntlet Apollo Baby")

---@param player EntityPlayer
---@param cache CacheFlag
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cache)
    local familiarAmountToSpawn = player:GetCollectibleNum(TheGauntlet.Items.Apollo.CollectibleType) + player:GetEffects():GetCollectibleEffectNum(TheGauntlet.Items.Apollo.CollectibleType)

    local apolloItemConfig = itemConfig:GetCollectible(TheGauntlet.Items.Apollo.CollectibleType)

    local rng = RNG(math.max(Random(), 1))
    player:CheckFamiliar(TheGauntlet.Items.Apollo.FamiliarVariant, familiarAmountToSpawn, rng, apolloItemConfig, TheGauntlet.Items.Apollo.FamiliarSubType)
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    if familiar.SubType ~= TheGauntlet.Items.Apollo.FamiliarSubType then return end

    familiar:AddToFollowers()
end, TheGauntlet.Items.Apollo.FamiliarVariant)

---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.SubType ~= TheGauntlet.Items.Apollo.FamiliarSubType then return end

    familiar:FollowParent()

    local sprite = familiar:GetSprite()
    if sprite:IsFinished("Hit") then
        sprite:Play("Idle")

        sfxManager:Play(SoundEffect.SOUND_SUPERHOLY)

        familiar.Player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeMultishot, false, 1)
    end
end, TheGauntlet.Items.Apollo.FamiliarVariant)

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider, low)
    if familiar.SubType ~= TheGauntlet.Items.Apollo.FamiliarSubType then return end

    if collider.Type ~= EntityType.ENTITY_PROJECTILE then return end
    if collider:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then return end

    collider:Die()

    local sprite = familiar:GetSprite()

    if sprite:IsPlaying("Hit") then return end
    if familiar.Player:GetEffects():HasNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeMultishot) then return end

    if familiar:GetDropRNG():RandomFloat() < CHANCE_TO_GIVE_BOOST then
        sprite:Play("Hit", true)

        sfxManager:Play(SoundEffect.SOUND_THUMBSUP)
    end

end, TheGauntlet.Items.Apollo.FamiliarVariant)

local weaponsThatDontHaveSpread = {
    [WeaponType.WEAPON_SPIRIT_SWORD] = true,
    [WeaponType.WEAPON_MONSTROS_LUNGS] = true,
    [WeaponType.WEAPON_LUDOVICO_TECHNIQUE] = true,
    [WeaponType.WEAPON_ROCKETS] = true,
}

---@param player EntityPlayer
---@param multiShotParams MultiShotParams
---@param weaponType WeaponType
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, function (_, player, multiShotParams, weaponType)
    if player:GetEffects():HasNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeMultishot) then
        multiShotParams:SetNumTears(multiShotParams:GetNumTears() + 2)
        multiShotParams:SetNumLanesPerEye(multiShotParams:GetNumLanesPerEye() + 2)

        if not weaponsThatDontHaveSpread[weaponType] then
            multiShotParams:SetSpreadAngle(weaponType, multiShotParams:GetSpreadAngle(weaponType) + 30)
        end
    end
end)