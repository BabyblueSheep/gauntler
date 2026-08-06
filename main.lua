if not REPENTOGON then
    error("[The Gauntlet] The Gauntlet requires REPENTOGON to be installed in order to work!", 0)
    return
end

local backupDataHolder = nil
if TheGauntlet ~= nil then
    backupDataHolder = TheGauntlet.DataHolder
end

TheGauntlet = RegisterMod("The Gauntlet", 1)

TheGauntlet.SaveManager = include("scripts.gauntlet.library.save_manager")
include("scripts.gauntlet.library.status_effect_library")
include("scripts.gauntlet.library.tearflagslib.main")

---@type DataHolder
TheGauntlet.DataHolder = include("scripts.gauntlet.library.data_holder")(TheGauntlet)
if backupDataHolder ~= nil then
    TheGauntlet.DataHolder.Update(TheGauntlet.DataHolder, backupDataHolder)
end

include("scripts.gauntlet.library.dead_sea_scrolls.integration")
include("scripts.gauntlet.library.dead_sea_scrolls.changelogs")

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
TheGauntlet.GauntletRoom.Constants = {}
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
TheGauntlet.Items.Zeus.Constants = {}
include("scripts.gauntlet.items.zeus.item")
include("scripts.gauntlet.items.zeus.lightning_bolt")
include("scripts.gauntlet.items.zeus.cases.berserk")
include("scripts.gauntlet.items.zeus.cases.breath_of_life")
include("scripts.gauntlet.items.zeus.cases.eraser")
include("scripts.gauntlet.items.zeus.cases.genesis")
include("scripts.gauntlet.items.zeus.cases.isaacs_tears")
include("scripts.gauntlet.items.zeus.cases.mama_mega")
include("scripts.gauntlet.items.zeus.cases.notched_axe")
include("scripts.gauntlet.items.zeus.cases.pandoras_box")
include("scripts.gauntlet.items.zeus.cases.spin_to_win")

include("scripts.gauntlet.items.locusts.demeter")
include("scripts.gauntlet.items.locusts.dionysus")
include("scripts.gauntlet.items.locusts.hades")
include("scripts.gauntlet.items.locusts.poseidon")
include("scripts.gauntlet.items.locusts.zeus")

TheGauntlet.Compat = {}

include("scripts.gauntlet.compat.accurate_blurbs")

TheGauntlet.Compat.FiendFolio = {}
include("scripts.gauntlet.compat.fiend_folio.add_custom_rooms")
include("scripts.gauntlet.compat.fiend_folio.item_tags")
include("scripts.gauntlet.compat.fiend_folio.keep_gauntlet_backdrop")
include("scripts.gauntlet.compat.fiend_folio.spirit_urn_gauntlets")
include("scripts.gauntlet.compat.fiend_folio.gauntlet_disc.gauntlet_disc")
include("scripts.gauntlet.compat.fiend_folio.gauntlet_disc.item_icons")
include("scripts.gauntlet.compat.fiend_folio.synergies.avgm_zeus")
include("scripts.gauntlet.compat.fiend_folio.synergies.electrum_zeus")
include("scripts.gauntlet.compat.fiend_folio.synergies.errors_crazy_slots_zeus")
include("scripts.gauntlet.compat.fiend_folio.synergies.excelsior_zeus")
include("scripts.gauntlet.compat.fiend_folio.synergies.golden_frog_head_zeus")
include("scripts.gauntlet.compat.fiend_folio.synergies.nyx_poseidon")
include("scripts.gauntlet.compat.fiend_folio.synergies.tipsy_geode_dionysus")

include("scripts.gauntlet.compat.minimapi")

include("scripts.gauntlet.compat.stageapi")

TheGauntlet.Compat.EID = {}
include("scripts.gauntlet.compat.eid.main")
include("scripts.gauntlet.compat.eid.data")
include("scripts.gauntlet.compat.eid.descriptions")

TheGauntlet.SaveManager.Init(TheGauntlet)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    TheGauntlet.Utility.Print("Not affiliated with Team Rapture")
end)