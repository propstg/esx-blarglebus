Blips = {}
Blips.routeBlips = {}

function Blips.StartBlips()
    for _, route in pairs(Config.Routes) do
        local coords = route.SpawnPoint
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 513)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(_U(route.Name))
        EndTextCommandSetBlipName(blip)
        Blips.routeBlips[route.Name] = blip
    end
end

function Blips.SetBlipAndWaypoint(routeName, x, y, z)
    SetBlipCoords(Blips.routeBlips[routeName], x, y, z)
    SetNewWaypoint(x, y)
end