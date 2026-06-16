TheGauntlet.Items.Zeus.Constants.AVGM_BOLT_AMOUNT = 1

TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(FiendFolio.ITEM.COLLECTIBLE.AVGM, function (configItem, player, slot)
    local data = player:GetData().ffsavedata
    if data.AVGMuses == 0 then
        return 1
    end
    return 0
end)