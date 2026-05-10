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

---Returns the current direction of the arrow, if it exists.
---@param player EntityPlayer
---@return Vector
function TheGauntlet.Items.Artemis.GetCurrentDirection(player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if data.Artemis == nil then
        return Vector.Zero
    end
    return data.Artemis.Direction
end

---Randomly rotates the arrow's direction, if it exists.
---@param player EntityPlayer
function TheGauntlet.Items.Artemis.RandomlyRotateArrow(player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if data.Artemis == nil then
        return
    end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE)

    --data.TimeLeft = TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES
    data.Artemis.PreviousDirection = data.Artemis.Direction
    data.Artemis.Direction = TheGauntlet.Utility.RandomCardinalVector(rng)
end

--Sets the arrow to a specific direction, if it exists.
---@param player EntityPlayer
---@param direction Vector
function TheGauntlet.Items.Artemis.RotateArrow(player, direction)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if data.Artemis == nil then
        return
    end

    data.Artemis.PreviousDirection = data.Artemis.Direction
    data.Artemis.Direction = direction:Normalized()
end

---Resets the timer to its initial value.
---@param player EntityPlayer
function TheGauntlet.Items.Artemis.ResetTimer(player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if data.Artemis == nil then
        return
    end

    data.Artemis.TimeLeft = TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES
end

---Returns the value of the timer.
---@param player EntityPlayer
function TheGauntlet.Items.Artemis.GetTimer(player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if data.Artemis == nil then
        return -1
    end
    return data.Artemis.TimeLeft
end

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)

    if not player:HasCollectible(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE) then
        data.Artemis = nil
        return
    end

    if data.Artemis == nil then
        local rng = player:GetCollectibleRNG(TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE)
        local randomDirection = TheGauntlet.Utility.RandomCardinalVector(rng)

        data.Artemis = {
            TimeLeft = TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES,
            Direction = randomDirection,
            PreviousDirection = randomDirection
        }
    end

    data.Artemis.TimeLeft = data.Artemis.TimeLeft - 1
    if data.Artemis.TimeLeft <= 0 then
        TheGauntlet.Items.Artemis.RandomlyRotateArrow(player)
        TheGauntlet.Items.Artemis.ResetTimer(player)
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

    local tearFireDirection = player:GetFireDirection()
    if tearFireDirection == Direction.NO_DIRECTION then return end
    local tearDirection = Isaac.GetAxisAlignedUnitVectorFromDir(tearFireDirection)
    local arrowDirection = TheGauntlet.Items.Artemis.GetCurrentDirection(player)

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > TheGauntlet.Items.Artemis.Constants.MINIMUM_VALID_ANGLE_DIFFERENCE then
        tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_PIERCING
        tearParams.TearDamage = tearParams.TearDamage * TheGauntlet.Items.Artemis.Constants.ARROW_DAMAGE_MULTIPLIER
        tearParams.SpeedMultiplier = tearParams.SpeedMultiplier * TheGauntlet.Items.Artemis.Constants.ARROW_SHOT_SPEED_MULTIPLIER

        if PIERCING_TEAR_VARIANTS[tearParams.TearVariant] ~= nil then
            tearParams.TearVariant = PIERCING_TEAR_VARIANTS[tearParams.TearVariant]
        end
    end
end)

local arrowSprite = Sprite("gfx/gauntlet/effects/artemis_arrow.anm2", true)
arrowSprite:Play("Left")

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
    local data = TheGauntlet.DataHolder.GetTemporaryData(player)
    if data.Artemis == nil then
        return
    end

    local angle = (data.Artemis.Direction:GetAngleDegrees() + 90) * math.pi / 180
    local previousAngle = (data.Artemis.PreviousDirection:GetAngleDegrees() + 90) * math.pi / 180

    local rotationProgress = TheGauntlet.Utility.InverseLerp(TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES, TheGauntlet.Items.Artemis.Constants.TIME_BETWEEN_ARROW_DIRECTION_CHANGE_FRAMES - 15, data.Artemis.TimeLeft)

    local easedRotationProgress = 1 - (1 - rotationProgress)^3 --Ease Out Cubic

    local renderAngle = TheGauntlet.Utility.LerpAngle(previousAngle, angle, easedRotationProgress) * 180 / math.pi

    local drawPosition = Isaac.WorldToScreen(player.Position + Vector(0.5, -60))
    arrowSprite.Rotation = renderAngle
    arrowSprite:Render(drawPosition)
end)