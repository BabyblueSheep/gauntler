local json = require("json")

---@return CustomSaveManager
return function (mod)



local saveKeys = {
    TEMPORARY = "temporary",
    PERSISTENT = "persistent",

    GLOBAL = "global",
    RUN = "run",
    FLOOR = "floor",
    ROOM = "room",

    INDEPENDENT = "independent",
    PLAYER = "player",
    FAMILIAR = "familiar",
    PER_ROOM_ENTITY = "per_room_entity",
}

local saveKeysPersistence = { saveKeys.TEMPORARY, saveKeys.PERSISTENT }
local saveKeysLifetimeAll = { saveKeys.GLOBAL, saveKeys.RUN, saveKeys.FLOOR, saveKeys.ROOM }
local saveKeysLifetimeRun = { saveKeys.RUN, saveKeys.FLOOR, saveKeys.ROOM }
local saveKeysEntityAll = { saveKeys.INDEPENDENT, saveKeys.PLAYER, saveKeys.FAMILIAR, saveKeys.PER_ROOM_ENTITY }
local saveKeysEntityPersistent = { saveKeys.INDEPENDENT, saveKeys.PLAYER, saveKeys.FAMILIAR }

local saveData = {}
local saveDataPreviousRooms = {}
for _, keyPersistence in ipairs(saveKeysPersistence) do
    saveData[keyPersistence] = {}
    saveDataPreviousRooms[keyPersistence] = {}
    for _, keyLifetime in ipairs(saveKeysLifetimeAll) do
        saveData[keyPersistence][keyLifetime] = {}
        saveDataPreviousRooms[keyPersistence][keyLifetime] = {}
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveData[keyPersistence][keyLifetime][keyEntity] = {}
            saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity] = { {}, {}, {} }
        end
    end
end


---@param table table
---@param key string | integer
local function GetOrInitIfNil(table, key)
    if table[key] == nil then
        table[key] = {}
    end
    return table[key]
end

---@param player EntityPlayer
---@return integer
local function GetPlayerIndex(player)
    return player:GetCollectibleRNG(1):GetSeed()
end

---@param entity Entity
---@return string, integer
local function GetEntityKeyAndUniqueIndex(entity)
    local player = entity:ToPlayer()
    local familiar = entity:ToFamiliar()
    if player ~= nil then
        return saveKeys.PLAYER, GetPlayerIndex(player)
    elseif familiar ~= nil then
        return saveKeys.FAMILIAR, familiar.InitSeed
    else
        return saveKeys.PER_ROOM_ENTITY, GetPtrHash(entity)
    end
end

---@param player EntityPlayer
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, function (_, player)
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveData[keyPersistence][saveKeys.RUN][keyEntity] = {}
        end
    end
end)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.IMPORTANT, function (_)
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        saveData[keyPersistence] = {}
        for _, keyLifetime in ipairs(saveKeysLifetimeAll) do
            saveData[keyPersistence][keyLifetime] = {}
            for _, keyEntity in ipairs(saveKeysEntityAll) do
                saveData[keyPersistence][keyLifetime][keyEntity] = {}
                saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity] = { {}, {}, {} }
            end
        end
    end

    local tableToSave = saveData[saveKeys.PERSISTENT]
    local stringToSave = json.encode(tableToSave)
    mod:SaveData(stringToSave)
end)

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, function (_)
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyLifetime in ipairs(saveKeysLifetimeRun) do
            for _, keyEntity in ipairs(saveKeysEntityPersistent) do
                saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][3] = saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][2]
                saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][2] = saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][1]
                saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][1] = saveData[keyPersistence][keyLifetime][keyEntity]  
            end
        end
    end

    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveData[keyPersistence][saveKeys.ROOM][keyEntity] = {}
        end
    end
end)

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, function (_)
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveData[keyPersistence][saveKeys.FLOOR][keyEntity] = {}
        end
    end
end)

---@param entity Entity
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.IMPORTANT, function (_, entity)
    local entityKey, index = GetEntityKeyAndUniqueIndex(entity)
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyLifetime in ipairs(saveKeysLifetimeRun) do
            if saveData[keyPersistence][keyLifetime][entityKey][index] ~= nil then
                saveData[keyPersistence][keyLifetime][entityKey][index] = nil
            end
        end
    end
end)

---@class CustomSaveManager
local saveManager = {}

---@enum PersistenceCategory
saveManager.PersistenceCategory = {
    TEMPORARY = 0,
    PERSISTENT = 1,
}

local persistenceCategoryToKey = {
    [0] = saveKeys.TEMPORARY,
    [1] = saveKeys.PERSISTENT
}

---@enum LifetimeCategory
saveManager.LifetimeCategory = {
    GLOBAL = 0,
    RUN = 1,
    FLOOR = 2,
    ROOM = 3,
}

local lifetimeCategoryToKey = {
    [0] = saveKeys.GLOBAL,
    [1] = saveKeys.RUN,
    [2] = saveKeys.FLOOR,
    [3] = saveKeys.ROOM
}

---@param persistenceCategory PersistenceCategory
---@param lifetimeCategory LifetimeCategory
---@param entity Entity?
---@return table
function saveManager.GetData(persistenceCategory, lifetimeCategory, entity)
    local persistenceKey = persistenceCategoryToKey[persistenceCategory]
    local lifetimeKey = lifetimeCategoryToKey[lifetimeCategory]

    if lifetimeKey == saveKeys.GLOBAL then
        return GetOrInitIfNil(saveData[persistenceKey], lifetimeKey)
    end

    if entity == nil then
        return GetOrInitIfNil(saveData[persistenceKey][lifetimeKey], saveKeys.INDEPENDENT)
    end

    local key, index = GetEntityKeyAndUniqueIndex(entity)
    return GetOrInitIfNil(saveData[persistenceKey][lifetimeKey][key], index)
end

function saveManager.GetTemporaryGlobalData()
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY, saveManager.LifetimeCategory.GLOBAL)
end

---@param entity Entity?
---@return table
function saveManager.GetTemporaryRunData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY, saveManager.LifetimeCategory.RUN, entity)
end

---@param entity Entity?
---@return table
function saveManager.GetTemporaryFloorData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY, saveManager.LifetimeCategory.FLOOR, entity)
end

---@param entity Entity?
---@return table
function saveManager.GetTemporaryRoomData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY, saveManager.LifetimeCategory.ROOM, entity)
end

function saveManager.GetPersistentGlobalData()
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY, saveManager.LifetimeCategory.GLOBAL)
end

---@param entity Entity?
---@return table
function saveManager.GetPersistentRunData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.PERSISTENT, saveManager.LifetimeCategory.RUN, entity)
end

---@param entity Entity?
---@return table
function saveManager.GetPersistentFloorData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.PERSISTENT, saveManager.LifetimeCategory.FLOOR, entity)
end

---@param entity Entity?
---@return table
function saveManager.GetPersistentRoomData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.PERSISTENT, saveManager.LifetimeCategory.ROOM, entity)
end

return saveManager



end