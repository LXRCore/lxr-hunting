--[[
    ██╗     ██╗  ██╗██████╗       ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██╗███╗   ██╗ ██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗███████║██║   ██║██╔██╗ ██║   ██║   ██║██╔██╗ ██║██║  ███╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██║██║   ██║██║╚██╗██║   ██║   ██║██║╚██╗██║██║   ██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║██║ ╚████║╚██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝

    LXR Core - Hunting

    The game spawns the animals and judges the kill: it knows how good the
    animal was (GetPedQuality) and how clean the shot (GetPedDamageCleanliness).
    This resource turns that into a pelt with a quality grade, meat by the
    size of the beast, the odd trophy, and a carcass you can sell whole. A
    skinned animal is marked on the entity itself, so it is skinned once.
    Every item here is the core catalog's; the trapper and the butcher buy
    them on their usual shelves.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (the prompt is lxr-interact's; nothing scans here)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ANIMALS ═══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
-- model → what comes off it. size: small (carcass_small), bird (carcass_bird),
-- medium (carcass_medium), large (skinned where it fell, no carcass item).
-- extras: { item, chance 0..1, amount? }. Every item is a core catalog item.
local function A(models, label, size, pelt, meat, meatMin, meatMax, extras)
    return { models = models, label = label, size = size, pelt = pelt, meat = meat, meatMin = meatMin, meatMax = meatMax, extras = extras or {} }
end
Config.Animals = {
    deer      = A({ 'a_c_deer_01' }, 'Whitetail Deer', 'large', 'pelt_deer', 'meat_venison', 2, 4, { { item = 'antlers', chance = 0.5 }, { item = 'sinew', chance = 0.6, amount = 2 } }),
    elk       = A({ 'a_c_elk_01' }, 'Elk', 'large', 'pelt_elk', 'meat_big_game', 3, 5, { { item = 'antlers_elk', chance = 0.5 }, { item = 'sinew', chance = 0.7, amount = 3 } }),
    moose     = A({ 'a_c_moose_01' }, 'Moose', 'large', 'pelt_moose', 'meat_big_game', 4, 6, { { item = 'antlers_moose', chance = 0.5 } }),
    pronghorn = A({ 'a_c_pronghorn_01' }, 'Pronghorn', 'large', 'pelt_pronghorn', 'meat_venison', 2, 3, { { item = 'sinew', chance = 0.5, amount = 2 } }),
    bighorn   = A({ 'a_c_bighornram_01' }, 'Bighorn', 'large', 'pelt_bighorn', 'meat_mutton', 2, 4, { { item = 'horn_bighorn', chance = 0.6 } }),
    bison     = A({ 'a_c_buffalo_01', 'a_c_buffalo_tatanka_01' }, 'Bison', 'large', 'pelt_bison', 'meat_big_game', 5, 8, { { item = 'horn_bison', chance = 0.7 }, { item = 'animal_fat', chance = 0.9, amount = 3 } }),
    bear      = A({ 'a_c_bear_01', 'a_c_bearblack_01' }, 'Bear', 'large', 'pelt_bear', 'meat_big_game', 4, 7, { { item = 'claw_bear', chance = 0.5 }, { item = 'tooth_bear', chance = 0.35 }, { item = 'animal_fat', chance = 0.9, amount = 4 } }),
    cougar    = A({ 'a_c_cougar_01' }, 'Cougar', 'large', 'pelt_cougar', 'meat_stringy', 2, 3, { { item = 'fang_cougar', chance = 0.4 } }),
    panther   = A({ 'a_c_panther_01' }, 'Panther', 'large', 'pelt_panther', 'meat_stringy', 2, 3, { { item = 'fang_cougar', chance = 0.4 } }),
    wolf      = A({ 'a_c_wolf', 'a_c_wolf_medium', 'a_c_wolf_small' }, 'Wolf', 'medium', 'pelt_wolf', 'meat_stringy', 1, 3, { { item = 'bone', chance = 0.5, amount = 2 } }),
    coyote    = A({ 'a_c_coyote_01' }, 'Coyote', 'medium', 'pelt_coyote', 'meat_stringy', 1, 2),
    fox       = A({ 'a_c_fox_01' }, 'Fox', 'medium', 'pelt_fox', 'meat_stringy', 1, 1),
    boar      = A({ 'a_c_boar_01' }, 'Boar', 'large', 'pelt_boar', 'meat_pork', 2, 4, { { item = 'animal_fat', chance = 0.8, amount = 2 } }),
    pig       = A({ 'a_c_pig_01' }, 'Pig', 'large', 'pelt_boar', 'meat_pork', 3, 5, { { item = 'animal_fat', chance = 0.9, amount = 3 } }),
    beaver    = A({ 'a_c_beaver_01' }, 'Beaver', 'medium', 'pelt_beaver', 'meat_gamey', 1, 2, { { item = 'tail_beaver', chance = 0.8 } }),
    rabbit    = A({ 'a_c_rabbit_01' }, 'Rabbit', 'small', 'pelt_rabbit', 'meat_gamey', 1, 1),
    raccoon   = A({ 'a_c_raccoon_01' }, 'Raccoon', 'small', 'pelt_raccoon', 'meat_gamey', 1, 1),
    badger    = A({ 'a_c_badger_01' }, 'Badger', 'small', 'pelt_badger', 'meat_gamey', 1, 1),
    muskrat   = A({ 'a_c_muskrat_01' }, 'Muskrat', 'small', 'pelt_muskrat', 'meat_gamey', 1, 1),
    skunk     = A({ 'a_c_skunk_01' }, 'Skunk', 'small', 'pelt_skunk', 'meat_gamey', 1, 1),
    opossum   = A({ 'a_c_possum_01' }, 'Opossum', 'small', 'pelt_opossum', 'meat_gamey', 1, 1),
    squirrel  = A({ 'a_c_squirrel_01' }, 'Squirrel', 'small', 'pelt_squirrel', 'meat_gamey', 1, 1),
    goat      = A({ 'a_c_goat_01' }, 'Goat', 'medium', 'pelt_goat', 'meat_mutton', 1, 2),
    sheep     = A({ 'a_c_sheep_01' }, 'Sheep', 'large', 'pelt_sheep', 'meat_mutton', 2, 3),
    cow       = A({ 'a_c_cow', 'a_c_bull_01', 'a_c_ox_01' }, 'Cattle', 'large', 'hide_cow', 'meat_beef', 4, 7, { { item = 'animal_fat', chance = 0.9, amount = 3 }, { item = 'bone', chance = 0.7, amount = 3 } }),
    gator     = A({ 'a_c_alligator_01', 'a_c_alligator_02', 'a_c_alligator_03' }, 'Alligator', 'large', 'hide_gator', 'meat_gator', 2, 4, { { item = 'tooth_gator', chance = 0.6 } }),
    snake     = A({ 'a_c_snake_01', 'a_c_snakeblacktailrattle_01', 'a_c_snakeferdelance_01', 'a_c_snakeredboa_01', 'a_c_snakewater_01', 'a_c_snake_pelican_01' }, 'Snake', 'small', 'hide_snake', 'meat_gristly', 1, 1),
    turkey    = A({ 'a_c_turkey_01', 'a_c_turkey_02' }, 'Turkey', 'bird', nil, 'meat_plump_bird', 1, 2, { { item = 'feather_turkey', chance = 0.9, amount = 3 } }),
    duck      = A({ 'a_c_duck_01' }, 'Duck', 'bird', nil, 'meat_plump_bird', 1, 1),
    goose     = A({ 'a_c_goosecanada_01' }, 'Goose', 'bird', nil, 'meat_plump_bird', 1, 2),
    pheasant  = A({ 'a_c_pheasant_01' }, 'Pheasant', 'bird', nil, 'meat_plump_bird', 1, 1),
    chicken   = A({ 'a_c_chicken_01' }, 'Chicken', 'bird', nil, 'meat_plump_bird', 1, 1),
    heron     = A({ 'a_c_heron_01' }, 'Heron', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_heron', chance = 0.6 } }),
    egret     = A({ 'a_c_egret_01' }, 'Egret', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_egret', chance = 0.6 } }),
    spoonbill = A({ 'a_c_spoonbill_01' }, 'Spoonbill', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_spoonbill', chance = 0.6 } }),
    eagle     = A({ 'a_c_eagle_01' }, 'Eagle', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_eagle', chance = 0.5 } }),
    hawk      = A({ 'a_c_hawk_01' }, 'Hawk', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_hawk', chance = 0.6 } }),
    owl       = A({ 'a_c_owl_01' }, 'Owl', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_owl', chance = 0.6 } }),
    crow      = A({ 'a_c_crow_01', 'a_c_raven_01' }, 'Crow', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_crow', chance = 0.8, amount = 2 } }),
    -- the rest of the game's wild animals (every model from the game's ped list)
    buck      = A({ 'a_c_buck_01' }, 'Whitetail Buck', 'large', 'pelt_deer', 'meat_venison', 3, 5, { { item = 'antlers', chance = 0.9 }, { item = 'sinew', chance = 0.6, amount = 2 } }),
    wolf_gray = A({ 'a_c_wolf_01' }, 'Timber Wolf', 'medium', 'pelt_wolf', 'meat_stringy', 1, 3, { { item = 'bone', chance = 0.5, amount = 2 } }),
    lion      = A({ 'a_c_lionmangy_01' }, 'Lion', 'large', 'pelt_lion', 'meat_stringy', 3, 5, { { item = 'fang_cougar', chance = 0.8, amount = 2 } }),
    javelina  = A({ 'a_c_javelina_01' }, 'Javelina', 'medium', 'pelt_javelina', 'meat_pork', 1, 3, { { item = 'animal_fat', chance = 0.6 } }),
    armadillo = A({ 'a_c_armadillo_01' }, 'Armadillo', 'small', 'pelt_armadillo', 'meat_gamey', 1, 1),
    iguana    = A({ 'a_c_iguana_01', 'a_c_iguanadesert_01' }, 'Iguana', 'small', 'pelt_iguana', 'meat_stringy', 1, 1),
    gila      = A({ 'a_c_gilamonster_01' }, 'Gila Monster', 'small', nil, 'meat_stringy', 1, 1, { { item = 'gila_venom', chance = 0.7 } }),
    chipmunk  = A({ 'a_c_chipmunk_01' }, 'Chipmunk', 'small', nil, 'meat_gamey', 1, 1),
    bat       = A({ 'a_c_bat_01' }, 'Bat', 'small', nil, 'meat_gristly', 1, 1, { { item = 'bat_wing', chance = 0.9, amount = 2 } }),
    toad      = A({ 'a_c_toad_01' }, 'Toad', 'small', nil, 'meat_gamey', 1, 1),
    turtle    = A({ 'a_c_turtlesnapping_01', 'a_c_turtlesea_01' }, 'Turtle', 'small', 'shell_turtle', 'meat_gamey', 1, 2),
    crab      = A({ 'a_c_crab_01' }, 'Crab', 'small', nil, 'meat_gamey', 1, 1),
    crawfish  = A({ 'a_c_crawfish_01' }, 'Crawfish', 'small', nil, 'meat_gamey', 1, 1),
    wildturkey= A({ 'a_c_turkeywild_01' }, 'Wild Turkey', 'bird', nil, 'meat_plump_bird', 1, 2, { { item = 'feather_turkey', chance = 0.9, amount = 3 } }),
    quail     = A({ 'a_c_quail_01' }, 'Quail', 'bird', nil, 'meat_plump_bird', 1, 1, { { item = 'feather_quail', chance = 0.8, amount = 2 } }),
    condor    = A({ 'a_c_californiacondor_01' }, 'Condor', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_condor', chance = 0.7 } }),
    vulture   = A({ 'a_c_vulture_01' }, 'Vulture', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_vulture', chance = 0.8, amount = 2 } }),
    crane     = A({ 'a_c_cranewhooping_01' }, 'Whooping Crane', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_crane', chance = 0.7 } }),
    loon      = A({ 'a_c_loon_01' }, 'Loon', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_seabird', chance = 0.7, amount = 2 } }),
    pelican   = A({ 'a_c_pelican_01' }, 'Pelican', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_seabird', chance = 0.8, amount = 3 } }),
    seagull   = A({ 'a_c_seagull_01' }, 'Seagull', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_seabird', chance = 0.8, amount = 2 } }),
    cormorant = A({ 'a_c_cormorant_01' }, 'Cormorant', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_seabird', chance = 0.8, amount = 2 } }),
    booby     = A({ 'a_c_redfootedbooby_01' }, 'Booby', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_seabird', chance = 0.8, amount = 2 } }),
    roseate   = A({ 'a_c_roseatespoonbill_01' }, 'Roseate Spoonbill', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_spoonbill', chance = 0.6 } }),
    songbird  = A({ 'a_c_songbird_01', 'a_c_bluejay_01', 'a_c_cardinal_01', 'a_c_carolinaparakeet_01', 'a_c_cedarwaxwing_01', 'a_c_oriole_01', 'a_c_parrot_01', 'a_c_robin_01', 'a_c_sparrow_01', 'a_c_woodpecker_01', 'a_c_woodpecker_02' }, 'Songbird', 'bird', nil, 'meat_gristly', 1, 1, { { item = 'feather_songbird', chance = 0.9, amount = 2 } }),
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE KNIFE, THE GRADE, THE LICENSE ═════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Skin = {
    knife = 'skinning_knife',    -- the proper tool: graded, wears by `wear` per skin
    -- any of these opens a carcass (a hunting knife from the starter kit is enough); the first one in the satchel is used
    knives = { 'skinning_knife', 'weapon_melee_knife', 'weapon_melee_knife_bear', 'weapon_melee_knife_civil_war', 'weapon_melee_knife_jawbone', 'weapon_melee_knife_miner' },
    wear = 2,
    seconds = { small = 3, bird = 2, medium = 5, large = 8 },
    scenario = 'WORLD_HUMAN_CROUCH_INSPECT',
    carcass = { small = 'carcass_small', bird = 'carcass_bird', medium = 'carcass_medium' },
}
-- pelt grade 1..3 from the game's own judgement: animal quality (0 poor..2 high) and damage cleanliness (0 poor..2 perfect)
Config.Grade = { weightQuality = 1.0, weightCleanliness = 1.0 }

Config.License = {
    required = true,             -- skinning without `item` can be reported
    item = 'hunting_license',
    reportChance = 0.2,          -- to lxr-dispatch, kind below, when law is on duty
    kind = 'lawcall',
}

Config.Security = { rateLimit = { windowMs = 2000, burst = 4 }, maxDistance = 4.0, promptDistance = 2.5 }
Config.Debug = { printBanner = true, log = true }
