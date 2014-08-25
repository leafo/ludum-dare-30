
class Transition extends FadeTransition
  time: 1.5
  color: {10, 10, 10}

class Screen
  new: =>
    @viewport = Viewport scale: GAME_CONFIG.scale

  draw: =>
    @viewport\apply!
    @draw_inner!
    @viewport\pop!

  draw_inner: =>

  update: (dt) =>

class GameOverScreen extends Screen
  new: =>
    super!
    @image = imgfy "images/game_over.png"
    @press_space = imgfy "images/press_space.png"

    @alpha = 0
    @visible = true
    @seq = Sequence ->
      wait 0.5
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

class TitleScreen extends Screen
  new: (@new_game) =>
    super!

    @image = imgfy "images/title.png"
    @press_space = imgfy "images/press_space.png"

    @alpha = 0
    @seq = Sequence ->
      tween @, 0.5, alpha: 255

      wait 0.5
      @visible = true
      wait 0.5
      @visible = false
      wait 0.15
      again!

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
    if CONTROLLER\is_down "confirm"
      DISPATCHER\replace @new_game, Transition

{
  :TitleScreen
  :GameOverScreen
}
