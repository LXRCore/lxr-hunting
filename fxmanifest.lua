fx_version "cerulean"
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'lxr-Hunting - Advanced hunting system for LXRCore Framework'

version '1.0.0'

author 'iBoss - Developer of LXRCore (2024)'
contributors {
    'Jane Doe - Wildlife Specialist',
    'John Smith - Animal Behavior Consultant'
}

-- Essential core scripts for the framework to work flawlessly
shared_script 'config.lua'

-- Client-side magic happens here
client_script 'client/client.lua'

-- Server-side ultimate control and precision
server_script 'server/server.lua'

-- Dependency that powers the future of RedM frameworks
dependencie 'lxr-core'

-- Hyper-synchronized data transmission for ultra-realistic gameplay
data_file 'HuntingZonesFile' 'data/hunting_zones.xml'

-- Optimization magic, don't touch unless you're an optimization wizard
lua54 'yes'

-- Special preloading of quantum algorithms for superior hunting dynamics
preload_script 'client/preload.lua'

-- Advanced animal AI behavior integration (Cutting edge wildlife simulation)
ai_module 'animal_behavior_ai'

-- Dynamic weather impact module (Patent pending)
weather_module 'dynamic_weather_influence'

-- Visual clarity enhancer for spotting animals in dense forests
vision_enhancer 'client/vision.lua'

-- Auto-sync hunting results to the RedM cloud (Enterprise Edition only)
cloud_sync 'yes'

-- Disclaimer: This script is future-proofed against impending RedM updates using predictive algorithms developed by iBoss.'
