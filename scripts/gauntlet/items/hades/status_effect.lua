local hadesSkullStatusEffectSprite = Sprite("gfx/gauntlet/statuseffects.anm2", true)
hadesSkullStatusEffectSprite:Play("HadesSkull", true)

TheGauntlet.Items.Hades.STATUS_EFFECT_ID = "TheGauntlet_HadesSkull"

StatusEffectLibrary.RegisterStatusEffect(
	TheGauntlet.Items.Hades.STATUS_EFFECT_ID,
	hadesSkullStatusEffectSprite,
    Color
    (
        1.0, 1.0, 1.0, 1.0,
        0.15, 0.15, 0.15,
        1.0, 1.0, 1.0, 0.5
    )
)

---Inflict the Calcified status effect to an enemy.
---@param entity Entity
---@param source EntityRef
---@param duration integer
function TheGauntlet.Items.Hades.InflictStatusEffect(entity, duration, source)
    StatusEffectLibrary:AddStatusEffect
    (
        entity,
        StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull,
        duration,
        source
    )
end

---@param entity Entity
---@param killSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    if not StatusEffectLibrary:HasStatusEffect(entity, StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull) then return end

    local source = StatusEffectLibrary:GetStatusEffectData(entity, StatusEffectLibrary.StatusFlag.TheGauntlet_HadesSkull).Source

    local isPersistent = entity:HasEntityFlags(EntityFlag.FLAG_PERSISTENT)

    Isaac.CreateTimer(function ()
        if entity:IsDead() then
            local bony = TheGauntlet.Utility.SpawnNPC
            (
                EntityType.ENTITY_BONY, 0, 0,
                entity.Position, Vector.Zero,
                nil
            )
            bony:AddCharmed(source, -1)
        end
    end, 1, 1, isPersistent)
end)