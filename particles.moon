
{ graphics: g } = love

class Dirt extends PixelParticle
  size: 3
  life: 0.8

  r: 30
  g: 20
  b: 20

  new: (@x, @y, @vel) =>
    @rot = 0
    @accel = Vec2d 0, 200

  draw: =>
    COLOR\pusha 255 * @fade_out!
    super!
    COLOR\pop!

class DirtEmitter extends Emitter
  rate: 0.05

  new: (@world, @x, @y, @facing) =>
    Sequence.__init @, ->
      while true
        @add_particle!
        wait @rate

  make_particle: (x, y) =>
    angle = if @facing == "right"
      180
    else
      0
      
    vel = Vec2d.from_angle(angle)\random_heading(128) * rand(20, 40)
    Dirt x, y, vel

{
  :DirtEmitter
}
