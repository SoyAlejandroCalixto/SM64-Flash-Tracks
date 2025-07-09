local first_frame = true

---@param m MarioState
function mario_update(m)
    if m.playerIndex ~= 0 then return end -- prevent executions of other players or ghost states.

    -- Bools abstraction for better readability
    local mario_landed = (m.prevAction & ACT_FLAG_AIR) ~= 0 and (m.action & ACT_FLAG_AIR) == 0
    local mario_above_checkpoint = m.floor.type == 48
    local mario_above_bounce = m.floor.type == 53
    local you_got_a_star = m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER
    local there_is_already_a_winner = gGlobalSyncTable.winner_index ~= nil
    local host_pressed_y_in_lobby = network_is_server() and m.controller.buttonPressed & Y_BUTTON ~= 0 and not gGlobalSyncTable.game_should_start and not gGlobalSyncTable.in_game and gNetworkPlayers[0].currLevelNum == LEVEL_LOBBY
    local countdown_should_start = gGlobalSyncTable.game_should_start and count_players_in_level(LEVEL_LOBBY, 1) == 0 and not countdown.displaying and not countdown.finished

    ----------------

    if first_frame then
        local function callback() -- Recursive callback that is called every second to increment the level timer.
            if not level_timer_freezed then
                level_timer = level_timer + 1
            end
            after_frames(30, callback)
        end
        after_frames(30, callback)

        first_frame = false
    end

    if mario_landed and mario_above_checkpoint then
        set_checkpoint(m.pos)
    end

    if mario_landed and mario_above_bounce then
        bounce(m)
    end

    if mario_above_bounce and m.pos.y + m.vel.y <= m.floorHeight then -- If just before touching the ground above a bounce
        m.peakHeight = m.pos.y -- Ignore fall damage
    end

    if you_got_a_star then
        win(m)
    end

    if there_is_already_a_winner then
        present_the_winner(m)
    end

    if host_pressed_y_in_lobby then
        gGlobalSyncTable.game_should_start = true
    end

    if gGlobalSyncTable.game_should_start then
        m.freeze = 1

        if not are_you_ready then
            on_game_start()
        end
    end

    if countdown_should_start then
        on_start_countdown(m)
    end

    if gGlobalSyncTable.game_should_end then
        on_game_end()
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
