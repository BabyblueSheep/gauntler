TheGauntlet.Items.Hades.Constants = {
    SKULL_STATUS_DURATION = 30 * 5,
    CHANCE_TO_APPLY_SKULL = 0.05,
}


local TEAR_BONE_COLOR = Color(1.0, 1.0, 1.0, 1.0)
local TEAR_VARIANTS_THAT_CANNOT_BE_BONED = {
    [TearVariant.FETUS] = true,
    [TearVariant.BALLOON] = true,
    [TearVariant.BALLOON_BOMB] = true,
    [TearVariant.BALLOON_BRIMSTONE] = true,
}

local BOMB_BONE_COLOR = Color
(
    1.0, 1.0, 1.0, 1.0,
    0.15, 0.15, 0.15,
    1.0, 1.0, 1.0, 1.0
)

local AQUARIUS_CREEP_COLOR = Color
(
    0, 0, 0, 1,
    0.8, 0.8, 0.8
)

local bombRocketIds = {
	[BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_ROCKET] = true,
	[BombVariant.BOMB_ROCKET_GIGA] = true
}




TheGauntlet.Items.Hades.COLLECTIBLE_TYPE = Isaac.GetItemIdByName("Hades")
TheGauntlet.Items.Hades.TEAR_FLAG = TearFlagsLib.RegisterTearFlag("TheGauntlet_Hades")

---Whether the effect should proc after calling this.
---@param player EntityPlayer
---@return boolean
function TheGauntlet.Items.Hades.ShouldProc(player)
    if not player:HasCollectible(TheGauntlet.Items.Hades.COLLECTIBLE_TYPE) then return false end
    local rng = player:GetCollectibleRNG(TheGauntlet.Items.Hades.COLLECTIBLE_TYPE)

    return rng:RandomFloat() < TheGauntlet.Items.Hades.Constants.CHANCE_TO_APPLY_SKULL
end

---@param weaponEntity Entity
---@param player EntityPlayer
---@param weaponFlags any
TheGauntlet:AddCallback(TearFlagsLib.Callback.POLL_TEARFLAGS, function (_, weaponEntity, player, weaponFlags)
    if TheGauntlet.Items.Hades.ShouldProc(player) then
        TearFlagsLib.AddTearFlags(weaponEntity, TheGauntlet.Items.Hades.TEAR_FLAG)
    end
end)

---@param recipient Entity
---@param player EntityPlayer
---@param fromPooling boolean
---@param weaponFlags any
---@param tearFlags any
TheGauntlet:AddPriorityCallback(TearFlagsLib.Callback.POST_ADD_TEARFLAG, CallbackPriority.LATE, function (_, recipient, player, fromPooling, weaponFlags, tearFlags)
    local tear = recipient:ToTear()
    if tear ~= nil then
        if not TEAR_VARIANTS_THAT_CANNOT_BE_BONED[tear.Variant] then
            tear:ChangeVariant(TearVariant.BONE)
            tear.Color = TEAR_BONE_COLOR
        end
    end

    local bomb = recipient:ToBomb()
    if bomb ~= nil then
        bomb.Color = BOMB_BONE_COLOR
    end
end, TheGauntlet.Items.Hades.TEAR_FLAG)

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if TearFlagsLib.HasTearFlags(effect, TheGauntlet.Items.Hades.TEAR_FLAG) and effect.FrameCount == 0 then
        effect.Color = AQUARIUS_CREEP_COLOR
    end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

---@param targetEntity EntityNPC
---@param player EntityPlayer
---@param weaponEntity Entity
---@param weaponFlags any
---@param params table
TheGauntlet:AddCallback(TearFlagsLib.Callback.APPLY_TEARFLAG_EFFECT, function(_, targetEntity, player, weaponEntity, weaponFlags, params)
    TheGauntlet.Items.Hades.InflictStatusEffect(targetEntity, TheGauntlet.Items.Hades.Constants.SKULL_STATUS_DURATION, EntityRef(player))
end, TheGauntlet.Items.Hades.TEAR_FLAG)