local itemDescriptions = {
    [TheGauntlet.Items.Aphrodite.CollectibleType] = "Charm enemy when hurt",
    [TheGauntlet.Items.Apollo.CollectibleType] = "DMG up if going to boss + DMG down if not",
    [TheGauntlet.Items.Ares.CollectibleType] = "More challenge rooms + DMG up on challenge clear",
    [TheGauntlet.Items.Artemis.CollectibleType] = "(DMG up + piercing) when shooting aligned with arrowhead",
    [TheGauntlet.Items.Athena.CollectibleType] = "5 reflective shield orbitals",
    [TheGauntlet.Items.Demeter.CollectibleType] = "Cycling season-themed room effects",
    [TheGauntlet.Items.Dionysus.CollectibleType] = "All stats up + (dizzy + slippery) when hurt",
    [TheGauntlet.Items.Hades.CollectibleType] = "Tears may curse enemies + cursed enemies reanimate on kill",
    [TheGauntlet.Items.Hephaestus.CollectibleType] = "Random golden trinket + golden pickup on floor entry",
    [TheGauntlet.Items.Hera.CollectibleType] = "Enemies can spawn Minisaacs when killed",
    [TheGauntlet.Items.Poseidon.CollectibleType] = "Controllable water flow",
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