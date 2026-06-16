local originalNyxShouldDoFloodEffect = FiendFolio.nyxShouldDoFloodEffect

function FiendFolio:nyxShouldDoFloodEffect(player, tearFlags)
    if player:HasCollectible(TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE) then
        return true
    end

    return originalNyxShouldDoFloodEffect(FiendFolio, player, tearFlags)
end

local originalNyxFlood = FiendFolio.nyxFlood

function FiendFolio:nyxFlood(gem)
    local player = gem.Player or Isaac.GetPlayer(0)

    local shouldRemoveFakePisces = false
    if player:HasCollectible(TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE) then
        shouldRemoveFakePisces = true
        player:AddInnateCollectible(CollectibleType.COLLECTIBLE_PISCES, 1, "GauntletNyxPoseidonHack")
    end

    originalNyxFlood(FiendFolio, gem)

    if shouldRemoveFakePisces then
       player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_PISCES, 1, "GauntletNyxPoseidonHack")
    end
end