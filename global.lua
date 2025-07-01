-- Global vars.

--- Last checkpoint coords.
last_checkpoint = { x = 0, y = 0, z = 0 } ---@type Vec3f

--- Time elapsed at each level.
level_timer = 0 ---@type number

--- If false, and the global sync 'game_should_start' is true, you will be teleported to the chosen game level, and then set to true.
are_you_ready = false ---@type boolean

--- If true, freezes the level_timer.
level_timer_freezed = false ---@type boolean

--- When 'change_music()' is run, this variable is set to the new song.
bg_music = nil ---@type ModAudio

--- Controls the countdown for when a new game starts.
countdown = {
    displaying = false, ---@type boolean
    number = 3, ---@type number
    finished = false ---@type boolean
}

-- Sync globals.

--- Sets whether a game is in progress or not.
gGlobalSyncTable.in_game = nil ---@type boolean

--- Sets whether the game should start but not all players are at the chosen level yet.
gGlobalSyncTable.game_should_start = nil ---@type boolean

--- Winner global index.
gGlobalSyncTable.winner_index = nil ---@type number
gGlobalSyncTable.winner_name = nil ---@type string

--- Level randomly chosen from those enabled to be played in the current game.
gGlobalSyncTable.chosen_level = nil ---@type number

--- Sets whether the game should end but not all players are at the lobby yet.
gGlobalSyncTable.game_should_end = nil ---@type boolean

-- Level equivalents.

LEVEL_LOBBY = LEVEL_CASTLE_GROUNDS
LEVEL_WINNER_PRESENTATION = LEVEL_CASTLE_COURTYARD
LEVEL_REAL_RUMBLE = LEVEL_BOB
LEVEL_TURTLES_PACE = LEVEL_WF
LEVEL_SLIPPERY_PLACE = LEVEL_JRB

-- Types.

---@class rgba
---@field r number
---@field g number
---@field b number
---@field a number

---@return rgba
function rgba(r, g, b, a)
    return {r=r, g=g, b=b, a=a}
end

-- Constants.
--
playable_levels = {
    { id = LEVEL_REAL_RUMBLE, name = "Real Rumble" },
    { id = LEVEL_TURTLES_PACE, name = "Turtle's Pace" },
    { id = LEVEL_SLIPPERY_PLACE, name = "Slippery Place" },
}

AUDIO_CONGRATULATIONS = audio_sample_load("congratulations.mp3")
AUDIO_COUNTDOWN_MORE_THAN_0 = audio_sample_load("countdown_more_than_0.mp3")
AUDIO_COUNTDOWN_0 = audio_sample_load("countdown_0.mp3")
