require "lovekit.all"

{graphics: g} = love

paused = false

class Player extends Entity
  update: (dt) =>
    true

class World
  collides: (thing) =>
    print "checking collision", thing
    false

class Game
  new: =>
    @viewport = EffectViewport scale: GAME_CONFIG.scale
    @player = Player 10, 10

    @world = World!
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


