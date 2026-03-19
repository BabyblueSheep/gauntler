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
        title = 'the gauntlet',
        tooltip = deadSeaScrollsIntegration.menuOpenToolTip,

        buttons = {
            { str = "mod settings", dest = "modSettings"},
            deadSeaScrollsIntegration.changelogsButton,
            {
                str = "menu settings",
                dest = "menuSettings",
                displayif = function ()
                    return not DeadSeaScrollsMenu.CanOpenGlobalMenu()
                end
            },
            { str = 'close', action = 'resume' },
        },
    },

    menuSettings = {
        deadSeaScrollsIntegration.hudOffsetButton,
        deadSeaScrollsIntegration.gamepadToggleButton,
        deadSeaScrollsIntegration.menuKeybindButton,
        deadSeaScrollsIntegration.menuHintButton,
        deadSeaScrollsIntegration.menuBuzzerButton,
        deadSeaScrollsIntegration.paletteButton
    },

    modSettings = {
        {
            str = "demeter visuals", fsize = 2,
            choices = { "enabled", "only tint", "only particles", "disabled" },
            setting = 1,
            variable = "TheGauntlet_DemeterVisuals",
            tooltip = {strset = {"configures", "visuals of", "demeter"}},

            load = function ()
                local value = 4

                if TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterTint == false then
                    value = value & 2
                end
                if TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterParticles == false then
                    value = value & 1
                end

                print(value)
                return value + 1
            end,
            store = function (value)
                value = value - 1

                TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterTint = value & 1 == 1
                TheGauntlet.SaveManager.GetSettingsSave().EnableDemeterParticles = value & 2 == 2
            end
        },
    }
}

local directoryKey = {
    Item = menu.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("The Gauntlet Menu", {
    Run = deadSeaScrollsIntegration.runMenu,
    Open = deadSeaScrollsIntegration.openMenu,
    Close = deadSeaScrollsIntegration.closeMenu,
    UseSubMenu = false,
    Directory = menu,
    DirectoryKey = directoryKey
})