
{graphics: g} = love

class Transition extends FadeTransition
  time: 1.5
  color: {10, 10, 10}

class Screen
  lazy press_space: -> imgfy "images/press_space.png"

  new: =>
    @viewport = Viewport scale: GAME_CONFIG.scale

  draw: =>
    @viewport\apply!
    @draw_inner!
    @viewport\pop!

  draw_inner: =>

  update: (dt) =>

class GameOverScreen extends Screen
  new: (@callback_fn) =>
    super!
    @image = imgfy "images/game_over.png"

    @alpha = 0
    @visible = true
    @seq = Sequence ->
      wait 0.5
      @ready = true
      tween @, 0.5, alpha: 255

      while true
        @visible = true
        wait 0.5
        @visible = false
        wait 0.25

  draw_inner: =>
    @image\draw (@viewport.w - @image\width!) / 2

    if @visible
      COLOR\pusha @alpha
      @press_space\draw (@viewport.w - @press_space\width!) / 2,
        @viewport.h - @press_space\height! - 30
      COLOR\pop!

  update: (dt) =>
    @seq\update dt


  on_key: =>
    return unless @ready

    if CONTROLLER\is_down "confirm", "cancel"
      @callback_fn and @callback_fn!
      @ready = false

class TitleScreen extends Screen
  new: (@new_game) =>
    super!

    @image = imgfy "images/title.png"

    @alpha = 0
    @seq = Sequence ->
      tween @, 0.5, alpha: 255
      @ready = true

      while true
        @visible = true
        wait 0.5
        @visible = false
        wait 0.25

  update: (dt) =>
    @seq\update dt

  draw_inner: =>
    COLOR\pusha @alpha
    @image\draw (@viewport.w - @image\width!) / 2
    COLOR\pop!

    if @visible
      @press_space\draw (@viewport.w - @press_space\width!) / 2,
        @viewport.h - @press_space\height! - 30

  on_key: =>
    return unless @ready

    if CONTROLLER\is_down "confirm", "cancel"
      DISPATCHER\replace @new_game, Transition
      @ready = false

class StageComplete extends Screen
  show_enemies: 0
  alpha: 0

  new: (seconds, @enemies, @enemies_total, @callback_fn) =>
    super!
    @seconds = math.floor seconds % 60
    @minutes = math.floor seconds / 60

    @seq = Sequence ->
      wait 0.1
      @ready = true
      tween @, 0.5, alpha: 255

      while true
        @visible = true
        wait 0.5
        @visible = false
        wait 0.25

  update: (dt) =>
    @seq\update dt
    @show_enemies = smooth_approach @show_enemies, @enemies, dt * 3

  on_key: =>
    return unless @ready

    if CONTROLLER\is_down "confirm", "cancel"
      @callback_fn and @callback_fn!
      @ready = false

  num: (num) =>
    "%04d"\format math.floor num

  draw_inner: =>
    g.setFont FONTS.number_font

    COLOR\pusha @alpha
    g.print "#{"%02d"\format @minutes}:#{"%02d"\format @seconds}", 10, 10, 0, 2,2
    g.setFont FONTS.default
    COLOR\pop!

    g.print "Elapsed", 10, 45

    max_rect = 100
    g.push!
    g.translate 10, 100

    COLOR\push 240, 0, 0
    g.rectangle "fill", 0, 0, @show_enemies/@enemies_total * max_rect, 20
    COLOR\pop!

    g.print "#{@num @show_enemies} / #{@num @enemies_total}", max_rect + 5, 0
    g.pop!

    if @visible
      @press_space\draw (@viewport.w - @press_space\width!) / 2,
        @viewport.h - @press_space\height! - 30

{
  :TitleScreen
  :GameOverScreen
  :Transition
  :StageComplete
}
