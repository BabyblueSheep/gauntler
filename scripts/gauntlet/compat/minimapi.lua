local game = Game()

local gauntletMinimapSprite = Sprite("gfx/gauntlet/ui/gauntlet_minimap_icon.anm2", true)
gauntletMinimapSprite:SetFrame("Idle", 0)

local demeterWinterSprite = Sprite("gfx/gauntlet/ui/demeter_season.anm2", true)
demeterWinterSprite:SetFrame("Idle", 0)
local demeterSpringSprite = Sprite("gfx/gauntlet/ui/demeter_season.anm2", true)
demeterSpringSprite:SetFrame("Idle", 1)
local demeterSummerSprite = Sprite("gfx/gauntlet/ui/demeter_season.anm2", true)
demeterSummerSprite:SetFrame("Idle", 2)
local demeterAutumnSprite = Sprite("gfx/gauntlet/ui/demeter_season.anm2", true)
demeterAutumnSprite:SetFrame("Idle", 3)

TheGauntlet.GauntletRoom.MINIMAPI_MAP_ICON = "TheGauntlet GauntletRoom"

TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_WINTER = "TheGauntlet Demeter Winter"
TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_SPRING = "TheGauntlet Demeter Spring"
TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_SUMMER = "TheGauntlet Demeter Summer"
TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_AUTUMN = "TheGauntlet Demeter Autumn"

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    if MinimapAPI == nil then return end

    MinimapAPI:AddIcon(TheGauntlet.GauntletRoom.MINIMAPI_MAP_ICON, gauntletMinimapSprite)


    MinimapAPI:AddMapFlag(TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_WINTER, function ()
        return TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.WINTER
    end, demeterWinterSprite, "Idle", 0)
    MinimapAPI:AddMapFlag(TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_SPRING, function ()
        return TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.SPRING
    end, demeterSpringSprite, "Idle", 1)
    MinimapAPI:AddMapFlag(TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_SUMMER, function ()
        return TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.SUMMER
    end, demeterSummerSprite, "Idle", 2)
    MinimapAPI:AddMapFlag(TheGauntlet.Items.Demeter.MINIMAPI_MAP_ICON_AUTUMN, function ()
        return TheGauntlet.Items.Demeter.GetSeason() == TheGauntlet.Items.Demeter.Season.AUTUMN
    end, demeterAutumnSprite, "Idle", 3)
end)

---@param dimension Dimension
local function UpdateMinimapIcon(dimension)
    local level = MinimapAPI:GetLevel(dimension)
    if level == nil then return end

    for _, room in ipairs(MinimapAPI:GetLevel(dimension)) do
        if room.Descriptor ~= nil and TheGauntlet.GauntletRoom.IsRoomGauntletRoom(room.Descriptor) then
            room.PermanentIcons = { TheGauntlet.GauntletRoom.MINIMAPI_MAP_ICON }
        end
    end
end

---@param roomIndex integer
---@param roomConfigRoom RoomConfigRoom
---@param dimension Dimension
TheGauntlet:AddCallback(TheGauntlet.Utility.Callbacks.POST_PLACE_GAUNTLET_ROOM, function (_, roomIndex, roomConfigRoom, dimension)
    if MinimapAPI == nil then return end

    local roomDescriptor = game:GetLevel():GetRoomByIdx(roomIndex, dimension)

    MinimapAPI:AddRoom({
        ID = nil,
        Position = MinimapAPI:GridIndexToVector(roomIndex),
        Shape = RoomShape.ROOMSHAPE_1x1,

        PermanentIcons = { TheGauntlet.GauntletRoom.MINIMAPI_MAP_ICON },
        Dimension = dimension,
        Descriptor = roomDescriptor,
        DisplayFlags = roomDescriptor.DisplayFlags,
        Clear = roomDescriptor.Clear,
    })
end)

TheGauntlet:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, function (_)
    if MinimapAPI == nil then return end

    UpdateMinimapIcon(Dimension.NORMAL)
    UpdateMinimapIcon(Dimension.MIRROR)
end)

---@param isContinued boolean
TheGauntlet:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, function (_, isContinued)
    if MinimapAPI == nil then return end

    UpdateMinimapIcon(Dimension.NORMAL)
    UpdateMinimapIcon(Dimension.MIRROR)
end)

TheGauntlet:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, CallbackPriority.LATE, function (_)
    if MinimapAPI == nil then return end

    UpdateMinimapIcon(Dimension.NORMAL)
    UpdateMinimapIcon(Dimension.MIRROR)
end)