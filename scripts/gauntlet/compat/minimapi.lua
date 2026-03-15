local game = Game()

local minimapSprite, t = Sprite("gfx/gauntlet/ui/gauntlet_minimap_icon.anm2", true)
minimapSprite:SetFrame("Idle", 0)

TheGauntlet.GauntletRoom.MINIMAPI_MAP_ICON = "TheGauntlet GauntletRoom"

TheGauntlet:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    if MinimapAPI == nil then return end

    MinimapAPI:AddIcon(TheGauntlet.GauntletRoom.MINIMAPI_MAP_ICON, minimapSprite)
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