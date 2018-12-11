local routeBlips = {}

local function startBlips()
    for i = 1, #Config.Routes do
        local coords = Config.Routes[i].SpawnPoint
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 513)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(_U(Config.Routes[i].Name))
        EndTextCommandSetBlipName(blip)
        routeBlips[Config.Routes[i].Name] = blip
    end
end

local function setBlipAndWaypoint(routeName, x, y, z)
    SetBlipCoords(routeBlips[routeName], x, y, z)
    SetNewWaypoint(x, y)
end

Blips = {
    StartBlips = startBlips,
    SetBlipAndWaypoint = setBlipAndWaypoint
}