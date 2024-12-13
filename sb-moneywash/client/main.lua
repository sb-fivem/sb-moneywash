local QBCore = exports['qb-core']:GetCoreObject()

local isPlacingWasher = false
local currentWasher = nil
local washerPlaced = false
local washerUses = 0
local rotation = 0

local function spawnWasher(coords)
    local model = GetHashKey("prop_washer_02")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end

    local washer = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    SetEntityAsMissionEntity(washer, true, true)
    SetEntityCollision(washer, false, false)
    SetEntityAlpha(washer, 51, false)
    PlaceObjectOnGroundProperly(washer)
    return washer
end

RegisterNetEvent("laundry:startPlacingWasher")
AddEventHandler("laundry:startPlacingWasher", function()
    if isPlacingWasher or washerPlaced then return end
    isPlacingWasher = true
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    Citizen.CreateThread(function()
        local tempWasher = spawnWasher(playerCoords + vector3(1.5, 0, 0))
        FreezeEntityPosition(tempWasher, true)

        while isPlacingWasher do
            Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local forwardOffset = GetEntityForwardVector(playerPed) * 1.5
            local coords = playerCoords + forwardOffset
            SetEntityCoords(tempWasher, coords.x, coords.y, coords.z, false, false, false, true)

            if IsControlPressed(0, 174) then
                rotation = rotation - 1
            elseif IsControlPressed(0, 175) then
                rotation = rotation + 1
            end

            local rotationMatrix = GetEntityRotation(playerPed, 2)
            local newRotation = rotationMatrix.z + rotation
            SetEntityHeading(tempWasher, newRotation)

            DrawText3D(coords.x, coords.y, coords.z + 1.0, "[E] Place Washer | [C] Cancel | Left/Right Arrow to Rotate")

            if IsControlJustReleased(0, 38) then
                isPlacingWasher = false
                PlaceObjectOnGroundProperly(tempWasher)
                FreezeEntityPosition(tempWasher, true)
                SetEntityCollision(tempWasher, true, true)
                SetEntityAlpha(tempWasher, 255, false)
                currentWasher = tempWasher
                washerPlaced = true
                washerUses = 0
                TriggerEvent("laundry:setupWasher", currentWasher)
            elseif IsControlJustReleased(0, 26) then
                isPlacingWasher = false
                DeleteEntity(tempWasher)
            end
        end
    end)
end)

RegisterNetEvent("laundry:setupWasher")
AddEventHandler("laundry:setupWasher", function(washer)
    if not washer then
        print("Error: Washer entity is nil.")
        return
    end

    exports['qb-target']:AddTargetEntity(washer, {
        options = {
            {
                label = "Clean Dirty Money",
                action = function()
                    if washerUses < 3 then
                        TriggerServerEvent("laundry:processMoney")
                        washerUses = washerUses + 1
                        TriggerEvent("QBCore:Notify", "Washer use #" .. washerUses, "info")

                        if washerUses >= 3 then
                            TriggerServerEvent("laundry:removeWasher")
                            DeleteEntity(washer)
                            washerPlaced = false
                            TriggerEvent("QBCore:Notify", "Washer has broken!", "error")
                        end
                    else
                        TriggerEvent("QBCore:Notify", "Washer has broken!", "error")
                    end
                end,
            },
            {
                label = "Pick Up Washer",
                action = function()
                    if washerUses < 3 then
                        DeleteEntity(washer)
                        washerPlaced = false
                        TriggerEvent("QBCore:Notify", "Washer picked up", "success")
                    else
                        TriggerEvent("QBCore:Notify", "Washer has already broken and cannot be picked up", "error")
                    end
                end,
            }
        },
        distance = 2.0
    })
end)

function DrawText3D(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
