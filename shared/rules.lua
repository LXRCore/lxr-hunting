--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-HUNTING — Shared rules: which animal, what grade, what comes off it
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRHunting = LXRHunting or {}
local H = LXRHunting
local byHash

local function index()
    if byHash then return byHash end
    byHash = {}
    for id, a in pairs(Config.Animals) do for _, m in ipairs(a.models) do byHash[joaat(m)] = id end end
    return byHash
end

---Animal id for a model hash (or name), or nil.
function H.Animal(model)
    if type(model) == 'string' then model = joaat(model) end
    local id = index()[model]
    return id, id and Config.Animals[id]
end

---Every model name this resource knows (for the interact model set).
function H.Models()
    local out = {}
    for _, a in pairs(Config.Animals) do for _, m in ipairs(a.models) do out[#out + 1] = m end end
    table.sort(out)
    return out
end

---Pelt grade 1..3 from the game's animal quality (0..2) and damage cleanliness (0..2). Unknown (-1) counts as 0.
function H.Grade(quality, cleanliness)
    quality = math.max(0, math.min(2, tonumber(quality) or 0))
    cleanliness = math.max(0, math.min(2, tonumber(cleanliness) or 0))
    local g = Config.Grade
    local score = (quality * g.weightQuality + cleanliness * g.weightCleanliness) / (g.weightQuality + g.weightCleanliness)
    return math.max(1, math.min(3, math.floor(score + 0.5) + 1))
end

---What a skin gives: { { item, amount, quality? }, ... } with an injectable rng (0..1) and int rng (1..n).
function H.Take(animalId, grade, rnd, rndInt)
    local a = Config.Animals[animalId]
    if not a then return {} end
    rnd = rnd or math.random
    rndInt = rndInt or math.random
    local out = {}
    if a.pelt then out[#out + 1] = { item = a.pelt, amount = 1, quality = grade } end
    if a.meat then out[#out + 1] = { item = a.meat, amount = a.meatMin + rndInt(a.meatMax - a.meatMin + 1) - 1 } end
    for _, x in ipairs(a.extras) do if rnd() < x.chance then out[#out + 1] = { item = x.item, amount = x.amount or 1 } end end
    local carcass = Config.Skin.carcass[a.size]
    if carcass then out[#out + 1] = { item = carcass, amount = 1 } end
    return out
end

function H.Seconds(animalId)
    local a = Config.Animals[animalId]
    return ((a and Config.Skin.seconds[a.size]) or 4) * 1000
end
