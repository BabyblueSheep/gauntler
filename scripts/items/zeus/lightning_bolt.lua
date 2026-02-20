local sfxManager = SFXManager()

TheGauntlet.Items.Zeus.ThunderZapSoundEffect = Isaac.GetSoundIdByName("TheGauntlet Thunder Zap")

local LIGHTNING_BOLT_VARIANT = Isaac.GetEntityVariantByName("TheGauntlet Zeus Lightning Bolt")
local LIGHTNING_BOLT_SUBTYPE = Isaac.GetEntitySubTypeByName("TheGauntlet Zeus Lightning Bolt")

local beamSprite = Sprite("gfx/gauntlet/lightning_bolt.anm2", true)
beamSprite:Play("Idle", true)

---@type Beam
local beam = Beam(beamSprite, "chain", false, false)

---@param position Vector
---@param source? Entity
function TheGauntlet.Items.Zeus.SpawnLightningBolt(position, source)
    local bolt = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, LIGHTNING_BOLT_VARIANT, LIGHTNING_BOLT_SUBTYPE,
        position, Vector.Zero,
        nil
    )
    bolt.RenderZOffset = -1000

    local rng = bolt:GetDropRNG()

    sfxManager:Play(TheGauntlet.Items.Zeus.ThunderZapSoundEffect)


    local color = Color(
        1.0, 1.0, 1.0, 1.0,
        0.5, 0.5, 1.0,
        0.0, 1.0, 1.0, 0.5
    )
    Game():BombExplosionEffects(position, 100, TearFlags.TEAR_JACOBS, color, source, 0.5)

    for i = 1, 32 do
        local velocity = rng:RandomVector() * TheGauntlet.Utility.RandomFloat(-2, 2, rng)
        ---@type EntityEffect
        ---@diagnostic disable-next-line assign-type-mismatch
        local ember = Isaac.Spawn
        (
            EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0,
            position, velocity,
            nil
        ):ToEffect()
        ember:GetSprite():ReplaceSpritesheet(0, "gfx/gauntlet/effect_lightning_ember.png", true)
        ember:SetTimeout(15)
    end
end

---@param effect EntityEffect
local function FormLightningPoints(effect)
    local beamPoints = effect:GetData().BeamPoints

    local rng = effect:GetDropRNG()

    local currentPosition = effect.Position
    local currentAngle = TheGauntlet.Utility.RandomFloat(15, 45, rng) * (rng:RandomInt(2) == 0 and 1 or -1)
    local currentDirection = Vector(0, -1):Rotated(currentAngle)

    for i = 1, 16 do
        local beamWidth = TheGauntlet.Utility.Lerp(0, 4, TheGauntlet.Utility.InverseLerp(1, 16, i))

        beamPoints[i] = {
            Position = currentPosition,
            Velocity = rng:RandomVector() * TheGauntlet.Utility.RandomFloat(-4, 4, rng),
            Width = beamWidth
        }

        local moveLength = TheGauntlet.Utility.Lerp(16, 64, TheGauntlet.Utility.InverseLerp(1, 16, i))
        currentPosition = currentPosition + currentDirection * moveLength
        currentAngle = TheGauntlet.Utility.RandomFloat(15, 45, rng) * (rng:RandomInt(2) == 0 and 1 or -1)
        currentDirection = Vector(0, -1):Rotated(currentAngle)
    end
end

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if effect.Variant ~= LIGHTNING_BOLT_VARIANT then return end
    if effect.SubType ~= LIGHTNING_BOLT_SUBTYPE then return end

    effect:GetData().BeamPoints = {}
    for i = 1, 16 do
        table.insert(effect:GetData().BeamPoints, nil)
    end

    FormLightningPoints(effect)
end)

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.Variant ~= LIGHTNING_BOLT_VARIANT then return end
    if effect.SubType ~= LIGHTNING_BOLT_SUBTYPE then return end

    if effect.FrameCount > 4 then
        effect:Remove()
    end
end)

---@param effect EntityEffect
---@param offset Vector
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function(_, effect, offset)
    if effect.Variant ~= LIGHTNING_BOLT_VARIANT then return end
    if effect.SubType ~= LIGHTNING_BOLT_SUBTYPE then return end

    local indexAmount = #effect:GetData().BeamPoints
    local focusIndex = math.floor(TheGauntlet.Utility.Lerp(indexAmount, 1, TheGauntlet.Utility.InverseLerp(0, 4, effect.FrameCount)))

    for i, point in ipairs(effect:GetData().BeamPoints) do
        local alpha = TheGauntlet.Utility.InverseLerp(focusIndex - 4, focusIndex, i) * TheGauntlet.Utility.InverseLerp(focusIndex + 4, focusIndex, i)
        local color = Color(1, 1, 1, alpha)

        beam:Add(Point(Isaac.WorldToScreen(point.Position), 0, point.Width, color))
    end

    beam:Render(true)

    return false
end)