ESX.RegisterServerEvent('blarglebus:finishRoute', function(source, amount)
    local player = ESX.GetPlayerFromId(source)
    player.addMoney(amount)
end)