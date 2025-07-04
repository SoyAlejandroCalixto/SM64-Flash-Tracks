local MUSIC_COMET_OBSERVATORY = audio_stream_load("comet_observatory.mp3")
local MUSIC_BEACH_BOWL_GALAXY = audio_stream_load("beach_bowl_galaxy.mp3")
local MUSIC_CASCADE_KINGDOM = audio_stream_load("cascade_kingdom.mp3")
local MUSIC_PURPLE_COINS = audio_stream_load("purple_coins.mp3")
local MUSIC_N64_RAINBOW_ROAD = audio_stream_load("n64_rainbow_road.mp3")
local MUSIC_GCN_RAINBOW_ROAD = audio_stream_load("gcn_rainbow_road.mp3")
local MUSIC_FLYING_MARIO = audio_stream_load("flying_mario.mp3")
MUSIC_WIN = audio_stream_load("win.mp3")

-- Vanilla powerups background music IDs.
local VANILLA_WING_CAP_MUSIC = 1038
local VANILLA_METAL_CAP_MUSIC = 1039
local VANILLA_SHELL_MUSIC = 1166

----------------.

--- Returns the ModAudio that corresponds to the level you are at.
---@return ModAudio
local function get_level_background_music()
    if gNetworkPlayers[0].currLevelNum == LEVEL_REAL_RUMBLE then
        return MUSIC_CASCADE_KINGDOM
    elseif gNetworkPlayers[0].currLevelNum == LEVEL_TURTLES_PACE then
        return MUSIC_BEACH_BOWL_GALAXY
    elseif gNetworkPlayers[0].currLevelNum == LEVEL_SLIPPERY_PLACE then
        return MUSIC_PURPLE_COINS
    else
        return MUSIC_COMET_OBSERVATORY
    end
end

---@param audio_stream ModAudio
function change_music(audio_stream)
    stop_background_music(get_current_background_music()) -- Stop vanilla music (if any is playing).

    if bg_music and bg_music.loaded then
        audio_stream_stop(bg_music) -- Stop custom music.
    end

    audio_stream_play(audio_stream, true, 1)
    audio_stream_set_looping(audio_stream, true)

    bg_music = audio_stream
end

local function on_level_init()
    if gGlobalSyncTable.winner_index ~= nil then -- Prevent music changes during the winner presentation.
        stop_background_music(get_current_background_music()) -- Without this, vanilla music would play in the background during the winner presentation.
    else
        change_music(get_level_background_music())
    end
end

hook_event(HOOK_ON_LEVEL_INIT, on_level_init)

---@param m MarioState
local function every_frame(m)
    if m.playerIndex ~= 0 then return end
    if gGlobalSyncTable.winner_index ~= nil then return end -- Prevent music changes during the winner presentation.

    -- Power-ups music should never be played.
    stop_background_music(VANILLA_WING_CAP_MUSIC)
    stop_background_music(VANILLA_METAL_CAP_MUSIC)
    stop_background_music(VANILLA_SHELL_MUSIC)

    local desired
    if (m.flags & (MARIO_METAL_CAP + MARIO_VANISH_CAP)) ~= 0 then
        desired = MUSIC_GCN_RAINBOW_ROAD
    elseif (m.action & ACT_FLAG_RIDING_SHELL) ~= 0 then
        desired = MUSIC_N64_RAINBOW_ROAD
    elseif (m.flags & MARIO_WING_CAP) ~= 0 then
        desired = MUSIC_FLYING_MARIO
    else
        desired = get_level_background_music()
    end

    if bg_music ~= desired then -- Only change if it's different.
        change_music(desired)
    end
end

hook_event(HOOK_MARIO_UPDATE, every_frame)
