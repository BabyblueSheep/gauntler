if FiendFolio == nil then return end



local game = Game()

local originalFireworkExplosion = FiendFolio.FireworkExplosion

function FiendFolio:FireworkExplosion(tear, data)
    local player = Isaac.GetPlayer(0)
    if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
        player = tear.SpawnerEntity:ToPlayer()
    end

    originalFireworkExplosion(FiendFolio, tear, data)

    if player:HasCollectible(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE) then
        TheGauntlet.Items.Zeus.SpawnLightningBolt(game:GetRoom():GetRandomPosition(10), player, data.SparkleColor)
    end
end