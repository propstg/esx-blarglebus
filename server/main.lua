ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('blarglebus:finishRoute')
AddEventHandler('blarglebus:finishRoute', function(amount)
    updateMoney(source, function(player) player.addMoney(amount) end)
end)

RegisterNetEvent('blarglebus:passengersLoaded')
AddEventHandler('blarglebus:passengersLoaded', function(amount)
    updateMoney(source, function(player) player.addMoney(amount) end)
end)

RegisterNetEvent('blarglebus:abortRoute')
AddEventHandler('blarglebus:abortRoute', function(amount)
    updateMoney(source, function(player) player.removeMoney(amount) end)
end)

function updateMoney(_source, updateMoneyCallback)
    local player = ESX.GetPlayerFromId(_source)
    
    if player.job.name ~= 'busdriver' then
        print(_('exploit_attempted_log_message', player.identifier))
        player.kick(_U('exploit_attempted_kick_message'))
        return
    end

    updateMoneyCallback(player)
end
