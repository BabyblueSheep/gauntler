local hadesSkullStatusEffectSprite = Sprite("gfx/gauntlet/statuseffects.anm2", true)
hadesSkullStatusEffectSprite:Play("HadesSkull", true)

StatusEffectLibrary.RegisterStatusEffect(
	"TheGauntlet_HadesSkull",
	hadesSkullStatusEffectSprite,
    Color(0.3, 0.3, 0.3, 1.0)
)

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
                EntityType.ENTITY_BLACK_BONY, 0, 0,
                entity.Position, Vector.Zero,
                nil
            )
            bony:AddCharmed(source, -1)
        end
    end, 1, 1, isPersistent)
end)