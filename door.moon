{graphics: g} = love

class EnergyParticle extends PixelParticle
  size: 3
  life: 0.8
  a: 255

  new: (@x, @y, @vel) =>
    @vel = @vel\random_heading(80) * 300
    @accel = Vec2d 0, 500
    @size = rand 3,6
    @rot = rand 0, math.pi * 2
    @a = math.floor rand 200, 255

  draw: =>
    half = @size/2
    COLOR\push @r, @g, @b, @a * @fade_out!
    g.push!
    g.translate @x, @y
    g.rotate @rot
    g.rectangle "fill", -half, -half, @size, @size
    g.pop!
    COLOR\pop!

class EnergyEmitter extends ForeverEmitter
  rate: 0.01
  rot: 0
  time: 0

  new: (world, x, y, @target_x, @target_y) =>
    @target = Vec2d @target_x, @target_y
    pos = Vec2d x,y

    @drot = rand 2,5
    @size = rand 8,10

    @vel = (pos - @target)\normalized! * rand 120, 160
    rot = if chance 0.5
      -60
    else
      60

    @vel = @vel\rotate(math.rad rot)\random_heading(30)

    super world, x, y

  update: (dt) =>
    super dt

    @time += dt
    @rot += dt * @drot

    @accel = (@target - Vec2d(@x,@y))\normalized! * 100 * (@time + 1)^2
    @vel\adjust unpack @accel * dt
    @x += @vel.x * dt
    @y += @vel.y * dt

    true

  make_particle: (x,y) =>
    EnergyParticle x,y, @vel\normalized!\flip!

  draw: =>
    g.push!
    g.translate @x, @y
    g.rotate @rot

    s1 = @size + 2
    g.rectangle "fill", -s1/2, -s1/2, s1,s1
    COLOR\push 240,0,0
    g.rectangle "fill", -@size/2, -@size/2, @size, @size
    COLOR\pop!
    g.pop!

class Door extends Entity
  w: 18
  h: 70
  is_door: true
  filled: 0

  lazy sprite: => Spriter "images/door.png"

  new: (x,y) =>
    super x,y

    with @sprite
      @anim = StateAnim "default", {
        default: \seq {
          "0,0,33,73"
          ox: 7
          oy: 10
        }
        filled: \seq {
          "48,0,33,73"
          ox: 7
          oy: 10
        }
      }

  update: (dt, @world) =>
    @anim\update dt

    @vel += @world.gravity * dt

    vx, vy = unpack @vel
    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cy
      if @vel[2] > 0
        @vel[1] = 0
        if not @on_ground
          @callback and @callback!
          @on_ground = true

      @vel[2] = 0

    true

  after_filled: =>
    @filled = 1
    @anim\set_state "filled"

  fill_dimensions: =>
    w = 7
    h = 50
    x = @x + 13 - 7
    y = @y + 13 - 10
    x,y,w,h * @filled

  draw: =>
    g.push!
    g.translate 0, 5 * math.sin love.timer.getTime! * 2

    COLOR\push 240, 0, 0
    g.rectangle "fill", @fill_dimensions!
    COLOR\pop!

    @anim\draw @x, @y

    g.pop!

  send_energy: (x, y) =>
    @world.particles\add EnergyEmitter @world, x, y, @center!

{
  :Door
}

