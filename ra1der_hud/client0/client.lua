Show = false
PlayerData = {}
isLoggedIn = false
inVehicle = false
playerPed = 0
pauseMenuState, lastpauseMenuState = 0, 0
bilgiler = {}

ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
  DisplayRadar(false)
end)

local hunger = 0
local thrist = 0
local stres = 0
local sesSeviyesi = 1
local bigMap = false
local onMap = false
local minimap = nil

function UIStuff()
    Citizen.CreateThread(function()
        while isLoggedIn do
            SendNUIMessage({
                action = 'tick',
                show = IsPauseMenuActive(),
                health = (GetEntityHealth(playerPed)-100),
                armor = GetPedArmour(playerPed),
                oxy = GetPlayerUnderwaterTimeRemaining(PlayerId()),
            })
            Citizen.Wait(200)
        end
    end)
    
    Citizen.CreateThread(function()
        minimap = RequestScaleformMovie("minimap")
        SetRadarBigmapEnabled(true, false)
        Citizen.Wait(200)
        SetRadarBigmapEnabled(false, false)

        while Show do
            Citizen.Wait(500)
            pauseMenuState = GetPauseMenuState()
            if pauseMenuState ~= lastpauseMenuState then
                lastpauseMenuState = pauseMenuState
                removeHealthBar()
            end

            playerPed = PlayerPedId()
            inVehicle = IsPedInAnyVehicle(playerPed, false) and not IsVehicleModel(GetVehiclePedIsIn(playerPed, false), `wheelchair`)
            if inVehicle and not onMap then
                SetPedConfigFlag(playerPed, 35, false)
                onMap = true
                if not bigMap then DisplayRadar(true) end
                removeHealthBar()
            elseif not inVehicle and onMap then
                onMap = false
                if not bigMap then DisplayRadar(false) end
                removeHealthBar()
            end
            
        end
    end)
end

function removeHealthBar()
    BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()
end

Citizen.CreateThread(function()
	while true do
		TriggerEvent('esx_status:getStatus', 'hunger', function(hunger)
			TriggerEvent('esx_status:getStatus', 'thirst', function(thirst)
			SetPedMaxTimeUnderwater(playerPed, 40.0)
			local myhunger = hunger.getPercent()
            local mythirst = thirst.getPercent()
		    SendNUIMessage({
				action = "updateStatus",
				st = {yemek = myhunger, su = mythirst},
			})	
			end)		
		end)
		Citizen.Wait(5000)
	end
end)

exports('setVoipMode', function(seviye)
    if seviye == 2.5 then
        SendNUIMessage({action = 'ses-0'})
    elseif seviye == 7.0 then
        SendNUIMessage({action = 'ses-1'})
    elseif seviye == 15.0 then
        SendNUIMessage({action = 'ses-2'})
    end
end)

exports('setVoipRadioMode', function(status)
    if status then
        SendNUIMessage({action = 'ses-aktif-telsiz'})
    elseif not status then
        SendNUIMessage({action = 'ses-pasif'})
    end
end)

local normalKonusmaAktif = false
RegisterNetEvent('SaltyChat_TalkStateChanged')
AddEventHandler('SaltyChat_TalkStateChanged', function(status)
    if status and not normalKonusmaAktif then
        normalKonusmaAktif = true
        SendNUIMessage({action = 'ses-aktif'})
    elseif not status and normalKonusmaAktif then
        normalKonusmaAktif = false
        SendNUIMessage({action = 'ses-pasif'})
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    PlayerData = ESX.GetPlayerData()
    SendNUIMessage({action = 'showui'})
    isLoggedIn = true
    Show = true
    UIStuff()
    Citizen.Wait(10000)
end)

AddEventHandler('playerSpawned', function()
    Citizen.Wait(8000)
    PlayerData = ESX.GetPlayerData()
    SendNUIMessage({action = 'showui'})
    isLoggedIn = true
    Show = true
    UIStuff()
end)

RegisterCommand('hud', function()
    TriggerEvent('ra1der_hud:open-hud')
end)

RegisterCommand('hudfix', function(source)
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })
    end)

RegisterNetEvent('ra1der_hud:open-hud')
AddEventHandler('ra1der_hud:open-hud', function()
    if not Show then
        PlayerData = ESX.GetPlayerData()
        TriggerEvent("ra1der_hud:load-data", GetEntityHealth(playerPed), GetPedArmour(playerPed))
        SendNUIMessage({action = 'showui'})
        UIStuff()
        isLoggedIn = true
        Show = true
    end
    SetNuiFocus(true, true)
    SendNUIMessage({action = 'showMenu'})
end)

RegisterNUICallback('close-ayar-menu', function()
    SetNuiFocus(false, false)
    ExecuteCommand("hudfix")
end)

RegisterNetEvent('ra1der_hud:load-data')
AddEventHandler('ra1der_hud:load-data', function(health, armor)
    while not isLoggedIn do 
        Citizen.Wait(1000)
    end
    local playerPed = PlayerPedId()
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    SetPedMaxTimeUnderwater(playerPed, 40.0)
    TriggerEvent('esx_status:getStatus', 'hunger', function(hunger)
	TriggerEvent('esx_status:getStatus', 'thirst', function(thirst)
    zirh = GetPedArmour(playerPed)
    heal = GetEntityHealth(playerPed)
    SetEntityMaxHealth(playerPed, 200)
    if health then
        SetEntityHealth(playerPed, health)
        SetPedArmour(playerPed, armor)
    else
        SetEntityHealth(playerPed, zirh)
        SetPedArmour(playerPed, heal)
    end
	SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
	oyuncuYulendi = true
		end)
	end)
end)

