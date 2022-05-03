ESX = nil
TriggerEvent('esx:SupremeObject', function(obj) ESX = obj end)

RegisterServerEvent('inside-farmer:payout')
AddEventHandler('inside-farmer:payout', function(arg)	
	local xPlayer = ESX.GetPlayerFromId(source)
	local Payout = Farmer.Payout * arg
	xPlayer.addMoney(Payout)
end)
