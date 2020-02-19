ESX = nil

Wrapper.TriggerEvent('esx:getSharedObject', setEsx)
function setEsx(obj) ESX = obj end

Wrapper.RegisterNetEvent('blarglebus:finishRoute')
Wrapper.AddEventHandler('blarglebus:finishRoute', function(amount)
    updateMoney(source, function(player) player.addMoney(amount) end)
end)

Wrapper.RegisterNetEvent('blarglebus:passengersLoaded')
Wrapper.AddEventHandler('blarglebus:passengersLoaded', function(amount)
    updateMoney(source, function(player) player.addMoney(amount) end)
end)

Wrapper.RegisterNetEvent('blarglebus:abortRoute')
Wrapper.AddEventHandler('blarglebus:abortRoute', function(amount)
    updateMoney(source, function(player) player.removeMoney(amount) end)
end)

function updateMoney(_source, updateMoneyCallback)
    local player = ESX.GetPlayerFromId(_source)

    if player.job.name ~= 'busdriver' then
        Wrapper.print(_('exploit_attempted_log_message', player.identifier))
        player.kick(_U('exploit_attempted_kick_message'))
        return
    end

    updateMoneyCallback(player)
end
