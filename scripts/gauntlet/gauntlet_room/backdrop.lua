TheGauntlet.GauntletRoom.Backdrop = Isaac.GetBackdropIdByName("TheGauntlet Gauntlet Room Backdrop")

TheGauntlet:AddCallback(ModCallbacks.MC_PRE_BACKDROP_CHANGE, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    return TheGauntlet.GauntletRoom.Backdrop
end)

local updateColorModifierFrameAmount = 0
TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local fxParams = Game():GetRoom():GetFXParams()
    fxParams.ColorModifier = ColorModifier(1.2, 0.8, 0.8, 0.2, 0, 1)
    fxParams.ShadowColor = KColor(0.04, 0.02, 0.02, 1.0)
    fxParams.LightColor = KColor(1.0, 0.8, 0.8, 1.0)
    updateColorModifierFrameAmount = 15
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if updateColorModifierFrameAmount > 0 then
        updateColorModifierFrameAmount = updateColorModifierFrameAmount - 1
        Game():GetRoom():UpdateColorModifier(true, true)
    end
end)