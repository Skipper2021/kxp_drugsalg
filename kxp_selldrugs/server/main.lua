ESX = nil

ESX = exports["es_extended"]:getSharedObject()


lib.callback.register('kxp_drugsalg:recieveinventory', function(source)
    local id = ESX.GetPlayerFromId(source)
    local inventar = {}

    for k, v in pairs(Config.Drugs) do
        table.insert(inventar, {
            drug = k, 
            amount = id.getInventoryItem(k).count
        })
    end

    Wait(50)
    
    return inventar
end)

RegisterNetEvent('kxp_drugsalg:sell', function(drug, zone)
    local src = source
    local id = ESX.GetPlayerFromId(src)
    local fjern = Config.Options.MinMax
    local reward = math.random(Config.Drugs[drug].Pris) * fjern
    if id.getInventoryItem(drug).count >= fjern then
        id.removeInventoryItem(drug, fjern)
        if Config.Options.DirtyMoney then
            id.addAccountMoney(Config.Options.DirtyAccount, reward)
            Log('ID: '..id.identifier..' modtog '..reward..' DKK i sorte penge for at sælge '..fjern..'x '..drug)
        else
            id.addMoney(reward)
            Log('ID: '..id.identifier..' modtog '..reward..' DKK i kontanter for at sælge '..fjern..'x '..drug)
        end
    else
    end
    TriggerClientEvent('sold', source, reward, drug)
    TriggerClientEvent('kxp_drugsalg:notify', src, Lang['drugs_sold']:format(fjern, drug, reward), 'success')
end)

-------------------
-- Politi Notify --
-------------------

--[[RegisterNetEvent('kxp_drugsalg:kontaktPoliti', function(x, y, z)
    local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
    local street = GetStreetNameAtCoord(plyPos.x, plyPos.y, plyPos.z)
    
    if street ~= nil and street ~= "" then
        local navnSted = GetStreetNameFromHashKey(street)
        
        for _, v in pairs(ESX.GetPlayers()) do
            local id = ESX.GetPlayerFromId(v)
            Wait(10)
            
            if id.source ~= nil and id.job == Config.PoliceOptions.Job then
                TriggerClientEvent('kxp_drugsalg:salgigang', id.source, navnSted)
            end
        end
    else
        print("Ugyldige koordinater eller ingen gadenavn fundet.")
    end
end)]]



---------------
-- Functions --
---------------

function Log(msg)
    local embeds = {
        {
            ["color"] = "8663711",
            ["title"] = "Logging",
            ["description"] = msg,
            ["footer"] = {
              ["text"] = "kxp-resources",
          },
        }
  }
  PerformHttpRequest(Config.Options.Webhook, function(err, text, headers) end, 'POST', json.encode({username = 'KXP - Store', embeds = embeds, avatar_url = 'https://cdn.discordapp.com/attachments/1117876925059305533/1120713383289831544/pokexkian_128x128.png'}), { ['Content-Type'] = 'application/json' })
end

