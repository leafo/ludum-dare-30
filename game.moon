{graphics: g} = love

import World from require "world"
import Player from require "player"

fixed_time_step = (rate, fn) ->
  target_dt = 1 / rate
  accum = 0

  (real_dt) =>
    accum += real_dt
    while accum > target_dt
      fn @, target_dt
      accum -= target_dt

class Game
  shroud_a: 0
  deaths: 0

  new: =>
    @hud_viewport = EffectViewport scale: GAME_CONFIG.scale
    @seqs = DrawList!

    @world = World @
    @player = Player 0, 0
    @world\add_player @player

  draw: =>
    @world\draw!
    @hud_viewport\apply!

    if @shroud_a > 0
      COLOR\push 0,0,0, @shroud_a
      @hud_viewport\draw!
      COLOR\pop!

    if DEBUG
      stat = table.concat {
        "V: #{"%.3f %.3f"\format unpack @player.velocity}"
        "Damp: #{"%.3f"\format @player.dampen_movement}"
        "Ground: #{@player.on_ground}"
        "Seqs: #{table.concat [s.name or "***" for s in *@player.seqs when s.alive], ", "}"
      }, "\n"

      g.print stat, 0,0

    @hud_viewport\pop!

  update: fixed_time_step 60, (dt) =>
    return if @paused
    @seqs\update dt
    @world\update dt

  game_over: =>
    AUDIO\play "level_fail"

    import GameOverScreen, Transition from require "screens"
    go = GameOverScreen ->
      @set_world @world.map_name
      DISPATCHER\pop!

    DISPATCHER\push go, Transition

  complete_stage: (map_name) =>
    import StageComplete from require "screens"
    AUDIO\play "level_complete"

    elapsed = love.timer.getTime! - @world.start_time
    enemies_killed = 0
    for e in *@world.enemies
      if not e.alive or e.dying
        enemies_killed += 1

    DISPATCHER\push StageComplete elapsed, enemies_killed, #@world.enemies, ->
      @set_world map_name
      DISPATCHER\pop!

  set_world: (map_name) =>
    world = World @, map_name
    player = Player 0, 0
    world\add_player player
    @world = world

  on_key: (key) =>
    if key == "p"
      @paused = not @paused

  mousepressed: (x,y) =>
    return unless DEBUG
    x,y = @world.viewport\unproject x, y
    @world.door\send_energy x,y

{ :Game }
