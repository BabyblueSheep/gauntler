--Personal library I made to replace entity:GetData()
--Besides (probably superfluous) performance benefits, this library respects Glowing Hourglass rewinds

local json = require("json")

---@return DataHolder
return function (mod)



---@class DataHolder
local saveManager = {}

local saveKeys = {
    TEMPORARY = "temporary",
    TEMPORARY_NO_HOURGLASS = "temporary_no_hourglass",

    PLAYER = "player",
    FAMILIAR = "familiar",
    BOMB = "bomb",
    KNIFE = "knife",
    PER_ROOM_ENTITY = "per_room_entity",
}

local saveKeysPersistenceAll = { saveKeys.TEMPORARY, saveKeys.TEMPORARY_NO_HOURGLASS }
local saveKeysPersistenceHourglassAffected = { saveKeys.TEMPORARY }
local saveKeysPersistenceEntities = { saveKeys.TEMPORARY, saveKeys.TEMPORARY_NO_HOURGLASS }
local saveKeysPersistenceHourglassAffectedEntities = { saveKeys.TEMPORARY }

local saveKeysEntityAll = { saveKeys.PLAYER, saveKeys.FAMILIAR, saveKeys.BOMB, saveKeys.KNIFE, saveKeys.PER_ROOM_ENTITY }
local saveKeysEntityPersistent = { saveKeys.PLAYER, saveKeys.FAMILIAR, saveKeys.BOMB, saveKeys.KNIFE }

local blacklistedBombVariants = {
    [BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_ROCKET] = true,
	[BombVariant.BOMB_ROCKET_GIGA] = true
}


saveManager._saveDataIndependent = {}
saveManager._saveDataIndependentPreviousRooms = {}

saveManager._saveDataEntities = {}
saveManager._saveDataEntitiesPreviousRooms = {}


local function ClearTables()
    for _, keyPersistence in ipairs(saveKeysPersistenceAll) do
        saveManager._saveDataIndependent[keyPersistence] = {}
    end

    for _, keyPersistence in ipairs(saveKeysPersistenceEntities) do
        saveManager._saveDataEntities[keyPersistence] = {}
        for _, keyEntity in ipairs(saveKeysEntityAll) do
            saveManager._saveDataEntities[keyPersistence][keyEntity] = {}
        end
    end


    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
        saveManager._saveDataIndependentPreviousRooms[keyPersistence] = { {}, {} }
    end

    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffectedEntities) do
        saveManager._saveDataEntitiesPreviousRooms[keyPersistence] = {}
        for _, keyEntity in ipairs(saveKeysEntityPersistent) do
            saveManager._saveDataEntitiesPreviousRooms[keyPersistence][keyEntity] = {}
        end
    end
end
ClearTables()


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
    local bomb = entity:ToBomb()
    local knife = entity:ToKnife()

    if player ~= nil then
        return saveKeys.PLAYER, GetPlayerIndex(player)
    elseif familiar ~= nil then
        return saveKeys.FAMILIAR, familiar.InitSeed
    elseif bomb ~= nil and blacklistedBombVariants[bomb.Variant] ~= true then
        return saveKeys.BOMB, bomb.InitSeed
    elseif knife ~= nil then
        return saveKeys.KNIFE, knife.InitSeed
    else
        return saveKeys.PER_ROOM_ENTITY, GetPtrHash(entity)
    end
end



mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.IMPORTANT, function (_, shouldSave)
    ClearTables()
end)



---@param slot integer
mod:AddPriorityCallback(ModCallbacks.MC_POST_GLOWING_HOURGLASS_LOAD, CallbackPriority.IMPORTANT, function (_, slot)
    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
        saveManager._saveDataIndependent[keyPersistence] = CopyTableDeep(saveManager._saveDataIndependentPreviousRooms[keyPersistence][slot + 1])
    end

    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffectedEntities) do
        for _, keyEntity in ipairs(saveKeysEntityPersistent) do
            for individualEntityKey, _ in pairs(saveManager._saveDataEntities[keyPersistence][keyEntity]) do
                saveManager._saveDataEntities[keyPersistence][keyEntity][individualEntityKey] = CopyTableDeep(saveManager._saveDataEntitiesPreviousRooms[keyPersistence][keyEntity][individualEntityKey][slot + 1])
            end
        end
    end
end)

---@param slot integer
mod:AddPriorityCallback(ModCallbacks.MC_POST_GLOWING_HOURGLASS_SAVE, CallbackPriority.IMPORTANT, function (_, slot)
    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffected) do
        saveManager._saveDataIndependentPreviousRooms[keyPersistence][slot + 1] = CopyTableDeep(saveManager._saveDataIndependent[keyPersistence])
    end

    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffectedEntities) do
        for _, keyEntity in ipairs(saveKeysEntityPersistent) do
            for individualEntityKey, _ in pairs(saveManager._saveDataEntities[keyPersistence][keyEntity]) do
                saveManager._saveDataEntitiesPreviousRooms[keyPersistence][keyEntity][individualEntityKey][slot + 1] = CopyTableDeep(saveManager._saveDataEntities[keyPersistence][keyEntity][individualEntityKey])
            end
        end
    end
end)

---@param entity Entity
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.IMPORTANT, function (_, entity)
    local bomb = entity:ToBomb()
    if bomb ~= nil then
        if bomb:GetExplosionCountdown() > 0 then return end
    end

    local entityKey, index = GetEntityKeyAndUniqueIndex(entity)

    for _, keyPersistence in ipairs(saveKeysPersistenceEntities) do
        saveManager._saveDataEntities[keyPersistence][entityKey][index] = nil
    end
    if entityKey == saveKeys.PER_ROOM_ENTITY then return end
    for _, keyPersistence in ipairs(saveKeysPersistenceHourglassAffectedEntities) do
        saveManager._saveDataEntitiesPreviousRooms[keyPersistence][entityKey][index] = nil
    end
end)




---@enum PersistenceCategory
saveManager.PersistenceCategory = {
    TEMPORARY = 0,
    TEMPORARY_NO_HOURGLASS = 1,
}

local persistenceCategoryToKey = {
    [0] = saveKeys.TEMPORARY,
    [1] = saveKeys.TEMPORARY_NO_HOURGLASS,
}

---@param persistenceCategory PersistenceCategory
---@param entity Entity | nil
---@return table
function saveManager.GetData(persistenceCategory, entity)
    local persistenceKey = persistenceCategoryToKey[persistenceCategory]

    if entity == nil then
        return saveManager._saveDataIndependent[persistenceKey]
    end

    local key, index = GetEntityKeyAndUniqueIndex(entity)
    local indexString = tostring(index)

    if saveManager._saveDataEntities[persistenceKey][key][indexString] == nil then
        saveManager._saveDataEntities[persistenceKey][key][indexString] = {}
        if persistenceCategory ~= saveManager.PersistenceCategory.TEMPORARY_NO_HOURGLASS then
            saveManager._saveDataEntitiesPreviousRooms[persistenceKey][key][indexString] = { {}, {} }
        end
    end
    return saveManager._saveDataEntities[persistenceKey][key][indexString]
end

---@param entity Entity?
function saveManager.GetTemporaryData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY, entity)
end

---@param entity Entity?
function saveManager.GetTemporaryNoHourglassData(entity)
    return saveManager.GetData(saveManager.PersistenceCategory.TEMPORARY_NO_HOURGLASS, entity)
end


---@param newSaveManager DataHolder
---@param oldSaveManager DataHolder
function saveManager.Update(newSaveManager, oldSaveManager)
    newSaveManager._saveDataIndependent = CopyTableDeep(oldSaveManager._saveDataIndependent)
    newSaveManager._saveDataIndependentPreviousRooms = CopyTableDeep(oldSaveManager._saveDataIndependentPreviousRooms)
    newSaveManager._saveDataEntities = CopyTableDeep(oldSaveManager._saveDataEntities)
    newSaveManager._saveDataEntitiesPreviousRooms = CopyTableDeep(oldSaveManager._saveDataEntitiesPreviousRooms)
end

return saveManager



end