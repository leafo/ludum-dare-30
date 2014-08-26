{graphics: g} = love

class EnergyParticle extends PixelParticle
  size: 3
  life: 0.8
  a: 255

  new: (@x, @y, @vel) =>
    @vel = @vel\random_heading(80) * rand 100,300
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
  rate: 0.02
  rot: 0
  time: 0
  alpha: 255

  new: (world, x, y, @target_x, @target_y, @complete_fn) =>
    super world, x, y

    @seqs = DrawList!

    @target = Vec2d @target_x, @target_y

    @drot = rand 2,5
    @size = rand 8,10

    pos = Vec2d x,y

    @vel = Vec2d 0, -150

    @seqs\add Sequence ->
      wait 0.1
      tween @vel, 0.4, {[2]: 0}
      @vel[2] = -50
      @traveling = true

    @rate = 0.1
    @seqs\add Sequence ->
      tween @, 0.5, rate: @@rate

  update: (dt) =>
    super dt

    @time += dt
    @rot += dt * @drot
    @seqs\update dt

    if not @dying
      if @traveling
        @accel = (@target - Vec2d(@x,@y))\normalized! * 100 * (@time + 1)^2
        @vel\adjust unpack @accel * dt

      @x += @vel.x * dt
      @y += @vel.y * dt

    if @world.door\touches_pt(@x, @y) and not @dying
      @dying = @seqs\add Sequence ->
        @complete_fn and @complete_fn!
        tween @, 0.5, alpha: 0, rate: 1
        @alive = false

    @alive

  make_particle: (x,y) =>
    EnergyParticle x,y, @vel\normalized!\flip!

  draw: =>
    g.push!
    g.translate @x, @y
    g.rotate @rot

    COLOR\pusha @alpha

    s1 = @size + 2
    g.rectangle "fill", -s1/2, -s1/2, s1,s1
    COLOR\push 240,0,0
    g.rectangle "fill", -@size/2, -@size/2, @size, @size
    COLOR\pop!

    COLOR\pop!

    g.pop!

class Door extends Entity
  w: 18
  h: 70
  is_door: true
  filled: 0
  have_energy: 0

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

  setup_energy: =>
    @needed_energy = 0

    for e in *@world.enemies
      if e.has_energy
        @needed_energy += 1

    if @needed_energy == 0
      @after_filled!

    @setup_energy = ->

  update: (dt, @world) =>
    @setup_energy!

    @anim\update dt

    @vel += @world.gravity * dt

    if @needed_energy > 0
      @filled = smooth_approach @filled, @have_energy/@needed_energy, dt

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

  is_ready: =>
    @filled == 1

  send_energy: (x, y) =>
    AUDIO\play "energy_appear"
    tx, ty = @center!
    @world.particles\add EnergyEmitter @world, x, y, tx, ty, ->
      @have_energy += 1
      if @have_energy/@needed_energy == 1
        @after_filled!

{
  :Door
}

