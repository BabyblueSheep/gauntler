local sfxManager = SFXManager()

TheGauntlet.Items.Aphrodite = {}
TheGauntlet.Items.Aphrodite.CollectibleType = Isaac.GetItemIdByName("Aphrodite")

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if entity.Type ~= EntityType.ENTITY_PLAYER then return end
    ---@type EntityPlayer
    ---@diagnostic disable-next-line assign-type-mismatch
    local player = entity:ToPlayer()

    if not player:HasCollectible(TheGauntlet.Items.Aphrodite.CollectibleType) then return end

    if source.Entity == nil then return end
    local enemyToCharm = nil
    if source.Entity:IsActiveEnemy() then
        enemyToCharm = source.Entity
    else
        --Allow projectiles and other non-NPC entities to charm the enemy (hopefully this doesn't have major flaws..)
        if source.Entity.SpawnerEntity ~= nil and source.Entity.SpawnerEntity:IsActiveEnemy() then
            enemyToCharm = source.Entity.SpawnerEntity
        elseif source.Entity.Parent ~= nil and source.Entity.Parent:IsActiveEnemy() then
            enemyToCharm = source.Entity.Parent
        end
    end
    if enemyToCharm == nil then return end

    if enemyToCharm:IsBoss() then return end

    enemyToCharm:AddCharmed(EntityRef(player), -1)

    local POOF_COLOR = Color
    (
        0, 0, 0, 1,
        1, 0.66, 1
    )

    local POOF_SPRITE_SIZE = 144

    local poofFinalSpriteScale = Vector.One * (0.5 + enemyToCharm.Size / POOF_SPRITE_SIZE) --Hopefully a good enough scaling equation

    local poof1 = TheGauntlet.Utility.SpawnEffect
    (
        EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1,
        enemyToCharm.Position, Vector.Zero,
        nil
    )
    poof1.SpriteScale = poofFinalSpriteScale
    poof1:GetSprite().Color = POOF_COLOR

    local poof2 = TheGauntlet.Utility.SpawnEffect
    (
        EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2,
        enemyToCharm.Position, Vector.Zero,
        nil
    )
    poof2.SpriteScale = poofFinalSpriteScale
    poof2:GetSprite().Color = POOF_COLOR

    sfxManager:Play(SoundEffect.SOUND_BLACK_POOF)
end)