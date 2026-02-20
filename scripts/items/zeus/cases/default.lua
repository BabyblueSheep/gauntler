---@param configItem ItemConfigItem
---@param player EntityPlayer
---@param slot ActiveSlot
return function (configItem, player, slot)
    if configItem.ChargeType == 2 then
        return 0
    elseif configItem.ChargeType == 1 then
        local chargeAmount = player:GetActiveCharge(slot)
        if chargeAmount == 0 then return chargeAmount end
        return math.ceil(chargeAmount / 45)
    else
        local chargeAmount = player:GetActiveCharge(slot)
        if chargeAmount == 0 then return chargeAmount end
        return chargeAmount + 2
    end
end