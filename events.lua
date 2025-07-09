function on_game_start()
    if network_is_server() then
        gGlobalSyncTable.game_should_end = false -- If the host presses Y before everyone reaches the lobby at the end of the game, 'game_should_end' is not set to false, causing a softlock in which the game warps you to the lobby and 'chosen_level' in a loop. With this you avoid it.
    end

    if #get_enabled_levels() == 0 then return end -- If no levels are enabled, do nothing.
    if network_is_server() then
        rand = math.random(1, #get_enabled_levels())
        gGlobalSyncTable.chosen_level = get_enabled_levels()[rand].id
    end

    if gGlobalSyncTable.chosen_level then
        warp_to_level(gGlobalSyncTable.chosen_level, 1, 0)
        are_you_ready = true
    end
end

---@param m MarioState
function win(m)
    m.action = ACT_IDLE
    clear_progress()
    gGlobalSyncTable.winner_index = gNetworkPlayers[0].globalIndex
    gGlobalSyncTable.winner_name = gNetworkPlayers[0].name
end

---@param m MarioState
function present_the_winner(m)
    winner = get_mario_with_global_index(gGlobalSyncTable.winner_index)

    if gNetworkPlayers[0].currLevelNum ~= LEVEL_WINNER_PRESENTATION then
        warp_to_level(LEVEL_WINNER_PRESENTATION, 1, 0)
    end

    winner.pos.x, winner.pos.y, winner.pos.z = 0, 0, -1600

    if m ~= winner then
        m.pos.x, m.pos.y, m.pos.z = 0, 0, 0
    end

    gLakituState.pos.x, gLakituState.pos.y, gLakituState.pos.z = 0, 128, -1000
    gLakituState.focus.x, gLakituState.focus.y, gLakituState.focus.z = 0, 32, -1600 -- The point Lakitu is looking at.
    m.area.camera.yaw = 32768 -- Reverse the stick so that backward is forward, etc.
    camera_freeze()
    level_timer_freezed = true

    if bg_music ~= MUSIC_WIN then
        change_music(MUSIC_WIN)
        after_frames(75, function()
            audio_sample_play(AUDIO_CONGRATULATIONS, m.pos, 2)
        end)
        after_frames(165, function()
            if network_is_server() then
                gGlobalSyncTable.game_should_end = true
            end
        end)
    end
end

function on_game_end()
    -- Reset globals.
    if network_is_server() then
        gGlobalSyncTable.in_game = false
        gGlobalSyncTable.winner_index = nil
        gGlobalSyncTable.winner_name = nil
        gGlobalSyncTable.chosen_level = nil
    end
    are_you_ready = false
    level_timer_freezed = false
    countdown.displaying = false
    countdown.number = 3
    countdown.finished = false

    camera_unfreeze()
    if gNetworkPlayers[0].currLevelNum ~= LEVEL_LOBBY then
        warp_to_level(LEVEL_LOBBY, 1, 0)
    end

    if count_players_in_level(LEVEL_LOBBY, 1) == network_player_connected_count() then
        if network_is_server() then
            gGlobalSyncTable.game_should_end = false
        end
    end
end

---@param m MarioState
function on_start_countdown(m)
    audio_sample_play(AUDIO_COUNTDOWN_MORE_THAN_0, m.pos, 5)
    level_timer_freezed = true

    countdown.displaying = true
    countdown.number = 3
    countdown.finished = false

    local function countdown_timer()
        if countdown.number > 0 then
            countdown.number = countdown.number - 1

            if countdown.number == 0 then
                countdown.finished = true -- When we reach 0 (GO!), start the game immediately.
                audio_sample_play(AUDIO_COUNTDOWN_0, m.pos, 5)
                level_timer_freezed = false

                gGlobalSyncTable.game_should_start = false
                gGlobalSyncTable.in_game = true

                after_frames(30, function() -- Keep countdown.displaying true for a moment to show "GO!".
                    countdown.displaying = false
                end)
            else
                audio_sample_play(AUDIO_COUNTDOWN_MORE_THAN_0, m.pos, 5)
                after_frames(30, countdown_timer) -- Do this every second until the countdown is 0.
            end
        end
    end

    after_frames(30, countdown_timer) -- Start countdown after 1 second.
end

---@param m MarioState
function bounce(m)
    if m.health > 0 then
        if m.action == ACT_GROUND_POUND_LAND then
            set_mario_action(m, ACT_TRIPLE_JUMP, 0)
            m.vel.y = 88
        else
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
            m.flags = m.flags | MARIO_MARIO_SOUND_PLAYED -- It is annoying to hear Mario's “HOOHOO” all the time.
            m.vel.y = 80
        end
        play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, m.marioObj.header.gfx.cameraToObject)
    end
end

--- @param m MarioState
local function on_death(m)
    each_frame(10, function() m.health = 2176 end) -- 10 invulnerability frames.
    m.hurtCounter = 0 -- If right now you have periodic damage (e.g., lava, which damages you gradually) it is removed.

    m.pos.x, m.pos.y, m.pos.z = last_checkpoint.x, last_checkpoint.y, last_checkpoint.z
    m.vel.x, m.vel.y, m.vel.z = 0, 0, 0
    m.forwardVel = 0
    if m.action & ACT_FLAG_RIDING_SHELL == 0 then -- If mario is riding a shell and you switch to idle, it becomes buggy.
        m.action = ACT_IDLE
    end
    reset_camera(m.area.camera)
end

hook_event(HOOK_ON_DEATH, function(m)
    on_death(m)
    return false
end)

local function on_level_init()
    if gNetworkPlayers[0].currLevelNum ~= LEVEL_WINNER_PRESENTATION then -- If the level is the winner presentation, keep the previous level counter.
        level_timer = 0 -- If not, reset the level timer for the new level.
    end
    each_frame(10, function() gMarioStates[0].health = 2176 end) -- 10 invulnerability frames.

    if gNetworkPlayers[0].currLevelNum == LEVEL_TURTLES_PACE then
        set_ttc_speed_setting(TTC_SPEED_FAST)
    else
        set_ttc_speed_setting(TTC_SPEED_SLOW)
    end

    save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
end

hook_event(HOOK_ON_LEVEL_INIT, on_level_init)

hook_event(HOOK_ON_PAUSE_EXIT, function() return false end)
