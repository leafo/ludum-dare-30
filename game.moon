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

  new: (@world_cls=World, @post_world_fn) =>
    @hud_viewport = EffectViewport scale: GAME_CONFIG.scale
    @set_world! -- loads default world

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
    @world\update dt

  game_over: =>
    AUDIO\play "level_fail"

    import GameOverScreen, Transition from require "screens"
    go = GameOverScreen ->
      @set_world @world.map_name, @world.checkpoint
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

  set_world: (map_name, checkpoint) =>
    old_world = @world

    world = @world_cls map_name
    @player = Player CONTROLLER, 0, 0
    world\add_player @player
    @world = world

    if checkpoint
      if old_door = old_world.door
        @world.door.have_energy = old_door.have_energy

      killzone = Box 0, 0, @world.viewport.w/2, @world.viewport.h/2
      killzone\move_center unpack checkpoint
      for e in *@world.enemies
        if e\touches_box killzone
          if e.has_energy and @world.door
            @world.door.have_energy += 1

          @world.entities\remove e

      @player.x, @player.y = unpack checkpoint

    @post_world_fn!

  on_key: (key) =>
    if key == "p"
      @paused = not @paused

  mousepressed: (x,y) =>
    return unless DEBUG
    x,y = @world.viewport\unproject x, y
    import CheckpointParticle from require "particles"
    @world.particles\add CheckpointParticle x,y
    -- @world.door\send_energy x,y

{ :Game }
