local ESX = exports["es_extended"]:getSharedObject()

-- Cooldowns pour empêcher l'exploit de spam
local endJobCooldown = {}

-- Give pizzas to player when starting or reloading
RegisterNetEvent('rep-pizzajob:givePizzas')
AddEventHandler('rep-pizzajob:givePizzas', function(amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        endJobCooldown[src] = nil
    end
end)

-- Remove 1 pizza and payout based on distance
RegisterNetEvent('rep-pizzajob:payoutDelivery')
AddEventHandler('rep-pizzajob:payoutDelivery', function(payout)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.addMoney(payout)
        -- Chance for a tip
        if math.random(1, 100) > (100 - Config.Payouts.tipChance) then
            local tip = math.random(Config.Payouts.tipRange.min, Config.Payouts.tipRange.max)
            xPlayer.addMoney(tip)
            xPlayer.showNotification("Vous avez reçu un pourboire de $" .. tip, "success")
        end
    end
end)

-- Clear all pizzas and give final bonus
RegisterNetEvent('rep-pizzajob:endJob')
AddEventHandler('rep-pizzajob:endJob', function(hasDeliveredAtLeastOne)
    local src = source

    -- Anti-spam : cooldown de 10 secondes par joueur
    if endJobCooldown[src] then return end
    endJobCooldown[src] = true
    SetTimeout(10000, function()
        endJobCooldown[src] = nil
    end)

    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        if hasDeliveredAtLeastOne then
            local bonus = math.random(Config.Payouts.endJobBonus.min, Config.Payouts.endJobBonus.max)
            xPlayer.addMoney(bonus)
            xPlayer.showNotification("Bonus de fin de service : $" .. bonus, "success")
        end
    end
end)
