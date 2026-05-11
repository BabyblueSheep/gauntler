return {
    ["pool.gauntlet.name"] = "Gauntlet",

    ["item.generic.gauntlet_chance_boost"] = "{{GauntletGauntletRoomStat}} +[1]% Gauntlet Room chance",

    ["item.aphrodite.name"] = "Aphrodite",
    ["item.aphrodite.description"] =
        "{{Friendly}} Taking damage from a non-boss enemy converts it to a friendly companion#"..
        "{{Charm}} Taking damage from a boss charms it",

    ["item.apollo.name"] = "Apollo",
    ["item.apollo.description"] =
        "Blocks projectiles#"..
        "When hit, [1]% chance to grant triple shot for [2] seconds",

    ["item.ares.name"] = "Ares",
    ["item.ares.description"] =
        "{{ChallengeRoom}} Spawns an additional (Boss) Challenge Room each even/odd numbered floor#"..
        "Clearing a {{ChallengeRoom}} Challenge Room grants ↑ {{Damage}} +[1] Damage for the floor#"..
        "Clearing a {{BossRushRoom}} Boss Challenge Room grants ↑ {{Damage}} +[2] Damage for the floor",

    ["item.artemis.name"] = "Artemis",
    ["item.artemis.description"] =
        "An arrow facing a cardinal direction appears above Isaac that periodically rotates#"..
        "Tears shot in the arrow's direction piece and gain a shot speed + [1]x damage boost",

    ["item.athena.name"] = "Athena",
    ["item.athena.description"] =
        "Grants [1] rotating shields around Isaac#"..
        "Shields reflect projectiles and knock enemies back#"..
        "{{Timer}} Shields go on a [2] second cooldown after deflecting",
    ["item.athena.description.duplicate"] = "Grants an additional shield",

    ["item.demeter.name"] = "Demeter",
    ["item.demeter.description"] =
        "Causes a room-wide effect that cycles after clearing a room:#"..
        "{{GauntletDemeterWinter}} Enemies are frozen on death#"..
        "{{GauntletDemeterSpring}} [1]% chance to shoot a sticky booger#"..
        "{{GauntletDemeterSummer}} Enemies constantly burn#"..
        "{{GauntletDemeterAutumn}} Enemies are permanently slowed down",
	["item.demeter.description.greed"] = "{{GreedMode}} Effect also cycles after every wave",

    ["item.dionysus.name"] = "Dionysus",
    ["item.dionysus.description"] =
        "↑ {{Speed}} +[1] Speed#"..
        "↑ {{Tears}} +[2] Tears#"..
        "↑ {{Damage}} +[3] Damage#"..
        "↑ {{Range}} +[4] Range#"..
        "↑ {{Luck}} +[5] Luck#"..
        "↑ {{Heart}} +[6] Health#"..
        "{{HealingRed}} Heals [7] heart#"..
        "+[8] {{Coin}} coin, {{Bomb}} bomb and {{Key}} key#"..
        "{{Warning}} Taking damage makes Isaac's movement slippery and distorts the screen for [9] seconds",

    ["item.hades.name"] = "Hades",
    ["item.hades.description"] =
        "{{GauntletHadesStatusEffect}} [1]% chance to shoot a bone tear that inflicts Calcified#"..
        "{{Friendly}} Killing a Calcified enemy spawns a friendly Bony",

    ["item.hephaestus.name"] = "Hephaestus",
    ["item.hephaestus.description"] =
        "{{Trinket}} Spawns 1 random golden trinket#"..
        "Entering a new floor spawns a random golden pickup",
    ["item.hephaestus.description.without_golden_trinket"] =
        "{{Trinket}} Spawns 1 random trinket#"..
        "Entering a new floor spawns a random golden pickup",
    ["item.hephaestus.description.duplicate"] = "Entering a new floor spawns an additional golden pickup",

    ["item.hera.name"] = "Hera",
    ["item.hera.description"] =
        "{{GauntletHeraStatusEffect}} Entering a room inflicts Pregnant on [1] enemies#"..
        "{{Timer}} Killing a Pregnant enemy spawns [2]-[3] Minisaac for the room",
    ["item.hera.description.duplicate"] = "Inflicts Pregnant on an additional enemy",

    ["item.poseidon.name"] = "Poseidon",
    ["item.poseidon.description"] =
        "All rooms are flooded#"..
        "Holding the fire buttons causes water to flow in the direction held, pushing enemies and consumables back",
    ["item.poseidon.description.duplicate"] = "Water flow is stronger",

    ["item.zeus.name"] = "Zeus",
    ["item.zeus.description"] =
        "Spawns lightning bolts that have a [1]% chance to add 1 charge to the active item#"..
        "Can be combined with a second active item to spawn lightning bolts, with the amount scaling with the item's charge#"..
        "{{Battery}} Fully recharges and overcharges the active item on pickup, and overcharges all future active items",
    ["item.zeus.description.book_of_virtues"] = "Wisps spawn a lightning bolt when destroyed",
    ["item.zeus.description.judas_birthright"] = "Lightning bolts burn enemies and leaves a fire behind",

    ["item.zeus.description.bolt_spawn.default"] = "Spawns [1] lightning bolts when use",
    ["item.zeus.description.bolt_spawn.default_one"] = "Spawns [1] lightning bolt when use",

    ["item.zeus.description.bolt_spawn.berserk"] = "Spawns a lightning bolt every [1] seconds while active",
    ["item.zeus.description.bolt_spawn.eraser"] = "Spawns [1] lightning bolts when erasing an enemy",
    ["item.zeus.description.bolt_spawn.mama_mega"] = "Spawns [1] lightning bolt when used and on room entry",
    ["item.zeus.description.bolt_spawn.notched_axe"] = "Spawns [1] lightning bolt when running out of charge",
    ["item.zeus.description.bolt_spawn.pandoras_box"] = "Spawns lightning bolts, with the amount scaling with the current floor number",

    --Tear flags formatting
    ["item.abyss.locust_effect.hades"] = "calcifying",

    --Locust flags formatting
    ["item.abyss.locust_effect.demeter"] = "{{Collectible"..CollectibleType.COLLECTIBLE_SINUS_INFECTION.."}} Attaches a booger tear when dealing damage",
    ["item.abyss.locust_effect.poseidon"] = "{{Collectible"..Isaac.GetItemIdByName("Poseidon").."}} Pushes nearby enemies in its direction when charging",
    ["item.abyss.locust_effect.zeus"] = "{{Collectible"..Isaac.GetItemIdByName("Zeus").."}} Spawns a lightning bolt when dealing damage",
}