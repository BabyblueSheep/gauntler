if FiendFolio == nil then return end

local game = Game()

local itemIcons = {}

---@param player EntityPlayer
---@param itemGfx string
---@param angle number
---@param isRemoval boolean
function TheGauntlet.Compat.FiendFolio.GauntletDisc.ShowItemIcon(player, itemGfx, angle, isRemoval)
	local sprite = Sprite()
	sprite:Load("gfx/005.100_collectible.anm2", false)
	sprite:Play("ShopIdle")
	sprite:ReplaceSpritesheet(1, itemGfx)
	sprite:LoadGraphics()

	local pos = player.Position
	if not isRemoval then
		pos = pos - Vector(0, 35)
	end
	local vel = Vector.FromAngle(angle + 180) * 5

	table.insert(itemIcons, {
		Sprite = sprite,
		Pos = pos,
		Vel = vel,
		Player = player,
		FrameCount = 0,
		IsRemoval = isRemoval,
	})
end

local itemIconsStartDuration = 100
local itemIconsDisappearDuration = 60

local colorWhite = Color(1,1,1,0.5,1,1,1)
local colorNormal = Color(1,1,1,0.8)
local colorInvisible = Color(1,1,1,0)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_RENDER, function (_)
	for k, tab in pairs(itemIcons) do
		if not game:IsPaused() then
			if tab.IsRemoval then
				tab.Vel = TheGauntlet.Utility.Lerp(tab.Vel, Vector.Zero, 0.075)
				tab.Sprite.Color = Color.Lerp(colorNormal, colorInvisible, tab.FrameCount / itemIconsDisappearDuration)
			elseif tab.FrameCount < itemIconsStartDuration then
				tab.Vel = TheGauntlet.Utility.Lerp(tab.Vel, Vector.Zero, 0.075)
				tab.Sprite.Color = Color.Lerp(colorWhite, colorNormal, math.min(tab.FrameCount / itemIconsStartDuration*5, 1))
			else
				tab.Vel = TheGauntlet.Utility.Lerp(tab.Vel, ((tab.Player.Position + tab.Player.Velocity) - tab.Pos):Resized(15), 0.1)
				local t = tab.Player.Position:Distance(tab.Pos) / 100
				t = math.min(math.max(t, 0), 1)
				local targetColor = Color.Lerp(colorWhite, colorNormal, t)
				tab.Sprite.Color = Color.Lerp(tab.Sprite.Color, targetColor, 0.2)
			end
			tab.Pos = tab.Pos + tab.Vel
			tab.FrameCount = tab.FrameCount + 1
		end

		tab.Sprite:Render(Isaac.WorldToScreen(tab.Pos), Vector.Zero, Vector.Zero)

		if tab.FrameCount >= 120*2 or (tab.IsRemoval and tab.FrameCount >= itemIconsDisappearDuration)
				or (tab.FrameCount >= itemIconsStartDuration and tab.Player.Position:Distance(tab.Pos) < 10) then
			itemIcons[k] = nil
		end
	end
end)

TheGauntlet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() 
	itemIcons = {}
end)