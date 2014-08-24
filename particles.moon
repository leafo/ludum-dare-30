
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
    @size = pick_dist { [3]: 2, [2]: 1 }

  draw: =>
    COLOR\pusha 255 * @fade_out!
    super!
    COLOR\pop!

class DirtEmitter extends ForeverEmitter
  rate: 0.05

  new: (world, x, y, @facing) =>
    super world, x, y

  make_particle: (x, y) =>
    angle = if @facing == "right"
      180
    else
      0
      
    vel = Vec2d.from_angle(angle)\random_heading(128) * rand(20, 40)
    Dirt x, y, vel

class Blood extends PixelParticle
  size: 3
  life: 0.8

  r: 200
  g: 40
  b: 40

  new: (@x, @y, @vel) =>
    unless @vel
      @vel = Vec2d(0, -1)\random_heading(120) * rand(100, 200)

    @accel = Vec2d 0, 500
    @size = pick_dist { [2]: 1, [3]: 2, [4]: 2, [5]: 1 }
    h,s,l = rgb_to_hsl @r, @g, @b
    l = l * random_normal!
    @r, @g, @b = hsl_to_rgb h,s,l

  draw: =>
    COLOR\pusha 255 * @fade_out!
    super!
    COLOR\pop!

class BloodEmitter extends Emitter
  count: 20

  new: (world, x,y, @shoot_right) =>
    super world, x,y

  make_particle: (x,y) =>
    vel = if @shoot_right != nil
      vel = if @shoot_right
        Vec2d.from_angle -65
      else
        Vec2d.from_angle 245

      vel\random_heading(60) * rand(100, 150)

    Blood x,y, vel

{
  :DirtEmitter
  :BloodEmitter
}
