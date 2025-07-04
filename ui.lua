djui_hud_set_resolution(RESOLUTION_DJUI)
sw = djui_hud_get_screen_width()
sh = djui_hud_get_screen_height()
djui_hud_set_resolution(RESOLUTION_N64)
sw64 = djui_hud_get_screen_width()
sh64 = djui_hud_get_screen_height()

local function in_lobby_hud()
    text64(network_player_connected_count().." players", .22, nil, nil, nil, 15)

    if network_is_server() then
        texture64(get_texture_info("y_button"), vec3f_new(16, 16), 1, nil, 31)
        text64("for a new game", 0.16, rgba(255, 192, 1, 255), nil, nil, 47)
    else
        text64("Waiting for the host to start the game", 0.16, rgba(64, 231, 64, 255), nil, nil, 31)
    end
end

local function waiting_for_everyone_to_start_hud()
    text64("Waiting for everyone to start...", .24, rgba(64, 231, 64, 255), nil, nil, nil)
end

local function in_game_hud()
    texture64(get_texture_info("clock"), vec3f_new(16, 16), 1, 16, 16)
    text64(string.format("%03d", math.min(level_timer, 999)), 1, nil, FONT_RECOLOR_HUD, 35, 16)
end

local function winner_presentation_hud()
    winner = get_mario_with_global_index(gGlobalSyncTable.winner_index)
    text64("Winner!", 1, rgba(255, 192, 1, 255), FONT_RECOLOR_HUD, nil, sh64-45)
    text64(tostring(gGlobalSyncTable.winner_name):gsub("\\#%w+\\", ""), .22, rgba(255, 255, 255, 255), nil, nil, sh64-25)
end

local function joined_in_the_middle_of_a_game_hud()
    text64(network_player_connected_count().." players", .22, nil, nil, nil, 15)
    text64("Game in progress. Wait for them...", 0.16, rgba(64, 231, 64, 255), nil, nil, 31)
end

local function countdown_hud()
    if countdown.number > 0 then
        text64(tostring(countdown.number), 3, rgba(255, 255, 64, 255), FONT_RECOLOR_HUD, nil, nil)
    else
        text64("GO!", 3, rgba(64, 255, 64, 255), FONT_RECOLOR_HUD, nil, nil)
    end
end

local function handle_ui()
    -- Bools abstraction for better readability.
    local in_lobby = not gGlobalSyncTable.in_game and not countdown.displaying
    local during_winner_presentation = gGlobalSyncTable.winner_index ~= nil
    local joined_in_the_middle_of_a_game = gGlobalSyncTable.in_game and gNetworkPlayers[0].currLevelNum == LEVEL_LOBBY and not during_winner_presentation

    ----------------

    -- Cases.
    if in_lobby then
        in_lobby_hud()
    end
    if gGlobalSyncTable.game_should_start and not countdown.displaying then
        waiting_for_everyone_to_start_hud()
    end
    if countdown.displaying then
        countdown_hud()
    end
    if gGlobalSyncTable.in_game and not joined_in_the_middle_of_a_game then
        in_game_hud()
    end
    if during_winner_presentation then
        winner_presentation_hud()
    end
    if joined_in_the_middle_of_a_game then
        joined_in_the_middle_of_a_game_hud()
    end

    -- In any case
    power_meter(sw64-48-13, 13)
    texture64(get_texture_info("speedometer"), vec3f_new(16, 16), 1, 16, sh64-16-16)

    local speedometer_num_color = rgba(255, 255, 255, 255)
    if gMarioStates[0].forwardVel > 50 then
        speedometer_num_color = rgba(255, 64, 64, 255)
    elseif gMarioStates[0].forwardVel > 40 then
        speedometer_num_color = rgba(255, 255, 64, 255)
    elseif gMarioStates[0].forwardVel > 30 then
        speedometer_num_color = rgba(64, 255, 64, 255)
    elseif gMarioStates[0].forwardVel > 0 then
        speedometer_num_color = rgba(64, 160, 255, 255)
    end

    text64(string.format("%.0f", gMarioStates[0].forwardVel), 1, speedometer_num_color, FONT_RECOLOR_HUD, 36, sh64-16-16)

    hud_hide() -- Hide vanilla HUD.
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, handle_ui)
