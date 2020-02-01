MetroStops = {
    [1]  = {x = -526.2774, y = -263.5606, z = 35.4519, unloadType = UnloadType.Some, name = 'stop_metro_carcer_way'},
    [3]  = {x = -1418.3283, y = -91.1142, z = 52.4513, unloadType = UnloadType.Some, name = 'stop_metro_eclipse_cougar'},
    [4]  = {x = -1475.4442, y = -635.4663, z = 31.0511, unloadType = UnloadType.Some, name = 'stop_metro_marathon_baycity'},
    [5]  = {x = -1413.7164, y = -566.5466, z = 30.8335, unloadType = UnloadType.Some, name = 'stop_metro_marathon_prosperity'},
    [6]  = {x = -1169.3343, y = -396.8692, z = 35.5438, unloadType = UnloadType.Some, name = 'stop_metro_marathon'},
    [7]  = {x = -692.2866, y = -671.1650, z = 31.2891, unloadType = UnloadType.Some, name = 'stop_metro_sanandreas_ginger'},
    [8]  = {x = -504.8421, y = -671.5119, z = 33.4909, unloadType = UnloadType.Some, name = 'stop_metro_sanandreas_calais'},
    [9]  = {x = 115.3352, y = -780.9725, z = 31.8174, unloadType = UnloadType.Some, name = 'stop_metro_fib'},
    [10] = {x = -248.1879, y = -712.1666, z = 33.9617, unloadType = UnloadType.Some, name = 'stop_metro_peaceful_san_andreas'},
    [11] = {x = -267.2324, y = -824.2173, z = 32.2911, unloadType = UnloadType.Some, name = 'stop_metro_peaceful_vespucci'},
    [12] = {x = -250.1772, y = -887.7517, z = 31.0675, unloadType = UnloadType.Some, name = 'stop_metro_vespucci_alta'},
    [13] = {x = 355.2163, y = -1067.8500, z = 29.9783, unloadType = UnloadType.Some, name = 'stop_metro_vespucci_sinner'},
    [14] = {x = -713.2615, y = -823.8684, z = 23.5511, unloadType = UnloadType.Some, name = 'stop_metro_vespucci_ginger'},
    [15] = {x = -932.4981, y = -120.2621, z = 37.7789, unloadType = UnloadType.Some, name = 'stop_metro_delperro_madwayne'},
    [16] = {x = -1528.3587, y = -463.6042, z = 35.8467, unloadType = UnloadType.Some, name = 'stop_metro_delperro_plaza'},
    [17] = {x = -642.2674, y = -135.7480, z = 37.8349, unloadType = UnloadType.Some, name = 'stop_metro_rockford_eastbourne'},
    [18] = {x = -681.7453, y = -381.3421, z = 34.2342, unloadType = UnloadType.Some, name = 'stop_metro_dorset_palomino'},
    [19] = {x = -179.0992, y = -818.2785, z = 31.0558, unloadType = UnloadType.Some, name = 'stop_metro_alta_gruppe'},
    [29] = {x = 66.2063, y = -966.0771, z = 29.3575, unloadType = UnloadType.Some, name = 'stop_metro_vespucci_elgin'},
    [32] = {x = -1281.3592, y = -317.1460, z = 36.7809, unloadType = UnloadType.Some, name = 'stop_metro_delperro_morningwood'},
    [34] = {x = 321.7252, y = -241.9803, z = 53.9631, unloadType = UnloadType.Some, name = 'stop_metro_hawick_meteor'},
    [39] = {x = 788.6597, y = -775.8231, z = 26.7654, unloadType = UnloadType.Some, name = 'stop_metro_popular'},
    [42] = {x = 263.5511, y = -1210.4304, z = 29.3386, unloadType = UnloadType.All, name = 'stop_metro_station_arrivals'},
    [43] = {x = 263.7222, y = -1194.2947, z = 29.3560, unloadType = UnloadType.All, name = 'stop_metro_station_departures'},
    [44] = {x = -216.5875, y = -600.5554, z = 34.2638, unloadType = UnloadType.Some, name = 'stop_metro_business_center'},
    [45] = {x = -698.0225, y = -0.4975, z = 38.2428, unloadType = UnloadType.Some, name = 'stop_metro_delperro_rockford'},
    [46] = {x = -735.3663, y = -750.2927, z = 26.8735, unloadType = UnloadType.Some, name = 'stop_metro_ginger'},
    [47] = {x = -249.4506, y = -337.0251, z = 29.9658, unloadType = UnloadType.Some, name = 'stop_metro_rockford_plaza'},
    [48] = {x = 303.4519, y = -765.7985, z = 29.3109, unloadType = UnloadType.Some, name = 'stop_metro_strawberry_ave'},
    [49] = {x = 187.6606, y = -187.2898, z = 54.0936, unloadType = UnloadType.Some, name = 'stop_metro_hawick_alta'},
}


MetroRoute = {
    Name = 'metro_route',
    Bus = BusType.CityBus,
    SpawnPoint = {x = 303.1034, y = -1208.9884, z = 29.4169, heading = 356.02},
    BusReturnPoint = {x = 303.1034, y = -1208.9884, z = 29.4169, heading = 356.02},
    Payment = 5000,
    PaymentPerPassenger = 5,
    Lines = {
        {
            Name = 'metro_yellow',
            BusColor = 42,
            Stops = {
                MetroStops[43], MetroStops[11], MetroStops[44], MetroStops[47], MetroStops[1], MetroStops[17],
                MetroStops[15], MetroStops[18], MetroStops[8], MetroStops[10], MetroStops[12], MetroStops[42]
            }
        },{
            Name = 'metro_blue',
            BusColor = 83,
            Stops = {
                MetroStops[43], MetroStops[34], MetroStops[45], MetroStops[15], MetroStops[32], MetroStops[16], 
                MetroStops[4], MetroStops[7], MetroStops[8], MetroStops[19], MetroStops[42]
            }
        },{
            Name = 'metro_red',
            BusColor = 39,
            Stops = {
                MetroStops[43], MetroStops[13], MetroStops[39], MetroStops[34], MetroStops[49], MetroStops[48], 
                MetroStops[10], MetroStops[12], MetroStops[42]
            }
        },{
            Name = 'metro_purple',
            BusColor = 148,
            Stops = {
                MetroStops[43], MetroStops[29], MetroStops[14], MetroStops[46], MetroStops[6], MetroStops[5], 
                MetroStops[3], MetroStops[18], MetroStops[8], MetroStops[19], MetroStops[42]
            }
        },{
            Name = 'metro_orange',
            BusColor = 41,
            Stops = {
                MetroStops[43], MetroStops[13], MetroStops[9], MetroStops[19], MetroStops[13], MetroStops[9], 
                MetroStops[19], MetroStops[13], MetroStops[9], MetroStops[19], MetroStops[42]
            }
        },{
            Name = 'metro_black',
            BusColor = 12,
            Stops = {
                MetroStops[43], MetroStops[14], MetroStops[46], MetroStops[7], MetroStops[8], MetroStops[10], 
                MetroStops[14], MetroStops[46], MetroStops[7], MetroStops[8], MetroStops[10], MetroStops[42]
            }
        },
    }
}
