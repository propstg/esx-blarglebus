local mockagne = require 'mockagne'
local when = mockagne.when
local any = mockagne.any
local verify = mockagne.verify
local verifyNoCall = mockagne.verify_no_call

describe('server - main', function()

    local esx

    before_each(function()
        _G.unpack = table.unpack
        _G.Wrapper = mockagne.getMock()
        _G.source = 'source'
        _G._ = function(text) return text end
        _G._U = function(text) return text end

        require('../../lib/stream')
        require('../../server/main')

        esx = mockagne.getMock()
        setEsx(esx)
    end)

    insulate('verify events', function()
        it('verify events registered', function()
            verify(_G.Wrapper.TriggerEvent('esx:getSharedObject'))
            verify(_G.Wrapper.RegisterNetEvent('blarglebus:finishRoute'))
            verify(_G.Wrapper.AddEventHandler('blarglebus:finishRoute', any()))
            verify(_G.Wrapper.RegisterNetEvent('blarglebus:passengersLoaded'))
            verify(_G.Wrapper.AddEventHandler('blarglebus:passengersLoaded', any()))
            verify(_G.Wrapper.RegisterNetEvent('blarglebus:abortRoute'))
            verify(_G.Wrapper.AddEventHandler('blarglebus:abortRoute', any()))
        end)
    end)

    insulate('finishRoute', function() 
        it('adds money when player is busdriver', function()
            local playerMock = setUpTestWithPlayerJobSetTo('busdriver')

            getFunctionFromNativeCall('AddEventHandler', 'blarglebus:finishRoute')(1000)

            verify(playerMock.addMoney(1000))
            verifyNoCall(_G.Wrapper.print(any()))
            verifyNoCall(playerMock.kick(any()))
        end)
    end)

    insulate('finishRoute', function()
        it('kicks player when not busdriver', function()
            local playerMock = setUpTestWithPlayerJobSetTo('miner')
    
            getFunctionFromNativeCall('AddEventHandler', 'blarglebus:finishRoute')(1000)
    
            verify(_G.Wrapper.print('exploit_attempted_log_message'))
            verify(playerMock.kick('exploit_attempted_kick_message'))
            verifyNoCall(playerMock.addMoney())
        end)
    end)

    insulate('passengersLoaded', function()
        it('adds money when player is busdriver', function()
            local playerMock = setUpTestWithPlayerJobSetTo('busdriver')

            getFunctionFromNativeCall('AddEventHandler', 'blarglebus:passengersLoaded')(1000)

            verify(playerMock.addMoney(1000))
            verifyNoCall(_G.Wrapper.print(any()))
            verifyNoCall(playerMock.kick(any()))
        end)
    end)

    insulate('passengersLoaded', function()
        it('kicks player when not busdriver', function()
            local playerMock = setUpTestWithPlayerJobSetTo('miner')
    
            getFunctionFromNativeCall('AddEventHandler', 'blarglebus:passengersLoaded')(1000)
    
            verify(_G.Wrapper.print('exploit_attempted_log_message'))
            verify(playerMock.kick('exploit_attempted_kick_message'))
            verifyNoCall(playerMock.addMoney())
        end)
    end)
    
    insulate('abortRoute', function()
        it('removes money when player is busdriver', function()
            local playerMock = setUpTestWithPlayerJobSetTo('busdriver')

            getFunctionFromNativeCall('AddEventHandler', 'blarglebus:abortRoute')(1000)
    
            verify(playerMock.removeMoney(1000))
            verifyNoCall(_G.print(any()))
            verifyNoCall(playerMock.kick(any()))
        end)
    end)

    insulate('abortRoute', function()
        it('abortRoute - kicks player when not busdriver', function()
            local playerMock = setUpTestWithPlayerJobSetTo('miner')

            getFunctionFromNativeCall('AddEventHandler', 'blarglebus:abortRoute')(1000)
    
            verify(_G.Wrapper.print('exploit_attempted_log_message'))
            verify(playerMock.kick('exploit_attempted_kick_message'))
            verifyNoCall(playerMock.removeMoney())
        end)
    end)

    function setUpTestWithPlayerJobSetTo(jobName)
        local playerMock = mockagne.getMock()
        playerMock.job = {name = jobName}
        when(esx.GetPlayerFromId('source')).thenAnswer(playerMock)
    
        return playerMock
    end

    function getFunctionFromNativeCall(nativeName, eventName)
        return Stream.of(_G.Wrapper.stored_calls)
            .filter(function(wrapperCall) return wrapperCall.key == nativeName end)
            .filter(function(wrapperCall) return wrapperCall.args[1] == eventName end)
            .map(function(wrapperCall) return wrapperCall.args[2] end)
            .collect()[1]
    end
end)
