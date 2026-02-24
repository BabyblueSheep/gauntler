TheGauntlet.Items.Hades = {}
TheGauntlet.Items.Hades.CollectibleType = Isaac.GetItemIdByName("Hades")

local SKULL_TEAR_SHOOT_CHANCE = 0.05
local SKULL_STATUS_DURATION = 30 * 5

local hadesSkullStatusEffectSprite = Sprite("gfx/gauntlet/statuseffects.anm2", true)
hadesSkullStatusEffectSprite:Play("HadesSkull", true)

StatusEffectLibrary.RegisterStatusEffect(
	"TheGauntlet_HadesSkull",
	hadesSkullStatusEffectSprite,
    Color(0.3, 0.3, 0.3, 1.0)
)

local variantsBlacklist = {
    [TearVariant.FETUS] = true,
    [TearVariant.BALLOON] = true,
    [TearVariant.BALLOON_BOMB] = true,
    [TearVariant.BALLOON_BRIMSTONE] = true,
}
local darkBoneColor = Color(0.2, 0.2, 0.2, 1)

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Hades.CollectibleType) then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hades.CollectibleType)
    if rng:RandomFloat() < SKULL_TEAR_SHOOT_CHANCE then
        tear:GetData().TheGauntletHadesTear = true

        if not variantsBlacklist[tear.Variant] then
            tear:ChangeVariant(TearVariant.BONE)
            tear.Color = darkBoneColor
        end
    end
end)

---@param bomb EntityBomb
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, function (_, bomb)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(bomb.SpawnerEntity, true)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Hades.CollectibleType) then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hades.CollectibleType)
    if rng:RandomFloat() < SKULL_TEAR_SHOOT_CHANCE then
        bomb:GetData().TheGauntletHadesTear = true
    end
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if source.Entity == nil then return end

    if source.Entity.Type ~= EntityType.ENTITY_TEAR then return end
    if not source.Entity:GetData().TheGauntletHadesTear then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(source.Entity.SpawnerEntity, true)
    if player == nil then return end

    StatusEffectLibrary:AddStatusEffect
    (
        entity,
        StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull,
        SKULL_STATUS_DURATION,
        EntityRef(player)
    )
end)

---@param entity Entity
---@param killSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    if not StatusEffectLibrary:HasStatusEffect(entity, StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull) then return end

    local source = StatusEffectLibrary:GetStatusEffectData(entity, StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull).Source

    local bony = Isaac.Spawn
    (
        EntityType.ENTITY_BLACK_BONY, 0, 0,
        entity.Position, Vector.Zero,
        nil
    )
    bony:AddCharmed(source, -1)

    StatusEffectLibrary:RemoveStatusEffect(entity, StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull)
end)