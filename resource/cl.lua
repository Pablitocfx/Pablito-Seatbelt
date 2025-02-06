local SetEntityCoords <const> = SetEntityCoords
local SetEntityVelocity <const> = SetEntityVelocity
local ApplyDamageToPed <const> = ApplyDamageToPed

local seatbeltOn = false
local dashboardPlaying = false

SeatbeltConfig = SeatbeltConfig or {}
SeatbeltConfig.ejectspeed = SeatbeltConfig.ejectspeed or 60.0
SeatbeltConfig.SeatbeltKey = SeatbeltConfig.SeatbeltKey or 29

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if IsControlJustReleased(0, SeatbeltConfig.SeatbeltKey) then
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                seatbeltOn = not seatbeltOn
                TriggerEvent('esx:showNotification', seatbeltOn and 'Seatbelt On' or 'Seatbelt Off')
                TriggerEvent('InteractSound_CL:PlayOnOne', 'buckled', 1.0)
                if not seatbeltOn and GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) > 1 then
                    TriggerEvent('InteractSound_CL:PlayOnOne', 'dashboard', 1.0)
                    dashboardPlaying = true
                else
                    TriggerEvent('InteractSound_CL:Stop', 'dashboard')
                    dashboardPlaying = false
                end
            end
        end

        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local speed = GetEntitySpeed(vehicle) * 2.236936

            if speed > 1 and not seatbeltOn and not dashboardPlaying then
                TriggerEvent('InteractSound_CL:PlayOnOne', 'dashboard', 1.0)
                dashboardPlaying = true
            elseif speed <= 1 and dashboardPlaying then
                TriggerEvent('InteractSound_CL:Stop', 'dashboard')
                dashboardPlaying = false
            end

            if speed >= SeatbeltConfig.ejectspeed and not seatbeltOn then
                local prevVelocity = GetEntityVelocity(vehicle)
                Citizen.Wait(100)
                local newVelocity = GetEntityVelocity(vehicle)
                local deltaSpeed = math.abs(newVelocity.x - prevVelocity.x) + math.abs(newVelocity.y - prevVelocity.y) + math.abs(newVelocity.z - prevVelocity.z)

                if deltaSpeed > 10 then
                    TriggerServerEvent('fl_core:server:checkSeatbelt', speed, seatbeltOn)
                end
            end

            if seatbeltOn then
                DisableControlAction(0, 75, true)
            end
        else
            if dashboardPlaying then
                TriggerEvent('InteractSound_CL:Stop', 'dashboard')
                dashboardPlaying = false
            end
        end

        if not IsPedInAnyVehicle(PlayerPedId(), false) and dashboardPlaying then
            TriggerEvent('InteractSound_CL:Stop', 'dashboard')
            dashboardPlaying = false
        end
    end
end)

RegisterNetEvent('fl_core:client:ejectPlayer', function(speed)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local coords = GetEntityCoords(ped)
    local velocity = GetEntityVelocity(vehicle)

    SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, true, true, true, false)
    SetEntityVelocity(ped, velocity.x, velocity.y, velocity.z)
    
    ApplyDamageToPed(ped, 200, false)
    TriggerEvent('InteractSound_CL:PlayOnOne', 'eject', 1.0)
end)
