TheGauntlet.Items.Zeus.Constants.ERRORS_CRAZY_SLOTS_BOLT_AMOUNT = 1

TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(FiendFolio.ITEM.COLLECTIBLE.ERRORS_CRAZY_SLOTS, function (configItem, player, slot)
    local data = player:GetData().ffsavedata
    if data.CrazyErrorSlot == nil then
        return TheGauntlet.Items.Zeus.Constants.ONE_TIME_USE_BOLT_AMOUNT
    end
    if data.CrazyErrorSlot ~= 1 then
        return TheGauntlet.Items.Zeus.Constants.ERRORS_CRAZY_SLOTS_BOLT_AMOUNT
    end
    return 0
end)