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
  new: =>
    @hud_viewport = EffectViewport scale: GAME_CONFIG.scale

    @world = World @
    @player = Player 0, 0
    @world\add_player @player

  draw: =>
    @world\draw!

    @hud_viewport\apply!
    stat = table.concat {
      "V: #{"%.3f %.3f"\format unpack @player.velocity}"
      "Damp: #{"%.3f"\format @player.dampen_movement}"
      "Ground: #{@player.on_ground}"
      "Seqs: #{table.concat [s.name or "***" for s in *@player.seqs when s.alive], ", "}"
    }, "\n"

    g.print stat, 0,0

    if DEBUG and @root
      Box.draw @root, {255,255,255, 80}

    @hud_viewport\pop!

  update: fixed_time_step 60, (dt) =>
    return if @paused
    @world\update dt

  on_key: (key) =>
    if key == "p"
      @paused = not @paused

  mousepressed: (x,y) =>
    x,y = @world.viewport\unproject x, y
    import Dagger from require "dagger"
    @player\die!
    -- idx = @world.map\pt_to_idx x, y
    -- import DirtEmitter from require "particles"
    -- @root = @world.map\get_wall_root x, y

{ :Game }
