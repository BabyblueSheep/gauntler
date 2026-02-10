TheGauntlet.Items.Dionysus = {}
TheGauntlet.Items.Dionysus.CollectibleType = Isaac.GetItemIdByName("Dionysus")

local TARGET_DIZZY_AMOUNT = 0.1 --Equivalent to one Wavy Cap use

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if not PlayerManager.AnyoneHasCollectible(TheGauntlet.Items.Dionysus.CollectibleType) then return end

    local currentDizzyAmount = Game():GetDizzyAmount()
    if currentDizzyAmount < TARGET_DIZZY_AMOUNT then
        Game():SetDizzyAmount(TARGET_DIZZY_AMOUNT + 0.02) --The 0.02 is to account for floating point imprecision
    end
end, TheGauntlet.Items.Dionysus.CollectibleType)
