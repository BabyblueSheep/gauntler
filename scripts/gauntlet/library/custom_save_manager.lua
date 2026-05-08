local json = require("json")

---@return CustomSaveManager
return function (mod)



---@class CustomSaveManager
local saveManager = {}

local saveKeys = {
    TEMPORARY = "temporary",
    TEMPORARY_NO_HOURGLASS = "temporary_no_hourglass",
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

local saveKeysPersistenceAll = { saveKeys.TEMPORARY, saveKeys.TEMPORARY_NO_HOURGLASS, saveKeys.PERSISTENT }
local saveKeysPersistenceHourglassAffected = { saveKeys.TEMPORARY, saveKeys.PERSISTENT }
local saveKeysLifetimeAll = { saveKeys.GLOBAL, saveKeys.RUN, saveKeys.FLOOR, saveKeys.ROOM }
local saveKeysLifetimeRun = { saveKeys.RUN, saveKeys.FLOOR, saveKeys.ROOM }
local saveKeysEntityAll = { saveKeys.INDEPENDENT, saveKeys.PLAYER, saveKeys.FAMILIAR, saveKeys.PER_ROOM_ENTITY }
local saveKeysEntityPersistent = { saveKeys.INDEPENDENT, saveKeys.PLAYER, saveKeys.FAMILIAR }

saveManager._saveData = {}
saveManager._saveDataPreviousRooms = {}

for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
    saveManager._saveData[keyPersistence] = {}
    for _, keyLifetime in ipairs(saveKeysLifetimeAll) do
        saveManager._saveData[keyPersistence][keyLifetime] = {}
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveManager._saveData[keyPersistence][keyLifetime][keyEntity] = {}
        end
    end
end
for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
    saveManager._saveDataPreviousRooms[keyPersistence] = {}
    for _, keyLifetime in ipairs(saveKeysLifetimeAll) do
        saveManager._saveDataPreviousRooms[keyPersistence][keyLifetime] = {}
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveManager._saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity] = { {}, {} }
        end
    end
end


---@param inputTable table
---@return table
function CopyTableDeep(inputTable)
    if type(inputTable) ~= "table" then
		return inputTable
	end

	local tableCopy = {}
	for k, v in pairs(inputTable) do
		tableCopy[k] = CopyTableDeep(v)
	end

	return tableCopy
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
    for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveManager._saveData[keyPersistence][saveKeys.RUN][keyEntity] = {}
        end
    end
end)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.IMPORTANT, function (_, shouldSave)
    for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
        for _, keyLifetime in ipairs(saveKeysLifetimeAll) do
            for _, keyEntity in ipairs(saveKeysEntityAll) do
                saveManager._saveData[keyPersistence][keyLifetime][keyEntity] = {}
            end
        end
    end
    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
        for _, keyLifetime in ipairs(saveKeysLifetimeAll) do
            for _, keyEntity in ipairs(saveKeysEntityAll) do
                saveManager._saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity] = { {}, {} }
            end
        end
    end

    if not shouldSave then return end

    local tableToSave = saveManager._saveData[saveKeys.PERSISTENT]
    local stringToSave = json.encode(tableToSave)

    print(saveManager._saveData[saveKeys.PERSISTENT][saveKeys.RUN][saveKeys.FAMILIAR])
    for k, v in pairs(saveManager._saveData[saveKeys.PERSISTENT][saveKeys.RUN][saveKeys.FAMILIAR]) do
        print(k, v, tableToSave[saveKeys.RUN][saveKeys.FAMILIAR][k].Hera)
    end

    print(stringToSave)
    mod:SaveData(stringToSave)
end)

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, function (_)
    for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveManager._saveData[keyPersistence][saveKeys.FLOOR][keyEntity] = {}
        end
    end
end)

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, function (_)
    for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveManager._saveData[keyPersistence][saveKeys.ROOM][keyEntity] = {}
        end
    end
end)

---@param slot integer
mod:AddPriorityCallback(ModCallbacks.MC_POST_GLOWING_HOURGLASS_LOAD, CallbackPriority.IMPORTANT, function (_, slot)
    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
        for _, keyLifetime in ipairs(saveKeysLifetimeRun) do
            for _, keyEntity in ipairs(saveKeysEntityPersistent) do
                saveManager._saveData[keyPersistence][keyLifetime][keyEntity] = CopyTableDeep(saveManager._saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][slot + 1])
            end
        end
    end
end)

---@param slot integer
mod:AddPriorityCallback(ModCallbacks.MC_POST_GLOWING_HOURGLASS_SAVE, CallbackPriority.IMPORTANT, function (_, slot)
    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
        for _, keyLifetime in ipairs(saveKeysLifetimeRun) do
            for _, keyEntity in ipairs(saveKeysEntityPersistent) do
                saveManager._saveDataPreviousRooms[keyPersistence][keyLifetime][keyEntity][slot + 1] = CopyTableDeep(saveManager._saveData[keyPersistence][keyLifetime][keyEntity])
            end
        end
    end
end)

---@param entity Entity
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.IMPORTANT, function (_, entity)
    local entityKey, index = GetEntityKeyAndUniqueIndex(entity)
    for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
        for _, keyLifetime in ipairs(saveKeysLifetimeRun) do
            if saveManager._saveData[keyPersistence][keyLifetime][entityKey][index] ~= nil then
                saveManager._saveData[keyPersistence][keyLifetime][entityKey][index] = nil
            end
        end
    end
end)



---@enum PersistenceCategory
saveManager.PersistenceCategory = {
    TEMPORARY = 0,
    TEMPORARY_NO_HOURGLASS = 1,
    PERSISTENT = 2,
}

local persistenceCategoryToKey = {
    [0] = saveKeys.TEMPORARY,
    [1] = saveKeys.TEMPORARY_NO_HOURGLASS,
    [2] = saveKeys.PERSISTENT
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
        return saveManager._saveData[persistenceKey][lifetimeKey]
    end

    if entity == nil then
        return saveManager._saveData[persistenceKey][lifetimeKey][saveKeys.INDEPENDENT]
    end

    local key, index = GetEntityKeyAndUniqueIndex(entity)
    if key == "familiar" then
        print(persistenceKey, lifetimeKey, key, index)
    end

    if saveManager._saveData[persistenceKey][lifetimeKey][key][index] == nil then
        saveManager._saveData[persistenceKey][lifetimeKey][key][index] = {}
    end
    return saveManager._saveData[persistenceKey][lifetimeKey][key][index]
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

function saveManager.GetTemporaryNoHourglassGlobalData()
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY_NO_HOURGLASS, saveManager.LifetimeCategory.GLOBAL)
end

---@param entity Entity?
---@return table
function saveManager.GetTemporaryNoHourglassRunData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY_NO_HOURGLASS, saveManager.LifetimeCategory.RUN, entity)
end

---@param entity Entity?
---@return table
function saveManager.GetTemporaryNoHourglassFloorData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY_NO_HOURGLASS, saveManager.LifetimeCategory.FLOOR, entity)
end

---@param entity Entity?
---@return table
function saveManager.GetTemporaryNoHourglassRoomData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY_NO_HOURGLASS, saveManager.LifetimeCategory.ROOM, entity)
end

function saveManager.GetPersistentGlobalData()
    return saveManager.GetData(saveManager.PersistenceCategory.PERSISTENT, saveManager.LifetimeCategory.GLOBAL)
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


---@param newSaveManager CustomSaveManager
---@param oldSaveManager CustomSaveManager
function saveManager.Update(newSaveManager, oldSaveManager)
    newSaveManager._saveData = CopyTableDeep(oldSaveManager._saveData)
    newSaveManager._saveDataPreviousRooms = CopyTableDeep(oldSaveManager._saveDataPreviousRooms)
end

return saveManager



end