TheGauntlet.Items.Zeus.Constants.CHANCE_TO_STRIKE_ENEMY = 0.75
TheGauntlet.Items.Zeus.Constants.BOLT_DAMAGE = 20
TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL = 0.1



local game = Game()
local sfxManager = SFXManager()
local generalRNG = RNG() --I don't think this is the best idea, but mehhhh

TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT = Isaac.GetEntityVariantByName("TheGauntlet Zeus Lightning Bolt")

TheGauntlet.Items.Zeus.THUNDER_ZAP_SOUND_EFFECT = Isaac.GetSoundIdByName("TheGauntlet Thunder Zap")

local scheduledLightningBolts = {}
local currentLightningBoltDelay = 0

local function DelayBetweenBolts(currentAmount)
    return math.ceil(TheGauntlet.Utility.Lerp(15, 5, TheGauntlet.Utility.InverseLerp(2, 10, currentAmount)))
end

---@enum ZeusBoltTargetType
TheGauntlet.Items.Zeus.TargetType = {
    RANDOM_TYPE = -1,
    RANDOM_POSITION = 0,
    ENEMY = 1,
}

---Schedules a lightning bolt to spawn in the room.
---@param targetType ZeusBoltTargetType
---@param source Entity
function TheGauntlet.Items.Zeus.ScheduleLightningBolt(targetType, source)
    if targetType == TheGauntlet.Items.Zeus.TargetType.RANDOM_TYPE then
        if generalRNG:RandomFloat() < TheGauntlet.Items.Zeus.Constants.CHANCE_TO_STRIKE_ENEMY then
            targetType = TheGauntlet.Items.Zeus.TargetType.ENEMY
        else
            targetType = TheGauntlet.Items.Zeus.TargetType.RANDOM_POSITION
        end
    end

    table.insert(scheduledLightningBolts, { TargetType = targetType, Source = source })
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if #scheduledLightningBolts > 0 then
        currentLightningBoltDelay = currentLightningBoltDelay + 1

        local delayToUse = DelayBetweenBolts(#scheduledLightningBolts)
        if currentLightningBoltDelay > delayToUse then

            local enemyPositions = {}
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity:IsActiveEnemy() then
                    table.insert(enemyPositions, entity.Position)
                end
            end

            local bolt = table.remove(scheduledLightningBolts, 1)
            local targetPosition = Vector.Zero

            if bolt.TargetType == TheGauntlet.Items.Zeus.TargetType.ENEMY and #enemyPositions > 0 then
                targetPosition = TheGauntlet.Utility.RandomItemFromList(enemyPositions, generalRNG)
            else
                targetPosition = game:GetRoom():GetRandomPosition(10)
            end

            TheGauntlet.Items.Zeus.SpawnLightningBolt(targetPosition, bolt.Source)

            currentLightningBoltDelay = 0

        end
    else
        currentLightningBoltDelay = 9999 --Make a lightning bolt instantly strike if it's the first one after no bolts
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    scheduledLightningBolts = {}
end)

---Creates a lightning bolt at a given position.
---@param position Vector
---@param source? Entity
function TheGauntlet.Items.Zeus.SpawnLightningBolt(position, source)
    local bolt = TheGauntlet.Utility.SpawnEffect
    (
        EntityType.ENTITY_EFFECT, TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT, 0,
        position, Vector.Zero,
        source
    )
    bolt.RenderZOffset = -1000

    sfxManager:Play(TheGauntlet.Items.Zeus.THUNDER_ZAP_SOUND_EFFECT, 1, 2, false, math.random() * 0.4 + 0.8)

    local tearFlags = TearFlags.TEAR_JACOBS
    if source ~= nil and source:ToPlayer() ~= nil and source:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
        tearFlags = tearFlags | TearFlags.TEAR_BURN
    end

    game:BombExplosionEffects(position, TheGauntlet.Items.Zeus.Constants.BOLT_DAMAGE, tearFlags, Color.Default, bolt, 0.5)

    if game:GetRoom():HasWater() then

        local sparkDirection = generalRNG:RandomVector() * 16

        local nearbyEnemies = Isaac.FindInRadius(position, 40 * 10, EntityPartition.ENEMY)
        if #nearbyEnemies > 0 then

            local closestEnemy = nearbyEnemies[1]
            for i = 2, #nearbyEnemies do
                if closestEnemy.Position:Distance(position) > nearbyEnemies[i].Position:Distance(position) then
                    closestEnemy = nearbyEnemies[i]
                end
            end
            local directionToClosestEnemy = (closestEnemy.Position - position)

            if directionToClosestEnemy:Length() > 0.01 then
                sparkDirection = directionToClosestEnemy
            end

        end

        local player = source
        if player == nil or player:ToPlayer() == nil then
            player = Isaac.GetPlayer()
        end

        local spark = EntityLaser.ShootAngle(LaserVariant.ELECTRIC, position, sparkDirection:GetAngleDegrees(), 7, Vector.Zero, player)
        spark.SubType = LaserSubType.LASER_SUBTYPE_NO_IMPACT
        spark.MaxDistance = sparkDirection:Length()
        spark:SetOneHit(true)
        spark.DisableFollowParent = true
        spark.TearFlags = TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_JACOBS
        spark.SpriteOffset = Vector(0, -18)

    end
end

local POINT_AMOUNT = 24

---@param effect EntityEffect
local function FormLightningPoints(effect)
    local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)
    local beamPoints = data.BeamPoints

    local rng = effect:GetDropRNG()

    local currentPosition = effect.Position
    local currentAngle = TheGauntlet.Utility.RandomFloat(15, 45, rng) * (rng:RandomInt(2) == 0 and 1 or -1)
    local currentDirection = Vector(0, -1):Rotated(currentAngle)

    for i = 1, POINT_AMOUNT do
        local beamWidth = TheGauntlet.Utility.Lerp(0, 4, TheGauntlet.Utility.InverseLerp(1, POINT_AMOUNT, i))

        beamPoints[i] = {
            Position = currentPosition,
            Velocity = rng:RandomVector() * TheGauntlet.Utility.RandomFloat(-4, 4, rng),
            Width = beamWidth
        }

        local moveLength = TheGauntlet.Utility.Lerp(16, 64, TheGauntlet.Utility.InverseLerp(1, POINT_AMOUNT, i))
        currentPosition = currentPosition + currentDirection * moveLength
        currentAngle = TheGauntlet.Utility.RandomFloat(15, 45, rng) * (rng:RandomInt(2) == 0 and 1 or -1)
        currentDirection = Vector(0, -1):Rotated(currentAngle)
    end
end

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if effect.Variant ~= TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT then return end

    local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)
    data.BeamPoints = {}
    for i = 1, POINT_AMOUNT do
        table.insert(data.BeamPoints, nil)
    end

    FormLightningPoints(effect)
end)

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.Variant ~= TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT then return end

    if effect.FrameCount > 4 then
        effect:Remove()
    end
end)

local beamSprite = Sprite("gfx/gauntlet/effects/lightning_bolt.anm2", true)
beamSprite:Play("Idle", true)

---@type Beam
local whiteBeam = Beam(beamSprite, "chain", false, false)
---@type Beam
local coloredBeam = Beam(beamSprite, "chain", false, false)
whiteBeam:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.NORMAL)
coloredBeam:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.NORMAL)

---@param effect EntityEffect
---@param offset Vector
TheGauntlet:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function(_, effect, offset)
    if effect.Variant ~= TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT then return end

    local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)

    local alpha = TheGauntlet.Utility.InverseLerp(4, 0, effect.FrameCount)

    for i, point in ipairs(data.BeamPoints) do
        local whiteColor = Color(1, 1, 1, alpha)
        whiteBeam:Add(Point(Isaac.WorldToScreen(point.Position), 0, point.Width * 0.5, whiteColor))
        local coloredColor = Color(0.6, 0.8, 1, alpha)
        coloredBeam:Add(Point(Isaac.WorldToScreen(point.Position), 0, point.Width, coloredColor))
    end
    coloredBeam:Render()
    whiteBeam:Render()

    return false
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if source.Entity == nil then return end
    if source.Entity.Type ~= EntityType.ENTITY_EFFECT then return end
    if source.Entity.Variant ~= TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT then return end

    if entity.Type ~= EntityType.ENTITY_PLAYER then return end

    if damageFlags & DamageFlag.DAMAGE_EXPLOSION == 0 then return end

    return false
end)

---@param entity Entity
---@param killSource EntityRef
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity, killSource)
    if killSource.Entity == nil then return end

    if killSource.Entity.Type ~= EntityType.ENTITY_EFFECT then return end
    if killSource.Entity.Variant ~= TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT then return end

    local player = TheGauntlet.Utility.GetPlayerFromEntity(killSource.Entity.SpawnerEntity)
    if not player then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE)
    
    if rng:RandomFloat() < TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL then
        player:AddActiveCharge(1)
    end
end)