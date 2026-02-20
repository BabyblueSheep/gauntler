---@param configItem ItemConfigItem
---@param player EntityPlayer
---@param slot ActiveSlot
return function (configItem, player, slot)
    if configItem.ChargeType == 2 then
        return 0
    elseif configItem.ChargeType == 1 then
        return math.ceil((player:GetActiveCharge(slot)) / 45)
    else
        return player:GetActiveCharge(slot) + 2
    end
end