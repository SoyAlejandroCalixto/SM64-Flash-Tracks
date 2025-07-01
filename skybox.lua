E_MODEL_SKYBOX_CUBE = smlua_model_util_get_id("Lobby_CubeSkybox_geo")
local l = gLakituState

function bhv_skybox_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.header.gfx.skipInViewCheck = true
    obj_scale(o, 10.0)
end

function bhv_skybox_loop(o)
    o.oPosX = l.pos.x
    o.oPosY = l.pos.y
    o.oPosZ = l.pos.z
end

id_bhv3DSkybox = hook_behavior(nil, OBJ_LIST_LEVEL, false, bhv_skybox_init, bhv_skybox_loop)

function SpawnSkybox()
    if gNetworkPlayers[0].currLevelNum == LEVEL_LOBBY or gNetworkPlayers[0].currLevelNum == LEVEL_WINNER_PRESENTATION then
        spawn_non_sync_object(id_bhv3DSkybox, E_MODEL_SKYBOX_CUBE, l.pos.x, l.pos.y, l.pos.z, function() end)
    end
end

hook_event(HOOK_ON_LEVEL_INIT, SpawnSkybox)
