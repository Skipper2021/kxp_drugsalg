Config = {

    Options = {
        DirtyMoney = true, -- Skal man modtage sorte penge (true/false) - Hvis false får du kontanter
        DirtyAccount = 'black_money', -- Account til sorte penge
        Webhook = 'https://discord.com/api/webhooks/1132529904257355936/jRWAGilC7qt8SaJ8d7h8MfyoXRtGHjv1o3hm1FszYQpz5ikH8bcewg5CFjQXORhweSLc', -- Webhook til logs af scriptet
        OpenCommand = true, -- Skal man kunne åbne salgs menuen via. command (true/false)
        KeyMapping = false, -- Hotkey til at åbne salgsmenuen (true/false)
        Command = 'drugsalg', -- Command til at starte salg
        MinMax = math.random(1,5), -- Vælg minimum og maksimum antal af stoffer der kan sælges
        MinDrugs = 1, -- Minimum antal stoffer man skal have på sig for at kunne starte salg
        BuyChance = 20, -- Købschance i procent
    },
    
    PoliceOptions = {
        Job = 'police', -- Politi job
        CallChance = 50, -- Chance 0/100 i % for at politiet bliver kontaktet
    },
    
    
    Drugs = {
        ['coke_pooch'] = { -- Skriv drugspawnkoden ind her
            Pris = 150, 300, -- Min og max pris pr. stk
            Label = 'Kokain', -- Label altså hvad kaldes itemmet?
        },
        ['meth_pooch'] = {
            Pris = 150, 375,
            Label = 'Crystal-Meth',
        },
        ['weed_pooch'] = {
            Pris = 150, 300,
            Label = 'Hash',
        },
        ['opium_pooch'] = {
            Pris = 150, 375,
            Label = 'Heroin',
        },
    },
    
    }
    
    
    Lang = { -- Oversæt og ændre formuleringer efter eget ønske
        ['menu_title'] = 'Narkotika Salg',
        ['drug_menu_title'] = 'Vælg et stof',
        ['did_not_choose'] = 'Du valgte ikke',
        ['started_selling'] = 'Du har valgt at sælge: %s',
        ['sale_stopped'] = 'Du stoppede salg af %s',
        ['already_sold'] = 'Du har allerede snakket med vedkommende.',
        ['drugs_sold'] = 'Du solgte %s %s for %s DKK',
        ['did_not_want_to_buy'] = 'Personen ønskede ikke at købe af dig',
        ['contacted_police'] = 'Personen kontaktet politiet!',
        -- Keymapping
        ['keymap_description'] = 'Start salg af narkotika',
    }
    
    function Notify(msg, type) -- Notify    -- Mulighed for at opsætte til eget notify
        lib.notify({
            title = 'Narkotika',
            description = msg,
            type = type,
            position = 'center-right',
        })
    end
    
    function PolitiNotify(x,y,z, streetname, zone) -- Notify til politi kan sættes op til dit eget
        local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
        local street = GetStreetNameAtCoord(plyPos.x, plyPos.y, plyPos.z)
        local navnSted = GetStreetNameFromHashKey(street)
        TriggerServerEvent('kxp_drugsalg:kontaktPoliti', navnSted)
    end