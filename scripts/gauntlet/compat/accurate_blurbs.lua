local itemDescriptions = {
    [TheGauntlet.Items.Aphrodite.COLLECTIBLE_TYPE] = "Charm enemy when hurt",
    [TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE] = "Musical blocking buddy",
    [TheGauntlet.Items.Ares.COLLECTIBLE_TYPE] = "More challenge rooms + DMG up on challenge clear",
    [TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE] = "(DMG up + piercing) when shooting aligned with arrowhead",
    [TheGauntlet.Items.Athena.COLLECTIBLE_TYPE] = "5 reflective shield orbitals",
    [TheGauntlet.Items.Demeter.CollectibleType] = "Cycling season-themed effects on room entry",
    [TheGauntlet.Items.Dionysus.CollectibleType] = "All stats up + get (dizzy + slippery) when hurt",
    [TheGauntlet.Items.Hades.CollectibleType] = "Tears may curse enemies + cursed enemies reanimate on kill",
    [TheGauntlet.Items.Hephaestus.COLLECTIBLE_TYPE] = "Random golden trinket + golden pickup on floor entry",
    [TheGauntlet.Items.Hera.COLLECTIBLE_TYPE] = "Enemies can spawn Minisaacs when killed",
    [TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE] = "Controllable water flow",
    [TheGauntlet.Items.Zeus.CollectibleType] = "Damaging lightning bolts when using actives"
}

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
    if AccurateBlurbs == nil then return end

    local itemconfig = Isaac.GetItemConfig()
    for itemId, description in pairs(itemDescriptions) do
        local config = itemconfig:GetCollectible(itemId)
        config.Description = description
    end
end)