
{ graphics: g } = love

class Dirt extends PixelParticle
  size: 3
  life: 0.8

  r: 30
  g: 20
  b: 20

  new: (@x, @y, @vel) =>
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

class Gib extends Particle
  lazy sprite: => Spriter "images/gibs.png", 16, 16

  new: (...) =>
    super ...
    @life = random_normal!
    @max_life = @life

    @rot = rand 0, 2 * math.pi
    @drot = rand -0.5, 0.5
    @anim = with @sprite\seq {1,2,3,4,5,6,7}, 0.05
      .once = true

  update: (dt) =>
    @anim\update dt
    @rot += dt * @drot
    super dt

  draw: =>
    COLOR\pusha 255 * @fade_out @max_life

    g.push!
    g.translate @x, @y
    g.rotate @rot
    @anim\draw -8, -8
    g.pop!

    COLOR\pop!

class GibEmitter extends Emitter
  count: 20

  make_particle: (x,y) =>
    speed = 100 * (random_normal! + 0.5)
    spread = 50

    Gib x + (random_normal! - 0.5) * spread,
      y + (random_normal! - 0.5) * spread,
      Vec2d(0, -speed)\random_heading(80), Vec2d(0, 500)

-- out and up
-- rotates
class Dust extends Particle
  lazy sprite: => Spriter "images/smoke.png", 8, 8

  new: (...) =>
    super ...

    @life = random_normal! * 0.8
    @max_life = @life

    @rot = rand 0, 2 * math.pi
    @drot = rand -0.5, 0.5

    @scale = 1
    @dscale = rand 3, 6

    @anim = @sprite\seq {0,1,2,3,4,5,6,7,8,9,10}, 0.05

  update: (dt) =>
    @anim\update dt
    @rot += dt * @drot
    @scale += dt * @dscale

    if @vel[1] != 0
      air_rate = 1
      @vel[1] = dampen @vel[1], dt * 1000

    super dt

  draw: =>
    COLOR\pusha 255 * @fade_out @max_life

    g.push!
    g.translate @x, @y
    g.rotate @rot
    g.scale @scale, @scale
    @anim\draw -4, -4
    g.pop!

    COLOR\pop!

class DustEmitter extends Emitter
  count: 8

  make_particle: (x,y) =>
    dir = pick_dist { [Vec2d(1,0)]: 1, [Vec2d(-1,0)]: 1 }
    dir = dir * rand 100,220

    Dust x + (random_normal! - 0.5) * 10,
      y, dir\random_heading(20), Vec2d(0, -100)

class GunSmokeEmitter extends Emitter
  count: 8
  make_particle: (x,y) =>
    spreadx = (random_normal! - 0.5) * 10
    spready = (random_normal! - 0.5) * 10
    Dust x + spreadx, y + spready, Vec2d(0,-5)\random_heading(60), Vec2d(0, -150)


class CheckpointParticle extends ImageParticle
  lazy sprite: => imgfy "images/checkpoint.png"

  new: (...) =>
    super ...
    @w = @sprite\width!
    @h = @sprite\height!
    @accel[2] = -50

{
  :DirtEmitter
  :BloodEmitter
  :GibEmitter
  :DustEmitter
  :GunSmokeEmitter
  :CheckpointParticle
}
