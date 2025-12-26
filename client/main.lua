local QBCore = nil
local qbx = nil

-- Framework Detection
if GetResourceState('qbx_core') == 'started' then
    qbx = exports.qbx_core
elseif GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function GetStatus()
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped) - 100
    local armor = GetPedArmour(ped)
    local hunger = 100
    local thirst = 100
    local stress = 0

    if qbx then
        local data = qbx:GetPlayerData()
        if data and data.metadata then
            hunger = data.metadata.hunger
            thirst = data.metadata.thirst
            stress = data.metadata.stress
        end
    elseif QBCore then
        local data = QBCore.Functions.GetPlayerData()
        if data and data.metadata then
            hunger = data.metadata.hunger
            thirst = data.metadata.thirst
            stress = data.metadata.stress
        end
    end

    -- Clamp values
    if health < 0 then health = 0 end
    if health > 100 then health = 100 end

    return {
        health = health,
        armor = armor,
        hunger = hunger,
        thirst = thirst,
        stress = stress
    }
end

-- Main Update Loop
CreateThread(function()
    while true do
        Wait(200) -- 5 times a second for responsiveness

        local status = GetStatus()

        SendNUIMessage({
            action = 'updateStatus',
            data = status
        })
    end
end)

-- Send Config to UI on startup
CreateThread(function()
    Wait(1000) -- Small delay to ensure UI is ready
    SendNUIMessage({
        action = 'setupConfig',
        data = Config
    })
end)

-- Visibility Loop (Hide in Pause Menu)
CreateThread(function()
    local lastPauseState = false
    while true do
        Wait(500)
        local isPaused = IsPauseMenuActive()
        if isPaused ~= lastPauseState then
            lastPauseState = isPaused
            SendNUIMessage({
                action = 'setVisible',
                data = not isPaused
            })
        end
    end
end)

-- Vehicle HUD Loop
CreateThread(function()
    print("DEBUG: Client Script Started - Vehicle Loop Init")
    local wasInVehicle = false
    while true do
        Wait(100) -- Check 10 times a second

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            -- Gather Data
            local speed = GetEntitySpeed(vehicle) * 3.6 -- km/h
            local fuel = GetVehicleFuelLevel(vehicle)
            local rpm = GetVehicleCurrentRpm(vehicle)
            local gear = GetVehicleCurrentGear(vehicle)

            -- Prepare data
            local data = {
                show = true,
                speed = speed,
                fuel = fuel,
                rpm = rpm,
                gear = gear
            }

            -- Send
            SendNUIMessage({
                action = 'updateVehicle',
                data = data
            })

            wasInVehicle = true
        else
            if wasInVehicle then
                SendNUIMessage({
                    action = 'updateVehicle',
                    data = { show = false }
                })
                wasInVehicle = false
            end
            Wait(500) -- Slower check when not in vehicle
        end
    end
end)

-- Debug Command
RegisterCommand("huddebug", function()
    print("Sending Test Vehicle Data")
    SendNUIMessage({
        action = 'updateVehicle',
        data = {
            show = true,
            speed = 120,
            fuel = 75,
            rpm = 0.8,
            gear = 3
        }
    })
end, false)

-- Info HUD Loop (Time, Job, Cash)
CreateThread(function()
    while true do
        Wait(1000) -- Update every second

        local jobName = "Unemployed"
        local cashAmount = 0
        local timeText = "00:00"

        -- Get Game Time
        local hours = GetClockHours()
        local minutes = GetClockMinutes()
        timeText = string.format("%.2d:%.2d", hours, minutes)

        -- Get Player Data
        if qbx then
            local data = qbx:GetPlayerData()
            if data then
                if data.job then
                    jobName = (data.job.label or "Unknown") .. " - " .. (data.job.grade.name or "None")
                end
                if data.money then
                    cashAmount = data.money.cash or 0
                end
            end
        elseif QBCore then
            local data = QBCore.Functions.GetPlayerData()
            if data then
                if data.job then
                    jobName = (data.job.label or "Unknown") .. " - " .. (data.job.grade.name or "None")
                end
                if data.money then
                    cashAmount = data.money.cash or 0
                end
            end
        end

        -- Simple currency formatting
        local formattedCash = "$"
        local k = 1
        local strCash = tostring(cashAmount)
        while true do
            formattedCash = string.sub(strCash, -3 * k, -3 * k + 2) .. (k > 1 and "," or "") .. formattedCash
            if string.len(strCash) <= 3 * k then
                local remaining = string.sub(strCash, 1, string.len(strCash) - 3 * k)
                if remaining ~= "" then
                    formattedCash = remaining .. "," .. string.sub(formattedCash, 1, -2)
                else
                    formattedCash = string.sub(formattedCash, 1, -2)
                end
                break
            end
            k = k + 1
        end
        -- Fallback if regex logic is too complex for simple impl, just use raw for now to be safe from inf loops
        formattedCash = "$" .. cashAmount

        SendNUIMessage({
            action = 'updateInfo',
            data = {
                time = timeText,
                cash = formattedCash,
                job = jobName
            }
        })
    end
end)
