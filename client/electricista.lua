local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                             = nil
local PlayerData                = {}
local GUI                       = {}
GUI.Time                        = 0
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local onDuty                    = false
local BlipCloakRoom             = nil
local BlipVehicle               = nil
local BlipVehicleDeleter		= nil
local Blips                     = {}
local OnJob                     = false
local Done 						= false
local txt						= Electricista.Locales

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	CreateElectricistaBlip()
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
	onDuty = false
    CreateElectricistaBlip()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
	onDuty = false
    CreateElectricistaBlip()
end)

-- NPC MISSIONS
function SelectPool()
    local index = GetRandomIntInRange(1,  #Electricista.Pool)

    for k,v in pairs(Electricista.Zones) do
      if v.Pos.x == Electricista.Pool[index].x and v.Pos.y == Electricista.Pool[index].y and v.Pos.z == Electricista.Pool[index].z then
        return k
      end
    end
end

function StartNPCJob()
    NPCTargetPool         = SelectPool()
    local zone            = Electricista.Zones[NPCTargetPool]

    Blips['NPCTargetPool'] = AddBlipForCoord(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)
    SetBlipRoute(Blips['NPCTargetPool'], true)
    pNotify(txt.GPS_info, 3000)
    Done = true
end

function StopNPCJob(cancel)

    if Blips['NPCTargetPool'] ~= nil then
      RemoveBlip(Blips['NPCTargetPool'])
      Blips['NPCTargetPool'] = nil
	end

	OnJob = false

    if cancel then
      pNotify(txt.cancel_mission, 3000)
	else
		TriggerServerEvent('electricista:Pago')
		StartNPCJob()
		Done = true
	end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)

        if NPCTargetPool ~= nil then

            local coords = GetEntityCoords(GetPlayerPed(-1))
            local zone   = Electricista.Zones[NPCTargetPool]
            local playerPed = GetPlayerPed(-1)

           	if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < 1.5 then

                HelpPromt(txt.pickup)

                if IsControlJustReleased(1, Keys["E"]) and ESX.PlayerData.job ~= nil then
					TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
					Wait(10000)
                    TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_POLICE_INVESTIGATE", 0, true)
					Wait(12000)
                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true)
                    Wait(17000)
                    StopNPCJob()
                    Wait(3000)
                    ClearPedTasksImmediately(playerPed)
                    Done = false
                end
            end
        end
    end
end)

-- Prise de service
function CloakRoomMenu()

	local elements = {}

	if onDuty then
		table.insert(elements, {label = txt.end_service, value = 'citizen_wear'})
	else
		table.insert(elements, {label = txt.take_service, value = 'job_wear'})
	end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'cloakroom',
        {
            title = 'Job Locker',
			align    = 'bottom-right',
            elements = elements
        },
        function(data, menu)

            if data.current.value == 'citizen_wear' then
				onDuty = false
				CreateElectricistaBlip()
				menu.close()
                pNotify(txt.end_service_notif, 3000)
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				  local model = nil

				  if skin.sex == 0 then
					model = GetHashKey("mp_m_freemode_01")
				  else
					model = GetHashKey("mp_f_freemode_01")
				  end

				  RequestModel(model)
				  while not HasModelLoaded(model) do
					RequestModel(model)
					Citizen.Wait(1)
				  end

				  SetPlayerModel(PlayerId(), model)
				  SetModelAsNoLongerNeeded(model)

				  TriggerEvent('skinchanger:loadSkin', skin)
				  TriggerEvent('esx:restoreLoadout')

				  local playerPed = GetPlayerPed(-1)
				  ClearPedBloodDamage(playerPed)
				  ResetPedVisibleDamage(playerPed)
				  ClearPedLastWeaponDamage(playerPed)
				end)
            end

            if data.current.value == 'job_wear' then
				onDuty = true
				CreateElectricistaBlip()
                menu.close()
                pNotify(txt.take_service_notif, 3000)
                pNotify(txt.start_job, 3000)
				local playerPed = GetPlayerPed(-1)
				setUniform(data.current.value, playerPed)

				ClearPedBloodDamage(playerPed)
				ResetPedVisibleDamage(playerPed)
				ClearPedLastWeaponDamage(playerPed)
            end

            CurrentAction     = 'cloakroom_menu'
            CurrentActionMsg  = Electricista.Zones.Cloakroom.hint
            CurrentActionData = {}
        end,
        function(data, menu)

            menu.close()

			CurrentAction     = 'cloakroom_menu'
			CurrentActionMsg  = Electricista.Zones.Cloakroom.hint
            CurrentActionData = {}
        end
    )

end

-- Prise du véhicule
function VehicleMenu()

    local elements = {
        {label = Electricista.Vehicles.Truck.Label, value = Electricista.Vehicles.Truck}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'spawn_vehicle',
        {
            title    = txt.Vehicle_Menu_Title,
			align    = 'bottom-right',
            elements = elements
        },
        function(data, menu)
            for i=1, #elements, 1 do
				menu.close()
				local playerPed = GetPlayerPed(-1)
				local coords    = Electricista.Zones.VehicleSpawnPoint.Pos
				local Heading    = Electricista.Zones.VehicleSpawnPoint.Heading
				local platenum = math.random(1000, 9999)
				local platePrefix = Electricista.platePrefix
				ESX.Game.SpawnVehicle(data.current.value.Hash, coords, Heading, function(vehicle)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					SetVehicleNumberPlateText(vehicle, platePrefix .. platenum)
					plate = GetVehicleNumberPlateText(vehicle)
					plate = string.gsub(plate, " ", "")
					name = 'Véhicule de '..platePrefix
					TriggerServerEvent('esx_vehiclelock:registerkeyjob', name, plate, 'no')
				end)
				break
            end
            menu.close()

    end,
function(data, menu)
    menu.close()
    CurrentAction     = 'vehiclespawn_menu'
    CurrentActionMsg  = Electricista.Zones.VehicleSpawner.hint
    CurrentActionData = {}
end
)
end

-- Quand le joueur entre dans la zone
AddEventHandler('esx_cityworks:hasEnteredMarker', function(zone)

    if zone == 'Cloakroom' then
        CurrentAction        = 'cloakroom_menu'
        CurrentActionMsg     = Electricista.Zones.Cloakroom.hint
        CurrentActionData    = {}
    end

    if zone == 'VehicleSpawner' then
        CurrentAction        = 'vehiclespawn_menu'
        CurrentActionMsg     = Electricista.Zones.VehicleSpawner.hint
        CurrentActionData    = {}
    end

    if zone == 'VehicleDeleter' then
        local playerPed = GetPlayerPed(-1)
        if IsPedInAnyVehicle(playerPed,  false) then
          CurrentAction        = 'delete_vehicle'
          CurrentActionMsg     = Electricista.Zones.VehicleDeleter.hint
          CurrentActionData    = {}
        end
    end
end)

-- Quand le joueur sort de la zone
AddEventHandler('esx_cityworks:hasExitedMarker', function(zone)
    CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

function CreateElectricistaBlip()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Electricista.nameJob then

		if BlipCloakRoom == nil then
			BlipCloakRoom = AddBlipForCoord(Electricista.Zones.Cloakroom.Pos.x, Electricista.Zones.Cloakroom.Pos.y, Electricista.Zones.Cloakroom.Pos.z)
			SetBlipSprite(BlipCloakRoom, Electricista.Zones.Cloakroom.BlipSprite)
			SetBlipColour(BlipCloakRoom, Electricista.Zones.Cloakroom.BlipColor)
			SetBlipAsShortRange(BlipCloakRoom, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(Electricista.Zones.Cloakroom.BlipName)
			EndTextCommandSetBlipName(BlipCloakRoom)
		end
	else

        if BlipCloakRoom ~= nil then
            RemoveBlip(BlipCloakRoom)
            BlipCloakRoom = nil
        end
	end

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Electricista.nameJob and onDuty then

        BlipVehicle = AddBlipForCoord(Electricista.Zones.VehicleSpawner.Pos.x, Electricista.Zones.VehicleSpawner.Pos.y, Electricista.Zones.VehicleSpawner.Pos.z)
        SetBlipSprite(BlipVehicle, Electricista.Zones.VehicleSpawner.BlipSprite)
        SetBlipColour(BlipVehicle, Electricista.Zones.VehicleSpawner.BlipColor)
        SetBlipAsShortRange(BlipVehicle, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Electricista.Zones.VehicleSpawner.BlipName)
        EndTextCommandSetBlipName(BlipVehicle)

        BlipVehicleDeleter = AddBlipForCoord(Electricista.Zones.VehicleDeleter.Pos.x, Electricista.Zones.VehicleDeleter.Pos.y, Electricista.Zones.VehicleDeleter.Pos.z)
        SetBlipSprite(BlipVehicleDeleter, Electricista.Zones.VehicleDeleter.BlipSprite)
        SetBlipColour(BlipVehicleDeleter, Electricista.Zones.VehicleDeleter.BlipColor)
        SetBlipAsShortRange(BlipVehicleDeleter, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Electricista.Zones.VehicleDeleter.BlipName)
        EndTextCommandSetBlipName(BlipVehicleDeleter)
    else

        if BlipVehicle ~= nil then
            RemoveBlip(BlipVehicle)
            BlipVehicle = nil
        end

        if BlipVente ~= nil then
            RemoveBlip(BlipVente)
            BlipVente = nil
        end

        if BlipVehicleDeleter ~= nil then
            RemoveBlip(BlipVehicleDeleter)
            BlipVehicleDeleter = nil
        end
    end
end

-- Activation du marker au sol
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if ESX.PlayerData.job ~= nil then
			local coords = GetEntityCoords(GetPlayerPed(-1))

			if ESX.PlayerData.job.name == Electricista.nameJob then
				if onDuty then

					for k,v in pairs(Electricista.Zones) do
						if v ~= Electricista.Zones.Cloakroom then
							if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Electricista.DrawDistance) then
								DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
							end
						end
					end

				end

				local Cloakroom = Electricista.Zones.Cloakroom
				if(Cloakroom.Type ~= -1 and GetDistanceBetweenCoords(coords, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, true) < Electricista.DrawDistance) then
					DrawMarker(Cloakroom.Type, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Cloakroom.Size.x, Cloakroom.Size.y, Cloakroom.Size.z, Cloakroom.Color.r, Cloakroom.Color.g, Cloakroom.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Detection de l'entrer/sortie de la zone du joueur
Citizen.CreateThread(function()
	while true do
		Wait(1)
		if ESX.PlayerData.job ~= nil then
			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			if ESX.PlayerData.job.name == Electricista.nameJob then
				if onDuty then
					for k,v in pairs(Electricista.Zones) do
						if v ~= Electricista.Zones.Cloakroom then
							if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) <= v.Size.x) then
								isInMarker  = true
								currentZone = k
							end
						end
					end
				end

				local Cloakroom = Electricista.Zones.Cloakroom
				if(GetDistanceBetweenCoords(coords, Cloakroom.Pos.x, Cloakroom.Pos.y, Cloakroom.Pos.z, true) <= Cloakroom.Size.x) then
					isInMarker  = true
					currentZone = "Cloakroom"
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_cityworks:hasEnteredMarker', currentZone)
			end
			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_cityworks:hasExitedMarker', LastZone)
			end
		end
	end
end)

-- Action après la demande d'accés
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if (IsControlJustReleased(1, Keys["E"]) or IsControlJustReleased(2, Keys["RIGHT"])) and ESX.PlayerData.job ~= nil then
				local playerPed = GetPlayerPed(-1)
				if ESX.PlayerData.job.name == Electricista.nameJob then
					if CurrentAction == 'cloakroom_menu' then
						if IsPedInAnyVehicle(playerPed, 0) then
                            pNotify(txt.in_vehicle, 3000)
						else
							CloakRoomMenu()
						end
					end
					if CurrentAction == 'vehiclespawn_menu' then
						if IsPedInAnyVehicle(playerPed, 0) then
                            pNotify(txt.in_vehicle, 3000)
						else
							VehicleMenu()
						end
					end
					if CurrentAction == 'vente' then
						TriggerServerEvent('esx_cityworks:startVente')
						TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_CLIPBOARD", 0, 1)
					end
					if CurrentAction == 'delete_vehicle' then
					  local playerPed = GetPlayerPed(-1)
					  local vehicle   = GetVehiclePedIsIn(playerPed,  false)
					  local hash      = GetEntityModel(vehicle)
					  local plate = GetVehicleNumberPlateText(vehicle)
					  local plate = string.gsub(plate, " ", "")
					  local platePrefix = Electricista.platePrefix

					  if string.find (plate, platePrefix) then
						local truck = Electricista.Vehicles.Truck

						if hash == GetHashKey(truck.Hash) then
							if GetVehicleEngineHealth(vehicle) <= 500 or GetVehicleBodyHealth(vehicle) <= 500 then
                                pNotify(txt.vehicle_broken, 3000)
							else
								TriggerServerEvent('esx_vehiclelock:vehjobSup', plate, 'no')
								DeleteVehicle(vehicle)
							end
						end
					  else
                        pNotify(txt.bad_vehicle, 3000)
					  end
					end
               	    CurrentAction = nil
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if IsControlJustReleased(1, Keys["F10"]) and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == Electricista.nameJob then

			if Onjob then
				StopNPCJob(true)
				RemoveBlip(Blips['NPCTargetPool'])
				Onjob = false
			else
				local playerPed = GetPlayerPed(-1)

				if IsPedInAnyVehicle(playerPed,  false) and IsVehicleModel(GetVehiclePedIsIn(playerPed,  false), GetHashKey("boxville")) then
					StartNPCJob()
					Onjob = true
				else
                    pNotify(txt.not_good_veh, 3000)
				end
			end
		end
	end
end)

function setUniform(job, playerPed)
  TriggerEvent('skinchanger:getSkin', function(skin)

    if skin.sex == 0 then
      if Electricista.Uniforms[job].male ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Electricista.Uniforms[job].male)
      else
        pNotify(txt.no_outfit, 3000)
      end
    else
      if Electricista.Uniforms[job].female ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Electricista.Uniforms[job].female)
      else
        pNotify(txt.no_outfit, 3000)
      end
    end

  end)
end

function HelpPromt(text)
	Citizen.CreateThread(function()
		SetTextComponentFormat("STRING")
		AddTextComponentString(text)
		DisplayHelpTextFromStringLabel(0, state, 0, -1)

	end)
end

pNotify = function(message, messageTimeout)
	TriggerEvent("pNotify:SendNotification", {
        text = message,
		timeout = messageTimeout
	})
end