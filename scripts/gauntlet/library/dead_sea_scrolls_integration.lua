local deadSeaScrollsCore = include("scripts.gauntlet.library.dead_sea_scrolls_core")

local modName = "Dead Sea Scrolls (The Gauntlet)"

local menuProvider = {}

function menuProvider.SaveSaveData()
    TheGauntlet.SaveManager.Save()
end

function menuProvider.GetPaletteSetting()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuPalette
end

function menuProvider.SavePaletteSetting(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuPalette = var
end

function menuProvider.GetHudOffsetSetting()
    return Options.HUDOffset * 10
end

function menuProvider.SaveHudOffsetSetting(var)

end

function menuProvider.GetGamepadToggleSetting()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().GamepadToggle
end

function menuProvider.SaveGamepadToggleSetting(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().GamepadToggle = var
end

function menuProvider.GetMenuKeybindSetting()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuKeybind
end

function menuProvider.SaveMenuKeybindSetting(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuKeybind = var
end

function menuProvider.GetMenuHintSetting()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuHint
end

function menuProvider.SaveMenuHintSetting(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuHint = var
end

function menuProvider.GetMenuBuzzerSetting()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuBuzzer
end

function menuProvider.SaveMenuBuzzerSetting(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenuBuzzer = var
end

function menuProvider.GetMenusNotified()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenusNotified
end

function menuProvider.SaveMenusNotified(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenusNotified = var
end

function menuProvider.GetMenusPoppedUp()
    return TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenusPoppedUp
end

function menuProvider.SaveMenusPoppedUp(var)
    TheGauntlet.SaveManager.GetDeadSeaScrollsSave().MenusPoppedUp = var
end

local deadSeaScrollsIntegration = deadSeaScrollsCore.init(modName, menuProvider)

local menu = {
    main = {
        title = "the gauntlet",
        tooltip = deadSeaScrollsIntegration.menuOpenToolTip,

        buttons = {
            deadSeaScrollsIntegration.changelogsButton,
            { str = "mod settings", dest = "modSettings" },
            {
                str = "menu settings",
                dest = "menuSettings",
                displayif = function ()
                    return not DeadSeaScrollsMenu.CanOpenGlobalMenu()
                end
            },
            { str = "credits", dest = "credits" },
            { str = "close", action = "resume" },
        },
    },

    menuSettings = {
        title = "menu settings",
        tooltip = deadSeaScrollsIntegration.menuOpenToolTip,
    
        buttons = {
            deadSeaScrollsIntegration.hudOffsetButton,
            deadSeaScrollsIntegration.gamepadToggleButton,
            deadSeaScrollsIntegration.menuKeybindButton,
            deadSeaScrollsIntegration.menuHintButton,
            deadSeaScrollsIntegration.menuBuzzerButton,
            deadSeaScrollsIntegration.paletteButton
        },
    },

    modSettings = {
        title = "mod settings",
        tooltip = deadSeaScrollsIntegration.menuOpenToolTip,

        buttons = {
            { str = "gameplay", fsize = 3, nosel = true },
            { str = "", fsize=1, nosel=true },

            {
                str = "remove dionysus", fsize = 2,
                choices = { "enabled", "disabled" },
                setting = 2,
                variable = "TheGauntlet_RemoveDionysus",
                tooltip = {strset = {"removes", "dionysus from", "the pool", "", "use if it", "strains", "your eyes"}},

                load = function ()
                    if TheGauntlet.SaveManager.GetSettingsSave().RemoveDionysus ~= true then
                        return 2
                    end
                    return 1
                end,
                store = function (value)
                    value = value

                    TheGauntlet.SaveManager.GetSettingsSave().RemoveDionysus = value == 1
                end
            },

            { str = "", fsize=3, nosel=true },
            { str = "visuals", fsize = 3, nosel = true },
            { str = "", fsize=1, nosel=true },

            {
                str = "demeter visuals", fsize = 2,
                choices = { "all enabled", "only tint", "only particles", "disabled" },
                setting = 1,
                variable = "TheGauntlet_DemeterVisuals",
                tooltip = {strset = {"configures", "visuals for", "demeter"}},

                load = function ()
                    local value = 4

                    if TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterTint ~= false then
                        value = value - 2
                    end
                    if TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterParticles ~= false then
                        value = value - 1
                    end

                    return value
                end,
                store = function (value)
                    TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterTint = value <= 2
                    TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterParticles = value % 2 == 1
                end
            },
            {
                str = "chance y-offset", fsize = 2,
                slider = true,
                increment = 1, max = 8,
                setting = 3,
                variable = "TheGauntlet_ChanceOffsetY",
                tooltip = {strset = { "adjust the", "position of", "the gauntlet", "room spawn", "chance" }},

                load = function ()
                    if TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetY == nil then
                        return 3
                    end
                    return TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetY + 3
                end,
                store = function (value)
                    TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetY = value - 3
                end
            },
            {
                str = "chance x-offset", fsize = 2,
                slider = true,
                increment = 1, max = 4,
                setting = 2,
                variable = "TheGauntlet_ChanceOffsetX",
                tooltip = {strset = { "adjust the", "position of", "the gauntlet", "room spawn", "chance" }},

                load = function ()
                    if TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetX == nil then
                        return 2
                    end
                    return TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetX + 2
                end,
                store = function (value)
                    TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetX = value - 2
                end
            },

            { str = "", fsize=3, nosel=true },
            { str = "debug", fsize = 3, nosel = true },
            { str = "", fsize=1, nosel=true },

            {
                str = "force gauntlet spawn", fsize = 2,
                choices = { "enabled", "disabled" },
                setting = 2,
                variable = "TheGauntlet_ForceGauntletSpawn",
                tooltip = {strset = {"forces gauntlet", "rooms to", "always spawn", "", "useful for", "showcasing or", "testing"}},

                load = function ()
                    if TheGauntlet.SaveManager.GetSettingsSave().ForceGauntletSpawn ~= true then
                        return 2
                    end
                    return 1
                end,
                store = function (value)
                    value = value

                    TheGauntlet.SaveManager.GetSettingsSave().ForceGauntletSpawn = value == 1
                end
            },
        },
    },

    credits = {
        title = "credits",
        tooltip = deadSeaScrollsIntegration.menuOpenToolTip,

        buttons = {
            { str = "doodledude", fsize = 2,
                tooltip = {strset = {"lead spriter", "", "concepts"}}},
            { str = "babybluesheep", fsize = 2,
                tooltip = {strset = {"lead coder"}}},
            { str = "poyo", fsize = 2,
                tooltip = {strset = {"backdrop", "spriter"}}},
            { str = "conboi", fsize = 2,
                tooltip = {strset = {"ideas"}}},
            { str = "vinny p", fsize = 2,
                tooltip = {strset = {"ideas"}}},
        }
    }
}

TheGauntlet.Settings = {
    EnableDemeterTint = function ()
        if not TheGauntlet.SaveManager.Utility.IsDataInitialized(true) then
            return true
        end
        if TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterTint == nil then
            return true
        end
        return TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterTint
    end,
    EnableDemeterParticles = function ()
        if not TheGauntlet.SaveManager.Utility.IsDataInitialized(true) then
            return true
        end
        if TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterParticles == nil then
            return true
        end
        return TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterParticles
    end,

    RemoveDionysus = function ()
        if not TheGauntlet.SaveManager.Utility.IsDataInitialized(true) then
            return false
        end
        if TheGauntlet.SaveManager.GetSettingsSave().RemoveDionysus == nil then
            return false
        end
        return TheGauntlet.SaveManager.GetSettingsSave().RemoveDionysus
    end,

    ChanceOffsetX = function ()
        if not TheGauntlet.SaveManager.Utility.IsDataInitialized(true) then
            return 0
        end
        if TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetX == nil then
            return 0
        end
        return TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetX
    end,
    ChanceOffsetY = function ()
        if not TheGauntlet.SaveManager.Utility.IsDataInitialized(true) then
            return 0
        end
        if TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetY == nil then
            return 0
        end
        return TheGauntlet.SaveManager.GetSettingsSave().ChanceOffsetY
    end,

    ForceGauntletSpawn = function ()
        if not TheGauntlet.SaveManager.Utility.IsDataInitialized(true) then
            return false
        end
        if TheGauntlet.SaveManager.GetSettingsSave().ForceGauntletSpawn == nil then
            return false
        end
        return TheGauntlet.SaveManager.GetSettingsSave().ForceGauntletSpawn
    end
}

local directoryKey = {
    Item = menu.main,
    Main = "main",
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("The Gauntlet", {
    Run = deadSeaScrollsIntegration.runMenu,
    Open = deadSeaScrollsIntegration.openMenu,
    Close = deadSeaScrollsIntegration.closeMenu,
    UseSubMenu = false,
    Directory = menu,
    DirectoryKey = directoryKey
})