--[[
    ██╗     ██╗  ██╗██████╗        ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██╗███╗   ██╗ ██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗███████║██║   ██║██╔██╗ ██║   ██║   ██║██╔██╗ ██║██║  ███╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██╔══██║██║   ██║██║╚██╗██║   ██║   ██║██║╚██╗██║██║   ██║
    ███████╗██╔╝ ██╗██║  ██║      ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║██║ ╚████║╚██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝

    🐺 LXR Hunting — Advanced Hunting System for RedM

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:      The Land of Wolves 🐺
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 1.0.0
    Framework Support: LXR-Core (Primary), RSG-Core, VORP Core, Standalone

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name        'lxr-hunting'
description 'LXR Hunting — Advanced hunting system for RedM | wolves.land'
author      'iBoss21 / The Lux Empire (wolves.land)'
version     '1.0.0'

shared_script 'config.lua'

client_script 'client/client.lua'

server_script 'server/server.lua'

-- dependencies block is intentionally omitted:
-- this resource supports LXR-Core, RSG-Core, VORP Core, and Standalone.
-- Ensure the correct framework is started before this resource.

lua54 'yes'
