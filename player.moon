
{graphics: g} = love

-- on_ground: is on ground
-- from_jump: is in air from doing a jump
-- wall_running: is wall running
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
    if @wall_running
      COLOR\push 100,255,100

    super ...

    if @wall_running
      COLOR\pop!

    -- draw a nose
    COLOR\push 255,128,128
    if @facing == "left"
      g.rectangle "fill", @x, @y, 10, 10
    else
      g.rectangle "fill", @x + @w/2 , @y, 10, 10

    COLOR\pop!

  update: (dt, @world) =>
    @seqs\update dt, @world


    if @wall_running
      @update_for_wall_run dt
    else
      @update_for_gravity dt

    true

  update_for_wall_run: (dt) =>
    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    if CONTROLLER\is_down @wall_run_up_key
      @velocity[2] = -math.abs(dx) * @speed
    else
      if @velocity[2] < 0
        @velocity[2] = 0

      @velocity += @world.gravity * dt

    cx, cy = @fit_move @velocity[1] * dt, @velocity[2] * dt, @world

    moving_away = if @wall_run_up_key == "left"
      dx > 0
    else
      dx < 0

    if not cx or cy or moving_away
      @seqs\remove @wall_running
      @end_wall_run!

  update_for_gravity: (dt) =>
    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    if dx != 0
      @facing = if dx < 0 then "left" else "right"

    if CONTROLLER\is_down "jump"
      @jump @world

    @velocity[1] = dx * @speed

    @velocity += @world.gravity * dt

    cx, cy = @fit_move @velocity[1] * dt, @velocity[2] * dt, @world

    if cx and @from_jump
      @wall_run!

    if cy
      if @velocity[2] > 0
        @on_ground = true
        @from_jump = false

      @velocity[2] = 0
    else
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

  wall_run: =>
    return if @wall_running

    -- cancel the jump
    if @jumping
      @seqs\remove @jumping
      @jumping = false

    @wall_running = @seqs\add Sequence ->
      @wall_run_up_key = @facing
      wait 0.5
      @end_wall_run!

  end_wall_run: =>
    @wall_running = false
    @from_jump = false
    @velocity[2] = math.max 0, @velocity[2]

  jump: (world) =>
    return if @jumping
    return unless @on_ground

    @jumping = @seqs\add Sequence ->
      @from_jump = true

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
