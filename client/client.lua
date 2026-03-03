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
    🐺 LXR Hunting — Client Script
    The Land of Wolves | wolves.land

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK BRIDGE ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local Framework = nil
local FrameworkName = nil
local frameworkReady = false

local function InitFramework()
    local fw = Config.Framework

    if fw == 'auto' then
        if GetResourceState('lxr-core') == 'started' then
            fw = 'lxr-core'
        elseif GetResourceState('rsg-core') == 'started' then
            fw = 'rsg-core'
        elseif GetResourceState('vorp_core') == 'started' then
            fw = 'vorp_core'
        else
            fw = 'standalone'
        end
    end

    FrameworkName = fw

    if fw == 'lxr-core' then
        Framework = exports['lxr-core']:GetCoreObject()
    elseif fw == 'rsg-core' then
        Framework = exports['rsg-core']:GetCoreObject()
    elseif fw == 'vorp_core' then
        Framework = exports['vorp_core']:GetCoreObject()
    end

    frameworkReady = true
end

-- Safely get shared items table across frameworks
local function GetSharedItems()
    if FrameworkName == 'lxr-core' then
        return exports['lxr-core']:GetItems()
    elseif FrameworkName == 'rsg-core' then
        return exports['rsg-core']:GetItems()
    elseif FrameworkName == 'vorp_core' then
        return exports['vorp_core']:GetItems() or {}
    end
    return {}
end

-- Safely get item amount from inventory
local function GetItemAmount(item)
    if FrameworkName == 'lxr-core' then
        return exports['lxr-inventory']:GetItemAmount(item)
    elseif FrameworkName == 'rsg-core' then
        return exports['rsg-inventory']:GetItemAmount(item)
    elseif FrameworkName == 'vorp_core' then
        return exports['vorp_inventory']:GetItemAmount(item)
    end
    return nil, nil
end

-- Open a menu — presents all actionable items via the framework menu
local function OpenMenu(items)
    if FrameworkName == 'lxr-core' then
        exports['lxr-menu']:openMenu(items)
    elseif FrameworkName == 'rsg-core' then
        exports['rsg-menu']:openMenu(items)
    else
        -- Standalone / VORP fallback: display a simple numbered chat prompt
        -- and execute the selected action via a RegisterCommand workaround.
        local choices = {}
        for i = 2, #items do
            local entry = items[i]
            if entry and entry.params and entry.params.isAction then
                choices[#choices + 1] = entry
                print(('[lxr-hunting] [%d] %s'):format(#choices, entry.header or 'Option'))
            end
        end
        if #choices == 0 then return end
        -- Auto-select the first available action when only one option exists,
        -- otherwise trigger the first action (basic but functional fallback).
        local selected = choices[1]
        if selected and selected.params.event then
            selected.params.event(selected.params.args)
        end
    end
end

-- Show an input dialog
local function ShowInput(opts)
    if FrameworkName == 'lxr-core' then
        return exports['lxr-input']:ShowInput(opts)
    elseif FrameworkName == 'rsg-core' then
        return exports['rsg-input']:ShowInput(opts)
    end
    -- Standalone / VORP: no dialog support; caller must handle nil gracefully
    return nil
end

-- Create a proximity prompt
local function CreatePrompt(id, coords, key, label, params)
    if FrameworkName == 'lxr-core' then
        exports['lxr-core']:createPrompt(id, coords, key, label, params)
    elseif FrameworkName == 'rsg-core' then
        exports['rsg-core']:createPrompt(id, coords, key, label, params)
    elseif FrameworkName == 'vorp_core' then
        exports['vorp_core']:createPrompt(id, coords, key, label, params)
    end
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ INIT ██████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local sharedItems = {}

CreateThread(function()
    InitFramework()
    sharedItems = GetSharedItems()
end)

-- Helper: resolve a human-readable item label, falling back to the item key
local function ItemLabel(key)
    return (sharedItems[key] and sharedItems[key]['label']) or tostring(key)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FUNCTIONS █████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

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
            txt = 'Trade For '..v..' '..ItemLabel(k),
            params = {
                isAction = true,
                event = DeleteCarryItem,
                args = {{item = k, amount = v}, entity}
            }
        }
    end

    exports['lxr-menu']:openMenu(MenuItem)
    OpenMenu(MenuItem)
end

-- Select how many items you want to sell
local function SelectSaleAmount(data)
    local dialog = exports['lxr-input']:ShowInput({
        header = 'Item: '..sharedItems[data[1]]['label']..' $'..data[4]..' Each',
    local dialog = ShowInput({
        header = 'Item: '..ItemLabel(data[1])..' $'..data[4]..' Each',
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
-- Open the hunting shop
local function OpenShop()
    if not frameworkReady then
        InitFramework()
        sharedItems = GetSharedItems()
    end

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
        if CarryItem and CarryItem.butcher then
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
            local amount, slot = GetItemAmount(k)
            if amount then
                MenuItems[#MenuItems+1] = {
                    header = 'Item: '..ItemLabel(k),
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
    OpenMenu(MenuItems)
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ EVENTS ████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

AddEventHandler('LXRCore:Event:Looted', function(data)
    if not frameworkReady then return end
    if data.ped ~= PlayerPedId() or data.complete == 0 then return end
    local animal = GetEntityModel(data.target)
    local Animalitem = Config.Items['Pickup'][animal] and Config.Items['Pickup'][animal].skin
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
-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THREADS ███████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

CreateThread(function()
    -- Wait for framework init before spawning world entities
    while not frameworkReady do Wait(100) end

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
        CreatePrompt('Hunting:'..k, coords, 0xF3830D8E, 'Talk With Butcher', {
            type = 'callback', event = OpenShop
        })
    end
    SetModelAsNoLongerNeeded(location.PedModel)
end)
