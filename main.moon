require "lovekit.all"

require "lovekit.reloader"

{graphics: g} = love

import Player from require "player"
import World from require "world"

paused = false

export DEBUG = true

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
    @viewport = EffectViewport scale: GAME_CONFIG.scale

    @world = World @
    @player = Player 0, 0
    @world\add_player @player

  draw: =>
    @viewport\apply!

    COLOR\push 222,84,84, 155
    @world.map_box\draw!
    COLOR\pop!

    @world\draw @viewport

    stat = table.concat {
      "V: #{"%.3f %.3f"\format unpack @player.velocity}"
      "Damp: #{"%.3f"\format @player.dampen_movement}"
      "Ground: #{@player.on_ground}"
      "Seqs: #{table.concat [s.name or "***" for s in *@player.seqs when s.alive], ", "}"
    }, "\n"

    g.print stat, @viewport.x, @viewport.y

    if DEBUG and @root
      Box.draw @root, {255,255,255, 80}

    @viewport\pop!

  update: fixed_time_step 60, (dt) =>
    return if paused

    @world\update dt
    @viewport\update dt
    -- @viewport\center_on @player, @world.map_box, dt
    @viewport\center_on @player, nil, dt

  on_key: (key) =>
    if key == "p"
      paused = not paused

  mousepressed: (x,y) =>
    x,y = @viewport\unproject x, y
    @root = @world.map\get_floor_range x,y

    -- idx = @world.map\pt_to_idx x, y
    -- import DirtEmitter from require "particles"
    -- @world.particles\add DirtEmitter @world, x,y
    -- @root = @world.map\get_wall_root x, y

load_font = (img, chars)->
  font_image = imgfy img
  g.newImageFont font_image.tex, chars

love.load = ->
  fonts = {
    default: load_font "images/font1.png", [[ ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~!"#$%&'()*+,-./0123456789:;<=>?]]
  }

  g.setFont fonts.default
  g.setBackgroundColor 13,15,12

  export CONTROLLER = Controller GAME_CONFIG.keys
  export DISPATCHER = Dispatcher Game!

  DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love


