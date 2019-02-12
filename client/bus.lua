Bus = {}
Bus.bus = nil
Bus.plate = nil

function Bus.CreateBus(coords, model, color)
    ESX.Game.SpawnVehicle(model, coords, coords.heading, function(createdBus)
        Bus.bus = createdBus
        Bus.plate = string.format('BLARG%03d', math.random(0, 999))
        SetVehicleNumberPlateText(Bus.bus, Bus.plate)
        SetVehicleColours(Bus.bus, color, color)
        Bus.WaitForFirstEntryAndFillTankIfNeededAsync()
    end)
end

function Bus.WaitForFirstEntryAndFillTankIfNeededAsync()
    if Config.UseLegacyFuel then
        Bus.DoFillForLegacyFuel()
    elseif Config.UseFrFuel then
        Bus.DoFillForFrFuel()
    end
end

function Bus.DoFillForLegacyFuel()
    SetVehicleFuelLevel(Bus.bus, 100.0)
    TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', Bus.plate, 100.0)
    TriggerServerEvent('LegacyFuel:CheckServerFuelTable', Bus.plate)
end

function Bus.DoFillForFrFuel()
    Citizen.CreateThread(function()
        local maxFuel = GetVehicleHandlingFloat(Bus.bus, 'CHandlingData', 'fPetrolTankVolume')

        while true do
            Citizen.Wait(500)
            
            if GetVehiclePedIsIn(PlayerPedId(), false) == Bus.bus then
                exports.frfuel:setFuel(maxFuel)
                break
            end
        end
    end)
end

function Bus.DeleteBus()
    DeleteVehicle(Bus.bus)
    Bus.bus = nil
end

function Bus.DisplayMessageAndWaitUntilBusStopped(notificationMessage)
    while not IsVehicleStopped(Bus.bus) do
        ESX.ShowNotification(notificationMessage)
        Citizen.Wait(500)
    end
end

function Bus.OpenDoorsAndActivateHazards(doors)
    Bus.ActivateHazards(true)
    Bus.OpenBusDoors(doors)
end

function Bus.OpenBusDoors(doors)
    for i = 1, #doors do
        SetVehicleDoorOpen(Bus.bus, doors[i], false, false)
    end

    Citizen.Wait(Config.DelayBetweenChanges)
end

function Bus.CloseDoorsAndDeactivateHazards()
    Bus.ActivateHazards(false)
    SetVehicleDoorsShut(Bus.bus, false)
end

function Bus.ActivateHazards(isOn)
    SetVehicleIndicatorLights(Bus.bus, 0, isOn)
    SetVehicleIndicatorLights(Bus.bus, 1, isOn)
end

function Bus.FindFreeSeats(firstSeat, capacity)
    local freeSeats = {}

    for i = firstSeat, capacity do
        if IsVehicleSeatFree(Bus.bus, i) then
            table.insert(freeSeats, i)
        end
    end

    return freeSeats
end