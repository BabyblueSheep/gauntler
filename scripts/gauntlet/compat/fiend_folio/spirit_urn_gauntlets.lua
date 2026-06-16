if FiendFolio == nil then return end



local game = Game()
local sfxManager = SFXManager()

local previousWaveNumber = -1
local didGauntletWaveStart = false
local didCheckForGauntletWave = false

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not didCheckForGauntletWave then
        local currentWaveNumber = TheGauntlet.GauntletRoom.GetCurrentWaveNumber()
        if currentWaveNumber ~= nil then
            if currentWaveNumber == 1 and previousWaveNumber == 0 then
                didGauntletWaveStart = true
            else
                didGauntletWaveStart = false
            end

            previousWaveNumber = currentWaveNumber
        end

        didCheckForGauntletWave = true
    end

    if not didGauntletWaveStart then return end

    if not player:HasTrinket(FiendFolio.ITEM.ROCK.SPIRIT_URN) then return end

    local data = player:GetData()

    if not data.spiritUrnChallenge then
        data.spiritUrnChallenge = true
        local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SPIRIT_URN)
        for i = 1, 2 + mult do
            player:AddWisp(0, player.Position, true, false)
        end
        sfxManager:Play(SoundEffect.SOUND_FLAME_BURST, 1, 0, false, 3)
    end
end)

---@param player EntityPlayer
TheGauntlet:AddCallback(ModCallbacks.MC_POST_UPDATE, function (_, player)
    didCheckForGauntletWave = false
end)