--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-HUNTING — Server: the skin, marked on the animal
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local H = LXRHunting
local RES = GetCurrentResourceName()
local buckets = {}

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function player(src) return LXRCore.Functions.GetPlayer(src) end
local function lawOnDuty()
    for _, P in pairs(LXRCore.Players) do
        local def = LXRShared.Jobs[P.PlayerData.job.name]
        if def and (def.type == 'leo' or def.type == 'federal') and P.PlayerData.job.onduty then return true end
    end
    return false
end
local function wearKnife(src)
    local it = LXRCore.Inventory.GetItem(src, Config.Skin.knife)
    if not it then return false end
    local def = LXRShared.Items[Config.Skin.knife]
    if def and def.quality and it.slot then
        local info = {} for k, v in pairs(it.info or {}) do info[k] = v end
        info.durability = math.max(0, (tonumber(info.durability) or 100) - Config.Skin.wear)
        LXRCore.Inventory.SetMetadata(src, it.slot, info)
    end
    return true
end

---quality / cleanliness come from the client's natives; the server clamps them and does everything else itself
LXR.RPC.Register('lxr-hunting:skin', function(src, netId, quality, cleanliness)
    if limited(src) then return false, 'rate' end
    local P = player(src)
    local ent = netId and NetworkGetEntityFromNetworkId(netId)
    if not P or not ent or ent == 0 or not DoesEntityExist(ent) then return false, 'invalid' end
    local id, a = H.Animal(GetEntityModel(ent))
    if not id then return false, 'invalid' end
    if GetEntityHealth(ent) > 0 then return false, 'alive' end
    local ped = GetPlayerPed(src)
    if ped == 0 or #(GetEntityCoords(ped) - GetEntityCoords(ent)) > Config.Security.maxDistance then return false, 'too_far' end
    local st = Entity(ent).state
    if st.skinned then return false, 'skinned' end
    if LXRCore.Inventory.GetItemCount(src, Config.Skin.knife) < 1 then return false, 'no_knife', LXRShared.Items[Config.Skin.knife].label end
    st:set('skinned', true, true)
    local grade = H.Grade(quality, cleanliness)
    local take = H.Take(id, grade)
    local got, left = {}, {}
    for _, line in ipairs(take) do
        local info = line.quality and { quality = line.quality } or nil
        if LXRCore.Inventory.CanCarry(src, line.item, line.amount) and P.Functions.AddItem(line.item, line.amount, nil, info, 'hunting:' .. id) then
            got[#got + 1] = { item = line.item, label = LXRShared.Items[line.item].label, amount = line.amount, quality = line.quality }
        else
            left[#left + 1] = LXRShared.Items[line.item].label
        end
    end
    wearKnife(src)
    local poached = false
    if Config.License.required and LXRCore.Inventory.GetItemCount(src, Config.License.item) < 1 then
        poached = true
        if math.random() < Config.License.reportChance and GetResourceState('lxr-dispatch') == 'started' and lawOnDuty() then
            exports['lxr-dispatch']:Raise({ kind = Config.License.kind, coords = GetEntityCoords(ent), title = Lang:t('call.poaching'), message = Lang:t('call.poaching_msg', { animal = a.label }) })
        end
    end
    LXRCore.Emit('lxr:hunting:skinned', nil, src, id, grade, got)
    if Config.Debug.log then LXRCore.Log.info('hunting', ('skinned %s grade %d (%d items)'):format(id, grade, #got), { source = src }) end
    return true, { animal = id, label = a.label, grade = grade, got = got, left = left, poached = poached }
end)

AddEventHandler('playerDropped', function() buckets[source] = nil end)
CreateThread(function() if Config.Debug.printBanner then local n = 0 for _ in pairs(Config.Animals) do n = n + 1 end print(('^1[lxr-hunting]^7 v%s — %d animals, %d models'):format(GetResourceMetadata(RES, 'version', 0), n, #H.Models())) end end)
exports('Animal', H.Animal)
exports('Grade', H.Grade)
