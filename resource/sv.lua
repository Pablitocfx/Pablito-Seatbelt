local RegisterNetEvent <const> = RegisterNetEvent
local TriggerClientEvent <const> = TriggerClientEvent

RegisterNetEvent('fl_core:server:checkSeatbelt', function(speed, isBuckled)
    local source = source
    if speed >= Config.EjectSpeed and not isBuckled then
        TriggerClientEvent('fl_core:client:ejectPlayer', source, speed)
    end
end)

