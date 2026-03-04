local game = Game()

TheGauntlet.Items.Apollo = {}
TheGauntlet.Items.Apollo.CollectibleType = Isaac.GetItemIdByName("Apollo")
TheGauntlet.Items.Apollo.CollectibleTypeOnPath = Isaac.GetNullItemIdByName("Apollo On Path Stats")
TheGauntlet.Items.Apollo.CollectibleTypeOffPath = Isaac.GetNullItemIdByName("Apollo Off Path Stats")

TheGauntlet.SaveManager.Utility.AddDefaultFloorData(TheGauntlet.SaveManager.DefaultSaveKeys.GLOBAL, {
    ApolloShortestPathToBoss = {}
})

local shortestPathToBoss = {}
local currentRoomStack = {}
local roomsCurrentlyInStack = {}

---@param level Level
---@param currentRoomIndex integer
local function RecursiveSearchPath(level, currentRoomIndex, targetRoomIndex)
    local currentRoomDescriptor = level:GetRoomByIdx(currentRoomIndex)

    if currentRoomDescriptor.Flags & RoomDescriptor.FLAG_RED_ROOM ~= 0 then
        return
    end

    if currentRoomDescriptor.SafeGridIndex == targetRoomIndex then
        if #shortestPathToBoss == 0 or #shortestPathToBoss > (#currentRoomStack + 1) then
            table.insert(currentRoomStack, currentRoomIndex)
            shortestPathToBoss = TheGauntlet.Utility.CopyTable(currentRoomStack)
            table.remove(currentRoomStack, #currentRoomStack)
        end
        
        return
    end

    table.insert(currentRoomStack, currentRoomIndex)
    roomsCurrentlyInStack[currentRoomIndex] = true

    for _, neighborDescriptor in pairs(currentRoomDescriptor:GetNeighboringRooms()) do
        if not roomsCurrentlyInStack[neighborDescriptor.SafeGridIndex] then
            RecursiveSearchPath(level, neighborDescriptor.SafeGridIndex, targetRoomIndex)
        end
    end

    table.remove(currentRoomStack, #currentRoomStack)
    roomsCurrentlyInStack[currentRoomIndex] = nil
end

function TheGauntlet.Items.Apollo.RefreshShortestPathToBoss()
    local level = game:GetLevel()
    
    local floorSave = TheGauntlet.SaveManager.GetFloorSave()

    shortestPathToBoss = {}
    currentRoomStack = {}
    roomsCurrentlyInStack = {}

    local currentStage = level:GetStage()
    local allRooms = level:GetRooms()

    --Reaching Home is "part of fate", and it's a non-standard layout anyways (and nearly all rooms are mandatory to visit anyways so meh)
    if currentStage == LevelStage.STAGE8 then
        for i = 0, allRooms.Size-1 do
            local room = allRooms:Get(i)

            if room.Flags & RoomDescriptor.FLAG_RED_ROOM == 0 then
                table.insert(shortestPathToBoss, room.SafeGridIndex)
            end
        end
    else
        local bossRoomIndex = -1

        for i = 0, allRooms.Size-1 do
            local room = allRooms:Get(i)
            
            if room.Data.Type ~= RoomType.ROOM_BOSS then goto continue end

            --"Fate" on Void leads to Delirium
            if level:GetStage() == LevelStage.STAGE7 then --Void
                if room.DeliriumDistance == 1 then
                    bossRoomIndex = room.SafeGridIndex
                end
            --"Fate" on all other floors leads to the boss that leads you down
            else
                level:ChangeRoom(room.SafeGridIndex)

                local currentRoom = game:GetRoom()

                if currentRoom:IsCurrentRoomLastBoss() then
                    bossRoomIndex = room.SafeGridIndex
                end

                Isaac.ExecuteCommand("rewind")
            end

            if bossRoomIndex ~= -1 then
                break
            end

            ::continue::
        end

        if bossRoomIndex == -1 then
            RecursiveSearchPath(level, level:GetStartingRoomIndex(), bossRoomIndex)
        end
    end

    floorSave.ApolloShortestPathToBoss = TheGauntlet.Utility.CopyTable(shortestPathToBoss)
end

function TheGauntlet.Items.Apollo.TryRefreshShortestPathToBoss()
    local floorSave = TheGauntlet.SaveManager.GetFloorSave()

    if #floorSave.ApolloShortestPathToBoss == 0 then
        TheGauntlet.Items.Apollo.RefreshShortestPathToBoss()
    end
end

function TheGauntlet.Items.Apollo.IsOnShortestPathToBoss()
    local level = Game():GetLevel()
    local currentRoomIndex = level:GetCurrentRoomIndex()

    local floorSave = TheGauntlet.SaveManager.GetFloorSave()

    local isFollowingProphecy = false
    for _, roomIndex in ipairs(floorSave.ApolloShortestPathToBoss) do
        if currentRoomIndex == roomIndex then
            isFollowingProphecy = true
            break
        end
    end

    return isFollowingProphecy
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    TheGauntlet.Items.Apollo.TryRefreshShortestPathToBoss()

    --Isaac.CreateTimer(function ()
    local isFollowingProphecy = TheGauntlet.Items.Apollo.IsOnShortestPathToBoss()

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player:HasCollectible(TheGauntlet.Items.Apollo.CollectibleType) then goto continue end
        
        player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath, -1)
        player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath, -1)

        if isFollowingProphecy then
            player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath)
        else
            player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath)
        end

        ::continue::
    end
    --end, 1, 1, false)
end)

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath, -1)
    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath, -1)

    if TheGauntlet.Items.Apollo.IsOnShortestPathToBoss() then
        player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath)
    else
        player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath)
    end
end, TheGauntlet.Items.Apollo.CollectibleType)

---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param removeFromPlayerForm boolean
---@param wisp boolean
TheGauntlet:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function (_, player, collectibleType, removeFromPlayerForm, wisp)
    if player:HasCollectible(collectibleType) then return end

    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath, -1)
    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath, -1)
end, TheGauntlet.Items.Apollo.CollectibleType)