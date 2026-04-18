local game = Game()

TheGauntlet.Items.Zeus.RegisterBoltAmountForItem(CollectibleType.COLLECTIBLE_BLUE_BOX, function (configItem, player, slot)
    return game:GetLevel():GetStage() + 3
end)