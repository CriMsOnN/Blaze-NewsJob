local isWorking = false
local PlayerData = nil
local Earnings = 0
local VehicleHash = nil
local PreviousLocation = nil
local isRouting = false
local CurrentLocation = 0
local CameraObject = nil
local PreviousLocation = nil
local ReporterBlip = 0

ESX = nil


Citizen.CreateThread(function()
     while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        Wait(0)
      end
      PlayerData = ESX.GetPlayerData()
      if PlayerData.job ~= nil and PlayerData.job.name == "news" then
        createBlips()
      end
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(data) 
    PlayerData.job = data
    createBlips()
end)

Citizen.CreateThread(function() 
    while true do
        Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, Config.StartWorking.x, Config.StartWorking.y, Config.StartWorking.z, true) < 1.5 and PlayerData.job ~= nil and PlayerData.job.name == "news" then
            if not isWorking then
                drawText(Config.StartWorking.x, Config.StartWorking.y, Config.StartWorking.z + 1.0, "Press [~r~E~s~] to start working")
                if IsControlJustPressed(0, 51) then
                    isWorking = true
                    createVehicle()
                end
            elseif isWorking then
                if Earnings == 0 then
                    drawText(Config.StartWorking.x, Config.StartWorking.y, Config.StartWorking.z + 1.0, "Press [~r~E~s~] to stop working")
                    if IsControlJustPressed(0, 51) then
                        stopJob()
                    end
                else
                    if not DoesEntityExist(VehicleHash) then
                        drawText(Config.StartWorking.x, Config.StartWorking.y, Config.StartWorking.z + 1.0, "Press [~r~E~s~] to recieve your paycheck")
                        if IsControlJustPressed(0, 51) then
                            TriggerServerEvent("newsjob:server:payCheck", Earnings)
                            stopJob()
                        end
                    else
                        drawText(Config.StartWorking.x, Config.StartWorking.y, Config.StartWorking.z + 1.0, "Return your vehicle first")
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function() 
    while true do
        Wait(0)
        local sleep = true
        if isWorking and Earnings > 0 then
            local coords = GetEntityCoords(PlayerPedId())
            local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, Config.ReturnCar.x, Config.ReturnCar.y, Config.ReturnCar.z, true)
            if IsPedInAnyVehicle(PlayerPedId()) then
                if GetVehiclePedIsIn(PlayerPedId(), false) == VehicleHash then
                    if distance < 7.0 then
                        sleep = false
                        drawText(Config.ReturnCar.x, Config.ReturnCar.y, Config.ReturnCar.z + 1.0, "Press [~r~E~s~] to return your vehicle")
                        DrawMarker(2, Config.ReturnCar.x, Config.ReturnCar.y, Config.ReturnCar.z + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 0, 0, 255, false, true, 2, nil, nil, false)
                        if IsControlJustPressed(0, 51) then
                            DeleteVehicle(VehicleHash)
                        end
                    end
                else
                    ESX.ShowAdvancedNotification("News", "Update", "This is not the vehicle we gave you", "CHAR_LIFEINVADER", 1)
                end
            end
        end

        if sleep then
            Wait(2000)
        end
    end
end)

stopJob = function() 
    if DoesEntityExist(VehicleHash) then
        DeleteVehicle(VehicleHash)
    end
    if ReporterBlip ~= 0 then
        RemoveBlip(ReporterBlip)
    end
    isWorking = false
    Earnings = 0
    VehicleHash = nil
    PreviousLocation = 0
    CurrentLocation = 0
    isRouting = false
    CameraObject = nil
    PreviousLocation = nil
    ReporterBlip = 0
end

function createVehicle()
    ESX.Game.SpawnVehicle(Config.Car, vector3(Config.CarSpawn.x, Config.CarSpawn.y, Config.CarSpawn.z), Config.CarSpawn.h, function(vehicle) 
        if DoesEntityExist(vehicle) then
            SetVehicleNumberPlateText(vehicle, "NEWS-"..tostring(math.random(1000, 2000)))
            SetVehicleLivery(vehicle, 2)
            VehicleHash = vehicle
            ESX.ShowAdvancedNotification("News", "Update", "Your vehicle is waiting for you outside i will update your GPS soon", "CHAR_LIFEINVADER", 1)
            Citizen.Wait(2000)
            Routing()
            isRouting = true
        end
    end)
end


function Routing()
    if isWorking then
        ESX.ShowAdvancedNotification("News", "Update", "I've updated your GPS", "CHAR_LIFEINVADER", 1)
        local random = math.random(1, #Config.Locations)
        CurrentLocation = Config.Locations[random]
        if PreviousLocation ~= nil then
            while PreviousLocation == CurrentLocation do
                Wait(1)
                Routing()
            end
        end
        if ReporterBlip ~= 0 then
            RemoveBlip(ReporterBlip)
        end
        ReporterBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
        SetBlipSprite(ReporterBlip, 1)
        SetBlipDisplay(ReporterBlip, 2)
        SetBlipScale(ReporterBlip, 1.0)
        SetBlipAsShortRange(ReporterBlip, false)
        SetBlipColour(ReporterBlip, 3)
        SetBlipRoute(ReporterBlip, true)
        SetBlipRouteColour(ReporterBlip, 3)
    end
end

Citizen.CreateThread(function() 
    while true do
        Wait(0)
        if isRouting then
           local coords = GetEntityCoords(PlayerPedId())
           local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, true)
           if distance > 2.0 and distance < 20.0 then
                drawText(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, "Stand Here")
                DrawMarker(2, CurrentLocation.x, CurrentLocation.y, CurrentLocation.z + 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 0, 0, 255, false, true, 2, nil, nil, false)
           elseif distance < 2.0 then
                drawText(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, "Press [~r~E~s~] to take a picture")
                if IsControlJustPressed(0, 51) then
                    Wait(1)
                    photoAnimation()
                end
           end
        end
    end
end)


photoAnimation = function()
    print("starting animation")
    local ped = GetPlayerPed(-1)
    LoadAnim('amb@world_human_paparazzi@male@enter')
    TaskPlayAnim(ped, 'amb@world_human_paparazzi@male@enter', 'enter', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    cameraObject()
    FreezeEntityPosition(ped, true)
    Citizen.Wait(1300)
    StopAnimTask(ped, 'amb@world_human_paparazzi@male@enter', 'enter', 1.0)
    LoadAnim('amb@world_human_paparazzi@male@base')
    TaskPlayAnim(ped, 'amb@world_human_paparazzi@male@base', 'base', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
    Citizen.Wait(1300)
    StopAnimTask(ped, 'amb@world_human_paparazzi@male@base', 'base', 1.0)
    FreezeEntityPosition(ped, false)
    DeleteObject(CameraObject)
    PreviousLocation = CurrentLocation
    if Earnings > 10 then
        Earnings = Earnings + Config.Bonus + 1 -- After 10 photos he will take a Bonus reward for every photo
    else
        Earnings = Earnings + 1
    end
    Routing()

    print("Earnings: ", Earnings)
end

cameraObject = function()
    local ped = GetPlayerPed(-1)
    CameraObject = CreateObject(GetHashKey('prop_pap_camera_01'), 0, 0, 0, true, true, true)
    AttachEntityToEntity(CameraObject, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
end

LoadAnim = function(dict)
    RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(10)
	end
end

function createBlips()
    local blip = AddBlipForCoord(Config.Ped.x, Config.Ped.y, Config.Ped.z)
    SetBlipSprite(blip, 184)
    SetBlipColour(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("News Job")
    EndTextCommandSetBlipName(blip)
end

drawText = function(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent("newsjob:client:payCheck")
AddEventHandler("newsjob:client:payCheck", function(reward) 
    ESX.ShowAdvancedNotification("News", "PayCheck", "You paycheck is $"..reward, "CHAR_LIFEINVADER", 1)
end)


AddEventHandler("onResourceStop", function(res) 
    if GetCurrentResourceName() ~= res then return end
    DeleteVehicle(VehicleHash)
end)
