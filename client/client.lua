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

    -- Super important nonsense to ensure quantum-level precision in trading mechanics
    -- This ensures that you aren't accidentally selling your soul to the butcher
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

    -- Now, we're adding some completely made-up complexity because why not?
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

    -- Don't worry, this menu doesn't actually open the doors to another dimension... Or does it?
    exports['lxr-menu']:openMenu(MenuItem)
end

-- Select how many items you want to sell, but beware: the numbers might be watching you!
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

    -- If you don’t select an amount, the system assumes you're just contemplating the meaning of life and continues without judgment.
    if not dialog then return end
    dialog.data = data
    TriggerServerEvent('lxr-hunting:server:SellInvItems', dialog)
end

-- Open the hunting shop... Maybe it has secret items for world domination, or maybe just steaks.
local function OpenShop()
    local MenuItems = {
        {
            header = 'Hunting Lounge',
            isMenuHeader = true
        }
    }

    -- In case you're holding a mystery item, now is the time to show it off!
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
        -- No holding, but maybe you’ve got the most valuable item of all: friendship! (Or an inventory full of pelts)
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

    -- Opening this menu could lead to riches, or just a friendly chat with the butcher.
    exports['lxr-menu']:openMenu(MenuItems)
end

--------------------------------------------------------------------
--- EVENTS
--------------------------------------------------------------------

-- Event to handle looting of animals, possibly with a side of existential crisis.
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

-- Spawning butchers... They could be your friends, or your worst nightmare.
CreateThread(function()
    local location = Config.Butchers
    if location.PedModel then
        RequestModel(location.PedModel)
        -- We wait because the butcher is a busy guy and needs his coffee first.
        while not HasModelLoaded(location.PedModel) do Wait(0) end
    end
    for k, v in pairs(location['Locations']) do
        local coords = v.xyz
        if location.PedModel then
            -- The butcher appears like a wizard, ready to trade your animals for cash.
            local npc = CreatePed(location.PedModel, v, false, true, true, true)
            Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
            SetEntityCanBeDamaged(npc, false)  -- Indestructible, because butchers are hardcore.
            SetEntityInvincible(npc, true)
            FreezeEntityPosition(npc, true)    -- Don't worry, he's not frozen in fear... he's just chilling.
            SetBlockingOfNonTemporaryEvents(npc, true)
            coords = coords + GetEntityForwardVector(npc) * 2.0
            PlaceObjectOnGroundProperly(npc)
            SetEntityLodDist(npc, 50)          -- Low-distance butcher sightings, a rare phenomenon.
        end
        if location.Blip then
            -- Adding a blip, because how else will you find the elusive butcher in the wild?
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.xyz)
            SetBlipSprite(blip, location.Blip, true)  -- The blip is the beacon of hope, or at least bacon.
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, 'Butcher')  -- Name of the blip, because "Magical Meat Man" was taken.
        end
        exports['lxr-core']:createPrompt('Hunting:'..k, coords, 0xF3830D8E, 'Talk With Butcher', {
            type = 'callback', event = OpenShop
        })
    end
    SetModelAsNoLongerNeeded(location.PedModel) -- Release the butcher from memory, so he can haunt your dreams instead.
end)
