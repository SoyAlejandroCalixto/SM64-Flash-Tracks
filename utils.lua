--- Save coords in last_checkpoint global variable when there is a checkpoint below Mario
---@param coords Vec3f
function set_checkpoint(coords)
    last_checkpoint = vec3f_new(coords.x, coords.y, coords.z)
end

function clear_progress()
    file = get_current_save_file_num() - 1
    for course = 0, 25 do
        save_file_remove_star_flags(file, course - 1, 0xFF)
    end
    save_file_clear_flags(0xFFFFFFFF)
    save_file_do_save(file, 1)
    update_all_mario_stars()

    save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
end

---@param globalIndex integer
---@return MarioState?
function get_mario_with_global_index(globalIndex)
    local players_count = network_player_connected_count()
    for i = 0, players_count - 1 do
        local np = gNetworkPlayers[i]
        if np and np.globalIndex == globalIndex then
            return gMarioStates[i]
        end
    end
    return nil
end

---@param x number
---@param y number
---@param z number?
---@return Vec3f
function vec3f_new(x, y, z)
    local v = { x = 0, y = 0, z = 0 }
    vec3f_set(v, x, y, z or 0)
    return v
end

function count_players_in_level(level, area_index)
    local counter = 0
    for i = 0, network_player_connected_count() - 1 do
        local p = gNetworkPlayers[i]
        if p and p.connected and p.currLevelNum == level and p.currAreaIndex == area_index then
            counter = counter + 1
        end
    end
    return counter
end

function get_enabled_levels()
    local list = {}
    for _, lvl in ipairs(playable_levels) do
        local key = ("enabled_level_%d"):format(lvl.id)
        if gGlobalSyncTable[key] then
            table.insert(list, lvl)
        end
    end
    return list
end

local timers = {}

function after_frames(frames, callback)
    table.insert(timers, {frames = frames, callback = callback, each_frame = false})
end

function each_frame(frames, callback)
    table.insert(timers, {frames = frames, callback = callback, each_frame = true})
end

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end

    for i = #timers, 1, -1 do
        local t = timers[i]
        if t.each_frame then
            t.callback()
        end
        if not t.each_frame and t.frames <= 0 then
            t.callback()
        end
        if t.frames <= 0 then
            table.remove(timers, i)
        end
        t.frames = t.frames - 1
    end
end)
