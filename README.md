# futro_progress
Futro Progress Bar

TriggerEvent("futro_progress:client:progress", {
        name = "akcija",
        duration = 10000,
        label = "TEXT",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "",
            anim = "",
        },
        prop = {
            model = "",
        }
    }, function(status)
        if not status then
            -- Do Something If Event Not Cancelled
        end
    end)
