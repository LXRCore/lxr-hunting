--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-HUNTING — Client: the prompt on a dead animal, the game's judgement of the kill
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local H = LXRHunting
local N = Citizen.InvokeNative
local busy = false

local function toast(key, kind, vars) LXRCore.Notify(Lang:t(key, vars), kind or 'info') end
local function page(action, payload) SendNUIMessage({ action = action, payload = payload, brand = LXRCore.Brand, lang = Config.Lang, locale = Lang.bundle() }) end
local function skinned(e) return e and e ~= 0 and Entity(e).state.skinned == true end
local function dead(e) return e and e ~= 0 and DoesEntityExist(e) and IsEntityDead(e) end

local function skin(d)
    local e = d.entity
    if busy or not dead(e) or skinned(e) then return end
    local id = H.Animal(GetEntityModel(e))
    if not id then return end
    local quality = N(0x7BCC6087D130312A, e, Citizen.ReturnResultAnyway(), Citizen.ResultAsInteger())       -- GetPedQuality
    local clean = N(0x88EFFED5FE8B0B4A, e, Citizen.ReturnResultAnyway(), Citizen.ResultAsInteger())         -- GetPedDamageCleanliness
    busy = true
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, e, 800) Wait(800)
    N(0x524B54361229154F, ped, joaat(Config.Skin.scenario), H.Seconds(id), true, false, false, false)
    Wait(H.Seconds(id))
    ClearPedTasks(ped)
    busy = false
    local ok, res, extra = LXR.RPC.Server('lxr-hunting:skin', d.netId, quality, clean)
    if not ok then return toast('error.' .. tostring(res), 'error', { label = extra }) end
    page('show', res)
    if #res.left > 0 then toast('error.left', 'warning', { items = table.concat(res.left, ', ') }) end
    if res.poached then toast('info.poached', 'warning') end
end

CreateThread(function()
    while GetResourceState('lxr-interact') ~= 'started' do Wait(1000) end
    exports['lxr-interact']:AddModel('lxr-hunting:animal', H.Models(), { label = Lang:t('ui.animal'), distance = Config.Security.promptDistance, options = {
        { label = Lang:t('ui.skin'), key = 'J', item = Config.Skin.knife, canInteract = function(e) return not busy and dead(e) and not skinned(e) end, onSelect = skin },
    }})
end)

RegisterNUICallback('close', function(_, cb) cb('ok') end)
AddEventHandler('onResourceStop', function(res) if res == GetCurrentResourceName() then exports['lxr-interact']:Remove('lxr-hunting:animal') end end)
exports('Busy', function() return busy end)
