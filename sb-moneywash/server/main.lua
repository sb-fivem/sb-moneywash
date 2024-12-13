local QBCore = exports["qb-core"]:GetCoreObject()

QBCore.Functions.CreateUseableItem(
    "washer_key",
    function(source)
        TriggerClientEvent("laundry:startPlacingWasher", source)
    end
)

RegisterNetEvent(
    "laundry:processMoney",
    function()
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local markedBills = Player.Functions.GetItemByName("markedbills")

        if markedBills and markedBills.amount > 0 then
            local cleanCash = math.floor(markedBills.amount * 0.8)
            Player.Functions.RemoveItem("markedbills", markedBills.amount)
            Player.Functions.AddMoney("cash", cleanCash)
            TriggerClientEvent(
                "QBCore:Notify",
                src,
                "You cleaned $" .. markedBills.amount .. " into $" .. cleanCash,
                "success"
            )
        else
            TriggerClientEvent("QBCore:Notify", src, "You have no marked bills!", "error")
        end
    end
)

RegisterNetEvent(
    "laundry:removeWasher",
    function()
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)

        local washerItem = Player.Functions.GetItemByName("washer_key")
        if washerItem and washerItem.amount > 0 then
            Player.Functions.RemoveItem("washer_key", 1)
            TriggerClientEvent(
                "QBCore:Notify",
                src,
                "The washer has broken and was removed from your inventory",
                "error"
            )
        else
            TriggerClientEvent("QBCore:Notify", src, "You do not have a washer in your inventory", "error")
        end
    end
)
