ESX = nil
local Status, isPaused = {}, false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
	Status = {
		hunger = 100,
		thirst = 100,
		stress = 0
	}
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(Config.TickTime)
			TriggerEvent('esx_status:remove', 'hunger', 0.045)
			TriggerEvent('esx_status:remove', 'thirst', 0.045)

			local playerPed  = PlayerPedId()
			local prevHealth = GetEntityHealth(playerPed)
			local health     = prevHealth

			if Status.hunger <= 0 then
				if prevHealth <= 150 then
					health = health - 5
				else
					health = health - 1
				end
			end

			if Status.thirst <= 0 then
				if prevHealth <= 150 then
					health = health - 5
				else
					health = health - 1
				end
			end

			if health ~= prevHealth then
				SetEntityHealth(playerPed, health)
			end
			TriggerEvent('reka:hud:client:sendStatus', Status)
		end
	end)
	-- Citizen.CreateThread(function()
	-- 	while true do
	-- 		Citizen.Wait(3000)
	-- 		if Status.stress > 75 then
	-- 			screenBlur()
	-- 			-- print(sikismis)
	-- 			Citizen.Wait(10000)
	-- 		elseif Status.stress > 55 then
	-- 			screenBlur()
	-- 			-- print(sikismis)
	-- 			Citizen.Wait(20000)
	-- 		elseif Status.stress > 35 then 
	-- 			screenBlur() 
	-- 			-- print(sikismis)
	-- 			Citizen.Wait(30000)
	-- 		elseif Status.stress > 15 then 
	-- 			screenBlur()
	-- 			-- print(sikismis)
	-- 			Citizen.Wait(40000)
	-- 		else
	-- 			Citizen.Wait(1000)
	-- 		end
	-- 	end
	-- end)
end)

function screenBlur()
    DoScreenFadeOut(2500)
    Citizen.Wait(2350)
    DoScreenFadeIn(1500)
end

RegisterNetEvent('esx_status:set')
AddEventHandler('esx_status:set', function(name, val)
	if val > 100 then
		val = 100
	end
	Status[name] = val
end)

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
	if Status[name] ~= nil then
		if Status[name] + val > 100 then
			Status[name] = 100
		else
			Status[name] = Status[name] + val
		end
	end
end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
	if Status[name] ~= nil then
		if Status[name] - val < 0 then
			Status[name] = 0
		else
			Status[name] = Status[name] - val
		end
	end
end)

function getStatus(type)
	if Status[type] == nil then
		return 100
	else
		return Status[type]
	end
end