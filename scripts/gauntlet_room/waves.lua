local sfxManager = SFXManager()
local musicManager = MusicManager()

local FAKE_PENTAGRAM_VARIANT = Isaac.GetEntityVariantByName("A Replication and Recreation of a Spawn Pentagram added in Repentance Plus")

local GAUNTLET_ROOM_ITEM_POOL = Isaac.GetPoolIdByName("gauntletRoom")

local WAVE_CONFIGURATIONS_NORMAL_MODE = {
    { 10, 5, 5 },
    { 10, 5, 10 },
    { 10, 5, 15 },
    { 10, 10, 15 },
    { 11, 1, 5 },
}
local WAVE_CONFIGURATIONS_HARD_MODE = {
    { 10, 5, 15 },
    { 10, 10, 15 },
    { 11, 1, 5 },
    { 10, 15, 15 },
    { 11, 5, 10 },
}

---@param type EntityType
---@param variant integer
---@param subtype integer
---@param position Vector
local function SpawnEnemyDelayed(type, variant, subtype, position)
    local entityConfig = EntityConfig.GetEntity(type, variant, subtype)
    if entityConfig == nil then return end

    ---@type EntityEffect
    ---@diagnostic disable-next-line assign-type-mismatch
    local effect = Isaac.Spawn
    (
        EntityType.ENTITY_EFFECT, FAKE_PENTAGRAM_VARIANT, 0,
        position, Vector.Zero, nil
    ):ToEffect()

    effect:GetData().FakeAmbush = {
        Type = type,
        Variant = variant,
        SubType = subtype
    }

    if entityConfig:IsBoss() then
        effect:GetSprite():Play("Boss Summon", true)
    end

    ---@diagnostic disable-next-line param-type-mismatch
    sfxManager:Play(871)
end

---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished() then
        local enemyData = effect:GetData().FakeAmbush

        Isaac.Spawn
        (
            enemyData.Type, enemyData.Variant, enemyData.SubType,
            effect.Position, Vector.Zero,
            nil
        )
        effect:Remove()

        sfxManager:Play(SoundEffect.SOUND_SUMMONSOUND)
    end
end, FAKE_PENTAGRAM_VARIANT)

---@param type integer
---@param minDifficulty integer
---@param maxDifficulty integer
local function SpawnAmbush(type, minDifficulty, maxDifficulty)
    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local rng = RNG(roomSave.WaveSeed)

    local ambushWave = RoomConfig.GetRandomRoom
    (
        rng:Next(),
        true,
        Isaac.GetCurrentStageConfigId(), RoomType.ROOM_CHALLENGE, nil,
        nil, nil,
        minDifficulty, maxDifficulty,
        0,
        type
    )

    for i = 0, #ambushWave.Spawns - 1 do
        local enemySpawn = ambushWave.Spawns:Get(i)
        local enemySpawnEntry = enemySpawn:PickEntry(rng:RandomFloat())

        local gridIndex = enemySpawn.X + 1 + (enemySpawn.Y + 1) * Game():GetRoom():GetGridWidth()

        SpawnEnemyDelayed(enemySpawnEntry.Type, enemySpawnEntry.Variant, enemySpawnEntry.Subtype, Game():GetRoom():GetGridPosition(gridIndex))
    end
end

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = Game():GetRoom()

    room:SetItemPool(GAUNTLET_ROOM_ITEM_POOL)

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()

    if not roomSave.Init then
        roomSave.TeleportSeed = room:GetAwardSeed()
        roomSave.WaveSeed = room:GetAwardSeed()

        roomSave.WaveDelay = 0
        roomSave.WaveNumber = 0

        roomSave.Init = true
    end

    roomSave.DidHostileEnemiesExist = false

    if room:IsAmbushDone() then
        musicManager:Play(Music.MUSIC_BOSS_OVER, 0)
        musicManager:UpdateVolume()
    end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    local room = Game():GetRoom()

    if room:IsAmbushDone() then return end

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()

    for _, doorSlot in pairs(DoorSlot) do
        local door = room:GetDoor(doorSlot)
        if door == nil then goto continue end

        door:Close(true)

        ::continue::
    end
    room:SetClear(false)
    room:KeepDoorsClosed()

    local doHostileEnemiesExist = false

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:IsActiveEnemy(true) and entity:CanShutDoors()) or (entity.Type == EntityType.ENTITY_EFFECT and entity.Variant == FAKE_PENTAGRAM_VARIANT) then
            doHostileEnemiesExist = true
            break
        end
    end

    if doHostileEnemiesExist then
        roomSave.WaveDelay = 0
    else
        roomSave.WaveDelay = roomSave.WaveDelay + 1
    end

    if not doHostileEnemiesExist and roomSave.DidHostileEnemiesExist then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:ToPlayer() ~= nil then
                entity:ToPlayer():TriggerRoomClear()
            end
            if entity:ToFamiliar() ~= nil then
                entity:ToFamiliar():TriggerRoomClear()
            end
        end
    end

    if roomSave.WaveDelay > 30 then
        roomSave.WaveDelay = 0

        roomSave.WaveNumber = roomSave.WaveNumber + 1
        local waveConfigurations = Game().Difficulty == Difficulty.DIFFICULTY_HARD and WAVE_CONFIGURATIONS_HARD_MODE or WAVE_CONFIGURATIONS_NORMAL_MODE

        if roomSave.WaveNumber > #waveConfigurations then
            room:SetClear(true)
            room:SetAmbushDone(true)

            musicManager:Play(Music.MUSIC_JINGLE_CHALLENGE_OUTRO, 0)
            musicManager:UpdateVolume()
            musicManager:Queue(Music.MUSIC_BOSS_OVER)

            local collectibleSpawnPosition = room:FindFreePickupSpawnPosition(room:GetCenterPos())

            Isaac.Spawn
            (
                EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0,
                collectibleSpawnPosition, Vector.Zero,
                nil
            )

            room:TriggerClear(true)
        else 
            if musicManager:GetCurrentMusicID() ~= Music.MUSIC_CHALLENGE_FIGHT then
                musicManager:Play(Music.MUSIC_CHALLENGE_FIGHT, 0)
                musicManager:UpdateVolume()
            end
            local waveConfiguration = waveConfigurations[roomSave.WaveNumber]
            SpawnAmbush(waveConfiguration[1], waveConfiguration[2], waveConfiguration[3])
        end
    end

    roomSave.DidHostileEnemiesExist = doHostileEnemiesExist
end)

---@param entity Entity
---@param damage number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param damageCooldown integer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function (_, entity, damage, damageFlags, source, damageCooldown)
    if not TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end
    if Game():GetRoom():IsAmbushDone() then return end

    if entity.Type ~= EntityType.ENTITY_PLAYER then return end
    ---@type EntityPlayer
    ---@diagnostic disable-next-line assign-type-mismatch
    local player = entity:ToPlayer()

    local roomSave = TheGauntlet.SaveManager.GetRoomSave()
    local teleportRNG = RNG(roomSave.TeleportSeed)
    roomSave.TeleportSeed = teleportRNG:Next()

    local randomRoomIndex = Game():GetLevel():GetRandomRoomIndex(false, roomSave.TeleportSeed)
    Game():StartRoomTransition(randomRoomIndex, -1, RoomTransitionAnim.TELEPORT)
end)