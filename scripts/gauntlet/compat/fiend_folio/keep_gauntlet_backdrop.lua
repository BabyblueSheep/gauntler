local originalbackdropReplacer = FiendFolio.backdropReplacer

function FiendFolio:backdropReplacer()
    if TheGauntlet.GauntletRoom.IsCurrentRoomGauntletRoom() then return end

    return originalbackdropReplacer(FiendFolio)
end