---@param collectibleType CollectibleType
---@param configItem ItemConfigItem
---@param player EntityPlayer
---@param slot ActiveSlot
return function (collectibleType, configItem, player, slot)
    local playerSave = TheGauntlet.SaveManager.GetRunSave(player)

    if player:GetActiveItem(slot) == 0 then return 16 end
    if player:GetTotalActiveCharge(slot) == playerSave.PreviousTotalChargeAmount and Game():GetDebugFlags() & DebugFlag.INFINITE_ITEM_CHARGES == 0 then return 0 end

    if configItem.ChargeType == 2 then
        return 0
    elseif configItem.ChargeType == 1 then
        local chargeAmount = playerSave.PreviousChargeAmount
        if chargeAmount == 0 then return chargeAmount end
        return chargeAmount // 60
    else
        local chargeAmount = playerSave.PreviousChargeAmount
        if chargeAmount == 0 then return chargeAmount end
        return chargeAmount
    end
end