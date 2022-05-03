ESX                			 = nil
local PlayersVente			 = {}

TriggerEvent('esx:SupremeObject', function(obj) ESX = obj end)

RegisterServerEvent('electricista:Pago')
AddEventHandler('electricista:Pago', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local pago = math.random(Electricista.PagoMin,Electricista.PagoMax)

	if pago ~= nil then
		xPlayer.addAccountMoney('bank', pago)
		TriggerClientEvent("pNotify:SendNotification",source , {
			text = Electricista.Locales.pago:format(pago),
			timeout = 3000
		})
	else
		print(xPlayer.." hacker?")
	end
end)