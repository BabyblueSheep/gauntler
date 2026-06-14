local itemDescriptions = {
    [TheGauntlet.Items.Aphrodite.COLLECTIBLE_TYPE] = "Charm the enemy when hurt",
    [TheGauntlet.Items.Apollo.COLLECTIBLE_TYPE] = "Musical blocking buddy",
    [TheGauntlet.Items.Ares.COLLECTIBLE_TYPE] = "More Challenges + DMG on Challenge clear",
    [TheGauntlet.Items.Artemis.COLLECTIBLE_TYPE] = "Rotating (DMG up + piercing) direction",
    [TheGauntlet.Items.Athena.COLLECTIBLE_TYPE] = "Reflective shield orbitals",
    [TheGauntlet.Items.Demeter.COLLECTIBLE_TYPE] = "Cycling season-themed effects on room entry",
    [TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE] = "All stats up + get (trippy + slippery) when hurt",
    [TheGauntlet.Items.Hades.COLLECTIBLE_TYPE] = "Tears may curse for friendly Bony on kill",
    [TheGauntlet.Items.Hephaestus.COLLECTIBLE_TYPE] = "Golden trinket + golden pickup on floor entry",
    [TheGauntlet.Items.Hera.COLLECTIBLE_TYPE] = "Minisaac-spawning enemies on room entry",
    [TheGauntlet.Items.Poseidon.COLLECTIBLE_TYPE] = "Rooms are flooded + controllable current",
    [TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE] = "Summon lightning on active use"
}

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
    if AccurateBlurbs == nil then return end

    local itemconfig = Isaac.GetItemConfig()
    for itemId, description in pairs(itemDescriptions) do
        local config = itemconfig:GetCollectible(itemId)
        config.Description = description
    end
end)