--[[
    ██╗     ██╗  ██╗██████╗        ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██╗███╗   ██╗ ██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗███████║██║   ██║██╔██╗ ██║   ██║   ██║██╔██╗ ██║██║  ███╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██║██║   ██║██║╚██╗██║   ██║   ██║██║╚██╗██║██║   ██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║██║ ╚████║╚██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝

    🐺 LXR Hunting — Server Script
    The Land of Wolves | wolves.land

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK BRIDGE ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

local FrameworkName = nil

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
end

-- Get a player object from source (server-side)
local function GetPlayer(src)
    if FrameworkName == 'lxr-core' then
        return exports['lxr-core']:GetPlayer(src)
    elseif FrameworkName == 'rsg-core' then
        return exports['rsg-core']:GetPlayer(src)
    elseif FrameworkName == 'vorp_core' then
        return exports['vorp_core']:GetUser(src)
    end
    return nil
end

-- Add an item to a player's inventory
local function AddItem(player, item, amount)
    if FrameworkName == 'lxr-core' or FrameworkName == 'rsg-core' then
        return player.Functions.AddItem(item, amount)
    elseif FrameworkName == 'vorp_core' then
        return exports['vorp_inventory']:addItem(player.source, item, amount)
    end
    return false
end

-- Remove an item from a player's inventory
local function RemoveItem(player, item, amount, slot)
    if FrameworkName == 'lxr-core' or FrameworkName == 'rsg-core' then
        return player.Functions.RemoveItem(item, amount, slot)
    elseif FrameworkName == 'vorp_core' then
        return exports['vorp_inventory']:removeItem(player.source, item, amount)
    end
    return false
end

-- Add money to a player
-- NOTE: VORP Core uses a single cash pool and does not differentiate accounts
-- (e.g. 'cash' vs 'gold'). The 'account' and 'reason' parameters are ignored
-- for VORP. Adjust the export call below if your VORP version supports them.
local function AddMoney(player, account, amount, reason)
    if FrameworkName == 'lxr-core' or FrameworkName == 'rsg-core' then
        return player.Functions.AddMoney(account, amount, reason)
    elseif FrameworkName == 'vorp_core' then
        return exports['vorp_core']:AddMoney(player.source, amount)
    end
    return false
end

-- Add XP to a player for the given skill
-- NOTE: VORP Core does not expose a generic XP API via exports; XP gain is
-- skipped silently for VORP. Implement a custom handler below if required.
local function AddXp(player, skill, amount)
    if FrameworkName == 'lxr-core' or FrameworkName == 'rsg-core' then
        if player.Functions.AddXp then
            return player.Functions.AddXp(skill, amount)
        end
        -- Log a warning only in development; remove for production
        -- print(('[lxr-hunting] Warning: AddXp not available on this framework build'))
    end
    -- VORP / Standalone: XP not supported — no-op
    return false
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ INIT ██████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitFramework()
    end
end)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ EVENTS ████████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent('lxr-hunting:server:AnimalItem', function(data)
    local src = source
    local Player = GetPlayer(src)
    if data.quality == nil or not Player then return end
    if AddItem(Player, data.item, data.amount or 1) then
        if data.quality then
            AddXp(Player, 'hunting', data.quality)
        end
    end
end)

RegisterNetEvent('lxr-hunting:server:SellInvItems', function(data)
    local src = source
    local Player = GetPlayer(src)
    local item, slot = table.unpack(data.data)
    if not (item and slot and Player) then return end
    local GiveItem = Config.Items['Inv'][item]
    if not GiveItem then return end
    if RemoveItem(Player, item, data.amount, slot) then
        AddMoney(Player, 'cash', GiveItem * data.amount, 'Sold-Hunting-Items')
    end
end)

RegisterNetEvent('lxr-hunting:server:SellCarryItems', function(data)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end
    if type(data) == 'table' then
        return AddItem(Player, data.item, data.amount)
    end
    AddMoney(Player, 'cash', tonumber(data), 'Sold-Hunting-Items')
end)
