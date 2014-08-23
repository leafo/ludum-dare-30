
{graphics: g} = love

class Player extends Entity
  speed: 100
  on_ground: false
  movement_locked: false

  new: (x,y) =>
    super x, y
    @seqs = DrawList!
    @velocity = Vec2d 0,0
    @facing = "left"

  draw: (...) =>
    super ...
    -- draw a nose
    COLOR\push 255,128,128
    if @facing == "left"
      g.rectangle "fill", @x, @y, 10, 10
    else
      g.rectangle "fill", @x + @w/2 , @y, 10, 10

    COLOR\pop!

  update: (dt, @world) =>
    @seqs\update dt, @world

    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    if dx != 0
      @facing = if dx < 0 then "left" else "right"

    if CONTROLLER\is_down "jump"
      @jump @world

    @velocity[1] = dx * @speed

    @velocity += @world.gravity * dt

    cx, cy = @fit_move @velocity[1] * dt, @velocity[2] * dt, @world

    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

    true

  jump: (world) =>
    return if @jumping
    return unless @on_ground

    @jumping = @seqs\add Sequence ->
      @velocity[2] = -200
      wait 0.1
      @jumping = false

  looking_at: (viewport) =>
    cx, cy = @center!
    if @facing == "left"
      cx - 20, cy
    else
      cx + 20, cy


{ :Player }
