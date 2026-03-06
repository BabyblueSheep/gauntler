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

    local returnValue = Isaac.RunCallback(TheGauntlet.Utility.Callbacks.PRE_APOLLO_REFRESH_PATH_TO_BOSS)

    local function CheckReturnValue()
        if returnValue == nil then
            return nil
        end

        if type(returnValue) == "number" then

            if not TheGauntlet.Utility.IsInteger(returnValue) then
                TheGauntlet.Utility.LogError("Number returned in "..TheGauntlet.Utility.Callbacks.PRE_APOLLO_REFRESH_PATH_TO_BOSS.." that is not an integer. Using default logic.")
                return false
            end
            return true

        end
        if type(returnValue) == "table" then

            local keyValuePairAmount = 0

            for key, value in pairs(returnValue) do
                keyValuePairAmount = keyValuePairAmount + 1

                if not TheGauntlet.Utility.IsInteger(key) then
                    TheGauntlet.Utility.LogError("Table returned in "..TheGauntlet.Utility.Callbacks.PRE_APOLLO_REFRESH_PATH_TO_BOSS.." is not a list. Using default logic.")
                    return false
                end
                if not TheGauntlet.Utility.IsInteger(value) then
                    TheGauntlet.Utility.LogError("Table returned in "..TheGauntlet.Utility.Callbacks.PRE_APOLLO_REFRESH_PATH_TO_BOSS.." has a non-integer element. Using default logic.")
                    return false
                end
            end

            if keyValuePairAmount == 0 then
                TheGauntlet.Utility.LogWarning("Table returned in "..TheGauntlet.Utility.Callbacks.PRE_APOLLO_REFRESH_PATH_TO_BOSS.." is empty. Please make sure it has at least one element.")
            end
            return true

        end

        TheGauntlet.Utility.LogError("Value returned in "..TheGauntlet.Utility.Callbacks.PRE_APOLLO_REFRESH_PATH_TO_BOSS.." that isn't a number or a table. Using default logic.")
        return false
    end
    local isReturnValid = CheckReturnValue()

    if isReturnValid == true then
        if TheGauntlet.Utility.IsInteger(returnValue) then
            table.insert(shortestPathToBoss, returnValue)
        end
        floorSave.ApolloShortestPathToBoss = TheGauntlet.Utility.CopyTable(shortestPathToBoss)
        return
    end

    --Greed mode has a set layout, so "fate" can probably just be the mandatory rooms.
    if game:IsGreedMode() then
        if currentStage == LevelStage.STAGE7_GREED then
            table.insert(shortestPathToBoss, 84)  --Starting room
            table.insert(shortestPathToBoss, 71)  --Greed boss room
            table.insert(shortestPathToBoss, 45)  --Ultra Greed boss room
        else
            table.insert(shortestPathToBoss, 84)  --Starting/main room
            table.insert(shortestPathToBoss, 71)  --Shop
            table.insert(shortestPathToBoss, 110) --Exit room
        end
    --Reaching Home is "part of fate", and it's a non-standard layout anyways (and nearly all rooms are mandatory to visit anyways so meh)
    elseif currentStage == LevelStage.STAGE8 then
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
            if level:GetStage() == LevelStage.STAGE7 then
                if room.DeliriumDistance == 1 then
                    bossRoomIndex = room.SafeGridIndex
                end
            --"Fate" on all other floors leads to the boss that leads you down
            else

                if room.SafeGridIndex == allRooms:Get(level:GetLastBossRoomListIndex()).SafeGridIndex then
                    bossRoomIndex = room.SafeGridIndex
                end
            end

            if bossRoomIndex ~= -1 then
                break
            end

            ::continue::
        end

        if bossRoomIndex ~= -1 then
            print("test")
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
    local currentRoomIndex = level:GetCurrentRoomDesc().SafeGridIndex

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

local function GrantApolloDamage()
    TheGauntlet.Items.Apollo.TryRefreshShortestPathToBoss()
    
    local isFollowingProphecy = TheGauntlet.Items.Apollo.IsOnShortestPathToBoss()

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath, -1)
        player:GetEffects():RemoveNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath, -1)

        if not player:HasCollectible(TheGauntlet.Items.Apollo.CollectibleType) then goto continue end

        if isFollowingProphecy then
            player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOnPath)
        else
            player:GetEffects():AddNullEffect(TheGauntlet.Items.Apollo.CollectibleTypeOffPath)
        end

        ::continue::
    end
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function (_)
    GrantApolloDamage()
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    GrantApolloDamage()
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