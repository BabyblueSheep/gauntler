local sfxManager = SFXManager()

TheGauntlet.Items.Athena = {}
TheGauntlet.Items.Athena.CollectibleType = Isaac.GetItemIdByName("Athena")

TheGauntlet.Items.Athena.AegisVariant = Isaac.GetEntityVariantByName("TheGauntlet Athena Aegis")
TheGauntlet.Items.Athena.AegisSubtype = Isaac.GetEntitySubTypeByName("TheGauntlet Athena Aegis")

local SHIELD_AMOUNT = 5
local SHIELD_ROTATION_SPEED = 3

local SHIELD_HITBOX_SIZE = 18

local SHIELD_RETRACT_TIME = 10
local SHIELD_DISABLE_TIME = 30 * 15

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    local hasAthena = player:HasCollectible(TheGauntlet.Items.Athena.CollectibleType)

    local data = player:GetData()

    for i = 1, SHIELD_AMOUNT do
        ---@type EntityEffect
        local shieldEffect = data["AthenaShield"..tostring(i)]

        if not (shieldEffect ~= nil and shieldEffect:Exists()) then
            if hasAthena then
                ---@type EntityEffect
                ---@diagnostic disable-next-line assign-type-mismatch
                local effect = Isaac.Spawn
                (
                    EntityType.ENTITY_EFFECT, TheGauntlet.Items.Athena.AegisVariant, TheGauntlet.Items.Athena.AegisSubtype,
                    player.Position, Vector.Zero,
                    player
                ):ToEffect()
                effect:Update()
                data["AthenaShield"..tostring(i)] = effect
            end
        else
            if not hasAthena then
                shieldEffect:Remove()
            end
        end
    end

    if not hasAthena then return end

    if data.AthenaRotationTimer == nil then
        data.AthenaRotationTimer = 0
    end
    data.AthenaRotationTimer = data.AthenaRotationTimer + 1

    for i = 1, SHIELD_AMOUNT do
        ---@type EntityEffect
        local shieldEffect = data["AthenaShield"..tostring(i)]

        local shieldSprite = shieldEffect:GetSprite()
        local shieldData = shieldEffect:GetData()

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

        local direction = Vector.FromAngle(data.AthenaRotationTimer * SHIELD_ROTATION_SPEED + i / SHIELD_AMOUNT * 360)
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
        local alpha = TheGauntlet.Utility.Lerp(1, 0.5, shieldData.RetractTimer)
        shieldSprite.Color = Color(1, 1, 1, alpha)

        if not shieldData.Disabled then
            local reflected = false
            local collidingProjectiles = Isaac.FindInRadius(shieldEffect.Position, SHIELD_HITBOX_SIZE, EntityPartition.BULLET)
            if #collidingProjectiles > 0 then
                local projectile = collidingProjectiles[1]:ToProjectile()
                if projectile ~= nil then
                    projectile.Velocity = projectile.Velocity:Length() * direction
                    projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CANT_HIT_PLAYER)

                    sfxManager:Play(907) --SoundEffect.SOUND_RIB_DEFLECT

                    reflected = true
                end
            else
                local collidingEnemies = Isaac.FindInRadius(shieldEffect.Position, SHIELD_HITBOX_SIZE, EntityPartition.ENEMY)
                if #collidingEnemies > 0 then
                    local enemy = collidingEnemies[1]:ToNPC()
                    if enemy ~= nil and enemy:IsActiveEnemy() then
                        enemy:AddKnockback(EntityRef(player), direction * 10, 10, true)

                        sfxManager:Play(907) --SoundEffect.SOUND_RIB_DEFLECT

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
                shieldData.RetractTimer = shieldData.RetractTimer + 1 / SHIELD_RETRACT_TIME
                if shieldData.RetractTimer > 1 then
                    shieldData.RetractTimer = 1
                    shieldData.Retracting = false
                    shieldData.DisabledTimer = 0
                end
                shieldData.EasedRetractTimer = 1.0 - (1.0 - shieldData.RetractTimer)^3
            elseif shieldData.Unretracting then
                shieldData.RetractTimer = shieldData.RetractTimer - 1 / SHIELD_RETRACT_TIME
                if shieldData.RetractTimer < 0 then
                    shieldData.RetractTimer = 0
                    shieldData.Unretracting = false
                    shieldData.Disabled = false
                end
                shieldData.EasedRetractTimer = shieldData.RetractTimer^3
            else
                shieldData.DisabledTimer = shieldData.DisabledTimer + 1 / SHIELD_DISABLE_TIME
                if shieldData.DisabledTimer > 1 then
                    shieldData.Unretracting = true
                end
            end
        end
    end
end)