--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-HUNTING — Offline tests: every animal's items exist, grade math, the take, locale parity
     Usage (from the lxr-hunting folder):  lua tests/run.lua [--mock out.js en|ka]
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE) os.exit(2) end
local Shim = require('tests.lib.fxshim')
for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/catalog.lua', 'shared/items.lua', 'shared/prices.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil Locale = nil
Shim.load('shared/locale.lua') Shim.load('locales/en.lua') Shim.load('locales/ka.lua') Shim.load('config.lua') Shim.load('shared/rules.lua')
local H = LXRHunting

local passed, failed = 0, 0
local function test(name, fn) local okT, err = xpcall(fn, debug.traceback) if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-hunting offline tests')
test('every animal maps to catalog items; models resolve both ways', function()
    local seen = {}
    for id, a in pairs(Config.Animals) do
        assert(#a.models > 0 and a.label and Config.Skin.seconds[a.size], id)
        if a.pelt then assert(LXRShared.Items[a.pelt], id .. ' pelt ' .. a.pelt) end
        assert(a.meat and LXRShared.Items[a.meat], id .. ' meat')
        assert(a.meatMin >= 1 and a.meatMax >= a.meatMin, id .. ' meat range')
        for _, x in ipairs(a.extras) do assert(LXRShared.Items[x.item], id .. ' extra ' .. x.item) assert(x.chance > 0 and x.chance <= 1) end
        for _, m in ipairs(a.models) do
            assert(not seen[m], 'model listed twice: ' .. m) seen[m] = true
            local got = H.Animal(m) eq(got, id, m)
            eq(H.Animal(joaat(m)), id)
        end
    end
    assert(H.Animal('a_c_horse_01') == nil)
    for _, c in pairs(Config.Skin.carcass) do assert(LXRShared.Items[c], c) end
    assert(LXRShared.Items[Config.Skin.knife] and LXRShared.Items[Config.License.item])
    eq(#H.Models(), (function() local n = 0 for _ in pairs(seen) do n = n + 1 end return n end)())
end)
test('grade: the game judges, we round', function()
    eq(H.Grade(0, 0), 1) eq(H.Grade(2, 2), 3) eq(H.Grade(1, 1), 2)
    eq(H.Grade(2, 0), 2) eq(H.Grade(0, 2), 2)
    eq(H.Grade(-1, -1), 1, 'unknown is poor') eq(H.Grade(9, 9), 3, 'clamped')
    eq(H.Grade(nil, nil), 1)
end)
test('the take: pelt carries the grade, meat in range, extras by chance, carcass by size', function()
    local t = H.Take('deer', 3, function() return 0.0 end, function(n) return n end)
    eq(t[1].item, 'pelt_deer') eq(t[1].quality, 3)
    eq(t[2].item, 'meat_venison') eq(t[2].amount, Config.Animals.deer.meatMax)
    assert(#t == 4, 'both extras taken at rnd 0: ' .. #t)
    local none = H.Take('deer', 1, function() return 1.0 end, function(n) return 1 end)
    eq(#none, 2) eq(none[2].amount, Config.Animals.deer.meatMin)
    local rabbit = H.Take('rabbit', 2, function() return 1.0 end, function(n) return 1 end)
    eq(rabbit[#rabbit].item, 'carcass_small')
    local duck = H.Take('duck', 2, function() return 1.0 end, function(n) return 1 end)
    eq(duck[1].item, 'meat_plump_bird', 'birds have no pelt') eq(duck[#duck].item, 'carcass_bird')
    eq(#H.Take('nothing', 1), 0)
    eq(H.Seconds('bear'), Config.Skin.seconds.large * 1000)
end)
test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)
print(('%d passed, %d failed'):format(passed, failed))
if arg and arg[1] == '--mock' and arg[2] then
    Config.Lang = arg[3] or 'en'
    local got = {}
    for _, l in ipairs(H.Take('elk', 3, function() return 0.0 end, function(n) return math.ceil(n / 2) end)) do got[#got + 1] = { item = l.item, label = LXRShared.Items[l.item].label, amount = l.amount, quality = l.quality } end
    local f = assert(io.open(arg[2], 'w'))
    f:write('window.__LXR_MOCK__ = ' .. json.encode({ action = 'show', payload = { animal = 'elk', label = Config.Animals.elk.label, grade = 3, got = got, left = {}, poached = false }, lang = Config.Lang, locale = Lang.bundle(), brand = { name = 'The Land of Wolves', theme = 'night' } }) .. ';\n')
    f:close()
    print('mock written to ' .. arg[2])
end
os.exit(failed == 0 and 0 or 1)
