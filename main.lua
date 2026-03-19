TheGauntlet = RegisterMod("The Gauntlet", 1)

TheGauntlet.SaveManager = include("scripts.gauntlet.library.save_manager")
include("scripts.gauntlet.library.status_effect_library")

include("scripts.gauntlet.library.dead_sea_scrolls_integration")

TheGauntlet.Utility = {}
include("scripts.gauntlet.utility.callbacks")
include("scripts.gauntlet.utility.challenge_rooms")
include("scripts.gauntlet.utility.entity_spawn")
include("scripts.gauntlet.utility.entity")
include("scripts.gauntlet.utility.logging")
include("scripts.gauntlet.utility.math")
include("scripts.gauntlet.utility.misc")
include("scripts.gauntlet.utility.random")

TheGauntlet.GauntletRoom = {}
include("scripts.gauntlet.gauntlet_room.common")
include("scripts.gauntlet.gauntlet_room.backdrop")
include("scripts.gauntlet.gauntlet_room.chance")
include("scripts.gauntlet.gauntlet_room.doors")
include("scripts.gauntlet.gauntlet_room.generation")
include("scripts.gauntlet.gauntlet_room.render_chance")
include("scripts.gauntlet.gauntlet_room.waves")

TheGauntlet.Items = {}
include("scripts.gauntlet.items.apollo")
include("scripts.gauntlet.items.aphrodite")
include("scripts.gauntlet.items.ares")
include("scripts.gauntlet.items.artemis")
include("scripts.gauntlet.items.athena")
TheGauntlet.Items.Demeter = {}
include("scripts.gauntlet.items.demeter.item")
include("scripts.gauntlet.items.demeter.visuals.colorize_shader")
include("scripts.gauntlet.items.demeter.visuals.heatwave_shader")
include("scripts.gauntlet.items.demeter.visuals.particle_engine")
TheGauntlet.Items.Dionysus = {}
include("scripts.gauntlet.items.dionysus.item")
include("scripts.gauntlet.items.dionysus.shader")
TheGauntlet.Items.Hades = {}
include("scripts.gauntlet.items.hades.item")
include("scripts.gauntlet.items.hades.status_effect")
include("scripts.gauntlet.items.hephaestus")
include("scripts.gauntlet.items.hera")
include("scripts.gauntlet.items.poseidon")
TheGauntlet.Items.Zeus = {}
include("scripts.gauntlet.items.zeus.item")
include("scripts.gauntlet.items.zeus.lightning_bolt")

include("scripts.gauntlet.items.locusts.demeter")
include("scripts.gauntlet.items.locusts.dionysus")
include("scripts.gauntlet.items.locusts.hades")
include("scripts.gauntlet.items.locusts.poseidon")
include("scripts.gauntlet.items.locusts.zeus")

include("scripts.gauntlet.compat.accurate_blurbs")
include("scripts.gauntlet.compat.minimapi")

TheGauntlet.SaveManager.Init(TheGauntlet)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    print("["..TheGauntlet.Name.."] Not affiliated with Team Rapture")
end)