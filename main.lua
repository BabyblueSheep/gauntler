TheGauntlet = RegisterMod("The Gauntlet", 1)

TheGauntlet.SaveManager = include("scripts.library.save_manager")
include("scripts.library.status_effect_library")

TheGauntlet.Utility = {}
include("scripts.utility.callbacks")
include("scripts.utility.challenge_rooms")
include("scripts.utility.entity_spawn")
include("scripts.utility.entity")
include("scripts.utility.logging")
include("scripts.utility.math")
include("scripts.utility.misc")
include("scripts.utility.random")

TheGauntlet.GauntletRoom = {}
include("scripts.gauntlet_room.common")
include("scripts.gauntlet_room.backdrop")
include("scripts.gauntlet_room.chance")
include("scripts.gauntlet_room.doors")
include("scripts.gauntlet_room.generation")
include("scripts.gauntlet_room.render_chance")
include("scripts.gauntlet_room.waves")

TheGauntlet.Items = {}
include("scripts.items.apollo")
include("scripts.items.aphrodite")
include("scripts.items.ares")
include("scripts.items.artemis")
include("scripts.items.athena")
TheGauntlet.Items.Demeter = {}
include("scripts.items.demeter.item")
include("scripts.items.demeter.visuals.colorize_shader")
include("scripts.items.demeter.visuals.particle_engine")
include("scripts.items.dionysus")
include("scripts.items.hades")
include("scripts.items.hephaestus")
include("scripts.items.hera")
include("scripts.items.poseidon")
TheGauntlet.Items.Zeus = {}
include("scripts.items.zeus.item")
include("scripts.items.zeus.lightning_bolt")

include("scripts.compat.accurate_blurbs")

TheGauntlet.SaveManager.Init(TheGauntlet)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    print("["..TheGauntlet.Name.."] Not affiliated with Team Rapture")
end)