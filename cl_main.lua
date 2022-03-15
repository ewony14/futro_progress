 futro_action = {
    name = "",
    duration = 0,
    label = "",
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    },
    animation = {
        animDict = nil,
        anim = nil,
        flags = 0,
        task = nil,
    },
    prop = {
        model = nil,
        bone = nil,
        coords = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    },
}

local isDoingAction = false
local disableMouse = false
local wasCancelled = false
local isAnim = false
local isProp = false
local prop_net = nil

function Progress(action, finish)
    futro_action = action

    if not IsEntityDead(GetPlayerPed(-1)) or futro_action.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "futro_progress",
                duration = futro_action.duration,
                label = futro_action.label
            })

            Citizen.CreateThread(function ()
                while isDoingAction do
                    Citizen.Wait(0)
                    if IsControlJustPressed(0, 178) and futro_action.canCancel then
                        TriggerEvent("futro_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            print('Action Already Performing') -- Replace with alert call if you want the player to see this warning on-screen
        end
    else
        print('Cannot do action while dead') -- Replace with alert call if you want the player to see this warning on-screen
    end
end

function ProgressWithStartEvent(action, start, finish)
    futro_action = action

    if not IsEntityDead(GetPlayerPed(-1)) or futro_action.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "futro_progress",
                duration = futro_action.duration,
                label = futro_action.label
            })

            Citizen.CreateThread(function ()
                if start ~= nil then
                    start()
                end
                while isDoingAction do
                    Citizen.Wait(1)
                    if IsControlJustPressed(0, 178) and futro_action.canCancel then
                        TriggerEvent("futro_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            print('Already Doing An Action')
        end
    else
        print('Cannot Perform An Action While Dead')
    end
end

function ProgressWithTickEvent(action, tick, finish)
    futro_action = action

    if not IsEntityDead(GetPlayerPed(-1)) or futro_action.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "futro_progress",
                duration = futro_action.duration,
                label = futro_action.label
            })

            Citizen.CreateThread(function ()
                while isDoingAction do
                    Citizen.Wait(1)
                    if tick ~= nil then
                        tick()
                    end
                    if IsControlJustPressed(0, 178) and futro_action.canCancel then
                        TriggerEvent("futro_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            print('Already Doing An Action')
        end
    else
        print('Cannot Perform An Action While Dead')
    end
end

function ProgressWithStartAndTick(action, start, tick, finish)
    futro_action = action

    if not IsEntityDead(GetPlayerPed(-1)) or futro_action.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "futro_progress",
                duration = futro_action.duration,
                label = futro_action.label
            })

            Citizen.CreateThread(function ()
                if start ~= nil then
                    start()
                end
                while isDoingAction do
                    Citizen.Wait(1)
                    if tick ~= nil then
                        tick()
                    end
                    if IsControlJustPressed(0, 178) and futro_action.canCancel then
                        TriggerEvent("futro_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            print('Already Doing An Action')
        end
    else
        print('Cannot Perform An Action While Dead')
    end
end

RegisterNetEvent("futro_progress:client:progress")
AddEventHandler("futro_progress:client:progress", function(action, finish)
    Progress(action, finish)
end)

RegisterNetEvent("futro_progress:client:ProgressWithStartEvent")
AddEventHandler("futro_progress:client:ProgressWithStartEvent", function(action, start, finish)
    ProgressWithStartEvent(action, start, finish)
end)

RegisterNetEvent("futro_progress:client:ProgressWithTickEvent")
AddEventHandler("futro_progress:client:ProgressWithTickEvent", function(action, tick, finish)
    ProgressWithTickEvent(action, tick, finish)
end)

RegisterNetEvent("futro_progress:client:ProgressWithStartAndTick")
AddEventHandler("futro_progress:client:ProgressWithStartAndTick", function(action, start, tick, finish)
    ProgressWithStartAndTick(action, start, tick, finish)
end)

RegisterNetEvent("futro_progress:client:cancel")
AddEventHandler("futro_progress:client:cancel", function()
    isDoingAction = false
    wasCancelled = true

    TriggerEvent("futro_progress:client:actionCleanup")

    SendNUIMessage({
        action = "futro_progress_cancel"
    })
end)

RegisterNetEvent("futro_progress:client:actionCleanup")
AddEventHandler("futro_progress:client:actionCleanup", function()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    StopAnimTask(ped, futro_action.animDict, futro_action.anim, 1.0)
    DetachEntity(NetToObj(prop_net), 1, 1)
    DeleteEntity(NetToObj(prop_net))
    prop_net = nil
end)

-- Disable controls while GUI open
Citizen.CreateThread(function()
    while true do
        if isDoingAction then
            if not isAnim then
                if futro_action.animation ~= nil then
                    if futro_action.animation.task ~= nil then
                        TaskStartScenarioInPlace(PlayerPedId(), futro_action.animation.task, 0, true)
                    elseif futro_action.animation.animDict ~= nil and futro_action.animation.anim ~= nil then
                        if futro_action.animation.flags == nil then
                            futro_action.animation.flags = 1
                        end

                        local player = PlayerPedId()
                        if ( DoesEntityExist( player ) and not IsEntityDead( player )) then
                            loadAnimDict( futro_action.animation.animDict )
                            TaskPlayAnim( player, futro_action.animation.animDict, futro_action.animation.anim, 3.0, 1.0, -1, futro_action.animation.flags, 0, 0, 0, 0 )     
                        end
                    else
                        TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_BUM_BIN', 0, true)
                    end
                end

                isAnim = true
            end
            if not isProp and futro_action.prop ~= nil and futro_action.prop.model ~= nil then
                RequestModel(futro_action.prop.model)

                while not HasModelLoaded(GetHashKey(futro_action.prop.model)) do
                    Citizen.Wait(0)
                end

                local pCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, 0.0)
                local modelSpawn = CreateObject(GetHashKey(futro_action.prop.model), pCoords.x, pCoords.y, pCoords.z, true, true, true)

                local netid = ObjToNet(modelSpawn)
                SetNetworkIdExistsOnAllMachines(netid, true)
                NetworkSetNetworkIdDynamic(netid, true)
                SetNetworkIdCanMigrate(netid, false)
                if futro_action.prop.bone == nil then
                    futro_action.prop.bone = 60309
                end

                if futro_action.prop.coords == nil then
                    futro_action.prop.coords = { x = 0.0, y = 0.0, z = 0.0 }
                end

                if futro_action.prop.rotation == nil then
                    futro_action.prop.rotation = { x = 0.0, y = 0.0, z = 0.0 }
                end

                AttachEntityToEntity(modelSpawn, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), futro_action.prop.bone), futro_action.prop.coords.x, futro_action.prop.coords.y, futro_action.prop.coords.z, futro_action.prop.rotation.x, futro_action.prop.rotation.y, futro_action.prop.rotation.z, 1, 1, 0, 1, 0, 1)
                prop_net = netid

                isProp = true
            end

            DisableActions(GetPlayerPed(-1))
        end
        Citizen.Wait(0)
    end
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

function DisableActions(ped)
    if futro_action.controlDisables.disableMouse then
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    end

    if futro_action.controlDisables.disableMovement then
        DisableControlAction(0, 30, true) -- disable left/right
        DisableControlAction(0, 31, true) -- disable forward/back
        DisableControlAction(0, 36, true) -- INPUT_DUCK
        DisableControlAction(0, 21, true) -- disable sprint
    end

    if futro_action.controlDisables.disableCarMovement then
        DisableControlAction(0, 63, true) -- veh turn left
        DisableControlAction(0, 64, true) -- veh turn right
        DisableControlAction(0, 71, true) -- veh forward
        DisableControlAction(0, 72, true) -- veh backwards
        DisableControlAction(0, 75, true) -- disable exit vehicle
    end

    if futro_action.controlDisables.disableCombat then
        DisablePlayerFiring(ped, true) -- Disable weapon firing
        DisableControlAction(0, 24, true) -- disable attack
        DisableControlAction(0, 25, true) -- disable aim
        DisableControlAction(1, 37, true) -- disable weapon select
        DisableControlAction(0, 47, true) -- disable weapon
        DisableControlAction(0, 58, true) -- disable weapon
        DisableControlAction(0, 140, true) -- disable melee
        DisableControlAction(0, 141, true) -- disable melee
        DisableControlAction(0, 142, true) -- disable melee
        DisableControlAction(0, 143, true) -- disable melee
        DisableControlAction(0, 263, true) -- disable melee
        DisableControlAction(0, 264, true) -- disable melee
        DisableControlAction(0, 257, true) -- disable melee
    end
end

RegisterNUICallback('actionFinish', function(data, cb)
    -- Do something here
    isDoingAction = false
    TriggerEvent("futro_progress:client:actionCleanup")
    cb('ok')
end)

RegisterNUICallback('actionCancel', function(data, cb)
    -- Do something here
    cb('ok')
end)