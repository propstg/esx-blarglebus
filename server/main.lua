ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterNetEvent('blarglebus:finishRoute')
AddEventHandler('blarglebus:finishRoute', function(source, amount)
    local player = ESX.GetPlayerFromId(source)
    player.addMoney(amount)
end)