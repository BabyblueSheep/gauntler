TheGauntlet.Items.Apollo = {}

TheGauntlet.Items.Apollo.Constants =
{
    CHANCE_TO_GIVE_BOOST = 0.15,
    BOOST_DURATION_FRAMES = 10 * 30
}



local itemConfig = Isaac.GetItemConfig()
local sfxManager = SFXManager()

TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Apollo")
TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE_MULTISHOT = Isaac.GetNullItemIdByName("Apollo Multishot")
TheGauntlet.Items.Apollo.FAMILIAR_VARIANT = Isaac.GetEntityVariantByName("TheGauntlet Apollo Baby")

TheGauntlet.Items.Apollo.HARP_SOUND_EFFECT = Isaac.GetSoundIdByName("TheGauntlet Harp")

---Triggers an Apollo familiar's animation for boosting the player.
---@param familiar EntityFamiliar
function TheGauntlet.Items.Apollo.TriggerHit(familiar)
    if familiar.Variant ~= TheGauntlet.Items.Apollo.FAMILIAR_VARIANT then return end

    familiar:GetSprite():Play("Hit", true)

    sfxManager:Play(SoundEffect.SOUND_THUMBSUP)
end

---@param player EntityPlayer
---@param cache CacheFlag
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cache)
    local familiarAmountToSpawn = player:GetCollectibleNum(TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE) + player:GetEffects():GetCollectibleEffectNum(TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE)

    local apolloItemConfig = itemConfig:GetCollectible(TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE)

    local rng = RNG(math.max(Random(), 1))
    player:CheckFamiliar(TheGauntlet.Items.Apollo.FAMILIAR_VARIANT, familiarAmountToSpawn, rng, apolloItemConfig)
end, CacheFlag.CACHE_FAMILIARS)

--I would implement charmed by Siren behavior, but neither Farting Baby nor Dry Baby seem to.
--Oh well.

---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:AddToFollowers()
end, TheGauntlet.Items.Apollo.FAMILIAR_VARIANT)

---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    familiar:FollowParent()

    local sprite = familiar:GetSprite()
    if sprite:IsEventTriggered("PlayHighActivation") then
        sfxManager:Play(TheGauntlet.Items.Apollo.HARP_SOUND_EFFECT)

        familiar.Player:AddNullItemEffect(TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE_MULTISHOT, true, TheGauntlet.Items.Apollo.Constants.BOOST_DURATION_FRAMES, false)
    end

    if sprite:IsFinished("Hit") then
        sprite:Play("Idle")
    end
end, TheGauntlet.Items.Apollo.FAMILIAR_VARIANT)

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider, low)
    if collider.Type ~= EntityType.ENTITY_PROJECTILE then return end
    if collider:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then return end

    collider:Die()

    if familiar:GetSprite():IsPlaying("Hit") then return end

    if familiar:GetDropRNG():RandomFloat() < TheGauntlet.Items.Apollo.Constants.CHANCE_TO_GIVE_BOOST then
        TheGauntlet.Items.Apollo.TriggerHit(familiar)
    end

end, TheGauntlet.Items.Apollo.FAMILIAR_VARIANT)

local weaponsThatDontHaveSpread = {
    [WeaponType.WEAPON_SPIRIT_SWORD] = true,
    [WeaponType.WEAPON_MONSTROS_LUNGS] = true,
    [WeaponType.WEAPON_LUDOVICO_TECHNIQUE] = true,
    [WeaponType.WEAPON_ROCKETS] = true,
    [WeaponType.WEAPON_UMBILICAL_WHIP] = true,
    [WeaponType.WEAPON_URN_OF_SOULS] = true,
}

---@param player EntityPlayer
---@param multiShotParams MultiShotParams
---@param weaponType WeaponType
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, function (_, player, multiShotParams, weaponType)
    if player:GetEffects():HasNullEffect(TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE_MULTISHOT) then
        multiShotParams:SetNumTears(multiShotParams:GetNumTears() + 2)
        multiShotParams:SetNumLanesPerEye(multiShotParams:GetNumLanesPerEye() + 2)

        if not weaponsThatDontHaveSpread[weaponType] then
            multiShotParams:SetSpreadAngle(weaponType, multiShotParams:GetSpreadAngle(weaponType) + 15)
        end
    end
end)