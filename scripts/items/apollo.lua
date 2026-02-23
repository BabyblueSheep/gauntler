TheGauntlet.Items.Apollo = {}
TheGauntlet.Items.Apollo.CollectibleType = Isaac.GetItemIdByName("Apollo")
TheGauntlet.Items.Apollo.CollectibleTypeOnPath = Isaac.GetNullItemIdByName("Apollo On Path Stats")
TheGauntlet.Items.Apollo.CollectibleTypeOffPath = Isaac.GetNullItemIdByName("Apollo Off Path Stats")

local shortestPathToBoss = {}
local currentRoomStack = {}
local roomsCurrentlyInStack = {}

---@param level Level
---@param currentRoomIndex integer
local function RecursiveSearchPathToBoss(level, currentRoomIndex)
    local currentRoomDescriptor = level:GetRoomByIdx(currentRoomIndex)

    local neighbourCount = 0
    for _, neighborDescriptor in pairs(currentRoomDescriptor:GetNeighboringRooms()) do
        if not roomsCurrentlyInStack[neighborDescriptor.SafeGridIndex] then
            neighbourCount = neighbourCount + 1
        end
    end
    local isDeadEnd = neighbourCount == 0

    if isDeadEnd then
        if currentRoomDescriptor.Data.Type == RoomType.ROOM_BOSS then
            if #shortestPathToBoss == 0 or #shortestPathToBoss > (#currentRoomStack + 1) then
                table.insert(currentRoomStack, currentRoomIndex)
                shortestPathToBoss = TheGauntlet.Utility.CopyTable(currentRoomStack)
                table.remove(currentRoomStack, #currentRoomStack)
            end
        end
        
        return
    end

    table.insert(currentRoomStack, currentRoomIndex)
    roomsCurrentlyInStack[currentRoomIndex] = true

    for _, neighborDescriptor in pairs(currentRoomDescriptor:GetNeighboringRooms()) do
        if not roomsCurrentlyInStack[neighborDescriptor.SafeGridIndex] then
            RecursiveSearchPathToBoss(level, neighborDescriptor.SafeGridIndex)
        end
    end

    table.remove(currentRoomStack, #currentRoomStack)
    roomsCurrentlyInStack[currentRoomIndex] = nil
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    Isaac.CreateTimer(function ()
        local level = Game():GetLevel()
        local currentRoomIndex = level:GetCurrentRoomIndex()

        local floorSave = TheGauntlet.SaveManager.GetFloorSave()

        if floorSave.ApolloShortestPathToBoss == nil then
            shortestPathToBoss = {}
            currentRoomStack = {}
            roomsCurrentlyInStack = {}

            RecursiveSearchPathToBoss(level, level:GetStartingRoomIndex())

            floorSave.ApolloShortestPathToBoss = TheGauntlet.Utility.CopyTable(shortestPathToBoss)
        end

        local isFollowingProphecy = false
        for _, roomIndex in ipairs(floorSave.ApolloShortestPathToBoss) do
            if currentRoomIndex == roomIndex then
                isFollowingProphecy = true
                break
            end
        end

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
    end, 1, 1, false)
end)

---@param collectibleType CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot integer
---@param varData integer
---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, collectibleType, charge, firstTime, slot, varData, player)
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

    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath, -1)
    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath, -1)

    if isFollowingProphecy then
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
    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath, -1)
    player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath, -1)
end, TheGauntlet.Items.Apollo.CollectibleType)