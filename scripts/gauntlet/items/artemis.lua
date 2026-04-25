TheGauntlet.Items.Artemis = {}

TheGauntlet.Items.Artemis.Constants = {
    ARROW_DAMAGE_MULTIPLIER = 1.5,
    ARROW_SHOT_SPEED_MULTIPLIER = 1.5,

    TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES = 30 * 5,
    MINIMUM_VALID_ANGLE_DIFFERENCE = 0.9, --Smaller = less strict. Used for unlocked rotation.
}



TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Artemis")

local PIERCING_TEAR_VARIANTS = {
    [TearVariant.BLUE] = TearVariant.CUPID_BLUE,
    [TearVariant.BLOOD] = TearVariant.CUPID_BLOOD
}

---@param player EntityPlayer
---@return Vector
function TheGauntlet.Items.Artemis.GetCurrentDirection(player)
    local data = player:GetData().GauntletArtemis
    return data and data.Direction or Vector.Zero
end

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not player:HasCollectible(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE) then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE)
    local randomDirection = TheGauntlet.Utility.RandomCardinalVector(rng)

    local data = player:GetData()
    if data.GauntletArtemis == nil then
        data.GauntletArtemis = {
            TimeLeft = TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES,
            Direction = randomDirection,
            PreviousDirection = randomDirection
        }
    end

    data.GauntletArtemis.TimeLeft = data.GauntletArtemis.TimeLeft - 1
    if data.GauntletArtemis.TimeLeft <= 0 then
        data.GauntletArtemis.TimeLeft = TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES
        data.GauntletArtemis.PreviousDirection = data.GauntletArtemis.Direction
        data.GauntletArtemis.Direction = TheGauntlet.Utility.RandomCardinalVector(rng)
    end
end)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wisp boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wisp)
    player:GetData().GauntletArtemis = nil
end, TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE)

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(tear.SpawnerEntity, true)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE) then return end

    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local tearDirection = tear.Velocity:Normalized()
    ---@type Vector
    local arrowDirection = data.GauntletArtemis.Direction

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > TheGauntlet.Items.Artemis.Constants.MINIMUM_VALID_ANGLE_DIFFERENCE then
        tear.Velocity = tear.Velocity * TheGauntlet.Items.Artemis.Constants.ARROW_SHOT_SPEED_MULTIPLIER
                
        --[[if PIERCING_TEAR_VARIANTS[tear.Variant] then
            tear:ChangeVariant(PIERCING_TEAR_VARIANTS[tear.Variant])
        end]]
    end
end)

---@param bomb EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, function (_, bomb)
    local player = TheGauntlet.Utility.GetPlayerFromEntity(bomb.SpawnerEntity, true)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE) then return end

    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local tearDirection = bomb.Velocity:Normalized()
    ---@type Vector
    local arrowDirection = data.GauntletArtemis.Direction

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > TheGauntlet.Items.Artemis.Constants.MINIMUM_VALID_ANGLE_DIFFERENCE then
        bomb.Velocity = bomb.Velocity * TheGauntlet.Items.Artemis.Constants.ARROW_SHOT_SPEED_MULTIPLIER
    end
end)

---@param player EntityPlayer
---@param tearParams TearParams
---@param weaponType WeaponType
---@param damageScale number
---@param tearDisplacement integer
---@param source Entity
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, function (_, player, tearParams, weaponType, damageScale, tearDisplacement, source)
    if not player:HasCollectible(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE) then return end

    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local tearFireDirection = player:GetFireDirection()
    if tearFireDirection == Direction.NO_DIRECTION then return end
    local tearDirection = Isaac.GetAxisAlignedUnitVectorFromDir(tearFireDirection)
    ---@type Vector
    local arrowDirection = data.GauntletArtemis.Direction

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > TheGauntlet.Items.Artemis.Constants.MINIMUM_VALID_ANGLE_DIFFERENCE then
        tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_PIERCING
        tearParams.TearDamage = tearParams.TearDamage * TheGauntlet.Items.Artemis.Constants.ARROW_DAMAGE_MULTIPLIER

        if PIERCING_TEAR_VARIANTS[tearParams.TearVariant] ~= nil then
            tearParams.TearVariant = PIERCING_TEAR_VARIANTS[tearParams.TearVariant]
        end
    end
end)

local arrowSprite = Sprite("gfx/gauntlet/effects/artemis_arrow.anm2", true)
arrowSprite:Play("Left")

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local angle = (data.GauntletArtemis.Direction:GetAngleDegrees() + 90) * math.pi / 180
    local previousAngle = (data.GauntletArtemis.PreviousDirection:GetAngleDegrees() + 90) * math.pi / 180

    local rotationProgress = TheGauntlet.Utility.InverseLerp(TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES, TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES - 15, data.GauntletArtemis.TimeLeft)

    local easedRotationProgress = 1 - (1 - rotationProgress)^3 --Ease Out Cubic

    local renderAngle = TheGauntlet.Utility.LerpAngle(previousAngle, angle, easedRotationProgress) * 180 / math.pi

    local drawPosition = Isaac.WorldToScreen(player.Position + Vector(0.5, -60))
    arrowSprite.Rotation = renderAngle
    arrowSprite:Render(drawPosition)
end)