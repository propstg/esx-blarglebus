# esx-blarglebus
Adds a bus driver job to drive NPCs around, with a few default routes. Airport shuttle route starts near the airport. LS metro starts at the Strawberry station under the highway. Scenic route starts at the Dashound Bus Center in Los Santos.

## Download & Installation

### Using Git
```
cd resources
git clone https://github.com/propstg/esx-blarglebus.git [esx]/esx-blarglebus
```

### Manually
- Download https://github.com/propstg/esx-blarglebus/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Add this to your `server.cfg`:

```
start esx-blarglebus
```

## Fuel script support
If you use FrFuel or LegacyFuel, set the appropriate option in config.lua to true to set the bus fuel level to 100% on spawn.
- FrFuel: Config.UseFrFuel
- LegacyFuel: Config.UseLegacyFuel

## Customizing

### Vehicles
Custom vehicles can be added by editing config/busType.lua and adding a bus object to the BusType table.
```
    CityBus = { -- This is the name that you will use in your route configs (BusType.CityBus)
        BusModel = 'bus',
        Capacity = 15,
        Doors = {0, 1, 2, 3},
        FirstSeat = 1
    },
```

1. Set BusModel to the name of the vehicle (use the name that you would use to spawn it).
2. Set the Capacity to the number of actual passenger seats (some buses have less seats than they appear to have). This controls how many peds will spawn. If it's too high, some peds will be left standing around after the others get on the bus.
3. Set this to the door numbers that you want opened automatically when the bus arrives at a stop. This may cause an issue if the list of doors references a door number that the vehicle model doesn't have.
4. Set first seat to the first passenger seat number. (This probably isn't really needed, but I don't remember why I added it. Leave it set to 1, probably.)
5. Update the appropriate route config file to reference this new bus type (set Bus = BusType.YourNewBusType)

### Routes
Routes can be customized with your own stops. A route can also consist of one or more "lines", which can be randomly or directly selected.

#### Adding a route
To create a new route:
1. Add a new config file in `config/routes`. Example, with details:
```
AirportRoute = { -- The name of the route (what you add to Config.Routes)
    Name = 'airport_route', -- The key to look up the display name in the localization file. A corresponding entry should be added to locales/*.lua.
    Bus = BusType.Shuttle, -- The default bus type to use for the route.
    SpawnPoint = {x = -923.7001, y = -2283.8886, z = 6.7090, heading = 333.65}, -- The spawn point for the bus.
    BusReturnPoint = {x = -923.7001, y = -2283.8886, z = 6.7090, heading = 333.65}, -- The place to go to return the bus at the end of a route.
    Payment = 8000,
    PaymentPerPassenger = 10,
    Lines = {...} -- A list of all the stops
}
```
2. Update Config.Routes in `config/config.lua` to reference the new route that you added

#### Lines
##### Multiple lines
For an example of how to have more than one line, take a look at the metro config.

##### Overriding route settings
The following properties can be set in a line to override the defaults for the route:

1. BusOverride: Set this to a different BusType to have this line use a different bus.
2. BusReturnPointOverride: Set this to a different point to have the bus for this line be returned to a different end point at the end of the route.

```
    Lines = {
        {
            BusOverride = BusType.Shuttle,
            BusReturnPointOverride = {x = 280.416, y = -1230.68, z = 29.138, heading = 265.05},
            ...
```

#### Adding a stop
Routes use a table of stop objects. Each has the coordinates, a key for the display name, and an unload type.

```
    {x = 424.7632,   y = -638.9176, z = 28.5001, name = 'stop_dashound', unloadType = UnloadType.All},
```

For routes that have no overlapping stops, it might be easiest to just have the table inline (airport and scenic). For routes that have many lines with overlapping stops, pulling the stops out into a common table and then just referencing them might save you some time if you ever need to make any changes to a commonly used stop (metro).

1. x, y, and z are the coordinates of where you want the peds to spawn. The coordinates should represent a point a little back from the road, to prevent the peds from spawning in traffic.
2. `name` is a key to look up the display name in the localization file. A corresponding entry should be added to locales/*.lua.
3. Unload type should be one of the following:
    * UnloadType.All: All Peds should depart the bus. Peds equal to the bus capacity will spawn.
    * UnloadType.Some: A random number of Peds will depart and a random number of Peds will spawn.
    * UnloadType.None: No peds will depart. If there are any empty seats, some peds may spawn.

# Legal
### License
esx-blarglebus - bus driver job

Copyright (C) 2019 Gregory Propst

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
