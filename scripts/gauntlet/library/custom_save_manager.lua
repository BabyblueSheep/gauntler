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
}

local saveKeysPersistence = { saveKeys.TEMPORARY, saveKeys.PERSISTENT }
local saveKeysLevelAll = { saveKeys.GLOBAL, saveKeys.RUN, saveKeys.FLOOR, saveKeys.ROOM }
local saveKeysLevelRun = { saveKeys.RUN, saveKeys.FLOOR, saveKeys.ROOM }
local saveKeysEntity = { saveKeys.INDEPENDENT, saveKeys.PLAYER }

local saveData = {}
local saveDataPreviousRooms = {}
for _, keyPersistence in ipairs(saveKeysPersistence) do
    for _, keyLevel in ipairs(saveKeysLevelAll) do
        for _, keyEntity in ipairs(saveKeysEntity) do
            saveData[keyPersistence][keyLevel][keyEntity] = {}
        end
    end
end
for _, keyPersistence in ipairs(saveKeysPersistence) do
    for _, keyLevel in ipairs(saveKeysLevelRun) do
        for _, keyEntity in ipairs(saveKeysEntity) do
            saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity] = { {}, {}, {} }
        end
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyLevel in ipairs(saveKeysLevelRun) do
            for _, keyEntity in ipairs(saveKeysEntity) do
                saveData[keyPersistence][keyLevel][keyEntity] = {}
                saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity] = { {}, {}, {} }
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    for _, keyPersistence in ipairs(saveKeysPersistence) do
        for _, keyLevel in ipairs(saveKeysLevelRun) do
            for _, keyEntity in ipairs(saveKeysEntity) do
                saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity][3] = saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity][2]
                saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity][2] = saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity][1]
                saveDataPreviousRooms[keyPersistence][keyLevel][keyEntity][1] = saveData[keyPersistence][keyLevel][keyEntity]  
            end
        end
    end
end)

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

---@enum LevelCategory
saveManager.LevelCategory = {
    GLOBAL = 0,
    RUN = 1,
    FLOOR = 2,
    ROOM = 3,
}

local levelCategoryToKey = {
    [0] = saveKeys.GLOBAL,
    [1] = saveKeys.RUN,
    [2] = saveKeys.FLOOR,
    [3] = saveKeys.ROOM
}

---@param player EntityPlayer
local function GetPlayerIndex(player)
    return player:GetCollectibleRNG(1):GetSeed()
end

---@param persistenceCategory PersistenceCategory
---@param levelCategory LevelCategory
---@param entity Entity?
---@return table
function saveManager.GetData(persistenceCategory, levelCategory, entity)
    local persistenceKey = persistenceCategoryToKey[persistenceCategory]
    local levelKey = levelCategoryToKey[levelCategory]

    if levelKey == saveKeys.GLOBAL then
        return saveData[persistenceKey][levelKey]
    end

    if entity == nil then
        return saveData[persistenceKey][levelKey][saveKeys.INDEPENDENT]
    end

    local player = entity:ToPlayer()
    if player ~= nil then
        return saveData[persistenceKey][levelKey][saveKeys.PLAYER][GetPlayerIndex(player)]
    end

    return {}
end

return saveManager



end