if FiendFolio == nil then return end



---@param effect EntityEffect
TheGauntlet:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if effect.Variant ~= TheGauntlet.Items.Zeus.BOLT_EFFECT_VARIANT then return end

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if not player:HasTrinket(FiendFolio.ITEM.ROCK.ELECTRUM) then goto continue end

		local mult = FiendFolio.GetGolemTrinketPower(player:ToPlayer(), FiendFolio.ITEM.ROCK.ELECTRUM)

        FiendFolio:alternateElectrumShock
        (
            player,
            player:GetCollectibleRNG(TheGauntlet.Items.Zeus.COLLECTIBLE_TYPE),
            player.Damage * mult,
            player.Position,
            1, nil,
            function (enemy, player, mult, rng)
                enemy:GetData().electrumZeusDeath = function()
                    if rng:RandomFloat() < TheGauntlet.Items.Zeus.Constants.CHANCE_TO_GIVE_PIP_ON_KILL then
                        player:AddActiveCharge(1)
                    end
                end
            end, mult)

        ::continue::
    end
end)

---@param npc EntityNPC
TheGauntlet:AddCallback(ModCallbacks.MC_NPC_UPDATE, function (_, npc)
	local data = npc:GetData()
	if data.electrumZeusDeath ~= nil then
		if npc:IsDead() or FiendFolio:isLeavingStatusCorpse(npc) then
			data.electrumZeusDeath(npc)
			data.electrumZeusDeath = nil
		end

		data.electrumZeusDeathLeniency = (data.electrumZeusDeathLeniency or 0)+1
		if data.electrumZeusDeathLeniency > 3 then
			data.electrumZeusDeath = nil
			data.electrumZeusDeathLeniency = nil
		end
	end
end)