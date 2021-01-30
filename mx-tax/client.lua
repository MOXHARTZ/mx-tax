ESX = nil
OR = nil
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

Citizen.CreateThread(function()
      RequestModel(0x0703F106)
      while not HasModelLoaded(0x0703F106) do
          Citizen.Wait(1)
      end
      OR = CreatePed(1, 0x0703F106, -120.24, -612.31, 36.28 - 1, 246.05, false, true)
      SetBlockingOfNonTemporaryEvents(OR, true)
      SetPedDiesWhenInjured(OR, false)
      SetPedCanPlayAmbientAnims(OR, true)
      SetPedCanRagdollFromPlayerImpact(OR, false)
      SetEntityInvincible(OR, true)
      FreezeEntityPosition(OR, true)
      local blip = AddBlipForCoord(-120.24, -612.31, 36.28)
      SetBlipSprite(blip, 525)
      SetBlipColour(blip, 2)
      SetBlipScale(blip, 0.7)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Tax Center")
      EndTextCommandSetBlipName(blip)
      SetBlipAsShortRange(blip, true)
end)


function MenuOpen()
  ESX.UI.Menu.CloseAll()
  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tax',{
    title    = 'TAX MENU',
    elements = {
     {label = "Vehicle Tax", value = "veh"},
     {label = "Citizen Tax", value = "cit"}
    }
  },
  function(data, menu)
    ESX.UI.Menu.CloseAll()
    if data.current.value == "veh" then
      local el = {}
      ESX.TriggerServerCallback('mx-tax:GetVehicleTax', function(info) 
        if info[1] ~= nil then
          for k,v in pairs(info) do
            local general = json.decode(v.vehicle)
            table.insert(el, {
              label  = ('%s <span style="color:red;">%s</span>'):format("Plate: "..general.plate, " Price: "..ESX.Math.GroupDigits(v.tax)),
              plate = general.plate,
              price = v.tax
            })
          end
        else
          exports['mythic_notify']:SendAlert('inform', 'You don\'t have any taxes')
          return false
        end
      end)
      while el[1] == nil do
          Citizen.Wait(100)
      end
      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tax',{
          title    = 'TAX MENU',
          elements = el
        },
        function(data2, menu2)
          ESX.TriggerServerCallback('mx-tax:PayVehicleTax', function(val) 
              if val ~= false then
                MenuOpen()
              end
          end, data2.current.plate, data2.current.price)
        end, function(data2, menu2)
            menu2.close()
        end)
    elseif data.current.value == "cit" then
      local el = {}
      ESX.TriggerServerCallback('mx-tax:GetCitizenTax', function(info) 
        if info[1] ~= nil then
          for _,v in pairs(info) do
            table.insert(el, {
              label  = ('%s <span style="color:red;">%s</span>'):format("Name: "..GetPlayerName(PlayerId()), " Price: "..ESX.Math.GroupDigits(v.tax)),
              price = v.tax
            })
          end
        else
          exports['mythic_notify']:SendAlert('inform', 'You don\'t have any taxes')
          return false
        end
      end)
      while el[1] == nil do
          Citizen.Wait(100)
      end
      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tax',{
          title    = 'TAX MENU',
          elements = el
        },
        function(data3, menu3)
          ESX.TriggerServerCallback('mx-tax:PayCitizenTax', function(val) 
              if val ~= false then
                MenuOpen()
              end
          end, data3.current.price)
        end, function(data3, menu3)
            menu3.close()
        end)
    end
  end, function(data, menu)
      menu.close()
  end)
end

local sleep
Citizen.CreateThread(function()
  Citizen.Wait(2000)
    while true do
      sleep = 2000
      p = GetEntityCoords(PlayerPedId())
      a = GetEntityCoords(OR)
      dst = #(p-a)
      if dst <= 5 then
        sleep = 7
        DrawMarker(2, a.x, a.y, a.z + 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
        if dst <= 2 then
          DrawText3D(-120.24, -612.31, 36.28 + 1.2, "~r~[E]~s~ Pay Tax")
          if IsControlJustPressed(0, 38) then -- Key E
            MenuOpen()
          end
        end
      end
      Citizen.Wait(sleep)
    end       
end)

function DrawText3D(x,y,z,text) SetTextScale(0.35, 0.35)   SetTextFont(4)   SetTextProportional(1)   SetTextColour(255, 255, 255, 215)   SetTextEntry("STRING")   SetTextCentre(true)   AddTextComponentString(text)   SetDrawOrigin(x,y,z, 0)   DrawText(0.0, 0.0)   local factor = (string.len(text)) / 370   DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75) ClearDrawOrigin() end