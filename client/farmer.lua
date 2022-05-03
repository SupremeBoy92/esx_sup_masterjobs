ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	CreateFarmerBlip()
	ESX.PlayerData = ESX.GetPlayerData()
end)

--------------------------------------------------------------------------------

local JobStart = Farmer.Farmer.JobStart
local Cloakroom = Farmer.Farmer.Cloakroom
local Container = Farmer.Farmer.Container
local Vehicle = Farmer.Farmer.Vehicle
local Payout = Farmer.Farmer.Payout
local PlayerData = {}
local lock, JobStarted, clothes, vegetable, block, CreateMarkerJob = false, false, false, false, false, false
local Type
local done, AmountPayout = 0, 0
local TractorFuera = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
	CreateFarmerBlip()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	CreateFarmerBlip()
end)


Citizen.CreateThread(function()
	while true do
		local sleep = 500
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Farmer.Job then
			if(GetDistanceBetweenCoords(coords, JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z, true) < 8.0) and not JobStarted then
				sleep = 5

				DrawMarker(JobStart.Type, JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, JobStart.Size.x, JobStart.Size.y, JobStart.Size.z, JobStart.Color.r, JobStart.Color.g, JobStart.Color.b, 100, false, true, 2, false, false, false, false)
				DrawMarker(29, JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z+0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 143, 235, 77, 100, false, true, 2, false, false, false, false)
				if(GetDistanceBetweenCoords(coords, JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z, true) < 1.5) then
					DrawText3Ds(JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z+1.4, 'Presiona [E] para iniciar el trabajo')
				end	
			elseif(GetDistanceBetweenCoords(coords, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, true) < 8.0) and JobStarted then
				sleep = 5

				DrawMarker(Cloakroom.Type, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Cloakroom.Size.x, Cloakroom.Size.y, Cloakroom.Size.z, Cloakroom.Color.r, Cloakroom.Color.g, Cloakroom.Color.b, 100, false, true, 2, false, false, false, false)
				DrawMarker(30, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z+0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
				if(GetDistanceBetweenCoords(coords, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, true) < 1.5) then
					if not clothes then
						DrawText3Ds(Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z+1.4, 'Presiona [E] para cambiarse a la ropa de Trabajo')
					elseif clothes then
						DrawText3Ds(Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z+1.4, 'Presiona [E] para cambiarse a la ropa de Civil')
					end	
				end	
			elseif(GetDistanceBetweenCoords(coords, Container.Pos.x, Container.Pos.y, Container.Pos.z, true) < 8.0) and clothes then
				sleep = 5

				if(GetDistanceBetweenCoords(coords, Container.Pos.x, Container.Pos.y, Container.Pos.z, true) < 1.5) and not vegetable then
					DrawText3Ds(Container.Pos.x, Container.Pos.y, Container.Pos.z+1.4, 'Presiona [E] para tomar los vegetales')
				end
			end
		end
	Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 500
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Farmer.Job then
		if(GetDistanceBetweenCoords(coords, JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z, true) < 1.5) and not JobStarted then
			sleep = 0

			if IsControlJustReleased(0, Keys['E']) and not IsPedInAnyVehicle(ped, false) then
				exports.pNotify:SendNotification({text = '<b>Granjero</b></br>El trabajo ha empezado, ve al Almacen!', timeout = 1500})
				JobStarted = true
				WarehouseBlip()
			elseif IsControlJustReleased(0, Keys['E']) and IsPedInAnyVehicle(ped, false) then
				exports.pNotify:SendNotification({text = '<b>Granjero</b></br>deja el Vehiculo!', timeout = 1500})
			end
		elseif(GetDistanceBetweenCoords(coords, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, true) < 1.5) and JobStarted then
			sleep = 0

			if IsControlJustReleased(0, Keys['E']) and not clothes and not IsPedInAnyVehicle(ped, false) then
				exports.rprogress:Custom({
					Duration = 2500,
					Label = "Cambiandose la Ropa...",
					Animation = {
						scenario = "WORLD_HUMAN_COP_IDLES", -- https://pastebin.com/6mrYTdQv
						animationDictionary = "idle_a", -- https://alexguirre.github.io/animations-list/
					},
					DisableControls = {
						Mouse = false,
						Player = true,
						Vehicle = true
					}
				})
				Citizen.Wait(2500)
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, Farmer.Clothes.male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, Farmer.Clothes.female)
					end
					clothes = true
					exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Ve al contenedor!', timeout = 1500})
					ContainerBlip()
				end)				
			elseif IsControlJustReleased(0, Keys['E']) and clothes and not IsPedInAnyVehicle(ped, false)  then
				exports.rprogress:Custom({
					Duration = 3000,
					Label = "Cambiandose la Ropa...",
					Animation = {
						scenario = "WORLD_HUMAN_COP_IDLES", -- https://pastebin.com/6mrYTdQv
						animationDictionary = "idle_a", -- https://alexguirre.github.io/animations-list/
					},
					DisableControls = {
						Mouse = false,
						Player = true,
						Vehicle = true
					}
				})
				Citizen.Wait(3000)
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
					clothes = false
					RemoveBlip(Containerblip)
					RemoveBlip(FarmBlip)
					CreateMarkerJob = false
					vegetable = false
					done = 0
					for i, v in ipairs(Farmer.CucumbersPositions) do
						v.planted = false
						RemoveBlip(v.blip)
					end
					for i, v in ipairs(Farmer.LettucePositions) do
						v.planted = false
						RemoveBlip(v.blip)
					end	
					for i, v in ipairs(Farmer.PotatoesPositions) do
						v.planted = false
						RemoveBlip(v.blip)
					end					
				end)				
			elseif IsControlJustReleased(0, Keys['E']) and clothes and IsPedInAnyVehicle(ped, false) then 
				exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Deja el vehiculo!', timeout = 1500})
			end
		elseif(GetDistanceBetweenCoords(coords, Container.Pos.x, Container.Pos.y, Container.Pos.z, true) < 1.5) and clothes then
			sleep = 0

			if IsControlJustReleased(0, Keys['E']) and not vegetable and not IsPedInAnyVehicle(ped, false) then
				vegetable = true
				exports.rprogress:Custom({
					Duration = 5000,
					Label = "Recolectando Vegetales...",
					Animation = {
						scenario = "WORLD_HUMAN_CLIPBOARD", -- https://pastebin.com/6mrYTdQv
						animationDictionary = "idle_a", -- https://alexguirre.github.io/animations-list/
					},
					DisableControls = {
						Mouse = false,
						Player = true,
						Vehicle = true
					}
				})
				Citizen.Wait(5000)
				RemoveBlip(Containerblip)
				VegetableType = Randomize(Farmer.Farms)	
				exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Hoy plantaremos '..VegetableType.FarmName, timeout = 1500})
				if not TractorFuera then
					ESX.Game.SpawnVehicle(Farmer.Tractor, Vehicle.Pos, Vehicle.Heading)
					TractorFuera = true
				end
				CreateFarmBlip(VegetableType)
				lock = false
				StartLoop()
			elseif IsControlJustReleased(0, Keys['E']) and not vegetable and IsPedInAnyVehicle(ped, false) then 
				exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Deja el Vehiculo!', timeout = 1500})
			end
		elseif(GetDistanceBetweenCoords(coords, Vehicle.Deleter.x, Vehicle.Deleter.y, Vehicle.Deleter.z, true) < 5) and IsPedInAnyVehicle(ped, true) then
			sleep = 0
			DrawMarker(27, Vehicle.Deleter.x, Vehicle.Deleter.y, Vehicle.Deleter.z-0.9, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 100, false, true, 2, false, false, false, false)
			if (GetDistanceBetweenCoords(coords, Vehicle.Deleter.x, Vehicle.Deleter.y, Vehicle.Deleter.z, true) < 3) and IsPedInAnyVehicle(ped, true) then
				ESX.Supreme3DText(Vehicle.Deleter, "Pulsa ~y~E~w~ para guardar el ~r~vehiculo~w~.")
				if IsControlJustReleased(0, Keys['E']) and IsPedInAnyVehicle(ped, true) then
					local vehicle = GetVehiclePedIsIn(ped, false)
					TaskLeaveVehicle(ped, vehicle, 0)
					FreezeEntityPosition(vehicle, true)
					exports.rprogress:Custom({
						Duration = 2000,
						Label = "Guardando el vehiculo",
						Animation = {
							scenario = "", -- https://pastebin.com/6mrYTdQv
							animationDictionary = "", -- https://alexguirre.github.io/animations-list/
						},
						DisableControls = {
							Mouse = false,
							Player = true,
							Vehicle = true
						}
					})
					Citizen.Wait(2000)
					NetworkFadeOutEntity(vehicle, true, true)
					Citizen.Wait(1000)
					DeleteVehicle(vehicle)
					TractorFuera = false
				end
			end

		end
	end
	Citizen.Wait(sleep)
	end
end)

function StartLoop()
	while true and not lock do
		local sleep = 500
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		if(GetDistanceBetweenCoords(coords, VegetableType.x, VegetableType.y, VegetableType.z, true) < 20) and vegetable then
			sleep = 5
			lock = true
			RemoveBlip(FarmBlip)
			CreateWork(VegetableType.FarmName)
		end
		Citizen.Wait(sleep)
	end
end

function CreateWork(type)

		if type == "Pepinos" then
			for i, v in ipairs(Farmer.CucumbersPositions) do
				v.blip = AddBlipForCoord(v.x, v.y, v.z)
				SetBlipSprite(v.blip, 1)
				SetBlipColour(v.blip, 0)
				SetBlipScale(v.blip, 0.3)
				SetBlipAsShortRange(v.blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('Pepinos')
				EndTextCommandSetBlipName(v.blip)
			end
		elseif type == "Lechugas" then
			for i, v in ipairs(Farmer.LettucePositions) do
				v.blip = AddBlipForCoord(v.x, v.y, v.z)
				SetBlipSprite(v.blip, 1)
				SetBlipColour(v.blip, 0)
				SetBlipScale(v.blip, 0.3)
				SetBlipAsShortRange(v.blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('Lechuga')
				EndTextCommandSetBlipName(v.blip)
			end
		elseif type == "Patatas" then
			for i, v in ipairs(Farmer.PotatoesPositions) do
				v.blip = AddBlipForCoord(v.x, v.y, v.z)
				SetBlipSprite(v.blip, 1)
				SetBlipColour(v.blip, 0)
				SetBlipScale(v.blip, 0.3)
				SetBlipAsShortRange(v.blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('Papas')
				EndTextCommandSetBlipName(v.blip)
			end
		end

		CreateMarkerJob = true
		Type = type
end

Citizen.CreateThread(function()
	while true do
		sleep = 500
		local ped = PlayerPedId()
		coords = GetEntityCoords(ped)
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Farmer.Job then
			if CreateMarkerJob then
				if Type == "Pepinos" then
					sleep = 5
					for i, v in ipairs(Farmer.CucumbersPositions) do
						if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) and vegetable and not v.planted then
							DrawMarker(20, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
							DrawText3Ds(v.x, v.y, v.z+0.5, 'Presiona [E] para plantar')
							if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.5) and vegetable and not v.planted then
								if IsControlJustReleased(0, Keys['E']) and vegetable and not block and not IsPedInAnyVehicle(ped, false) then
									block = true
									exports.rprogress:Custom({
										Duration = 8000,
										Label = "Plantando Pepinos...",
										Animation = {
											scenario = "WORLD_HUMAN_GARDENER_PLANT", -- https://pastebin.com/6mrYTdQv
											animationDictionary = "enter", -- https://alexguirre.github.io/animations-list/
										},
										DisableControls = {
											Mouse = false,
											Player = true,
											Vehicle = true
										}
									})
									Citizen.Wait(8000)
									v.planted = true
									RemoveBlip(v.blip)
									done = done + 1
									block = false
									if done == #Farmer.CucumbersPositions then
										JobDone(Farmer.CucumbersPositions)
									end
								elseif IsControlJustReleased(0, Keys['E']) and vegetable and not block and IsPedInAnyVehicle(ped, false) then 
									exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Deja el vehiculo!', timeout = 1500})
								end
							end
						end
					end
				elseif Type == "Patatas" then
					sleep = 5
					for i, v in ipairs(Farmer.PotatoesPositions) do
						if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) and vegetable and not v.planted then
							DrawMarker(20, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
							DrawText3Ds(v.x, v.y, v.z+0.5, 'Presiona [E] para plantar')
							if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.5) and vegetable and not v.planted then
								if IsControlJustReleased(0, Keys['E']) and vegetable and not block and not IsPedInAnyVehicle(ped, false) then
									block = true
									exports.rprogress:Custom({
										Duration = 8000,
										Label = "Plantando Papas...",
										Animation = {
											scenario = "WORLD_HUMAN_GARDENER_PLANT", -- https://pastebin.com/6mrYTdQv
											animationDictionary = "enter", -- https://alexguirre.github.io/animations-list/
										},
										DisableControls = {
											Mouse = false,
											Player = true,
											Vehicle = true
										}
									})
									Citizen.Wait(8000)
									v.planted = true
									RemoveBlip(v.blip)
									done = done + 1
									block = false
									if done == #Farmer.PotatoesPositions then
										JobDone(Farmer.PotatoesPositions)
									end
								elseif IsControlJustReleased(0, Keys['E']) and vegetable and not block and IsPedInAnyVehicle(ped, false) then 
									exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Deja el Vehiculo!', timeout = 1500})
								end
							end
						end
					end
				elseif Type == "Lechugas" then
					sleep = 5
					for i, v in ipairs(Farmer.LettucePositions) do
						if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) and vegetable and not v.planted then
							DrawMarker(20, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
							DrawText3Ds(v.x, v.y, v.z+0.5, 'Presiona [E] para plantar')
							if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.5) and vegetable and not v.planted then
								if IsControlJustReleased(0, Keys['E']) and vegetable and not block and not IsPedInAnyVehicle(ped, false) then
									block = true
									exports.rprogress:Custom({
										Duration = 8000,
										Label = "Plantando lechuga...",
										Animation = {
											scenario = "WORLD_HUMAN_GARDENER_PLANT", -- https://pastebin.com/6mrYTdQv
											animationDictionary = "enter", -- https://alexguirre.github.io/animations-list/
										},
										DisableControls = {
											Mouse = false,
											Player = true,
											Vehicle = true
										}
									})
									Citizen.Wait(8000)
									v.planted = true
									RemoveBlip(v.blip)
									done = done + 1
									block = false
									if done == #Farmer.LettucePositions then
										JobDone(Farmer.LettucePositions)	
									end
								elseif IsControlJustReleased(0, Keys['E']) and vegetable and not block and IsPedInAnyVehicle(ped, false) then 
									exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Deja el vehiculo!', timeout = 1500})
								end
							end
						end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

function JobDone(type)
	CreateMarkerJob = false
	vegetable = false
	done = 0
	AmountPayout = AmountPayout + 1
	exports.pNotify:SendNotification({text = '<b>Granjero</b></br>El pago ya puede ser recolectado', timeout = 1500})
	RemoveBlip(PayoutBlip)
	CreatePayoutBlip()
	ContainerBlip()
	for i, v in ipairs(type) do
		v.planted = false
		RemoveBlip(v.blip)
	end
end

Citizen.CreateThread(function()
	while true do
		sleep = 500
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Farmer.Job then
			if(GetDistanceBetweenCoords(coords, Payout.Pos.x, Payout.Pos.y, Payout.Pos.z, true) < 3) and AmountPayout > 0 and JobStarted then
				sleep = 0

				DrawMarker(Payout.Type, Payout.Pos.x, Payout.Pos.y, Payout.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Payout.Size.x, Payout.Size.y, Payout.Size.z, Payout.Color.r, Payout.Color.g, Payout.Color.b, 100, false, true, 2, false, false, false, false)
				DrawMarker(29, Payout.Pos.x, Payout.Pos.y, Payout.Pos.z+0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 143, 235, 77, 100, false, true, 2, false, false, false, false)
				DrawText3Ds(Payout.Pos.x, Payout.Pos.y, Payout.Pos.z+1.4, 'Presiona [E] para recoger tu pago')
				if(GetDistanceBetweenCoords(coords, Payout.Pos.x, Payout.Pos.y, Payout.Pos.z, true) < 1.5) and AmountPayout > 0 and JobStarted then
					if IsControlJustReleased(0, Keys['E']) and AmountPayout > 0 and JobStarted and not IsPedInAnyVehicle(ped, false) then
						exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Has ganado '..AmountPayout*Farmer.Payout..'$', timeout = 1500})
						TriggerServerEvent('inside-farmer:payout', AmountPayout)
						AmountPayout = 0
						RemoveBlip(PayoutBlip)
					elseif IsControlJustReleased(0, Keys['E']) and AmountPayout > 0 and JobStarted and IsPedInAnyVehicle(ped, false) then 
						exports.pNotify:SendNotification({text = '<b>Granjero</b></br>Deja el vehiculo!', timeout = 1500})
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

function Randomize(tb)
	local keys = {}
	for k in pairs(tb) do table.insert(keys, k) end
	return tb[keys[math.random(#keys)]]
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function CreatePayoutBlip()
	PayoutBlip = AddBlipForCoord(Payout.Pos.x, Payout.Pos.y, Payout.Pos.z)
  
	SetBlipSprite (PayoutBlip, 500)
	SetBlipDisplay(PayoutBlip, 4)
	SetBlipScale  (PayoutBlip, 0.6)
	SetBlipColour (PayoutBlip, 11)
	SetBlipAsShortRange(PayoutBlip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Pago')
	EndTextCommandSetBlipName(PayoutBlip)
end

function CreateFarmBlip(type)
	FarmBlip = AddBlipForCoord(type.x, type.y, type.z)
  
	SetBlipSprite (FarmBlip, 280)
	SetBlipDisplay(FarmBlip, 4)
	SetBlipScale  (FarmBlip, 0.8)
	SetBlipColour (FarmBlip, 11)
	SetBlipAsShortRange(FarmBlip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(type.FarmName)
	EndTextCommandSetBlipName(FarmBlip)
end

function WarehouseBlip()
	local blip = AddBlipForCoord(Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z)
  
	SetBlipSprite (blip, 478)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.6)
	SetBlipColour (blip, 0)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Almacen')
	EndTextCommandSetBlipName(blip)
end

function ContainerBlip()
	Containerblip = AddBlipForCoord(Container.Pos.x, Container.Pos.y, Container.Pos.z)
  
	SetBlipSprite (Containerblip, 479)
	SetBlipDisplay(Containerblip, 4)
	SetBlipScale  (Containerblip, 0.5)
	SetBlipColour (Containerblip, 0)
	SetBlipAsShortRange(Containerblip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Contenedor')
	EndTextCommandSetBlipName(Containerblip)
end

CreateFarmerBlip = function()
	Citizen.CreateThread(function()

		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Farmer.Job then
			FarmerBlip = AddBlipForCoord(JobStart.Pos.x, JobStart.Pos.y, JobStart.Pos.z)
		
			SetBlipSprite (FarmerBlip, 141)
			SetBlipDisplay(FarmerBlip, 4)
			SetBlipScale  (FarmerBlip, 1.2)
			SetBlipColour (FarmerBlip, 5)
			SetBlipAsShortRange(FarmerBlip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('Granjero')
			EndTextCommandSetBlipName(FarmerBlip)
		else

			if FarmerBlip ~= nil then
				RemoveBlip(FarmerBlip)
				FarmerBlip = nil
			end
		end
	end)
end
