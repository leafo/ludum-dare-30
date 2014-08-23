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
  movement_locked: false

  new: (x,y) =>
    super x, y
    @seqs = DrawList!
    @velocity = Vec2d 0,0
    @facing = "left"

  draw: (...) =>
    super ...
    -- draw a nose
    COLOR\push 255,128,128
    if @facing == "left"
      g.rectangle "fill", @x, @y, 10, 10
    else
      g.rectangle "fill", @x + @w/2 , @y, 10, 10

    COLOR\pop!

  update: (dt, @world) =>
    @seqs\update dt, @world

    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    if dx != 0
      @facing = if dx < 0 then "left" else "right"

    if CONTROLLER\is_down "jump"
      @jump @world

    @velocity[1] = dx * @speed

    @velocity += @world.gravity * dt

    cx, cy = @fit_move @velocity[1] * dt, @velocity[2] * dt, @world

    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

    true

  jump: (world) =>
    return if @jumping
    return unless @on_ground

    @jumping = @seqs\add Sequence ->
      @velocity[2] = -200
      wait 0.1
      @jumping = false

  looking_at: (viewport) =>
    cx, cy = @center!
    if @facing == "left"
      cx - 20, cy
    else
      cx + 20, cy

class World
  gravity: Vec2d 0, 500

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
    return true unless @map_box\contains_box thing
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
    @viewport\update dt
    -- @viewport\center_on @player, @world.map_box, dt
    @viewport\center_on @player, nil, dt

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


