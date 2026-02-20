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
    if not source.Entity:IsActiveEnemy() and not source.Entity.SpawnerEntity:IsActiveEnemy() then return end
    if source.Entity:IsBoss() then return end

    source.Entity:AddCharmed(EntityRef(player), -1)

    local poof = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0,
        source.Entity.Position, Vector.Zero,
        nil
    )
    poof:GetSprite().Color = Color
    (
        0, 0, 0, 1,
        1, 0.66, 1
    )
    poof.SortingLayer = SortingLayer.SORTING_BACKGROUND
end)