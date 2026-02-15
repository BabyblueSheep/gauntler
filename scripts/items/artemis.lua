TheGauntlet.Items.Artemis = {}
TheGauntlet.Items.Artemis.CollectibleType = Isaac.GetItemIdByName("Artemis")

local TIME_BETWEEN_ARROW_DIRECTION_CHANGE = 30 * 5
local MINIMUM_VALID_ANGLE_DIFFERENCE = 0.9

local ARROW_DAMAGE_MULTIPLIER = 1.5
local ARROW_SHOT_SPEED_MULTIPLIER = 1.5

local CARDINAL_DIRECTIONS = {
    Vector(1, 0),
    Vector(-1, 0),
    Vector(0, 1),
    Vector(0, -1)
}

local TEAR_COPYING_FAMILIARS = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    [FamiliarVariant.FATES_REWARD] = true
}

---@param tear EntityTear
---@return EntityPlayer?
local function GetPlayerFromTear(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if not player then
        local familiar = tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar()
        if not familiar then return end
        if not TEAR_COPYING_FAMILIARS[familiar.Variant] then return end
        player = familiar.Player
    end
    if player then return player end
    return nil
end

local PIERCING_TEAR_VARIANTS = {
    [TearVariant.BLUE] = TearVariant.CUPID_BLUE,
    [TearVariant.BLOOD] = TearVariant.CUPID_BLOOD
}

---@param rng RNG
---@return Vector
local function RandomCardinalVector(rng)
    return CARDINAL_DIRECTIONS[rng:RandomInt(#CARDINAL_DIRECTIONS) + 1]
end

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not player:HasCollectible(TheGauntlet.Items.Artemis.CollectibleType) then return end

    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Artemis.CollectibleType)

    local data = player:GetData()
    if data.GauntletArtemis == nil then
        data.GauntletArtemis = {
            TimeLeft = TIME_BETWEEN_ARROW_DIRECTION_CHANGE,
            Direction = RandomCardinalVector(rng)
        }
    end

    data.GauntletArtemis.TimeLeft = data.GauntletArtemis.TimeLeft - 1
    if data.GauntletArtemis.TimeLeft <= 0 then
        data.GauntletArtemis.TimeLeft = TIME_BETWEEN_ARROW_DIRECTION_CHANGE
        data.GauntletArtemis.Direction = RandomCardinalVector(rng)
    end
end)

---@param tear EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    local player = GetPlayerFromTear(tear)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Artemis.CollectibleType) then return end

    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local tearDirection = tear.Velocity:Normalized()
    ---@type Vector
    local arrowDirection = data.GauntletArtemis.Direction

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > MINIMUM_VALID_ANGLE_DIFFERENCE then
        tear.Velocity = tear.Velocity * ARROW_SHOT_SPEED_MULTIPLIER
                
        --[[if PIERCING_TEAR_VARIANTS[tear.Variant] then
            tear:ChangeVariant(PIERCING_TEAR_VARIANTS[tear.Variant])
        end]]
    end
end)

---@param bomb EntityTear
TheGauntlet:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, function (_, bomb)
    local player = GetPlayerFromTear(bomb)
    if player == nil then return end

    if not player:HasCollectible(TheGauntlet.Items.Artemis.CollectibleType) then return end

    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local tearDirection = bomb.Velocity:Normalized()
    ---@type Vector
    local arrowDirection = data.GauntletArtemis.Direction

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > MINIMUM_VALID_ANGLE_DIFFERENCE then
        bomb.Velocity = bomb.Velocity * ARROW_SHOT_SPEED_MULTIPLIER
    end
end)

---@param player EntityPlayer
---@param tearParams TearParams
---@param weaponType WeaponType
---@param damageScale number
---@param tearDisplacement integer
---@param source Entity
TheGauntlet:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, function (_, player, tearParams, weaponType, damageScale, tearDisplacement, source)
    if not player:HasCollectible(TheGauntlet.Items.Artemis.CollectibleType) then return end

    local data = player:GetData()
    if data.GauntletArtemis == nil then return end

    local tearFireDirection = player:GetFireDirection()
    if tearFireDirection == Direction.NO_DIRECTION then return end
    local tearDirection = Isaac.GetAxisAlignedUnitVectorFromDir(tearFireDirection)
    ---@type Vector
    local arrowDirection = data.GauntletArtemis.Direction

    local angleDifference = tearDirection:Dot(arrowDirection)
    if angleDifference > MINIMUM_VALID_ANGLE_DIFFERENCE then
        tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_PIERCING
        tearParams.TearDamage = tearParams.TearDamage * ARROW_DAMAGE_MULTIPLIER
        
        if PIERCING_TEAR_VARIANTS[tearParams.TearVariant] ~= nil then
            tearParams.TearVariant = PIERCING_TEAR_VARIANTS[tearParams.TearVariant]
        end
    end
end)

local ANGLE_TO_ARROW = {
    [0] = "/\\",
    [90] = ">",
    [180] = "\\/",
    [270] = "<",
}

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
    local data = player:GetData()
    if data.GauntletArtemis == nil then return end
    ---@type Vector
    local direction = data.GauntletArtemis.Direction

    local drawPosition = Isaac.WorldToScreen(player.Position)
    Isaac.RenderText(ANGLE_TO_ARROW[math.floor(direction:GetAngleDegrees() + 90)], drawPosition.X, drawPosition.Y - 50, 1, 1, 1, 255)
end)