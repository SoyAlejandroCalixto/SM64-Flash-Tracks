if network_is_server() then
    hook_mod_menu_text("Playable levels")
    for _, level in ipairs(playable_levels) do
        local name = level.name
        local id = level.id
        local key = ("enabled_level_%d"):format(id)

        if gGlobalSyncTable[key] == nil then
            gGlobalSyncTable[key] = true -- If it's not already in the sync table, it puts it in.
        end

        hook_mod_menu_checkbox(name, true, function(_, value)
            gGlobalSyncTable[key] = value
        end)
    end
end
