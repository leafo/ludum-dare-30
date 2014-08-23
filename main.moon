require "lovekit.all"

{graphics: g} = love

paused = false

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

  collides: (thing) =>
    false

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale

    @world = World!
    @player = Player 10, 10

    @entities = with DrawList!
      \add @player

  draw: =>
    @viewport\apply!
    @entities\draw!
    @viewport\pop!

  update: (dt) =>
    @entities\update dt, @world

love.load = ->
  export CONTROLLER = Controller GAME_CONFIG.keys
  export DISPATCHER = Dispatcher Game!

  DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love


