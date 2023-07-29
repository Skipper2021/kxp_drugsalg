local active = false
local CurrentDrug = nil
local PlayerData = {}
local npc = {}
local Option = Config.Options
local oldPed = nil

local IsDead = false



AddEventHandler('esx:onPlayerDeath', function(data)
    IsDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
    IsDead = false
end)


RegisterNetEvent('kxp_drugsalg:toggleDealing', function()
    local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
    local street = GetStreetNameAtCoord()
    local navnSted = GetStreetNameFromHashKey(street)
    local zone = Zones[GetNameOfZone(plyPos.x, plyPos.y, plyPos.z)]

    if IsDead == true then
        lib.notify({
            title = '',
            description = 'Du kan ikke bruge dette når du er død!',
            type = 'info'
        }) 
    lib.hideContext(onExit)
    else
    local invalid = true
    if active then
        active = false
        Notify(Lang['sale_stopped']:format(CurrentDrug), 'error')
        exports.qtarget:RemovePed({'Sælg '.. Config.Drugs[CurrentDrug].Label})
        CurrentDrug = nil
    else
        lib.registerContext({
            id = 'start_menu',
            title = Lang['menu_title'],
            options = {
                {
                  title = 'Start salg',
                  description = 'Vælg hvilket stof du vil sælge',
                  menu = 'chooseDrug',
                  icon = 'money-bill'
                },
                {
                  title = 'Annuler salg',
                  description = 'Stop øjeblikkeligt salg af narkotika',
                  icon = 'stop',
                  event = 'kxp_drugsalg:toggleDealing',
                },
                {
                    title = 'Zone',
                    description = 'Du befinder dig ved ' ..zone,
                    icon = 'map-pin'
                }
            }
        })

        active = true
        lib.callback('kxp_drugsalg:recieveinventory', false, function(drugs)
            local elements = {}
                for k, v in pairs(drugs) do
                    table.insert(elements, {
                        title = Config.Drugs[v.drug].Label..' | Antal: '..v.amount,
                        arrow = true,
                        event = 'kxp_drugsalg:selectDrug',
                        args = {type = v.drug, antal = v.amount},
                        disabled = v.amount == 0
                    })
                end

            lib.registerContext({
                id = 'chooseDrug',
                title = Lang['drug_menu_title'],
                menu = 'start_menu',
                onExit = function()
                    active = false
                    Notify(Lang['did_not_choose'], 'error')
                end,
                    options = elements,
                })
        end)
    end
        lib.showContext('start_menu')
    end
end)

RegisterNetEvent('kxp_drugsalg:selectDrug', function(data)
    local antal = data.antal
    if antal >= Config.Options.MinDrugs then
        exports.qtarget:Ped({
            options = {
                {
                    event = 'kxp_drugsalg:confirm',
                    icon = 'fas fa-capsules',
                    label = 'Sælg '..Config.Drugs[data.type].Label,
                    num = 1
                },
            }, distance = 2})
        CurrentDrug = data.type
        Notify(Lang['started_selling']:format(Config.Drugs[data.type].Label), 'success')
    else
        exports.qtarget:RemovePed({'Sælg '.. Config.Drugs[data.type].Label})
        Notify('Du har ikke nok på dig, Minimum: ' .. Config.Options.MinDrugs, 'error')
        active = false
    end
end)


RegisterNetEvent('kxp_drugsalg:confirm', function(data)
    local pcoords = GetEntityCoords(PlayerPedId())

    if oldPed == data.entity then 
        Notify(Lang['already_sold'], 'error')
        return
    end

    if math.random(0, 100) >= Config.PoliceOptions.CallChance then
        local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
        local street = GetStreetNameAtCoord()
        local navnSted = GetStreetNameFromHashKey(street)
        local zone = Zones[GetNameOfZone(plyPos.x, plyPos.y, plyPos.z)]
            PolitiNotify(plyPos.x, plyPos.y, plyPos.z, street, zone)
            lib.notify({
                title = 'Drugsalg',
                position = 'center-right',
                description = Lang['contacted_police'],
                type = 'error'
            })
            oldPed = data.entity
        return
    else
        oldPed = data.entity
        SalesEmote(data.entity)
        TriggerServerEvent('kxp_drugsalg:sell', CurrentDrug, GetNameOfZone(pcoords.x, pcoords.y,pcoords.z))
    end
end)


---------------------------
-- Command og Keymapping --
---------------------------

if Option.OpenCommand then
    RegisterCommand(Option.Command, function()
        TriggerEvent('kxp_drugsalg:toggleDealing')
    end)
    if Option.KeyMapping then
        RegisterKeyMapping(Option.Command, Lang['keymap_description'], 'keyboard', 'F7')   
    end
end

----------
-- Misc --
----------

RegisterNetEvent('kxp_drugsalg:salgigang', function(streetname)
    TriggerClientEvent('outlawNotify', -1, '~r~ En ~w~person ~r~prøvede at sælge narkotika tæt på~w~ '..streetname)
end)

RegisterNetEvent('kxp_drugsalg:notify', function(msg, type)
    Notify(msg, type)
end)

function SalesEmote(entity)
    GameMakeEntityFaceEntity(PlayerPedId(), entity)
    GameMakeEntityFaceEntity(entity, PlayerPedId())
    obj = CreateObject(GetHashKey('prop_weed_bottle'), 0, 0, 0, true)
    AttachEntityToEntity(obj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
    obj2 = CreateObject(GetHashKey('hei_prop_heist_cash_pile'), 0, 0, 0, true)
    FreezeEntityPosition(entity, true)
    AttachEntityToEntity(obj2, entity, GetPedBoneIndex(entity,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
    GamePlayAnim('mp_common', 'givetake1_a', 8.0, -1, 0)
    GamePlayAnimOnPed(entity, 'mp_common', 'givetake1_a', 8.0, -1, 0)
    Wait(1000)
    AttachEntityToEntity(obj2, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
    AttachEntityToEntity(obj, entity, GetPedBoneIndex(npc.ped,  57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
    Wait(1250)
    DeleteEntity(obj)
    DeleteEntity(obj2)
    FreezeEntityPosition(entity, false)
    SetPedAsNoLongerNeeded(entity)
end

function GameMakeEntityFaceEntity(entity1, entity2)
	local p1 = GetEntityCoords(entity1, true)
	local p2 = GetEntityCoords(entity2, true)

	local dx = p2.x - p1.x
	local dy = p2.y - p1.y

	local heading = GetHeadingFromVector_2d(dx, dy)
	SetEntityHeading(entity1, heading)
end

function GamePlayAnim(dict, anim, speed, time, flag)
	GameRequestAnimDict(dict, function()
		TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1, false, false, false)
	end)
end

function GamePlayAnimOnPed(ped, dict, anim, speed, time, flag)
	GameRequestAnimDict(dict, function()
		TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
	end)
end

function GameRequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

Zones = {
    ["AIRP"] = "Los Santos International Airport",
    ["ALAMO"] = "Alamo Sea",
    ["ALTA"] = "Alta",
    ["ARMYB"] = "Fort Zancudo",
    ["BANHAMC"] = "Banham Canyon Dr",
    ["BANNING"] = "Banning",
    ["BEACH"] = "Vespucci Beach",
    ["BHAMCA"] = "Banham Canyon",
    ["BRADP"] = "Braddock Pass",
    ["BRADT"] = "Braddock Tunnel",
    ["BURTON"] = "Burton",
    ["CALAFB"] = "Calafia Bridge",
    ["CANNY"] = "Raton Canyon",
    ["CCREAK"] = "Cassidy Creek",
    ["CHAMH"] = "Chamberlain Hills",
    ["CHIL"] = "Vinewood Hills",
    ["CHU"] = "Chumash",
    ["CMSW"] = "Chiliad Mountain State Wilderness",
    ["CYPRE"] = "Cypress Flats",
    ["DAVIS"] = "Davis",
    ["DELBE"] = "Del Perro Beach",
    ["DELPE"] = "Del Perro",
    ["DELSOL"] = "La Puerta",
    ["DESRT"] = "Grand Senora Desert",
    ["DOWNT"] = "Downtown",
    ["DTVINE"] = "Downtown Vinewood",
    ["EAST_V"] = "East Vinewood",
    ["EBURO"] = "El Burro Heights",
    ["ELGORL"] = "El Gordo Lighthouse",
    ["ELYSIAN"] = "Elysian Island",
    ["GALFISH"] = "Galilee",
    ["GOLF"] = "GWC and Golfing Society",
    ["GRAPES"] = "Grapeseed",
    ["GREATC"] = "Great Chaparral",
    ["HARMO"] = "Harmony",
    ["HAWICK"] = "Hawick",
    ["HORS"] = "Vinewood Racetrack",
    ["HUMLAB"] = "Humane Labs and Research",
    ["JAIL"] = "Bolingbroke Penitentiary",
    ["KOREAT"] = "Little Seoul",
    ["LACT"] = "Land Act Reservoir",
    ["LAGO"] = "Lago Zancudo",
    ["LDAM"] = "Land Act Dam",
    ["LEGSQU"] = "Legion Square",
    ["LMESA"] = "La Mesa",
    ["LOSPUER"] = "La Puerta",
    ["MIRR"] = "Mirror Park",
    ["MORN"] = "Morningwood",
    ["MOVIE"] = "Richards Majestic",
    ["MTCHIL"] = "Mount Chiliad",
    ["MTGORDO"] = "Mount Gordo",
    ["MTJOSE"] = "Mount Josiah",
    ["MURRI"] = "Murrieta Heights",
    ["NCHU"] = "North Chumash",
    ["NOOSE"] = "N.O.O.S.E",
    ["OCEANA"] = "Pacific Ocean",
    ["PALCOV"] = "Paleto Cove",
    ["PALETO"] = "Paleto Bay",
    ["PALFOR"] = "Paleto Forest",
    ["PALHIGH"] = "Palomino Highlands",
    ["PALMPOW"] = "Palmer-Taylor Power Station",
    ["PBLUFF"] = "Pacific Bluffs",
    ["PBOX"] = "Pillbox Hill",
    ["PROCOB"] = "Procopio Beach",
    ["RANCHO"] = "Rancho",
    ["RGLEN"] = "Richman Glen",
    ["RICHM"] = "Richman",
    ["ROCKF"] = "Rockford Hills",
    ["RTRAK"] = "Redwood Lights Track",
    ["SANAND"] = "San Andreas",
    ["SANCHIA"] = "San Chianski Mountain Range",
    ["SANDY"] = "Sandy Shores",
    ["SKID"] = "Mission Row",
    ["SLAB"] = "Stab City",
    ["STAD"] = "Maze Bank Arena",
    ["STRAW"] = "Strawberry",
    ["TATAMO"] = "Tataviam Mountains",
    ["TERMINA"] = "Terminal",
    ["TEXTI"] = "Textile City",
    ["TONGVAH"] = "Tongva Hills",
    ["TONGVAV"] = "Tongva Valley",
    ["VCANA"] = "Vespucci Canals",
    ["VESP"] = "Vespucci",
    ["VINE"] = "Vinewood",
    ["WINDF"] = "Ron Alternates Wind Farm",
    ["WVINE"] = "West Vinewood",
    ["ZANCUDO"] = "Zancudo River",
    ["ZP_ORT"] = "Port of South Los Santos",
    ["ZQ_UAR"] = "Davis Quartz"
}

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        if active == true then
            lib.notify({
                id = 'some_identifier',
                title = '',
                description = 'Drugsalg blev stoppet af en dev. Skriv /drugsalg for at starte igen.',
                type = 'info'
            }) 
        lib.hideContext(onExit)
        active = false
        end
	end
end)