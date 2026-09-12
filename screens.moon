
{graphics: g} = love

controls = require "controls"

class Transition extends FadeTransition
  time: 1.5
  color: {10, 10, 10}

class Screen
  new: =>
    @viewport = Viewport scale: GAME_CONFIG.scale

  -- "press space" prompt along the bottom, names the pad button when there is one
  draw_prompt: =>
    g.printf "press #{controls.prompts.confirm!}", 0, @viewport.h - 16 - 30, @viewport.w, "center"

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
      @draw_prompt!
      COLOR\pop!

  update: (dt) =>
    @seq\update dt

    if @ready and CONTROLLER\is_down "confirm", "cancel"
      AUDIO\play "confirm"
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
    if @ready and CONTROLLER\is_down "confirm", "cancel"
      AUDIO\play "confirm"
      DISPATCHER\replace @new_game, Transition
      @ready = false

  draw_inner: =>
    COLOR\pusha @alpha
    @image\draw (@viewport.w - @image\width!) / 2
    COLOR\pop!

    if @visible
      @draw_prompt!


class StageComplete extends Screen
  show_enemies: 0
  alpha: 0

  lazy background: -> imgfy "images/stage_clear.png"

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
    if @ready and CONTROLLER\is_down "confirm", "cancel"
      AUDIO\play "confirm"
      @callback_fn and @callback_fn!
      @ready = false

  num: (num) =>
    "%04d"\format math.floor num

  draw_inner: =>
    -- the art is wider than the viewport, position the stats relative to it
    ox = math.floor (@viewport.w - @background\width!) / 2
    @background\draw ox

    g.push!
    g.translate ox + 185, 150

    g.setFont FONTS.number_font
    COLOR\pusha @alpha
    g.print "#{"%02d"\format @minutes}:#{"%02d"\format @seconds}", 0, 0, 0, 2,2
    g.setFont FONTS.default
    COLOR\pop!

    g.pop!

    max_rect = 142

    p = @show_enemies/@enemies_total

    COLOR\push 240, 0, 0
    g.rectangle "fill", ox + 170, 112, p * max_rect, 10
    COLOR\pop!

    g.print "#{@num @show_enemies} / #{@num @enemies_total}", ox + 190, 90

    if @visible
      @draw_prompt!

{
  :TitleScreen
  :GameOverScreen
  :Transition
  :StageComplete
}
