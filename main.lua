TheGauntlet = RegisterMod("The Gauntlet", 1)

TheGauntlet.SaveManager = include("scripts.library.save_manager")
TheGauntlet.SaveManager.Init(TheGauntlet)

TheGauntlet.Gauntlet = {}
include("scripts.gauntlet.chance")

TheGauntlet.Items = {}
include("scripts.items.artemis")
include("scripts.items.dionysus")
include("scripts.items.hephaestus")