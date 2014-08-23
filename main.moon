require "lovekit.all"

{graphics: g} = love

import Player from require "player"
import World from require "world"

paused = false

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

    @world = World!
    @player = Player assert(@world.spawn_x), @world.spawn_y

    @entities = with DrawList!
      \add @player

  draw: =>
    @viewport\apply!
    g.print "V: #{"%.3f %.3f"\format unpack @player.velocity}\nDamp: #{"%.3f"\format @player.dampen_movement}", 20, 20

    COLOR\pusha 10
    @world.map_box\draw!
    COLOR\pop!

    @world\draw @viewport
    @entities\draw @viewport

    if @root
      Box.draw @root, {255,255,255, 80}

    @viewport\pop!

  update: fixed_time_step 60, (dt) =>
    @viewport\update dt
    -- @viewport\center_on @player, @world.map_box, dt
    @viewport\center_on @player, nil, dt

    @entities\update dt, @world

  mousepressed: (x,y) =>
    x,y = @viewport\unproject x, y
    @root = @world.map\get_wall_root x, y

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


