if FiendFolio == nil then return end


local originalTipsyGeodeUpdate = FiendFolio.tipsyGeodeUpdate

function FiendFolio:tipsyGeodeUpdate(player, data)
    originalTipsyGeodeUpdate(FiendFolio, player, data)

    if player:HasTrinket(FiendFolio.ITEM.ROCK.TIPSY_GEODE) and player:HasCollectible(TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE) then
        data.tipsyGeodeStrength = data.tipsyGeodeStrength + 0.2
    end
end

local originalGetGolemTrinketPower = FiendFolio.GetGolemTrinketPower

function FiendFolio.GetGolemTrinketPower(player, trinketId)
    local originalTrinketPower, originalHasTwoGeodes = originalGetGolemTrinketPower(player, trinketId)
    if trinketId == FiendFolio.ITEM.ROCK.TIPSY_GEODE and player:HasCollectible(TheGauntlet.Items.Dionysus.COLLECTIBLE_TYPE) then
        originalTrinketPower = originalTrinketPower + 1
    end
    return originalTrinketPower, originalHasTwoGeodes
end