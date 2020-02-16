ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('blarglebus:finishRoute')
AddEventHandler('blarglebus:finishRoute', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name == 'busdriver' then
    ESX.GetPlayerFromId(source).addMoney(amount)
    else
        print(('blarglebus: %s attempted to exploit the job!'):format(xPlayer.identifier))
	xPlayer.kick("You are kicked because of cheat!")
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
