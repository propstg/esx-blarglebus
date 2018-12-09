Config = {}
Config.Locale = 'en'

Config.Marker = {
    Size = 5.0
}

AirportRoute = {
    Name = 'airport_route',
    BusModel = 'rentalbus',
    Capacity = 9,
    SpawnPoint = {x = 1, y = 1, z = 1, heading = 1},
    Payment = 5000,
    Stops = {
        {x = 1, y = 1, z = 1}, -- airport
        {x = 1, y = 1, z = 1}, -- hotel 1
        {x = 1, y = 1, z = 1}, -- hotel 2
        {x = 1, y = 1, z = 1}, -- hotel 3
        {x = 1, y = 1, z = 1}, -- airport 
        {x = 1, y = 1, z = 1}, -- hotel 1
        {x = 1, y = 1, z = 1}, -- hotel 2
        {x = 1, y = 1, z = 1}, -- hotel 3
        {x = 1, y = 1, z = 1}, -- airport
    }
}

IntercityRoute = {
    Name = 'intercity_route',
    BusModel = 'coach',
    Capacity = 9,
    SpawnPoint = {x = 1, y = 1, z = 1, heading = 1},
    Payment = 10000,
    Stops = {
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
    }
}

VinewoodRoute = {
    Name = 'vinewood_route',
    BusModel = 'bus',
    Capacity = 15,
    SpawnPoint = {x = 1, y = 1, z = 1, heading = 1},
    Payment = 5000,
    Stops = {
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
        {x = 1, y = 1, z = 1},
    }
}

Routes = {
    AirportRoute, IntercityRoute, VinewoodRoute
}