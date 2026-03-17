local WIGGLE_AMOUNT_ANGLE = 10
local WIGGLE_SPEED = 0.5



---@param familiar EntityFamiliar
TheGauntlet:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    if familiar.SubType ~= TheGauntlet.Items.Dionysus.CollectibleType then return end

    if familiar.State == TheGauntlet.Utility.LocustState.CHARGING then

        familiar.Velocity = familiar.Velocity:Rotated(TheGauntlet.Utility.Lerp(-WIGGLE_AMOUNT_ANGLE, WIGGLE_AMOUNT_ANGLE, math.cos(familiar.FrameCount * WIGGLE_SPEED) * 0.5 + 0.5))

    end
end, FamiliarVariant.ABYSS_LOCUST)