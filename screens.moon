
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
  new: =>
    super!

    @image = imgfy "images/title.png"
    @press_space = imgfy "images/press_space.png"

    @seq = Sequence ->
      @visible = true
      wait 0.5
      @visible = false
      wait 0.25
      again!

  update: (dt) =>
    @seq\update dt

  draw_inner: =>
    @image\draw (@viewport.w - @image\width!) / 2

    if @visible
      @press_space\draw (@viewport.w - @press_space\width!) / 2,
        @viewport.h - @press_space\height! - 30

{
  :TitleScreen
  :GameOverScreen
}
