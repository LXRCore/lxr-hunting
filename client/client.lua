--[[
    ██╗     ██╗  ██╗██████╗        ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██╗███╗   ██╗ ██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗███████║██║   ██║██╔██╗ ██║   ██║   ██║██╔██╗ ██║██║  ███╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██║██║   ██║██║╚██╗██║   ██║   ██║██║╚██╗██║██║   ██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║██║ ╚████║╚██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝

    🐺 LXR Hunting System - Client Script

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:    The Land of Wolves 🐺
    Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land
    Discord:   https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

local sharedItems = exports['lxr-core']:GetItems()

--------------------------------------------------------------------
--- FUNCTIONS
--------------------------------------------------------------------

-- Delete the carried item and sell it to the butcher
local function DeleteCarryItem(data)
    DeleteEntity(data[2])
    TriggerServerEvent('lxr-hunting:server:SellCarryItems', data[1])
end

-- Trade the carried item for cash or items
local function TradeCarryItem(data)
    local itemData, entity = table.unpack(data)

    local MenuItem = {
        {
            header = 'Trading '..itemData.name,
            isMenuHeader = true
        },
        {
            header = 'Sell',
            txt = 'Sell For $'..itemData.butcher.cash,
            params = {
                isAction = true,
                event = DeleteCarryItem,
                args = {itemData.butcher.cash, entity}
            }
        }
    }

    for k, v in pairs(itemData.butcher.items) do
        MenuItem[#MenuItem+1] = {
            header = 'Trade',
            txt = 'Trade For '..v..' '..sharedItems[k]['label'],
            params = {
                isAction = true,
                event = DeleteCarryItem,
                args = {{item = k, amount = v}, entity}
            }
        }
    end

    exports['lxr-menu']:openMenu(MenuItem)
end

-- Select how many items you want to sell
local function SelectSaleAmount(data)
    local dialog = exports['lxr-input']:ShowInput({
        header = 'Item: '..sharedItems[data[1]]['label']..' $'..data[4]..' Each',
        submitText = "Submit Sale",
        inputs = {
            {
                text = "Total Amount Available: "..data[3],
                name = "amount",
                type = "number",
                isRequired = true
            },
        },
    })

    if not dialog then return end
    dialog.data = data
    TriggerServerEvent('lxr-hunting:server:SellInvItems', dialog)
end

-- Open the butcher shop menu
local function OpenShop()
    local MenuItems = {
        {
            header = 'Hunting Lounge',
            isMenuHeader = true
        }
    }

    local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
    if holding then
        local CarryItem = Config.Items['Pickup'][GetEntityModel(holding)]
        if CarryItem?.butcher then
            MenuItems[#MenuItems+1] = {
                header = "Item: "..CarryItem.name,
                params = {
                    isAction = true,
                    event = TradeCarryItem,
                    args = {CarryItem, holding}
                }
            }
        end
    else
        for k, v in pairs(Config.Items['Inv']) do
            local amount, slot = exports['lxr-inventory']:GetItemAmount(k)
            if amount then
                MenuItems[#MenuItems+1] = {
                    header = 'Item: '..sharedItems[k]['label'],
                    icon = k,
                    params = {
                        isAction = true,
                        event = SelectSaleAmount,
                        args = {k, slot, amount, v}
                    }
                }
            end
        end
    end

    exports['lxr-menu']:openMenu(MenuItems)
end

--------------------------------------------------------------------
--- EVENTS
--------------------------------------------------------------------

-- Handle looting of animals
AddEventHandler('LXRCore:Event:Looted', function(data)
    if data.ped ~= PlayerPedId() or data.complete == 0 then return end
    local animal = GetEntityModel(data.target)
    local Animalitem = Config.Items['Pickup'][animal]?.skin
    if not Animalitem then return end
    Animalitem.quality = Citizen.InvokeNative(0x88EFFED5FE8B0B4A, data.target)
    TriggerServerEvent('lxr-hunting:server:AnimalItem', Animalitem)
    Wait(200)
    local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, PlayerPedId())
    if holding then DeleteEntity(holding) end
end)

--------------------------------------------------------------------
--- THREADS
--------------------------------------------------------------------

-- Spawn butcher NPCs and blips at configured locations
CreateThread(function()
    local location = Config.Butchers
    if location.PedModel then
        RequestModel(location.PedModel)
        while not HasModelLoaded(location.PedModel) do Wait(0) end
    end
    for k, v in pairs(location['Locations']) do
        local coords = v.xyz
        if location.PedModel then
            local npc = CreatePed(location.PedModel, v, false, true, true, true)
            Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
            SetEntityCanBeDamaged(npc, false)
            SetEntityInvincible(npc, true)
            FreezeEntityPosition(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            coords = coords + GetEntityForwardVector(npc) * 2.0
            PlaceObjectOnGroundProperly(npc)
            SetEntityLodDist(npc, 50)
        end
        if location.Blip then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.xyz)
            SetBlipSprite(blip, location.Blip, true)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Butcher')
        end
        exports['lxr-core']:createPrompt('Hunting:'..k, coords, 0xF3830D8E, 'Talk With Butcher', {
            type = 'callback', event = OpenShop
        })
    end
    SetModelAsNoLongerNeeded(location.PedModel)
end)
