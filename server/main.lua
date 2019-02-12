ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('blarglebus:finishRoute')
AddEventHandler('blarglebus:finishRoute', function(amount)
    ESX.GetPlayerFromId(source).addMoney(amount)
end)

RegisterNetEvent('blarglebus:passengersLoaded')
AddEventHandler('blarglebus:passengersLoaded', function(amount)
    ESX.GetPlayerFromId(source).addMoney(amount)
end)

RegisterNetEvent('blarglebus:abortRoute')
AddEventHandler('blarglebus:abortRoute', function(amount)
    ESX.GetPlayerFromId(source).removeMoney(amount)
end)