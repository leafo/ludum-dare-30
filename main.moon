require "lovekit.all"

{graphics: g} = love

paused = false

fixed_time_step = (rate, fn) ->
  target_dt = 1 / rate
  accum = 0

  (real_dt) =>
    accum += real_dt
    while accum > target_dt
      fn @, target_dt
      accum -= target_dt

class Player extends Entity
  speed: 100
  on_ground: false

  new: (x,y) =>
    super x, y
    @velocity = Vec2d 0,0

  update: (dt, @world) =>
    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    @velocity += @world.gravity * dt

    cx, cy = @fit_move @velocity[1] * dt, @velocity[2] * dt, @world

    -- platformer physics
    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

    true


class World
  gravity: Vec2d 0, 100

  new: (map) =>
    @map = TileMap.from_tiled "maps.dev", {
      object: (o) ->
        switch o.name
          when "spawn"
            @spawn_x = o.x
            @spawn_y = o.y
    }

    @map_box = @map\to_box!

  collides: (thing) =>
    return false unless @map_box\contains_box thing
    @map\collides thing

  draw: (viewport) =>
    @map\draw viewport

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale

    @world = World!
    @player = Player assert(@world.spawn_x), @world.spawn_y

    @entities = with DrawList!
      \add @player

  draw: =>
    @viewport\apply!
    g.print "Hello world", 20, 20

    @world\draw @viewport
    @entities\draw @viewport
    @viewport\pop!

  update: fixed_time_step 60, (dt) =>
    @entities\update dt, @world

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


