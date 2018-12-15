local bus = nil

local function createBus(coords, model)
    ESX.Game.SpawnVehicle(model, coords, coords.heading, function(createdBus)
        bus = createdBus
        SetVehicleFuelLevel(bus, 100.0)
    end)
end

local function deleteBus()
    DeleteVehicle(bus)
    bus = nil
end

local function displayMessageAndWaitUntilBusStopped(notificationMessage)
    while not IsVehicleStopped(bus) do
        ESX.ShowNotification(notificationMessage)
        Citizen.Wait(500)
    end
end

local function openDoorsAndActivateHazards(doors)
    activateHazards(true)
    openBusDoors(doors)
end

local function openBusDoors(doors)
    for i = 1, #doors do
        SetVehicleDoorOpen(bus, doors[i], false, false)
    end

    Citizen.Wait(Config.DelayBetweenChanges)
end

local function closeDoorsAndDeactivateHazards()
    activateHazards(false)
    SetVehicleDoorsShut(bus, false)
end

local activateHazards(isOn)
    SetVehicleIndicatorLights(bus, 0, isOn)
    SetVehicleIndicatorLights(bus, 1, isOn)
end

local function findFreeSeats(firstSeat, capacity)
    local freeSeats = {}

    for i = firstSeat, capacity do
        if IsVehicleSeatFree(bus, i) then
            table.insert(freeSeats, i)
        end
    end

    return freeSeats
end

local function getBus()
    return bus
end

Bus = {
    CreateBus = createBus,
    DeleteBus = deleteBus,
    DisplayMessageAndWaitUntilBusStopped = displayMessageAndWaitUntilBusStopped,
    IsBusStopped = isBusStopped,
    OpenDoorsAndActivateHazards = openDoorsAndActivateHazards,
    CloseDoorsAndDeactivateHazards = closeDoorsAndDeactivateHazards,
    FindFreeSeats = findFreeSeats,
    GetBus = getBus
}