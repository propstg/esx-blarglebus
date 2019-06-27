Log = {}

function Log.debug(message)
    if Config.DebugLog then
        print('Blarglebus: ' .. message)
    end
end