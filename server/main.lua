ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('blarglebus:finishRoute')
AddEventHandler('blarglebus:finishRoute', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name == 'busdriver' then
    xPlayer.addMoney(amount)
    else
        print(_U('exploit_attempted_log_message', xPlayer.identifier))
        xPlayer.kick(_U('exploit_attempted_kick_message'))
     end
end)

RegisterNetEvent('blarglebus:passengersLoaded')
AddEventHandler('blarglebus:passengersLoaded', function(amount)
    ESX.GetPlayerFromId(source).addMoney(amount)
end)

RegisterNetEvent('blarglebus:abortRoute')
AddEventHandler('blarglebus:abortRoute', function(amount)
    ESX.GetPlayerFromId(source).removeMoney(amount)
end)
