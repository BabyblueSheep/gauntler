TheGauntlet.Items.Athena = {}

TheGauntlet.Items.Athena.Constants = {
    SHIELD_AMOUNT = 5,
    SHIELD_ROTATION_SPEED = 3,

    SHIELD_HITBOX_SIZE = 18,

    SHIELD_RETRACT_TIME_FRAMES = 10,
    SHIELD_DISABLE_TIME_FRAMES = 15 * 30,
}



local game = Game()
local sfxManager = SFXManager()

TheGauntlet.Items.Athena.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Athena")

TheGauntlet.Items.Athena.SHIELD_EFFECT_VARIANT = Isaac.GetEntityVariantByName("TheGauntlet Athena Aegis")

TheGauntlet.Items.Athena.METAL_HIT_SOUND_EFFECT = Isaac.GetSoundIdByName("TheGauntlet Metal Hit")

---@param position Vector
---@param angle number
local function DeflectEffects(position, angle)
    local poofEffect = TheGauntlet.Utility.SpawnEffect
    (
        EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 10,
        position, Vector.Zero,
        nil
    )

    poofEffect.Rotation = -90 - angle
    poofEffect.DepthOffset = 99999
    poofEffect.Color = Color(0, 0, 0, 1, 1, 1, 1)

    sfxManager:Play(905, 50) --SoundEffect.SOUND_TEAR_BOUNCE
    sfxManager:Play(TheGauntlet.Items.Athena.METAL_HIT_SOUND_EFFECT)
end

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    local hasAthena = player:HasCollectible(TheGauntlet.Items.Athena.COLLECTIBLE_TYPE)

    local dataHourglass = TheGauntlet.DataHolder.GetTemporaryData(player)
    local data = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(player)

    if data.Athena == nil then
        data.Athena = {}
        data.Athena.MaximumShieldAmount = 5
    end
    if dataHourglass.Athena == nil then
        dataHourglass.Athena = {}
    end

    local shieldAmount = TheGauntlet.Items.Athena.Constants.SHIELD_AMOUNT + (player:GetCollectibleNum(TheGauntlet.Items.Athena.COLLECTIBLE_TYPE) - 1)
    if not hasAthena then
        shieldAmount = 0
    end
    data.Athena.MaximumShieldAmount = math.max(data.Athena.MaximumShieldAmount, shieldAmount)

    for i = 1, shieldAmount do
        ---@type EntityPtr
        local shieldEffect = data.Athena["ShieldEntity"..tostring(i)]
        local shieldSavedData = dataHourglass.Athena["ShieldSavedData"..tostring(i)]

        if not (shieldEffect ~= nil and shieldEffect.Ref ~= nil) then
            local effect = TheGauntlet.Utility.SpawnEffect
            (
                EntityType.ENTITY_EFFECT, TheGauntlet.Items.Athena.SHIELD_EFFECT_VARIANT, 0,
                player.Position, Vector.Zero,
                player
            )
            effect:Update()
            data.Athena["ShieldEntity"..tostring(i)] = EntityPtr(effect)
            if shieldSavedData ~= nil then
                local shieldData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(effect)
                for k, v in pairs(shieldSavedData) do
                    shieldData[k] = v
                end
            end
        end
    end

    for i = shieldAmount + 1, data.Athena.MaximumShieldAmount do
        local shieldEffect = data.Athena["ShieldEntity"..tostring(i)]
        if shieldEffect ~= nil and shieldEffect.Ref ~= nil then
            shieldEffect.Ref:Remove()
        end
    end

    if not hasAthena then return end
    if game:IsPaused() then return end

    if dataHourglass.Athena.RotationTimer == nil then
        dataHourglass.Athena.RotationTimer = 0
    end
    dataHourglass.Athena.RotationTimer = dataHourglass.Athena.RotationTimer + 1

    for i = 1, shieldAmount do
        ---@type EntityPtr
        local shieldEffectPtr = data.Athena["ShieldEntity"..tostring(i)]
        if shieldEffectPtr == nil or shieldEffectPtr.Ref == nil then
            goto continue
        end

        ---@type Entity
        local shieldEffect = shieldEffectPtr.Ref

        local shieldSprite = shieldEffect:GetSprite()
        local shieldData = TheGauntlet.DataHolder.GetTemporaryNoHourglassData(shieldEffect)

        if shieldData.DisabledTimer == nil then
            shieldData.DisabledTimer = 0
        end
        if shieldData.RetractTimer == nil then
            shieldData.RetractTimer = 0
        end
        if shieldData.EasedRetractTimer == nil then
            shieldData.EasedRetractTimer = 0
        end
        if shieldData.Retracting == nil then
            shieldData.Retracting = false
        end
        if shieldData.Disabled == nil then
            shieldData.Disabled = false
        end
        if shieldData.Unretracting == nil then
            shieldData.Unretracting = false
        end

        local direction = Vector.FromAngle(dataHourglass.Athena.RotationTimer * TheGauntlet.Items.Athena.Constants.SHIELD_ROTATION_SPEED + i / shieldAmount * 360)
        local distanceFromPlayer = TheGauntlet.Utility.Lerp(40, 20, shieldData.EasedRetractTimer)
        shieldEffect.Position = player.Position + direction * distanceFromPlayer
        shieldEffect.Velocity = Vector.Zero

        local angle = direction:GetAngleDegrees()

        local isFacingDown = angle > 45 and angle < 135
        local isFacingUp = angle < -45 and angle > -135
        local isFacingRight = angle > -45 and angle < 45

        if isFacingDown then
            shieldSprite:SetFrame("Front", 0)
            shieldSprite.Rotation = TheGauntlet.Utility.Lerp(-30, 30, TheGauntlet.Utility.InverseLerp(45, 135, angle))
            shieldEffect.FlipX = false
        elseif isFacingUp then
            shieldSprite:SetFrame("Back", 0)
            shieldSprite.Rotation = TheGauntlet.Utility.Lerp(-30, 30, TheGauntlet.Utility.InverseLerp(-135, -45, angle))
            shieldEffect.FlipX = false
        elseif isFacingRight then
            shieldSprite:SetFrame("Side", 0)
            shieldSprite.Rotation = TheGauntlet.Utility.Lerp(-120, -60, TheGauntlet.Utility.InverseLerp(-45, 45, angle))
            shieldEffect.FlipX = false
        else
            local correctedAngle = angle
            if correctedAngle < 0 then
                correctedAngle = 360 - math.abs(correctedAngle)
            end
            shieldSprite:SetFrame("Side", 0)
            shieldSprite.Rotation = TheGauntlet.Utility.Lerp(-60, -120, TheGauntlet.Utility.InverseLerp(135, 225, correctedAngle))
            shieldEffect.FlipX = true
        end
        local alpha = TheGauntlet.Utility.Lerp(1, 0.25, shieldData.RetractTimer / TheGauntlet.Items.Athena.Constants.SHIELD_RETRACT_TIME_FRAMES)
        shieldSprite.Color = Color(1, 1, 1, alpha)

        if not shieldData.Disabled then
            local reflected = false
            local collidingProjectiles = Isaac.FindInRadius(shieldEffect.Position, TheGauntlet.Items.Athena.Constants.SHIELD_HITBOX_SIZE, EntityPartition.BULLET)
            if #collidingProjectiles > 0 then
                local projectile = collidingProjectiles[1]:ToProjectile()
                if projectile ~= nil then
                    projectile.Velocity = projectile.Velocity:Length() * direction
                    projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CANT_HIT_PLAYER)

                    DeflectEffects(shieldEffect.Position + direction * 10, angle)

                    reflected = true
                end
            else
                local collidingEnemies = Isaac.FindInRadius(shieldEffect.Position, TheGauntlet.Items.Athena.Constants.SHIELD_HITBOX_SIZE, EntityPartition.ENEMY)
                if #collidingEnemies > 0 then
                    local enemy = collidingEnemies[1]:ToNPC()
                    if enemy ~= nil and enemy:IsActiveEnemy() then
                        enemy.Velocity = Vector.Zero
                        enemy:AddKnockback(EntityRef(player), direction * 10, 15, true)

                        DeflectEffects(shieldEffect.Position + direction * 10, angle)

                        reflected = true
                    end
                end
            end

            if reflected then
                shieldData.RetractTimer = 0
                shieldData.Retracting = true
                shieldData.Disabled = true
            end
        end

        if shieldData.Disabled then
            if shieldData.Retracting then
                shieldData.RetractTimer = shieldData.RetractTimer + 1
                if shieldData.RetractTimer > TheGauntlet.Items.Athena.Constants.SHIELD_RETRACT_TIME_FRAMES then
                    shieldData.RetractTimer = TheGauntlet.Items.Athena.Constants.SHIELD_RETRACT_TIME_FRAMES
                    shieldData.Retracting = false
                    shieldData.DisabledTimer = 0
                end
                shieldData.EasedRetractTimer = 1.0 - (1.0 - (shieldData.RetractTimer / TheGauntlet.Items.Athena.Constants.SHIELD_RETRACT_TIME_FRAMES))^3
            elseif shieldData.Unretracting then
                shieldData.RetractTimer = shieldData.RetractTimer - 1
                if shieldData.RetractTimer < 0 then
                    shieldData.RetractTimer = 0
                    shieldData.Unretracting = false
                    shieldData.Disabled = false
                end
                shieldData.EasedRetractTimer = (shieldData.RetractTimer / TheGauntlet.Items.Athena.Constants.SHIELD_RETRACT_TIME_FRAMES)^3
            else
                shieldData.DisabledTimer = shieldData.DisabledTimer + 1
                if shieldData.DisabledTimer > TheGauntlet.Items.Athena.Constants.SHIELD_DISABLE_TIME_FRAMES then
                    shieldData.Unretracting = true
                end
            end
        end

        dataHourglass.Athena["ShieldSavedData"..tostring(i)] = TheGauntlet.Utility.CopyTableShallow(shieldData)

        ::continue::
    end
end)