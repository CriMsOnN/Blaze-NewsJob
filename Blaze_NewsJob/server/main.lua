ESX = nil


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent("newsjob:server:payCheck")
AddEventHandler("newsjob:server:payCheck", function(reward) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local totalReward = Config.PayCheck * reward
    xPlayer.addAccountMoney("bank", tonumber(totalReward))
    TriggerClientEvent("newsjob:client:payCheck", _source, totalReward)
end)